AIContext.Scripts["KeyRing"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local items = {}
    local bag = -2
    local numSlots = GetContainerNumSlots(bag)
    if numSlots > 0 then
        for slot = 1, numSlots do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local itemName = GetItemInfo(link)
                if itemName then
                    table.insert(items, string.format('"%s"', Escape(itemName)))
                end
            end
        end
    end
    return '{"KeyRing":['..table.concat(items, ",")..']}'
end