import json
import os

import luadata

CONSTANTS = {}

for filename in ["mapdesignations.lua","keysets.lua"]:
    with open(os.path.join("scripts","constants",filename)) as constantsFile:
        constantsLua = constantsFile.read()
        CONSTANTS[filename[:filename.find('.')]] = luadata.unserialize(constantsLua)

baseGame = "doom"
basePath = os.path.join(
    "variants",
    baseGame,
    "locations",
    "underworld"
)

numMapsHistory = []
if os.path.isdir(basePath):
    print(f"Game: {baseGame}")
    for episode in os.listdir(basePath):
        if os.path.isdir(os.path.join(basePath,episode)):
            epID = episode[1:]
            print(f"  E{epID}")
            if int(epID) != 6:
                continue
            numMaps = len(CONSTANTS["keysets"][baseGame]["episodes"][int(epID) - 1]["maps"])
            numMapsHistory.append(numMaps)
            epName = CONSTANTS["keysets"][baseGame]["episodes"][int(epID) - 1]["name"]
            epRoot = [
                {
                    "name": epName,
                    "parent": f"{epName} (E{epID})",
                    "children": []
                }
            ]
            epMaps = []
            for mapPath in os.listdir(os.path.join(basePath,episode)):
                if os.path.isfile(os.path.join(basePath,episode,mapPath)):
                    with open(os.path.join(
                        basePath,
                        episode,
                        mapPath
                    ), "r") as mapFile:
                        mapID = os.path.splitext(mapPath)[0][3:]
                        mapHandle = f"e{epID}m{mapID}"
                        if CONSTANTS["mapdesignations"][baseGame] == "mapxx":
                            mapIDX = mapID
                            # if later "episode" add previous lengths
                            for numEp,numMaps in enumerate(numMapsHistory):
                                if (numEp + 1) < int(epID):
                                    mapIDX = int(mapIDX) + numMaps
                            mapHandle = "map" + str(mapIDX).rjust(2,"0")
                        print(f"    E{epID}: {mapHandle}")
                        mapJSON = json.load(mapFile)
                        # get first element
                        mapJSON = mapJSON[0]
                        mapObj = {}
                        # move name
                        mapObj["name"] = mapJSON["parent"]
                        # add access rules
                        mapObj["access_rules"] = [ f"$access|{mapHandle}" ]
                        # add children as sections
                        mapObj["sections"] = []
                        for child in mapJSON["children"]:
                            if "Entrance" not in child["name"]:
                                child["access_rules"] = []
                                for sectionID,section in enumerate(child["sections"]):
                                    if "item_count" in section:
                                        child["item_count"] = section["item_count"]
                                del child["sections"]
                                del child["map_locations"]
                                if "Exit" in child["name"]:
                                    child["hosted_item"] = f"e{epID}m{mapID}_complete"
                                mapObj["sections"].append(child)
                        mapObj["map_locations"] = [
                            {
                                "map": "overworld",
                                "x": 24 * int(mapID),
                                "y": 0,
                                "restrict_visibility_rules": [
                                    f"ep{epID}_on"
                                ]
                            }
                        ]
                        epMaps.append(mapObj)
            epRoot[0]["children"] = epMaps
            with open(os.path.join(basePath,"..","overworld",f"e{epID}.json"), "w") as epFile:
                json.dump(epRoot, epFile, indent=2)
