import os
import sys
import time
import json
import random
import shutil
import requests

from pathlib import Path

temp_folder = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("./anime_pic")
os.makedirs(temp_folder, exist_ok = True)

def load_or_default(json_path, default_dict, writeback=False):
    final_vars = default_dict
    if os.path.isfile(json_path):
        try:
            vars = json.load(open(json_path))
            final_vars = {**default_dict, **vars}
        except Exception as e:
            final_vars = default_dict
    if writeback:
        open(json_path,"w").write(json.dumps(final_vars,ensure_ascii=False,indent=4))
    return final_vars

config = load_or_default(temp_folder / ".config.json",  {"source": "reddit", "reddit":{"sub":"Animewallpaper","flair_name":"Desktop"}} ,writeback=True)
vars = load_or_default(temp_folder / ".vars.json", {"prev_update":0 , "pic_data": {} })

def fetch_img_list_from_reddit(reddit_config,pages,after="",ps={}):
    if pages == 0 or after == None:
        return ps
    else:
        sub_name = reddit_config["sub"]
        flair_name = reddit_config["flair_name"] if "flair_name" in reddit_config else None
        url = f'https://gateway.reddit.com/desktopapi/v1/subreddits/{ sub_name }/search'
        url += r'?rtj=only&allow_over18=&include=prefsSubreddit&sort=new&t=all&type=link&include_over_18=&restrict_sr=1&b=true'
        if flair_name != None:
            url += r'&q=flair_name%3A%22' + flair_name + '%22'
        url += ("" if after == "" else "&after=" + after)
        r = requests.get(url, headers = {'User-agent': 'your bot 0.2'})
        r.raise_for_status()
        a = json.loads(r.text)
        for p in a["postOrder"]:
            try:
                picurl = a["posts"][p]["media"]["content"]
                if picurl.startswith("http"):
                    if p not in ps:
                        ps[p] = {"score":a["posts"][p]["score"],"url":picurl}
                    else:
                        raise Exception("p exists")
            except:
                pass
        return fetch_img_list_from_reddit(reddit_config, pages-1, a["postOrder"][-1] if len(a["postOrder"]) > 0 else None , ps)

def update_img_list_from_reddit():
    if vars["prev_update"] < time.time()- 80000:
        if len(vars["pic_data"].keys()) > 10:
            vars["pic_data"].pop(random.choice(list(vars["pic_data"].keys())))
        vars["pic_data"] = {**vars["pic_data"], **fetch_img_list_from_reddit(config["reddit"],6)}
        vars["pic_data"] = [[k,v] for k,v in sorted(zip(vars["pic_data"].keys(),vars["pic_data"].values()),key = lambda d:-d[1]["score"])]
        vars["pic_data"] = {k:v for k,v in vars["pic_data"][:4096] }
        vars["prev_update"] = time.time()


def try_get_pic_from_local_fallback_reddit(try_t = 3):
    c = random.choices(list(vars["pic_data"].keys()), weights=map(lambda x:x["score"],list(vars["pic_data"].values())))[0]
    if os.path.isfile(temp_folder / (c + ".png")):
        return str(temp_folder / c) + ".png"
        #sys.stdout.buffer.write(open(temp_folder / (c + ".png"),"rb").read())
    else:
        try:
            r = requests.get(vars["pic_data"][c]["url"])
            r.raise_for_status()
            open(temp_folder / (c + ".png"),"wb").write(r.content)
            return str(temp_folder / c) + ".png"
            #sys.stdout.buffer.write(r.content)
        except requests.HTTPError as e:
            if try_t > 0:
                vars["pic_data"][c]["score"] = 0
                try_get_pic_from_local_fallback_reddit(try_t -1)
            else:
                raise e
        except Exception as e:
            raise e

def get_img_from_local(folder_path: str) -> str:
    if not os.path.isdir(folder_path):
        raise NotADirectoryError(f"'{folder_path}' is not a valid directory.")
    files = [f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f)) and f[0] != "." ]
    if not files:
        raise FileNotFoundError(f"No valid files found in '{folder_path}'.")
    return str(temp_folder /  random.choice(files))

if config["source"] == "reddit":
    update_img_list_from_reddit()
    img_path = try_get_pic_from_local_fallback_reddit()
    print(img_path)
    json.dump(vars,open(temp_folder / ".vars.json","w"))
    for file in os.listdir(temp_folder):
        if file[0] != "." and file.rsplit(".",1)[0] not in vars["pic_data"]:
            os.remove(temp_folder / file)
elif config["source"] == "local":
    img_path = get_img_from_local(temp_folder)
    print(img_path)