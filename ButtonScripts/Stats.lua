AIContext.Scripts["Stats"] = function()
    local s = {}
    local stats = {"Str", "Agi", "Sta", "Int", "Spi"}
    for i=1, 5 do
        local base, stat, posBuff, negBuff = UnitStat("player", i)
        table.insert(s, '"'..stats[i]..'":'..stat)
    end
    table.insert(s, '"Hit":'..GetCombatRating(6))
    table.insert(s, '"Expertise":'..GetCombatRating(24))
    table.insert(s, '"Haste":'..GetCombatRating(18))
    table.insert(s, '"SP":'..GetSpellBonusDamage(2))
    table.insert(s, string.format('"ManaRegen":%.2f', GetManaRegen() * 5))
    table.insert(s, string.format('"Crit":%.2f', GetSpellCritChance(2)))
    local _, effectiveArmor = UnitArmor("player")
    table.insert(s, '"Armor":'..effectiveArmor)
    local baseDef, armorDef = UnitDefense("player")
    table.insert(s, '"Defense":'..(baseDef + armorDef))
    table.insert(s, string.format('"Dodge":%.2f', GetDodgeChance()))
    table.insert(s, string.format('"Parry":%.2f', GetParryChance()))
    table.insert(s, string.format('"Block":%.2f', GetBlockChance()))
    table.insert(s, '"Resilience":'..GetCombatRating(15))
    return '{"Stats":{'..table.concat(s, ",")..'}}'
end