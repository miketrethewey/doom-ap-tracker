AccessItem = class(CustomItem)

function AccessItem:init(
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
    m1_access = code:endswith"m1_access"
    map_notation = string.find(
        get_map_metadata(
            baseGame,
            string.sub(code,2,2),
            string.sub(code,4,4)
        ),
        "map"
    )
    if (m1_access and not map_notation) or
        (string.find(code,"e1m1_") and map_notation) then
        self:setProperty("active", true)
        self.ItemInstance.IgnoreUserInput = true
    end

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
function AccessItem:setActive(active)
    -- print(self.ItemInstance.Name .. " Value to " .. (active and "Active" or "Inactive"))
    self:setProperty("active", active)
end

-- Get if it's In/Active
function AccessItem:getActive()
    -- print(self.ItemInstance.Name .. " State is " .. (self:getProperty("active") and "Active" or "Inactive"))
    return self:getProperty("active")
end

-- Update Icon
function AccessItem:updateIcon()
    if self:getActive() then
        -- print(self.ItemInstance.Name .. " Icon to Active")
        self.ItemInstance.Icon = self.activeImage
    else
        -- print(self.ItemInstance.Name .. " Icon to Inactive")
        self.ItemInstance.Icon = self.disabledImage
    end
end

-- OnLeftClick: Toggle
function AccessItem:onLeftClick()
    self:setActive(not self:getActive())
end

-- OnRightClick: Use Left Click
function AccessItem:onRightClick()
    self:onLeftClick()
end

-- True if code is present
function AccessItem:canProvideCode(code)
    if self.code[code] ~= nil then
        -- print(self.ItemInstance.Name .. " can provide " .. code)
        return true
    else
        -- print(self.ItemInstance.Name .. " can NOT provide " .. code)
        return false
    end
end

-- True if code is present and item is active
function AccessItem:providesCode(code)
    if self.code[code]~=nil and self:getActive() then
        -- print(self.ItemInstance.Name .. " " .. tostring(self.code[code]) .. " is checking")
        return 1
    end
    return 0
end

-- Save state
function AccessItem:save()
    local saveData = {}
    saveData["active"] = self:getActive()
    return saveData
end

-- Load state
function AccessItem:load(data)
    if data["active"] ~= nil then
        self:setActive(data["active"])
    end
    return true
end

-- Update icon if property is changed
function AccessItem:propertyChanged(key, value)
    -- print(self.ItemInstance.Name .. " '" .. key .. "' changed to [" .. tostring(value) .. ']')
    self:updateIcon()
end

function load_access()
    if keySets == nil then
        print("No KeySets!")
        return
    end
    if keySets[baseTheme] == nil then
        print("No KeySets for " .. baseTheme .. "!")
        return
    end
    if keySets[baseTheme][baseGame] == nil then
        print("No KeySets for " .. baseTheme .. "/" .. baseGame .. "!")
        return
    end
    if keySets[baseTheme][baseGame]["episodes"] == nil then
        print("No Episodes for " .. baseTheme .. "/" .. baseGame .. "!")
        return
    end
    items = {}
    for epID,episode in pairs(keySets[baseTheme][baseGame]["episodes"]) do
        if episode ~= nil and not skip_episode(epID) then
            epName = episode["name"]
            msg = baseGame .. ": " .. epName .. " (E" .. epID .. ")"
            -- print(msg)
            if episode["maps"] ~= nil then
                for mapID,map in pairs(episode["maps"]) do
                    mapName = map["name"]
                    mapHandle = string.upper(get_map_metadata(baseGame, epID, mapID))
                    if string.find(mapHandle,"MAP") then
                        overlay = string.lower(mapHandle) .. ".png"
                    else
                        overlay = epID .. "-" .. mapID .. ".png"
                    end

                    msg = " " .. mapName .. " (" .. mapHandle .. ") - Access"
                    itemName = msg
                    items[itemName] = AccessItem(
                        itemName,
                        "e" .. epID .. "m" .. mapID .. "_access",
                        "variants/" .. "doom" .. "/images/levels/" .. "e" .. epID .. ".png",
                        nil,
                        "overlay|variants/" .. "doom" .. "/images/overlays/" .. overlay,
                        "@disabled,overlay|variants/" .. "doom" .. "/images/overlays/" .. overlay
                    )
                    print(msg)
                end
            end
        end
    end
end

load_access()
