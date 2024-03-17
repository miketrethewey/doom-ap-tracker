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
    if mapDesignations[baseTheme][baseGame] == "mapxx" then
        -- print(baseTheme,baseGame,epID,mapID)
        if keySets[baseTheme][baseGame] and
            keySets[baseTheme][baseGame]["episodes"] and
            keySets[baseTheme][baseGame]["episodes"][epID] and
            keySets[baseTheme][baseGame]["episodes"][epID]["maps"] then
            newMapID = mapID
            if epID - 1 > 0 then
                for i = 1,(epID - 1),1 do
                    epLen = #keySets[baseTheme][baseGame]["episodes"][i]["maps"]
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

function difficulty(episode, one, two, three, four, five)
    episode = episode or 1
    one = one or nil
    two = two or nil
    three = three or nil
    four = four or nil
    five = five or nil

    hasEpisode = has("ep" .. episode .. "_on")
    ret = hasEpisode
    if ret then
        if one ~= nil then
            ret = has("difficulty_" .. one)
        end
        if two ~= nil and not ret then
            ret = has("difficulty_" .. two)
        end
        if three ~= nil and not ret then
            ret = has("difficulty_" .. three)
        end
        if four ~= nil and not ret then
            ret = has("difficulty_" .. four)
        end
        if five0 ~= nil and not ret then
            ret = has("difficulty_" .. five)
        end
    end

    return ret
end

function difficulty_range(episode, diff)
    diff = diff or "lo"
    if diff:match("^lo(.*)") then
        return difficulty(episode, "baby", "easy")
    elseif diff:match("^mid(.*)") then
        return difficulty(episode, "medium")
    elseif diff:match("^hi(.*)") then
        return difficulty(episode, "uv", "nm")
    end
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
