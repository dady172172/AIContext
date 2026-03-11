AIContext.Scripts["Equipment"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local g = {}
    for i=1, 19 do
        local link = GetInventoryItemLink("player", i)
        if link then
            table.insert(g, string.format('"%d":"%s"', i, Escape(link)))
        end
    end
    return '{"Equipment":{'..table.concat(g, ",")..'}}'
end