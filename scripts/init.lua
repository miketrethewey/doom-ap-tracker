local variant = Tracker.ActiveVariantUID
IS_UNLABELLED = variant:find("maps-u")

function skip_episode(epID)
    skip = false
    if epID == 1 or
        epID == 2 or
        epID == 3 or
        epID == 4 then
        skip = true
    end
    return skip
end

-- Load Constants
print("Load Constants")
ScriptHost:LoadScript("./scripts/constants/constants.lua")
print("")

-- Items
print("Loading Items")
Tracker:AddItems("items/items.json")
ScriptHost:LoadScript("scripts/class.lua")
ScriptHost:LoadScript("scripts/items/custom_item.lua")
ScriptHost:LoadScript("scripts/items/access.lua")
ScriptHost:LoadScript("scripts/items/complete.lua")
ScriptHost:LoadScript("scripts/items/key.lua")
print("")

-- Logic
print("Loading Logic")
ScriptHost:LoadScript("scripts/logic/logic.lua")
print("")

-- Maps
print("Loading Maps")
Tracker:AddMaps("maps/maps.json")
print("")

-- Layout
print("Loading Layouts")
Tracker:AddLayouts("layouts/levels.json")
Tracker:AddLayouts("layouts/keys.json")
Tracker:AddLayouts("layouts/weapons.json")
Tracker:AddLayouts("layouts/settings.json")
Tracker:AddLayouts("layouts/tabs.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")
print("")

-- Locations
print("Loading Locations")
Tracker:AddLocations("locations/mars/mars.json") -- Mars
for epID,episode in pairs(keySets[baseGame]["episodes"]) do
    if episode ~= nil and not skip_episode(epID) then
        episodeFile = "locations/mars/overworld/" .. "e" .. epID .. ".json"
        Tracker:AddLocations(episodeFile)
        if episode["maps"] ~= nil then
            for mapID,map in pairs(episode["maps"]) do
                mapFile = "locations/mars/underworld/" .. "e" .. epID .. "/" .. "e" .. epID .. "m" .. mapID .. ".json"
                Tracker:AddLocations(mapFile)
                exitCode = "@E" .. epID .. "M" .. mapID .. " Exit/Level Completed"
                entranceCode = string.gsub(string.gsub(exitCode, "Exit", "Entrance"),"Completed","Start")
                locationObject = Tracker:FindObjectForCode(entranceCode)
                completedCode = "e" .. epID .. "m" .. mapID .. "_complete"
                if locationObject ~= nil then
                    startCode = string.gsub(completedCode, "_complete", "_access")
                    itemObject = Tracker:FindObjectForCode(startCode)
                    if itemObject ~= nil then
                        locationObject.CapturedItem = itemObject
                    end
                end

                itemObject = Tracker:FindObjectForCode(completedCode)

                for _,locationCode in pairs({exitCode, string.gsub(exitCode, "Exit", "Secret Exit")}) do
                    locationObject = Tracker:FindObjectForCode(exitCode)
                    if locationObject ~= nil then
                        if itemObject ~= nil then
                            locationObject.CapturedItem = itemObject
                        end
                    end
                end
            end
        end
    end
end
print("")

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
