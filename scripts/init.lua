-- Start Time
timeKeys = {}
timeKey = "start"
table.insert(timeKeys, timeKey)
times = {
    [timeKey] = os.clock()
}

-- Variant?
local variant = Tracker.ActiveVariantUID
IS_UNLABELLED = variant:find("maps-u")

-- Default to DOOM
baseTheme = "doom"
baseGame = "doom"

-- Set Variant if we're loading one
if variant ~= nil then
    baseTheme = string.sub(variant,1,string.find(variant, "/")-1)
    baseGame = string.sub(variant,string.find(variant, "/")+1,-1)
end

-- See if value is in table
function table_contains(tbl, value)
    for _,val in ipairs(tbl) do
        if val == value then
            return true
        end
    end
    return false
end

-- Skip Episode for testing
function skip_episode(epID)
    return table_contains(
        {5,6},
        epID
    )
end

-- The bulk of the situation
function load_meat()
    -- We've got no keysets
    if keySets == nil then
        print("No KeySets!")
        return
    end
    -- This theme's got no keysets
    if keySets[baseTheme] == nil then
        print("No KeySets for " .. baseTheme .. "!")
        return
    end
    -- Cycle through Episodes
    for epID,episode in pairs(keySets[baseTheme][baseGame]["episodes"]) do
        if episode ~= nil and not skip_episode(epID) then
            -- Add Overworld
            episodeFile = "variants/" .. baseTheme .. '/' .. baseGame .. "/locations/overworld/" .. "e" .. epID .. ".json"
            timeKey = "e" .. epID
            table.insert(timeKeys, timeKey)
            times[timeKey] = os.clock()
            Tracker:AddLocations(episodeFile)

            -- Add Underworld
            if episode["maps"] ~= nil then
                for mapID,map in pairs(episode["maps"]) do
                    mapFile = "variants/" .. baseTheme .. '/' .. baseGame .. "/locations/underworld/" .. "e" .. epID .. "/" .. "e" .. epID .. "m" .. mapID .. ".json"
                    Tracker:AddLocations(mapFile)

                    timeKey = "e" .. epID .. "m" .. mapID
                    table.insert(timeKeys, timeKey)
                    times[timeKey] = os.clock()

                    -- Get Map Name
                    mapName = string.upper(get_map_metadata(baseGame, epID, mapID))
                    -- Get ID for Exit
                    exitCode = "@" .. mapName .. " Exit/Level Completed"

                    -- Get handle for Entrance Location
                    entranceCode = string.gsub(string.gsub(exitCode, "Exit", "Entrance"),"Completed","Start")
                    locationObject = Tracker:FindObjectForCode(entranceCode)

                    -- Get ID for Level Complete item
                    completedCode = "e" .. epID .. "m" .. mapID .. "_complete"

                    if locationObject ~= nil then
                        -- Get ID for Level Access item
                        startCode = string.gsub(completedCode, "_complete", "_access")
                        -- Get handle for Level Access item
                        itemObject = Tracker:FindObjectForCode(startCode)
                        if itemObject ~= nil then
                            -- Set Level Access Item to Entrance Location captured item
                            -- print(timeKey,startCode)
                            locationObject.CapturedItem = itemObject
                        end
                    end

                    -- Get handle for Level Complete Item
                    itemObject = Tracker:FindObjectForCode(completedCode)

                    -- Check Exit/Secret Exit
                    for _,locationCode in pairs({exitCode, string.gsub(exitCode, "Exit", "Secret Exit")}) do
                        if type(locationCode) == "string" then
                            -- Get handle for Exit/Secret Exit
                            locationObject = Tracker:FindObjectForCode(locationCode)
                            if locationObject ~= nil then
                                if itemObject ~= nil then
                                    -- Set Level Complete Item to Exit Location/Secret Exit Location captured item
                                    -- print(timeKey,locationCode)
                                    locationObject.CapturedItem = itemObject
                                end
                            end
                        end
                    end
                    if true then
                        goto continue
                    end
                    ::continue::
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
if baseGame == "hexen" then
    Tracker:AddItems("variants/" .. baseTheme .. "/items/fighter.json")
    Tracker:AddItems("variants/" .. baseTheme .. "/items/cleric.json")
    Tracker:AddItems("variants/" .. baseTheme .. "/items/mage.json")
end
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
    if baseGame == "hexen" then
        Tracker:AddLayouts("variants/" .. baseTheme .. "/layouts/grids/classes.json")
    end
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

timeKey = "startMeat"
table.insert(timeKeys, timeKey)
times[timeKey] = os.clock()

load_meat()

timeKey = "endMeat"
table.insert(timeKeys, timeKey)
times[timeKey] = os.clock()

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end

timeKey = "end"
table.insert(timeKeys, timeKey)
times[timeKey] = os.clock()

for _,timeKey in ipairs(timeKeys) do
    print(timeKey, times[timeKey]-times["start"])
end
