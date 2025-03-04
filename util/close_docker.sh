#!/bin/bash

# Check if the first parameter is provided
USER_NAME="$1"

if [[ -z "$USER_NAME" ]]; then
    echo "Error: USER_NAME is required."
    exit 1
fi

# Check if CONTAINER_NAME starts with a letter and contains only alphanumeric characters
if [[ ! "$USER_NAME" =~ ^[a-zA-Z][0-9a-zA-Z]*$ ]]; then
    echo "Error: USER_NAME must start with a letter and contain only alphanumeric characters."
    exit 1
fi

CONTAINER_NAME="docker-$USER_NAME"

get_pstree() {
    local pid=$1
    local ppid

    if [ -z "$pid" ]; then
        echo "Error: No PID provided."
        return 1
    fi

    local pstree=""
    while [ "$pid" -ne 1 ]; do
        pstree+="$pid "
        ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d '[:space:]')
        if [ -z "$ppid" ]; then
            break
        fi
        pid=$ppid
    done

    echo "$pstree"
}

echo "Stopping container $CONTAINER_NAME"
docker stop "$CONTAINER_NAME" &>/dev/null

# Check if the container stopped successfully
if [ $? -eq 0 ]; then
    echo "Container stopped successfully."
    exit 0
else
    echo "Error stopping container. Cleaning uncleanable processes..."
fi

# Attempt to get process IDs using 'docker top'
PIDS=$(docker top "$CONTAINER_NAME" | awk 'NR>1 {print $2}')

# Check if docker top was successful and PIDS is not empty
if [[ $? -eq 0 && -n "$PIDS" ]]; then
    echo "Successfully retrieved PIDs using 'docker top'."
else
    # If 'docker top' failed, try to get PID from 'docker inspect'
    echo "'docker top' failed, attempting with 'docker inspect'."
    INSPECT_OUTPUT=$(docker inspect "$CONTAINER_NAME")
    if [[ $? -eq 0 && -n "$INSPECT_OUTPUT" ]]; then
        # Extract the PID using jq
        PIDS=$(echo "$INSPECT_OUTPUT" | jq -r '.[0].State.Pid')

        # Check if jq produced a non-null result
        if [[ $? -eq 0 && "$PIDS" != "null" && -n "$PIDS" ]]; then
            echo "Successfully retrieved PID using 'docker inspect' and jq."
        else
            echo "Error: Failed to extract PID from 'docker inspect' output using jq."
            exit 1
        fi
    else
        echo "Error: 'docker inspect' failed or returned empty output."
        exit 1
    fi
fi

# Kill the entire process tree for each PID
for PID in $PIDS; do
    if [ "$PID" != "1" ]; then
        echo "Killing $PID and parent tree..."
        # Get the process tree using 'get_pstree'
        PSTREE="$(get_pstree $PID)"
        
        # Check if pstree is empty
        if [ -z "$PSTREE" ]; then
            echo "No process tree found for PID $PID. Aborting."
            exit 1
        fi

        for PID2 in $PSTREE; do
            kill -9 "$PID2"
            echo "kill -9 $PID2"
        done
    fi
done

# Get the container ID
CONTAINER_ID=$(docker inspect -f '{{.Id}}' "$CONTAINER_NAME")

# Check if docker inspect failed or CONTAINER_ID is empty
if [[ $? -ne 0 || -z "$CONTAINER_ID" ]]; then
    echo "Error: Failed to get container ID with 'docker inspect'."
    exit 1
fi

# Remove the runtime directories
echo "rm -r /run/containerd/io.containerd.runtime.v2.task/moby/$CONTAINER_ID"
rm -r "/run/containerd/io.containerd.runtime.v2.task/moby/$CONTAINER_ID"
echo "rm -r /run/docker/runtime-runc/moby/$CONTAINER_ID"
rm -r "/run/docker/runtime-runc/moby/$CONTAINER_ID"

echo "Cleanup completed. Container ID: $CONTAINER_ID"
