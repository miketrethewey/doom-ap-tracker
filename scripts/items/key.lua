KeyItem = class(CustomItem)

function KeyItem:init(
    name,
    code,
    color,
    size
)
    size = size or "normal"
    -- print(name,code,img,size)

    -- Default to cards
    keyType = "cards"
    if baseGame == "doom" then
        -- switch to skulls
        if string.find(code,"e2m6") or
        string.find(code,"e2m9") or
        string.find(code,"e3") or
        string.find(code,"e4") or
        string.find(code,"e5") or
        string.find(code,"e6") then
            keyType = "skulls"
        end
        -- except these cards
        if string.find(code,"e6m5") or
            (string.find(code,"e6m7") and color == "red") or
            string.find(code,"e6m9") then
            keyType = "cards"
        end
    elseif baseGame == "doomii" then
    elseif baseGame == "tnt" then
    elseif baseGame == "plutonia" then
    elseif baseGame == "nrftl" then
        -- Default to skulls
        keyType = "skulls"
        -- except these cards
        if string.find(code,"e1m1") or
        string.find(code,"e1m2") or
        (string.find(code,"e1m3") and color == "blue") then
            keyType = "cards"
        end
    end

    if keyType == "cards" then
        name = name .. " keycard"
    elseif keyType == "skulls" then
        name = name .. " skull key"
    end

    self:createItem(name)
    self.code = {}
    self:setProperty("active", false)
    self.code[code] = true

    img = "images/items/keys/" .. keyType .. "/" .. color
    imgMods = ""
    if size == "slim" then
        code = code .. "_slim"
        img = img .. "_slim"
        self.code[code] = true
    else
        imgMods = "overlay|images/overlays/" .. string.sub(code,2,2) .. '-' .. string.sub(code,4,4) .. ".png"
    end

    img = img .. ".png"

    disabledMods = imgMods .. "," .. "@disabled"

    self.activeImage = ImageReference:FromPackRelativePath(
        img,
        imgMods
    )
    self.disabledImage = ImageReference:FromPackRelativePath(
        disabledImg or img,
        disabledMods or imgMods
    )

    self:updateIcon()
end

-- Set state to Active
function KeyItem:setActive(active)
    -- print(self.ItemInstance.Name .. " Value to " .. (active and "Active" or "Inactive"))
    self:setProperty("active", active)
end

-- Get if it's In/Active
function KeyItem:getActive()
    -- print(self.ItemInstance.Name .. " State is " .. (self:getProperty("active") and "Active" or "Inactive"))
    return self:getProperty("active")
end

-- Update Icon
function KeyItem:updateIcon()
    if self:getActive() then
        -- print(self.ItemInstance.Name .. " Icon to Active")
        self.ItemInstance.Icon = self.activeImage
    else
        -- print(self.ItemInstance.Name .. " Icon to Inactive")
        self.ItemInstance.Icon = self.disabledImage
    end
end

-- OnLeftClick: Toggle
function KeyItem:onLeftClick()
    self:setActive(not self:getActive())
end

-- OnRightClick: Use Left Click
function KeyItem:onRightClick()
    self:onLeftClick()
end

-- True if code is present
function KeyItem:canProvideCode(code)
    if self.code[code] ~= nil then
        -- print(self.ItemInstance.Name .. " can provide " .. code)
        return true
    else
        -- print(self.ItemInstance.Name .. " can NOT provide " .. code)
        return false
    end
end

-- True if code is present and item is active
function KeyItem:providesCode(code)
    if self.code[code]~=nil and self:getActive() then
        -- print(self.ItemInstance.Name .. " " .. tostring(self.code[code]) .. " is checking")
        return 1
    end
    return 0
end

-- Save state
function KeyItem:save()
    local saveData = {}
    saveData["active"] = self:getActive()
    return saveData
end

-- Load state
function KeyItem:load(data)
    if data["active"] ~= nil then
        self:setActive(data["active"])
    end
    return true
end

-- Update icon if property is changed
function KeyItem:propertyChanged(key, value)
    -- print(self.ItemInstance.Name .. " '" .. key .. "' changed to [" .. tostring(value) .. ']')
    self:updateIcon()
end

items = {}
for epID,episode in pairs(keySets[baseGame]["episodes"]) do
    if episode ~= nil and not skip_episode(epID) then
        epName = episode["name"]
        msg = baseGame .. ": " .. epName .. " (E" .. epID .. ")"
        -- print(msg)
        if episode["maps"] ~= nil then
            for mapID,map in pairs(episode["maps"]) do
                mapName = map["name"]
                mapHandle = "E" .. epID .. "M" .. mapID
                if baseGame == "doomii" or
                    baseGame == "tnt" or
                    baseGmae == "plutonia" or
                    baseGame == "nrftl" then
                    mapHandle = "MAP" .. string.format("%02d", mapID)
                end
                msg = " " .. mapName .. " (" .. mapHandle .. ")"
                itemName = msg
                if map["keys"] ~= nil then
                    msg = msg .. " [" .. map["keys"] .. "]"
                    colorSet = map["keys"]
                    for c in colorSet:gmatch"." do
                        c = string.lower(c)
                        if c == "b" then
                            c = "blue"
                        elseif c == "y" then
                            c = "yellow"
                        elseif c == "r" then
                            c = "red"
                        end
                        keyName = itemName .. " - " .. string.upper(string.sub(c,0,1)) .. string.sub(c,2)
                        msg = keyName
                        KeyItem(
                            keyName,
                            "e" .. epID .. "m" .. mapID .. "_" .. c,
                            c
                        )
                        KeyItem(
                            keyName,
                            "e" .. epID .. "m" .. mapID .. "_" .. c,
                            c,
                            "slim"
                        )
                        -- print(msg)
                    end
                end
            end
        end
    end
end
