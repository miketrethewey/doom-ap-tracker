import json
import luadata
import os
import yaml

CONSTANTS = {}

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except:
    from yaml import Loader, Dumper

for filename in ["mapdesignations.lua","keysets.lua"]:
    with open(os.path.join("scripts","constants",filename)) as constantsFile:
        constantsLua = constantsFile.read()
        CONSTANTS[filename[:filename.find('.')]] = luadata.unserialize(constantsLua)

baseTheme = "heretic"
baseGame = "heretic"

numMapsHistory = []
for epID in range(1,len(CONSTANTS["keysets"][baseTheme][baseGame]["episodes"]) + 1):
    numMaps = len(CONSTANTS["keysets"][baseTheme][baseGame]["episodes"][epID-1]["maps"])
    numMapsHistory.append(numMaps)
    ymlPath = os.path.join(
        "resources",
        "manifests",
        baseTheme,
        baseGame,
        f"e{epID}.yaml"
    )
    print(ymlPath)
    if os.path.isfile(ymlPath):
        print(f"Processing: '{baseTheme}/{baseGame}' [E{epID}]")
        with open(ymlPath, "r") as ymlFile:
            epYaml = yaml.load(ymlFile, Loader=Loader)
            for _,maps in epYaml.items():
                for mapID,mapData in maps.items():
                    mapID = int(mapID[1:])
                    mapName = f"E{epID}M{mapID}"
                    mapIDX = mapID
                    if CONSTANTS["mapdesignations"][baseTheme][baseGame] == "mapxx":
                        # if later "episode" subtract previous lengths
                        for numMaps in numMapsHistory:
                            if mapIDX > numMaps:
                                mapIDX = mapIDX - numMaps
                        mapName = f"MAP{str(mapID).rjust(2,"0")}"
                    mapDB = CONSTANTS["keysets"][baseTheme][baseGame]["episodes"][epID-1]["maps"][mapIDX-1]
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
                        qs = {}
                        note = ""
                        visibility = []

                        # More than one
                        if "q" in location:
                            q = location["q"]
                            qs["all"] = q
                        # Low
                        if "q12" in location:
                            check = location["q12"]
                            if check > 0:
                                q = check
                                qs["low"] = q
                                visibility.append(f"$difficulty_range|{epID}|low")
                        # Med
                        if "q_3" in location:
                            check = location["q_3"]
                            if check > 0:
                                q = check
                                qs["med"] = q
                                visibility.append(f"$difficulty|{epID}|med")
                        # High
                        if "q45" in location:
                            check = location["q45"]
                            if check > 0:
                                q = check
                                qs["high"] = q
                                visibility.append(f"$difficulty_range|{epID}|high")
                        if len(visibility) == 0:
                            visibility = [f"ep{epID}_on"]
                        elif len(visibility) >= 3:
                            note = "#FIXME: Check spawns on difficulties"

                        locName = location["name"]
                        for thisQ in range(1,q+1):
                            if thisQ > 1:
                                locName = location["name"] + " " + str(thisQ)
                            isEntrance = "Entrance" in location["name"]
                            isExit = "Exit" in location["name"]
                            child = {}
                            for srch,repl in {
                                "Map": "Computer Area Map",
                                "Card": "Keycard",
                                "Skull": "Skull key",
                                "Rocket": "Rocket Launcher",
                                "Plasma": "Plasma Gun",
                                "BFG": "BFG9000"
                            }.items():
                                if srch in locName:
                                    locName = locName.replace(srch,repl)
                            if isEntrance or isExit:
                                locName = f"{mapName} {locName}"
                            child["name"] = locName
                            if note != "":
                                child["note"] = note
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
                                    "restrict_visibility_rules": visibility
                                }
                            ]

                            if isEntrance or isExit:
                                child["map_locations"][0]["size"] = 20

                            locPos = {
                                "x": 24 * locID,
                                "y": 0
                            }
                            if locID > 20:
                                locPos = {
                                    "x": 24 * (locID % 20),
                                    "y": int(locID / 20)
                                }
                            if "x" in location:
                                locPos["x"] = location["x"]
                            if "y" in location:
                                locPos["y"] = location["y"]

                            child["map_locations"][0] = locPos

                            if isEntrance:
                                child["access_rules"] = [ "$access|null" ]
                                child["sections"] = [ { "ref": ref, "name": "Level Start", "item_count": 1 } ]
                            if isExit:
                                child["sections"] = [ { "ref": ref, "name": "Level Completed", "hosted_item": f"e{epID}m{mapIDX}_complete" } ]
                            jsonData[0]["children"].append(child)
                            locID = locID + 1
                    writePath = os.path.join("variants",baseTheme,baseGame,"locations","underworld",f"e{epID}")
                    if not os.path.isdir(writePath):
                        os.makedirs(writePath)
                    with open(os.path.join(writePath,f"e{epID}m{mapIDX}.json"), "w") as jsonFile:
                        json.dump(jsonData, jsonFile, indent=2)
