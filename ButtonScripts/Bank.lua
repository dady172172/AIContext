AIContext.Scripts["Bank"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local db = AIContext.GetDB() 
    local bankFrame = _G["BankFrame"]
    if bankFrame and bankFrame:IsShown() then
        AIContext.ScanBank()
    end
    
    local itemCounts = {}
    
    -- Aggregate bank items by name and count
    if db.Bank and #db.Bank > 0 then
        for _, item in ipairs(db.Bank) do
            if item.link then
                local name = GetItemInfo(item.link)
                if name then
                    if not itemCounts[name] then
                        itemCounts[name] = 0
                    end
                    itemCounts[name] = itemCounts[name] + (item.count or 1)
                end
            end
        end
    end
    
    -- Build JSON object
    local items = {}
    for name, count in pairs(itemCounts) do
        table.insert(items, string.format('"%s":%d', Escape(name), count))
    end
    return '{"Bank":{'..table.concat(items, ",")..'}}'
end
