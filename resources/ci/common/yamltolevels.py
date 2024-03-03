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

baseGame = "nrftl"

for epID in range(1,6+1):
# for epID in range(1,4+1):
    ymlPath = os.path.join(
        "resources",
        "manifests",
        baseGame,
        f"e{epID}.yaml"
    )
    if os.path.isfile(ymlPath):
        print(f"Processing: '{baseGame}' [E{epID}]")
        with open(ymlPath, "r") as ymlFile:
            epYaml = yaml.load(ymlFile, Loader=Loader)
            for _,maps in epYaml.items():
                for mapID,mapData in maps.items():
                    mapID = int(mapID[1:])
                    mapDB = CONSTANTS["keysets"][baseGame]["episodes"][epID-1]["maps"][mapID-1]
                    mapName = f"E{epID}M{mapID}"
                    if baseGame in [
                        "doomii",
                        "nrftl"
                    ]:
                        mapName = f"MAP{str(mapID).rjust(2,"0")}"
                    print(f" Processing: {mapName}")
                    jsonData = [
                        {
                            "name": mapName,
                            "parent": mapDB["name"] + f" ({mapName})",
                            "children": []
                        }
                    ]
                    locID = 0
                    for location in mapData["locations"]:
                        q = 1
                        if "q" in location:
                            q = location["q"]
                        for thisQ in range(1,q+1):
                            if thisQ > 1:
                                location["name"] = location["name"] + " " + str(thisQ)
                            isEntrance = "Entrance" in location["name"]
                            isExit = "Exit" in location["name"]
                            child = {}
                            locName = location["name"]
                            for srch,repl in {
                                "Map": "Computer Area Map",
                                "Card": "Keycard",
                                "Skull": "Skull key",
                                "Rocket": "Rocket Launcher",
                                "Plasma": "Plasma Rifle",
                                "BFG": "BFG9000"
                            }.items():
                                if srch in locName:
                                    locName = locName.replace(srch,repl)
                            if isEntrance or isExit:
                                locName = f"{mapName} {locName}"
                            child["name"] = locName
                            if isEntrance:
                                child["chest_unopened_img"] = "/images/items/levelstart.png"
                                child["chest_opened_img"] = "/images/items/levelstart.png"
                            ref = mapDB["name"] + f" ({mapName})/" + locName
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
                                    "map": f"{mapName.lower()}",
                                    "restrict_visibility_rules": [
                                        f"ep{epID}_on"
                                    ]
                                }
                            ]

                            if isEntrance or isExit:
                                child["map_locations"][0]["size"] = 20

                            child["map_locations"][0]["x"] = location["x"] if "x" in location else (24 * locID)
                            child["map_locations"][0]["y"] = location["y"] if "y" in location else 0

                            if isEntrance:
                                child["access_rules"] = [ "$access|null" ]
                                child["sections"] = [ { "ref": ref, "name": "Level Start", "item_count": 1 } ]
                            if isExit:
                                child["sections"] = [ { "ref": ref, "name": "Level Completed", "hosted_item": f"e{epID}m{mapID}_complete" } ]
                            jsonData[0]["children"].append(child)
                            locID = locID + 1
                    with open(os.path.join("variants",baseGame,"locations","underworld",f"e{epID}",f"e{epID}m{mapID}.json"), "w") as jsonFile:
                        json.dump(jsonData, jsonFile, indent=2)
