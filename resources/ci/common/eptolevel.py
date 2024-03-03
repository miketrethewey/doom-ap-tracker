import json
import os

locationsPath = os.path.join(
    "locations",
    "locations.json"
)
if os.path.isfile(locationsPath):
    with open(locationsPath, "r") as locationsFile:
        locations = json.load(locationsFile)
        for mapData in locations:
            mapName = mapData["name"]
            if "E" in mapName:
                epID = mapName.lower()[1:2]
                mapID = mapName.lower()[3:4]
                del mapData["chest_unopened_img"]
                del mapData["chest_opened_img"]
                for child in mapData["children"]:
                    if child["name"] == "Exit":
                        del child["sections"][0]["item_count"]
                        child["sections"][0]["hosted_item"] = f"e{epID}m{mapID}_complete"
                        child["map_locations"][0]["size"] = 20
                    child["map_locations"][0]["visibility_rules"] = child["visibility_rules"]
                    del child["visibility_rules"]
                    ref = ""
                    for section in child["sections"]:
                        section["ref"] = section["ref"].replace("Mars/","")
                        ref = section["ref"]
                    mapData["parent"] = ref[:ref.find('/')]
                    child["access_rules"] =  [ f"@{ref}" ]
                entrance = {
                    "name": "Entrance",
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
                            "visibility_rules": [ f"ep{epID}_on" ],
                            "size": 20,
                            "x": 0,
                            "y": 0
                        }
                    ]
                }
                mapData["children"].insert(0,entrance)
                mapData = [mapData]
                print(mapData)
                with open(os.path.join("locations","doom","underworld",f"e{epID}",f"e{epID}m{mapID}.json"), "w") as mapFile:
                    json.dump(mapData,mapFile,indent=2)
