import json
import luadata
import os
import yaml

CONSTANTS = {}

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except:
    from yaml import Loader, Dumper

for filename in ["keysets.lua"]:
    with open(os.path.join("scripts","constants",filename)) as constantsFile:
        constantsLua = constantsFile.read()
        CONSTANTS[filename[:filename.find('.')]] = luadata.unserialize(constantsLua)

baseGame = "doom"

# for epID in range(1,6+1):
for epID in range(1,4+1):
    ymlPath = os.path.join(
        "resources",
        "manifests",
        f"e{epID}.yaml"
    )
    if os.path.isfile(ymlPath):
        with open(ymlPath, "r") as ymlFile:
            epYaml = yaml.load(ymlFile, Loader=Loader)
            for _,maps in epYaml.items():
                for mapID,mapData in maps.items():
                    mapID = int(mapID[1:])
                    mapDB = CONSTANTS["keysets"][baseGame]["episodes"][epID-1]["maps"][mapID-1]
                    jsonData = [
                        {
                            "name": f"E{epID}M{mapID}",
                            "parent": mapDB["name"] + f" (E{epID}M{mapID})",
                            "children": []
                        }
                    ]
                    for location in mapData["locations"]:
                        isEntrance = "Entrance" in location["name"]
                        isExit = "Exit" in location["name"]
                        child = {}
                        child["name"] = location["name"]
                        ref = mapDB["name"] + f" (E{epID}M{mapID})/" + location["name"]
                        if isEntrance:
                            child["chest_unopened_img"] = "/images/items/levelstart.png"
                            child["chest_opened_img"] = "/images/items/levelstart.png"
                        child["access_rules"] = [ f"@{ref}" ]
                        child["sections"] = [
                            {
                                "ref": ref,
                                "name": "Item",
                                "item_count": 1
                            }
                        ]
                        child["map_locations"] = [
                            {
                                "map": f"e{epID}m{mapID}",
                                "restrict_visibility_rules": [
                                    f"ep{epID}_on"
                                ]
                            }
                        ]

                        if isEntrance or isExit:
                            child["map_locations"][0]["size"] = 20

                        child["map_locations"][0]["x"] = location["x"]
                        child["map_locations"][0]["y"] = location["y"]

                        if isEntrance:
                            child["access_rules"] = [ "$access|null" ]
                            child["sections"] = [ { "ref": ref, "name": "Level Start", "item_count": 1 } ]
                        if isExit:
                            child["sections"] = [ { "ref": ref, "name": "Level Completed", "hosted_item": f"e{epID}m{mapID}_complete" } ]
                        jsonData[0]["children"].append(child)
                    with open(os.path.join("locations","mars","underworld",f"e{epID}",f"e{epID}m{mapID}.json"), "w") as jsonFile:
                        json.dump(jsonData, jsonFile, indent=2)
