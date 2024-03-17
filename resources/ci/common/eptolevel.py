import json
import os
import re

baseTheme = "doom"
baseGame = "doom"

locationsPath = os.path.join(
    "variants",
    baseTheme,
    baseGame,
    "locations",
    "overworld"
)

if os.path.isdir(locationsPath):
    for filename in os.listdir(locationsPath):
        if os.path.isfile(os.path.join(locationsPath,filename)):
            if filename not in ["e6.json"]:
                continue
            with open(os.path.join(locationsPath,filename), "r") as episodeFile:
                episodeData = json.load(episodeFile)
                epName = episodeData[0]["name"]
                locations = episodeData[0]["children"]
                for mapData in locations:
                    mapName = mapData["name"]
                    if "(E" in mapName:
                        mapHandle = re.search(r"(?:[^(]+)(?:[\(])([^\)]+)(?:[\)])",mapName)
                        mapHandle = mapHandle.groups(0)[0]
                        epID = mapHandle.lower()[1:2]
                        mapID = mapHandle.lower()[3:4]
                        for keyName in [
                            "chest_unopened_img",
                            "chest_opened_img"
                        ]:
                            if keyName in mapData:
                                del mapData[keyName]
                        for childID,child in enumerate(mapData["sections"]):
                            ref = f"{mapName}/{child['name']}"
                            child["sections"] = [
                                {
                                    "name": "Item",
                                    "item_count": 1
                                }
                            ]
                            child["map_locations"] = [
                                {
                                    "map":mapHandle.lower(),
                                    "x":(childID + 1) * 24,
                                    "y":0,
                                    "restrict_visibility_rules":[f"ep{epID}_on"]
                                }
                            ]
                            if "item_count" in child:
                                del child["item_count"]
                            if "Exit" in child["name"]:
                                isSecret = "Secret Exit" in child["name"]
                                child["name"] = f"{mapHandle} Exit"
                                child["name"] = f"{mapHandle} Secret Exit" if isSecret else child["name"]
                                child["sections"] = [
                                    {
                                        "ref": ref,
                                        "name": "Level Completed",
                                        "hosted_item": child["hosted_item"]
                                    }
                                ]
                                child["map_locations"][0]["size"] = 20

                                if "restrict_visibility_rules" in child["map_locations"][0]:
                                    visibility = child["map_locations"][0]["restrict_visibility_rules"]
                                    del child["map_locations"][0]["restrict_visibility_rules"]
                                    child["map_locations"][0]["restrict_visibility_rules"] = visibility

                                access = child["access_rules"]
                                del child["access_rules"]
                                child["access_rules"] = access

                                del child["hosted_item"]
                            if "visibility_rules" in child:
                                child["map_locations"][0]["restrict_visibility_rules"] = child["visibility_rules"]

                            for keyName in [
                                "restrict_visibility_rules"
                                "visibility_rules"
                            ]:
                                if keyName in child:
                                    del child[keyName]

                            child["access_rules"] =  [ f"@{ref}" ]
                        entrance = {
                            "name": f"{mapHandle} Entrance",
                            "chest_unopened_img": "/images/items/levelstart.png",
                            "chest_opened_img": "/images/items/levelstart.png",
                            "access_rules": [ "$access|null" ],
                            "sections": [
                                {
                                    "name": "Level Start",
                                    "item_count": 1
                                }
                            ],
                            "map_locations": [
                                {
                                    "map": f"e{epID}m{mapID}",
                                    "restrict_visibility_rules": [ f"ep{epID}_on" ],
                                    "size": 20,
                                    "x": 0,
                                    "y": 0
                                }
                            ]
                        }
                        mapData["sections"].insert(0,entrance)
                        mapData["children"] = mapData["sections"]
                        mapData["name"] = mapHandle
                        mapData["parent"] = mapName
                        del mapData["map_locations"]
                        del mapData["sections"]
                        mapData = [mapData]
                        # print(json.dumps(mapData))
                        with open(os.path.join("variants",baseTheme,baseGame,"locations","underworld",f"e{epID}",f"e{epID}m{mapID}.json"), "w") as mapFile:
                            json.dump(mapData,mapFile,indent=2)
