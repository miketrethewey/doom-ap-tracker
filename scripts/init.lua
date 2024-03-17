local variant = Tracker.ActiveVariantUID
IS_UNLABELLED = variant:find("maps-u")

baseTheme = "doom"
baseGame = "doom"
if variant ~= nil then
    baseTheme = string.sub(variant,1,string.find(variant, "/")-1)
    baseGame = string.sub(variant,string.find(variant, "/")+1,-1)
end

function skip_episode(epID)
    skip = false
    -- if epID == 1 or
    --     epID == 2 or
    --     epID == 3 or
    --     epID == 4 then
    --     skip = true
    -- end
    return skip
end

function load_meat()
    if keySets == nil then
        print("No KeySets!")
        return
    end
    if keySets[baseTheme] == nil then
        print("No KeySets for " .. baseTheme .. "!")
        return
    end
    for epID,episode in pairs(keySets[baseTheme][baseGame]["episodes"]) do
        if episode ~= nil and not skip_episode(epID) then
            episodeFile = "variants/" .. baseTheme .. '/' .. baseGame .. "/locations/overworld/" .. "e" .. epID .. ".json"
            Tracker:AddLocations(episodeFile)
            if episode["maps"] ~= nil then
                for mapID,map in pairs(episode["maps"]) do
                    mapFile = "variants/" .. baseTheme .. '/' .. baseGame .. "/locations/underworld/" .. "e" .. epID .. "/" .. "e" .. epID .. "m" .. mapID .. ".json"
                    Tracker:AddLocations(mapFile)
                    mapName = string.upper(get_map_metadata(baseGame, epID, mapID))
                    exitCode = "@" .. mapName .. " Exit/Level Completed"

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
                        if type(locationCode) == "string" then
                            locationObject = Tracker:FindObjectForCode(locationCode)
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
    end
    print("")
end

-- Load Constants
print("Load Constants")
ScriptHost:LoadScript("./scripts/constants/constants.lua")
print("")

-- Logic
print("Loading Logic")
ScriptHost:LoadScript("scripts/logic/logic.lua")
print("")

-- Items
print("Loading Items")
Tracker:AddItems("variants/" .. baseTheme .. "/items/items.json")
ScriptHost:LoadScript("scripts/class.lua")
ScriptHost:LoadScript("scripts/items/custom_item.lua")
ScriptHost:LoadScript("scripts/items/access.lua")
ScriptHost:LoadScript("scripts/items/complete.lua")
ScriptHost:LoadScript("scripts/items/key.lua")
print("")

-- Maps
print("Loading Maps")
Tracker:AddMaps("variants/" .. baseTheme .. '/' .. baseGame .. "/maps/maps.json")
print("")

-- Grids
print("Loading Grids")
Tracker:AddLayouts("variants/" .. baseTheme .. "/layouts/grids/capture.json")
Tracker:AddLayouts("variants/" .. baseTheme .. "/layouts/grids/keys.json")
Tracker:AddLayouts("variants/" .. baseTheme .. "/layouts/grids/settings.json")
if baseGame == "doom64" then
    Tracker:AddLayouts("variants/" .. baseTheme .. '/' .. baseGame .. "/layouts/grids/weapons.json")
else
    Tracker:AddLayouts("variants/" .. baseTheme .. "/layouts/grids/weapons.json")
end
print("")

-- Variant
print("Loading Variant")
Tracker:AddLayouts("variants/" .. baseTheme .. '/' .. baseGame .. "/layouts/broadcast.json")
Tracker:AddLayouts("variants/" .. baseTheme .. '/' .. baseGame .. "/layouts/keys.json")
Tracker:AddLayouts("variants/" .. baseTheme .. '/' .. baseGame .. "/layouts/tabs.json")
print("")

-- Base Layouts
print("Loading Base Layouts")
Tracker:AddLayouts("variants/" .. baseTheme .. "/layouts/tracker.json")
Tracker:AddLayouts("variants/" .. baseTheme .. "/layouts/broadcast.json")
print("")

-- Locations
print("Loading Locations")
Tracker:AddLocations("variants/" .. baseTheme .. '/' .. baseGame .. "/locations/" .. baseGame .. ".json")

load_meat()

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
