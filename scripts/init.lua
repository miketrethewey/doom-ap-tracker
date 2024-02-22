local variant = Tracker.ActiveVariantUID
IS_UNLABELLED = variant:find("maps-u")

-- Items
print("Loading Items")
Tracker:AddItems("items/items.json")

-- Logic
print("Loading Logic")
ScriptHost:LoadScript("scripts/logic/logic.lua")

-- Maps
print("Loading Maps")
Tracker:AddMaps("maps/maps.json")

-- Layout
print("Loading Layouts")
Tracker:AddLayouts("layouts/levels.json")
Tracker:AddLayouts("layouts/keys.json")
Tracker:AddLayouts("layouts/weapons.json")
Tracker:AddLayouts("layouts/settings.json")
Tracker:AddLayouts("layouts/tabs.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

-- Locations
print("Loading Locations")
Tracker:AddLocations("locations/mars/mars.json")            -- Mars
Tracker:AddLocations("locations/mars/overworld/e1.json")    -- KDitD
Tracker:AddLocations("locations/mars/underworld/e1/e1m1.json")
Tracker:AddLocations("locations/mars/underworld/e1/e1m2.json")
Tracker:AddLocations("locations/mars/overworld/e2.json")    -- TSoH
Tracker:AddLocations("locations/mars/overworld/e3.json")    -- I
Tracker:AddLocations("locations/mars/overworld/e4.json")    -- TFC
Tracker:AddLocations("locations/locations.json")            -- Mars (Original)

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
