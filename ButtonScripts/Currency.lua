AIContext.Scripts["Currency"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local curr = {}
    local totalCopper = GetMoney()
    local gold = floor(totalCopper / 10000)
    local silver = floor((totalCopper % 10000) / 100)
    local copper = totalCopper % 100
    table.insert(curr, '"Gold":'..gold..',"Silver":'..silver..',"Copper":'..copper)
    local numCurrency = GetCurrencyListSize()
    for i=1, numCurrency do
        local name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(i)
        if not isHeader then
            table.insert(curr, string.format('"%s":%d', Escape(name), count))
        end
    end
    return '{"Currency":{'..table.concat(curr, ",")..'}}'
end