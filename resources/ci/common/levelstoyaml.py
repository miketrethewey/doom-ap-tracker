import json
import os
import yaml

for epID in range(1,6+1):
    yml = {
        f"E{epID}": {}
    }
    for mapID in range(1,9+1):
        mapPath = os.path.join(
            "locations",
            "doom",
            "underworld",
            f"e{epID}",
            f"e{epID}m{mapID}.json"
        )
        if os.path.isfile(mapPath):
            yml[f"E{epID}"][f"M{mapID}"] = {}
            with open(mapPath, "r") as mapFile:
                mapJSON = json.load(mapFile)
                locations = []
                for location in mapJSON[0]["children"]:
                    locationName = location["name"]
                    for check in [
                        "Entrance",
                        "Exit",
                        "Secret Exit"
                    ]:
                        if locationName == check:
                            locationName = f"E{epID}M{mapID} {check}"
                    locations.append(
                        {
                            "name": locationName,
                            "x": location["map_locations"][0]["x"],
                            "y": location["map_locations"][0]["y"]
                        }
                    )
                yml[f"E{epID}"][f"M{mapID}"] = {
                    "locations": locations
                }
    with open(os.path.join("resources","manifests",f"e{epID}.yaml"), "w") as yamlFile:
        yaml.dump(yml, yamlFile)
