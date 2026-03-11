AIContext.Scripts["GuildBank"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local db = AIContext.GetDB() 
    local guildBankFrame = _G["GuildBankFrame"]
    if guildBankFrame and guildBankFrame:IsShown() then
        AIContext.ScanGuildBank()
    end
    
    local gbk = {}
    if db.GuildBank and next(db.GuildBank) then
        for tab, tabData in pairs(db.GuildBank) do
            local tabItems = {}
            if tabData.items then
                for _, item in ipairs(tabData.items) do
                    table.insert(tabItems, string.format('{"s":%d,"i":"%s","c":%d}', item.slot, Escape(item.link), item.count))
                end
            end
            table.insert(gbk, string.format('"Tab%d":{"n":"%s","i":[%s]}', tab, Escape(tabData.name or ""), table.concat(tabItems, ",")))
        end
    else
        table.insert(gbk, '"error":"No guild bank data saved"')
    end
    return '{"GuildBank":{'..table.concat(gbk, ",")..'}}'
end
