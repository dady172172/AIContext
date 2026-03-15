AIContext.Scripts["Skills"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local skills = {}
    local numSkills = GetNumSkillLines()
    for i=1, numSkills do
        local skillName, header, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
        if not header then
            table.insert(skills, string.format('"%s":"%d/%d"', Escape(skillName), skillRank, skillMaxRank))
        end
    end
    return '{"Skills":{'..table.concat(skills, ",")..'}}'
end