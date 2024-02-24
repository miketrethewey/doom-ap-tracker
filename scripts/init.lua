local variant = Tracker.ActiveVariantUID
IS_UNLABELLED = variant:find("maps-u")

-- Items
print("Loading Items")
Tracker:AddItems("items/items.json")
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
for e = 1,4
do
    Tracker:AddLocations(
        "locations/mars/overworld/" ..
        "e" .. e ..
        ".json"
    )
    for m = 1,9
    do
        Tracker:AddLocations(
            "locations/mars/underworld/" ..
            "e" .. e ..
            "/" ..
            "e" .. e ..
            "m" .. m ..
            ".json"
        )
    end
end
-- Tracker:AddLocations("locations/locations.json")            -- Mars (Original)
print("")

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
