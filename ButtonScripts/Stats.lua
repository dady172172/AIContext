AIContext.Scripts["Stats"] = function()
    local stats = {}

    -- 1. Vitals
    stats.MaxHealth = UnitHealthMax("player")
    stats.MaxPower = UnitPowerMax("player")

    -- 2. Base Stats (1=Str, 2=Agi, 3=Sta, 4=Int, 5=Spi)
    stats.Str = select(2, UnitStat("player", 1))
    stats.Agi = select(2, UnitStat("player", 2))
    stats.Sta = select(2, UnitStat("player", 3))
    stats.Int = select(2, UnitStat("player", 4))
    stats.Spi = select(2, UnitStat("player", 5))

    -- 3. Melee Stats
    local baseAP, posBuffAP, negBuffAP = UnitAttackPower("player")
    stats.MeleeAP = baseAP + posBuffAP + negBuffAP
    stats.ArmorPen = GetArmorPenetration()
    stats.MeleeHit = GetCombatRating(6)
    stats.MeleeCrit = math.floor(GetCritChance() * 100) / 100
    stats.MeleeHaste = GetCombatRating(18)
    stats.Expertise = GetExpertise()

    -- 4. Ranged Stats
    local baseRAP, posBuffRAP, negBuffRAP = UnitRangedAttackPower("player")
    stats.RangedAP = baseRAP + posBuffRAP + negBuffRAP
    stats.RangedHit = GetCombatRating(7)
    stats.RangedCrit = math.floor(GetRangedCritChance() * 100) / 100
    stats.RangedHaste = GetCombatRating(19)

    -- 5. Spell Stats
    -- Loops through magic schools to find the highest Spell Power value
    local maxSpellPower = 0
    for i=1, 7 do
        local sp = GetSpellBonusDamage(i)
        if sp > maxSpellPower then maxSpellPower = sp end
    end
    stats.SpellPower = maxSpellPower
    stats.BonusHealing = GetSpellBonusHealing()
    stats.SpellHit = GetCombatRating(8)
    -- Loop through magic schools to find the highest Spell Crit (2=Holy, 3=Fire, 4=Nature, 5=Frost, 6=Shadow, 7=Arcane)
    local maxSpellCrit = 0
    for i=2, 7 do
        local crit = GetSpellCritChance(i)
        if crit > maxSpellCrit then maxSpellCrit = crit end
    end
    stats.SpellCrit = math.floor(maxSpellCrit * 100) / 100
    stats.SpellHaste = GetCombatRating(20)
    stats.SpellPen = GetSpellPenetration()
    
    local baseRegen, castingRegen = GetManaRegen()
    -- GetManaRegen returns per 1 second, multiply by 5 for the standard MP5 stat
    stats.ManaRegenBase = math.floor(baseRegen * 5)
    stats.ManaRegenCasting = math.floor(castingRegen * 5)

    -- 6. Defenses
    local _, effectiveArmor = UnitArmor("player")
    stats.Armor = effectiveArmor
    local baseDef, armorDef = UnitDefense("player")
    stats.Defense = math.floor(baseDef + armorDef)
    stats.Dodge = math.floor(GetDodgeChance() * 100) / 100
    stats.Parry = math.floor(GetParryChance() * 100) / 100
    stats.Block = math.floor(GetBlockChance() * 100) / 100
    stats.Resilience = GetCombatRating(15)

    -- 7. Resistances (2=Fire, 3=Nature, 4=Frost, 5=Shadow, 6=Arcane)
    stats.ResistFire = select(2, UnitResistance("player", 2))
    stats.ResistNature = select(2, UnitResistance("player", 3))
    stats.ResistFrost = select(2, UnitResistance("player", 4))
    stats.ResistShadow = select(2, UnitResistance("player", 5))
    stats.ResistArcane = select(2, UnitResistance("player", 6))

    -- Format everything into JSON
    local jsonParts = {}
    for k, v in pairs(stats) do
        table.insert(jsonParts, string.format('"%s":%s', k, tostring(v)))
    end

    return '{"Stats":{' .. table.concat(jsonParts, ",") .. '}}'
end