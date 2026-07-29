#!/usr/bin/python3
# Build --uidmap/--gidmap arguments for rootful podman so a container only
# carries a single target user's identity.
#
# Only IDs the user actually holds inside PASSTHROUGH_RANGES are identity
# mapped. Every other ID in the namespace (including container root) is
# shifted by OFFSET to a host range where no real account exists, so even
# root inside the container cannot setuid() into another user and touch
# their files on shared bind mounts like /data.
#
# Never identity map a whole range: mapping the full student segment would
# let container root setuid() into any other student on the host.

import engine_util

BASE   = 0
SIZE   = 1_000_000_000
OFFSET = 1_000_000_000

# /proc/PID/{uid,gid}_map each accept at most 340 entries
# (UID_GID_MAP_MAX_EXTENTS, Linux 4.15+), counted per user namespace
MAX_EXTENTS = 340

PASSTHROUGH_RANGES = [
    (10_000, 99_999),            # project GID
    (100_000_000, 999_999_999),  # student UID / GID
]

_idmap_config = engine_util.get_config().get("idmap", {})
SIZE   = int(_idmap_config.get("size", SIZE))
OFFSET = int(_idmap_config.get("offset", OFFSET))
PASSTHROUGH_RANGES = [tuple(r) for r in _idmap_config.get("passthrough_ranges", PASSTHROUGH_RANGES)]

def enabled():
    return bool(_idmap_config.get("enable", True))

def is_passthrough(id_):
    return any(lo <= id_ <= hi for lo, hi in PASSTHROUGH_RANGES)

def merge_consecutive(ids):
    # sorted unique ids -> list of (start, count)
    runs = []
    for id_ in sorted(set(ids)):
        if runs and id_ == runs[-1][0] + runs[-1][1]:
            runs[-1][1] += 1
        else:
            runs.append([id_, 1])
    return [tuple(r) for r in runs]

def build_id_map(passthrough_ids):
    # list of (container_id, host_id, count) covering BASE .. BASE+SIZE-1:
    # passthrough ids map to themselves, everything else maps to +OFFSET
    for id_ in passthrough_ids:
        if not is_passthrough(id_):
            raise ValueError("id {} is not inside the passthrough ranges".format(id_))
        if id_ < BASE or id_ >= BASE + SIZE:
            raise ValueError("id {} is outside the namespace (BASE={} SIZE={})".format(id_, BASE, SIZE))
    entries = []
    cur = BASE
    for start, count in merge_consecutive(passthrough_ids):
        if start > cur:
            entries.append((cur, cur + OFFSET, start - cur))
        entries.append((start, start, count))
        cur = start + count
    if cur < BASE + SIZE:
        entries.append((cur, cur + OFFSET, BASE + SIZE - cur))
    if len(entries) > MAX_EXTENTS:
        raise ValueError("{} map entries exceed the kernel limit of {} (UID_GID_MAP_MAX_EXTENTS)".format(len(entries), MAX_EXTENTS))
    return entries

def idmap_args(uid, gid, supplementary_gids):
    uid = int(uid)
    gid = int(gid)
    supplementary_gids = [int(g) for g in supplementary_gids]
    if not is_passthrough(uid):
        raise ValueError(
            "uid {} is not inside the passthrough ranges {}, refuse to start container. "
            "Recreate the user with a uid inside the ranges, or adjust idmap.passthrough_ranges "
            "(or set idmap.enable=false) in /etc/code-server-hub/config.json".format(uid, PASSTHROUGH_RANGES))
    if not is_passthrough(gid):
        raise ValueError(
            "primary gid {} is not inside the passthrough ranges {}, refuse to start container. "
            "Adjust idmap.passthrough_ranges (or set idmap.enable=false) "
            "in /etc/code-server-hub/config.json".format(gid, PASSTHROUGH_RANGES))
    # only GIDs the user actually holds are identity mapped; system groups
    # like sudo/docker/adm are host level permissions and must not leak in
    gids = [g for g in supplementary_gids + [gid] if is_passthrough(g)]
    args = []
    for c, h, n in build_id_map([uid]):
        args += ["--uidmap", "{}:{}:{}".format(c, h, n)]
    for c, h, n in build_id_map(gids):
        args += ["--gidmap", "{}:{}:{}".format(c, h, n)]
    return args
