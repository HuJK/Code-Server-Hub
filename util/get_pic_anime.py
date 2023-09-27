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


vars = {"prev_update":0 , "pic_data": {} }
if os.path.isfile(temp_folder / ".vars.json"):
    try:
        vars = json.load(open(temp_folder / ".vars.json"))
    except Exception as e:
        os.remove(temp_folder / ".vars.json")
        vars = {"prev_update":0 , "pic_data": {} }

def get_recent_pic(pages,after="",ps={}):
    if pages == 0 or after == None:
        return ps
    else:
        url = r'https://gateway.reddit.com/desktopapi/v1/subreddits/Animewallpaper/search?rtj=only&allow_over18=&include=prefsSubreddit&q=flair_name%3A%22Desktop%22&sort=new&t=all&type=link&include_over_18=&restrict_sr=1&b=true' + ("" if after == "" else "&after=" + after)
        r = requests.get(url, headers = {'User-agent': 'your bot 0.2'})
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
        return get_recent_pic(pages-1,a["postOrder"][-1] if len(a["postOrder"]) > 0 else None ,ps)
if vars["prev_update"] < time.time()- 80000:
    if len(vars["pic_data"].keys()) > 10:
        vars["pic_data"].pop(random.choice(list(vars["pic_data"].keys())))
    vars["pic_data"] = {**vars["pic_data"], **get_recent_pic(6)}
    vars["pic_data"] = [[k,v] for k,v in sorted(zip(vars["pic_data"].keys(),vars["pic_data"].values()),key = lambda d:-d[1]["score"])]
    vars["pic_data"] = {k:v for k,v in vars["pic_data"][:4096] }
    vars["prev_update"] = time.time()


def try_get_pic(try_t = 3):
    c = random.choices(list(vars["pic_data"].keys()), weights=map(lambda x:x["score"],list(vars["pic_data"].values())))[0]
    if os.path.isfile(temp_folder / (c + ".png")):
        print(str(temp_folder / c) + ".png")
        #sys.stdout.buffer.write(open(temp_folder / (c + ".png"),"rb").read())
        
    else:
        try:
            r = requests.get(vars["pic_data"][c]["url"])
            r.raise_for_status()
            open(temp_folder / (c + ".png"),"wb").write(r.content)
            print(str(temp_folder / c) + ".png")
            #sys.stdout.buffer.write(r.content)
        except requests.HTTPError as e:
            if try_t > 0:
                vars["pic_data"][c]["score"] = 0
                try_get_pic(try_t -1)
            else:
                raise e
        except Exception as e:
            raise e
try_get_pic()
json.dump(vars,open(temp_folder / ".vars.json","w"))

for file in os.listdir(temp_folder):
    if file[0] != "." and file.rsplit(".",1)[0] not in vars["pic_data"]:
        os.remove(temp_folder / file)
