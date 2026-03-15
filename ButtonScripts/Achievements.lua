AIContext.Scripts["Achievements"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local ach = {}
    local categories = GetCategoryList()
    for _, catId in ipairs(categories) do
        local numAch = GetCategoryNumAchievements(catId)
        for i=1, numAch do
            local id, name, points, completed = GetAchievementInfo(catId, i)
            if completed then
                table.insert(ach, '"'..Escape(name)..'"')
            end
        end
    end
    return '{"Achievements":['..table.concat(ach, ",")..']}'
end
