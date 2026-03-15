AIContext.Scripts["Recipes"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local db = AIContext.GetDB()
    local tradeName = GetTradeSkillLine()
    if tradeName and tradeName ~= "UNKNOWN" then
        AIContext.ScanProfession()
    end
    
    local r_list = {}
    if db.Recipes then
        for prof, list in pairs(db.Recipes) do
            local p_r = {}
            for _, r in ipairs(list) do table.insert(p_r, '"'..Escape(r)..'"') end
            table.insert(r_list, '"'..prof..'":['..table.concat(p_r, ",")..']')
        end
    end
    
    return '{"Recipes":{'..table.concat(r_list, ",")..'}}'
end
