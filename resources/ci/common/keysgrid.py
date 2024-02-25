import json
import os

import luadata

CONSTANTS = {}

for filename in ["keysets.lua","mapnames.lua"]:
    with open(os.path.join("scripts","constants",filename)) as constantsFile:
        constantsLua = constantsFile.read()
        CONSTANTS[filename[:filename.find('.')]] = luadata.unserialize(constantsLua)
print(CONSTANTS)

keysgrid = {
    "keys_grid": {
        "type": "array",
        "orientation": "horizontal",
        "content": []
    }
}
for epID, maps in enumerate(CONSTANTS["mapnames"]):
    epID = epID + 1
    episode = {
        "type": "array",
        "orientation": "horizontal",
        "content": []
    }
    for mapID, mapname in enumerate(maps):
        mapID = mapID + 1
        map = {
            "type": "itemgrid",
            "item_size": 16,
            "item_margin": "0",
            "rows": []
        }
        map["rows"].append([f"e{epID}m{mapID}_access"])
        hasKeys = False
        keyset = CONSTANTS["keysets"][epID - 1][mapID - 1]
        print(f"E{epID}M{mapID}: {keyset}")
        for ltr in ["B","Y","R"]:
            if ltr in keyset:
                hasKeys = True
                color = ""
                if ltr.lower() == "b":
                    color = "blue"
                elif ltr.lower() == "y":
                    color = "yellow"
                elif ltr.lower() == "r":
                    color = "red"
                map["rows"].append(
                    [
                        f"e{epID}m{mapID}_{color}_slim"
                    ]
                )
            else:
                map["rows"].append([""])
        map["rows"].append([f"e{epID}m{mapID}_complete"])
        episode["content"].append(map)
    keysgrid["keys_grid"]["content"].append(episode)

with open(os.path.join("layouts","keys2.json"), "w") as keysFile:
    json.dump(keysgrid, keysFile, indent=2)
