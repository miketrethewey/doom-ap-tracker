CompleteItem = class(CustomItem)

function CompleteItem:init(
    name,
    code,
    img,
    disabledImg,
    imgMods,
    disabledImgMods
)
    self:createItem(name)
    self.code = {}
    self.code[code] = true

    if img and img ~= nil then
        self.activeImage = ImageReference:FromPackRelativePath(
            img,
            imgMods or ""
        )
        self.disabledImage = ImageReference:FromPackRelativePath(
            disabledImg or img,
            disabledImgMods or "@disabled"
        )
    end
    if disabledImg and disabledImg ~= nil then
        self.disabledImage = ImageReference:FromPackRelativePath(
            disabledImg,
            disabledImgMods or "@disabled"
        )
    end

    self:updateIcon()
end

-- Set state to Active
function CompleteItem:setActive(active)
    -- print(self.ItemInstance.Name .. " Value to " .. (active and "Active" or "Inactive"))
    self:setProperty("active", active)
end

-- Get if it's In/Active
function CompleteItem:getActive()
    -- print(self.ItemInstance.Name .. " State is " .. (self:getProperty("active") and "Active" or "Inactive"))
    return self:getProperty("active")
end

-- Update Icon
function CompleteItem:updateIcon()
    if self:getActive() then
        -- print(self.ItemInstance.Name .. " Icon to Active")
        self.ItemInstance.Icon = self.activeImage
    else
        -- print(self.ItemInstance.Name .. " Icon to Inactive")
        self.ItemInstance.Icon = self.disabledImage
    end
end

-- OnLeftClick: Toggle
function CompleteItem:onLeftClick()
    self:setActive(not self:getActive())
end

-- OnRightClick: Use Left Click
function CompleteItem:onRightClick()
    self:onLeftClick()
end

-- True if code is present
function CompleteItem:canProvideCode(code)
    if self.code[code] ~= nil then
        -- print(self.ItemInstance.Name .. " can provide " .. code)
        return true
    else
        -- print(self.ItemInstance.Name .. " can NOT provide " .. code)
        return false
    end
end

-- True if code is present and item is active
function CompleteItem:providesCode(code)
    if self.code[code]~=nil and self:getActive() then
        -- print(self.ItemInstance.Name .. " " .. tostring(self.code[code]) .. " is checking")
        return 1
    end
    return 0
end

-- Save state
function CompleteItem:save()
    local saveData = {}
    saveData["active"] = self:getActive()
    return saveData
end

-- Load state
function CompleteItem:load(data)
    if data["active"] ~= nil then
        self:setActive(data["active"])
    end
    return true
end

-- Update icon if property is changed
function CompleteItem:propertyChanged(key, value)
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
                msg = " " .. mapName .. " (E" .. epID .. "M" .. mapID .. ") - Complete"
                itemName = msg
                items[itemName] = CompleteItem(
                    itemName,
                    "e" .. epID .. "m" .. mapID .. "_complete",
                    "images/items/levelcomplete.png"
                )
                -- print(msg)
            end
        end
    end
end
