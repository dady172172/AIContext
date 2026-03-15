AIContext.Scripts["Talents"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local tal = {}
    for t=1, GetNumTalentTabs() do
        local tabName, _, pointsSpent = GetTalentTabInfo(t)
        local t_build = {}
        for i=1, GetNumTalents(t) do
            local name, _, _, _, rank, maxRank = GetTalentInfo(t, i)
            if rank > 0 then table.insert(t_build, string.format('"%s":%d', Escape(name), rank)) end
        end
        table.insert(tal, string.format('"%s (%d)":{%s}', Escape(tabName), pointsSpent, table.concat(t_build, ",")))
    end
    return '{"Talents":{'..table.concat(tal, ",")..'}}'
end