import json
import os

for epID in range(1,4+1):
    with open(os.path.join("locations","doom","overworld",f"e{epID}.json"),"r") as epFile:
        epJSON = json.load(epFile)
        for mapData in epJSON[0]["children"]:
            if len(mapData["sections"]) > 10:
                print(str(len(mapData["sections"])) + ": " + mapData["name"])
