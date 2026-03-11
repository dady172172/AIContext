AIContext.Scripts["KeyRing"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local items = {}
    local bag = -2
    local numSlots = GetContainerNumSlots(bag)
    if numSlots > 0 then
        for slot = 1, numSlots do
            local link = GetContainerItemLink(bag, slot)
            if link then
                table.insert(items, string.format('"%d":"%s"', slot, Escape(link)))
            end
        end
    end
    return '{"KeyRing":{'..table.concat(items, ",")..'}}'
end