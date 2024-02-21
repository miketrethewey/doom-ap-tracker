function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

function key_access(level, color)
    return (
        has(level .. "_access") and has(level .. "_" .. color)
    )
end

-- blue && yellow
function e1m3_blueyellowaccess()
    return key_access("e1m3", "blue") and key_access("e1m3", "yellow")
end

-- blue || yellow
function e1m4_blueyellow()
    return key_access("e1m4", "blue") or key_access("e1m4", "yellow")
end

-- blue && yellow
function e1m5_blueyellowaccess()
    return key_access("e1m5", "blue") and key_access("e1m5", "yellow")
end

-- blue || yellow
function e1m6_blueyellowaccess()
    return key_access("e1m6", "blue") or key_access("e1m6", "yellow")
end

-- blue && yellow
function e1m7_blueyellowaccess()
    return key_access("e1m7", "blue") and key_access("e1m7", "yellow")
end

-- yellow && red
function e1m7_yellowredaccess()
    return key_access("e1m7", "yellow") and key_access("e1m7", "red")
end

-- blue && yellow
function e2m4_blueyellowaccess()
    return key_access("e2m4", "blue") and key_access("e2m4", "yellow")
end

-- blue && yellow && red
function e2m6_blueyellowredaccess()
    return key_access("e2m6", "blue") and key_access("e2m6", "yellow") and key_access("e2m6", "red")
end

-- blue && red
function e2m7_blueredaccess()
    return key_access("e2m7", "blue") and key_access("e2m7", "red")
end

-- blue && yellow
function e3m4_blueyellowaccess()
    return key_access("e3m4", "blue") and key_access("e3m4", "yellow")
end

-- blue && red
function e3m4_blueredaccess()
    return key_access("e3m4", "blue") and key_access("e3m4", "red")
end

-- yellow && red
function e3m7_yellowredaccess()
    return key_access("e3m7", "yellow") and key_access("e3m7", "red")
end

-- defined but not used?
-- red
function e3m9_redaccess()
    return (
        has("e3m9_access") and has("e3m9_red")
    )
end

-- blue && red
function e3m9_blueredaccess()
    return key_access("e3m9", "blue") and key_access("e3m9", "red")
end

-- blue || yellow
function e4m2_blueyellowaccess()
    return key_access("e4m2", "blue") or key_access("e4m2", "yellow")
end

-- blue && red
function e4m3_blueredaccess()
    return key_access("e4m3", "blue") and key_access("e4m3", "red")
end

-- blue && red
function e4m6_blueredaccess()
    return key_access("e4m6", "blue") and key_access("e4m6", "red")
end

-- blue && red
function e4m6_bluered()
    return key_access("e4m6", "blue") and key_access("e4m6", "red")
end

-- yellow && red
function e4m8_yellowredaccess()
    return key_access("e4m8", "yellow") and key_access("e4m8", "red")
end
