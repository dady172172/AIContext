AIContext.Scripts["Spells"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local spells = {}
    local i = 1
    while true do
        local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then break end
        if spellRank and spellRank ~= "" then
            table.insert(spells, string.format('"%s (%s)"', Escape(spellName), Escape(spellRank)))
        else
            table.insert(spells, '"'..Escape(spellName)..'"')
        end
        i = i + 1
    end
    return '{"Spells":['..table.concat(spells, ",")..']}'
end