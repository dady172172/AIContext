AIContext.Scripts["Quests"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local q_list = {}
    ExpandQuestHeader(0) 
    local numEntries, _ = GetNumQuestLogEntries()
    for i=1, numEntries do
        local title, level, _, _, isHeader, _, isComplete = GetQuestLogTitle(i)
        if not isHeader and title then
            local st = (isComplete == 1 and 1) or (isComplete == -1 and -1) or 0
            table.insert(q_list, string.format('{"t":"%s","l":%d,"s":%d}', Escape(title), level, st))
        end
    end
    return '{"Quests":['..table.concat(q_list, ",")..']}'
end