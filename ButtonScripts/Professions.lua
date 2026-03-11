AIContext.Scripts["Professions"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local db = AIContext.GetDB()
    local tradeName = GetTradeSkillLine()
    if tradeName and tradeName ~= "UNKNOWN" then
        AIContext.ScanProfession()
    end
    
    local profs = {}
    local numSkills = GetNumSkillLines()
    local currentHeader = ""
    for i=1, numSkills do
        local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
        if isHeader then
            currentHeader = skillName
        else
            if currentHeader == "Professions" or currentHeader == "Secondary Skills" then
                table.insert(profs, string.format('"%s":{"r":%d,"m":%d}', Escape(skillName), skillRank, skillMaxRank))
            end
        end
    end
    
    local r_list = {}
    if db.Recipes then
        for prof, list in pairs(db.Recipes) do
            local p_r = {}
            for _, r in ipairs(list) do table.insert(p_r, '"'..Escape(r)..'"') end
            table.insert(r_list, '"'..prof..'":['..table.concat(p_r, ",")..']')
        end
    end
    
    return '{"Professions":{'..table.concat(profs, ",")..'},"Recipes":{'..table.concat(r_list, ",")..'}}'
end