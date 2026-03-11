AIContext.Scripts["Bags"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local inv = {}
    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        if numSlots > 0 then
            for slot = 1, numSlots do
                local link = GetContainerItemLink(bag, slot)
                if link then
                    local _, count = GetContainerItemInfo(bag, slot)
                    table.insert(inv, string.format('"B%dS%d":"%s"', bag, slot, Escape(link)))
                end
            end
        end
    end
    return '{"Bags":{'..table.concat(inv, ",")..'}}'
end