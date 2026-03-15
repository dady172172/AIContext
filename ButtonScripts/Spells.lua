AIContext.Scripts["Spells"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    
    local highestSpells = {}
    local spellList = {}
    local i = 1

    -- Loop through the entire spellbook
    while true do
        local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
        
        -- If we run out of spells, break the loop
        if not spellName then break end
        
        -- We want to extract just the number if it says "Rank X"
        local rankNum = 0
        if spellRank and string.find(spellRank, "Rank") then
            rankNum = tonumber(string.match(spellRank, "%d+")) or 0
        end
        
        -- If we haven't seen this spell yet, OR if this rank is higher than the stored one, update it
        if not highestSpells[spellName] or rankNum > highestSpells[spellName].num then
            highestSpells[spellName] = {
                num = rankNum,
                text = spellRank -- keeps things like "Passive" or "Shapeshift"
            }
        end
        
        i = i + 1
    end

    -- Now, convert our filtered list into the JSON strings
    for name, data in pairs(highestSpells) do
        local safeName = Escape(name)
        local formattedSpell = '"' .. safeName .. '"'
        
        -- If it has a rank number, append it like "Healing Touch (15)"
        if data.num > 0 then
            formattedSpell = string.format('"%s (%d)"', safeName, data.num)
        -- If it has special text like "Passive", append that
        elseif data.text and data.text ~= "" then
            formattedSpell = string.format('"%s (%s)"', safeName, data.text)
        end
        
        table.insert(spellList, formattedSpell)
    end

    -- Combine into the final JSON array
    return '{"Spells":[' .. table.concat(spellList, ",") .. ']}'
end
