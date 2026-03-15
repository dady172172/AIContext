AIContext.Scripts["Quests"] = function()
    local questList = {}
    ExpandQuestHeader(0)
    local numEntries = GetNumQuestLogEntries()
    
    for i = 1, numEntries do
        -- Get the base quest info
        local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)
        
        -- We skip headers (category names like "Icecrown")
        if not isHeader then
            -- Helper function to escape any random quotes in quest names
            local safeTitle = string.gsub(title or "", '"', '\\"')
            local statusText = ""
            
            -- 1. Check if it's done or failed
            if isComplete == 1 then
                statusText = " (Complete)"
            elseif isComplete == -1 then
                statusText = " (Failed)"
            else
                -- 2. If active, check for objectives
                local numObjectives = GetNumQuestLeaderBoards(i)
                if numObjectives and numObjectives > 0 then
                    local objList = {}
                    
                    for j = 1, numObjectives do
                        -- This returns Blizzard's pre-formatted string like "Boars slain: 4/10"
                        local objText, objType, objFinished = GetQuestLogLeaderBoard(j, i)
                        if objText then
                            -- Escape any weird characters just in case
                            local safeObjText = string.gsub(objText, '"', '\\"')
                            table.insert(objList, safeObjText)
                        end
                    end
                    
                    -- If we found objectives, wrap them in parentheses
                    if #objList > 0 then
                        statusText = " (" .. table.concat(objList, ", ") .. ")"
                    end
                end
            end
            
            -- Glue it all together: "[80] Flame Leviathan Must Die! (Leviathan slain: 0/1)"
            local formattedQuest = string.format('"[%d] %s%s"', level, safeTitle, statusText)
            table.insert(questList, formattedQuest)
        end
    end
    
    -- Combine the array into the final JSON output
    return '{"Quests":[' .. table.concat(questList, ",") .. ']}'
end
