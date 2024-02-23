function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
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

-- defined but not used?
-- red
function e3m9_redaccess()
    return (
        has("e3m9_access") and has("e3m9_red")
    )
end
