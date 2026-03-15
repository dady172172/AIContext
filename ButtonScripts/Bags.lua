AIContext.Scripts["Bags"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local itemCounts = {}
    
    -- Aggregate items by name and count
    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        if numSlots > 0 then
            for slot = 1, numSlots do
                local link = GetContainerItemLink(bag, slot)
                if link then
                    local name = GetItemInfo(link)
                    local _, count = GetContainerItemInfo(bag, slot)
                    if name then
                        if not itemCounts[name] then
                            itemCounts[name] = 0
                        end
                        itemCounts[name] = itemCounts[name] + count
                    end
                end
            end
        end
    end
    
    -- Build JSON object
    local items = {}
    for name, count in pairs(itemCounts) do
        table.insert(items, string.format('"%s":%d', Escape(name), count))
    end
    return '{"Bags":{'..table.concat(items, ",")..'}}'
end
