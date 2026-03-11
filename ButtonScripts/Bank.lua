AIContext.Scripts["Bank"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local db = AIContext.GetDB() 
    local bankFrame = _G["BankFrame"]
    if bankFrame and bankFrame:IsShown() then
        AIContext.ScanBank()
    end
    
    local items = {}
    if db.Bank and #db.Bank > 0 then
        for _, item in ipairs(db.Bank) do
            table.insert(items, string.format('{"b":%d,"s":%d,"i":"%s","c":%d}', item.bag, item.slot, Escape(item.link), item.count))
        end
    end
    return '{"Bank":{'..table.concat(items, ",")..'}}'
end