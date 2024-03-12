function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

function string:endswith(suffix)
    return self:sub(-#suffix) == suffix
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        -- We grab the first index of our sub-table instead
        if value == val or value[1] == val then
            return true
        end
    end

    return false
end

function get_map_metadata(baseGame, epID, mapID)
    mapHandle = "e" .. epID .. "m" .. mapID
    if mapDesignations[baseGame] == "mapxx" then
        -- print(baseGame,epID,mapID)
        if keySets[baseGame] and
            keySets[baseGame]["episodes"] and
            keySets[baseGame]["episodes"][epID] and
            keySets[baseGame]["episodes"][epID]["maps"] then
            newMapID = mapID
            if epID - 1 > 0 then
                for i = 1,(epID - 1),1 do
                    epLen = #keySets[baseGame]["episodes"][i]["maps"]
                    newMapID = newMapID + epLen
                end
            end
            mapID = newMapID
        end
        mapHandle = "map" .. string.format("%02d", mapID)
    end
    return mapHandle
end

function access(level, one, two, three)
    one = one or nil
    two = two or nil
    three = three or nil

    ret = has(level .. "_access")
    if one ~= nil then
        ret = ret and has(level .. "_" .. one)
    end
    if two ~= nil then
        ret = ret and has(level .. "_" .. two)
    end
    if three ~= nil then
        ret = ret and has(level .. "_" .. three)
    end

    return ret
end

function or_access(level, one, two, three)
    one = one or nil
    two = two or nil
    three = three or nil

    ret = has(level .. "_access")
    if one ~= nil then
        ret = ret and has(level .. "_" .. one)
    end
    if two ~= nil then
        ret = ret or has(level .. "_" .. two)
    end
    if three ~= nil then
        ret = ret or has(level .. "_" .. three)
    end

    return ret
end

function canShootSigil()
    return has("pistol") or has("shotgun") or has("chaingun")
end

function canDo30SecTrial()
    return has("30sec")
end

-- defined but not used?
-- red
function e3m9_redaccess()
    return (
        has("e3m9_access") and has("e3m9_red")
    )
end
