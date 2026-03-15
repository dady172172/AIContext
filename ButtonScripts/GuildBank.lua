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
            local itemCounts = {}
            if tabData.items then
                for _, item in ipairs(tabData.items) do
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
            
            -- Build items object for this tab
            local tabItems = {}
            for name, count in pairs(itemCounts) do
                table.insert(tabItems, string.format('"%s":%d', Escape(name), count))
            end
            
            table.insert(gbk, string.format('"%s":{%s}', Escape(tabData.name or "Tab"..tab), table.concat(tabItems, ",")))
        end
    else
        table.insert(gbk, '"error":"No guild bank data saved"')
    end
    return '{"GuildBank":{'..table.concat(gbk, ",")..'}}'
end
