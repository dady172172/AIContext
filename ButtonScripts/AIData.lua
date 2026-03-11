AIContext.Scripts["AI"] = function()
    -- 1. Helper Functions
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local parts = {}
    
    -- 2. Database & Live Scanning
    local db = AIContext.GetDB() 
    
    if _G["BankFrame"] and _G["BankFrame"]:IsShown() then
        AIContext.ScanBank()
    end

    if GetTradeSkillLine() and GetTradeSkillLine() ~= "UNKNOWN" then
        AIContext.ScanProfession()
    end

    -- =========================================================
    -- 3. DATA COLLECTION
    -- =========================================================

    -- INFO
    SetMapToCurrentZone()
    local zone = GetRealZoneText() or "Unknown"
    local subzone = GetMinimapZoneText() or ""
    if subzone == "" then subzone = zone end
    local px, py = GetPlayerMapPosition("player")
    local coords = (px and py) and string.format("%.1f,%.1f", px*100, py*100) or "0,0"
    local totalCopper = GetMoney()
    local gold = floor(totalCopper / 10000)
    local silver = floor((totalCopper % 10000) / 100)
    local copper = totalCopper % 100
    table.insert(parts, string.format('"Info":{"Name":"%s","Lvl":%d,"Class":"%s","Race":"%s","Realm":"%s","Zone":"%s","SubZone":"%s","Loc":"%s","Gold":%d,"Silver":%d,"Copper":%d}', 
        UnitName("player"), UnitLevel("player"), select(2,UnitClass("player")), select(2,UnitRace("player")), GetRealmName(), zone, subzone, coords, gold, silver, copper))

    -- STATS
    local s = {}
    table.insert(s, '"Str":'..UnitStat("player", 1))
    table.insert(s, '"Agi":'..UnitStat("player", 2))
    table.insert(s, '"Sta":'..UnitStat("player", 3))
    table.insert(s, '"Int":'..UnitStat("player", 4))
    table.insert(s, '"Spi":'..UnitStat("player", 5))
    table.insert(s, '"SP":'..GetSpellBonusDamage(2))
    table.insert(s, string.format('"Crit":%.2f', GetSpellCritChance(2)))
    table.insert(s, '"Haste":'..GetCombatRating(18))
    table.insert(s, '"Hit":'..GetCombatRating(6))
    table.insert(s, '"Expertise":'..GetCombatRating(24))
    table.insert(s, string.format('"ManaRegen":%.2f', GetManaRegen() * 5))
    local _, effectiveArmor = UnitArmor("player")
    table.insert(s, '"Armor":'..effectiveArmor)
    local baseDef, armorDef = UnitDefense("player")
    table.insert(s, '"Defense":'..(baseDef + armorDef))
    table.insert(s, string.format('"Dodge":%.2f', GetDodgeChance()))
    table.insert(s, string.format('"Parry":%.2f', GetParryChance()))
    table.insert(s, string.format('"Block":%.2f', GetBlockChance()))
    table.insert(s, '"Resilience":'..GetCombatRating(15))
    table.insert(parts, '"Stats":{'..table.concat(s, ",")..'}')

    -- GEAR
    local g = {}
    for i=1, 19 do
        local l = GetInventoryItemLink("player", i)
        if l then table.insert(g, string.format('"%d":"%s"', i, Escape(l))) end
    end
    table.insert(parts, '"Gear":{'..table.concat(g, ",")..'}')

    -- INVENTORY (Bags 0-4 + KeyRing -2 + Saved Bank + Saved Guild Bank)
    local inv = {}
    -- Scan Bags 0-4 and KeyRing -2
    local bagsToScan = {0, 1, 2, 3, 4, -2}
    for _, bag in ipairs(bagsToScan) do
        for slot=1,GetContainerNumSlots(bag) do
            local l = GetContainerItemLink(bag, slot)
            if l then 
                local _, c = GetContainerItemInfo(bag, slot)
                table.insert(inv, string.format('"%s":%d', Escape(l), c or 1))
            end
        end
    end
    -- Add Saved Bank Items
    if db.Bank then
        for _, v in ipairs(db.Bank) do
             table.insert(inv, string.format('"%s":%d', Escape(v.link), v.count or 1))
        end
    end
    table.insert(parts, '"Inv":{'..table.concat(inv, ",")..'}')

    -- GUILD BANK
    local gbk = {}
    if db.GuildBank then
        for tab, tabData in pairs(db.GuildBank) do
            local tabItems = {}
            if tabData.items then
                for _, item in ipairs(tabData.items) do
                    table.insert(tabItems, string.format('{"s":%d,"i":"%s","c":%d}', item.slot, Escape(item.link), item.count))
                end
            end
            table.insert(gbk, string.format('"Tab%d":{"n":"%s","i":[%s]}', tab, Escape(tabData.name or ""), table.concat(tabItems, ",")))
        end
    end
    table.insert(parts, '"GuildBank":{'..table.concat(gbk, ",")..'}')

    -- CURRENCY
    local curr = {}
    for i=1, GetCurrencyListSize() do
        local name, isHeader, _, _, _, count = GetCurrencyListInfo(i)
        if not isHeader and count > 0 then
            table.insert(curr, string.format('"%s":%d', Escape(name), count))
        end
    end
    table.insert(parts, '"Currency":{'..table.concat(curr, ",")..'}')

    -- SKILLS
    local skills = {}
    for i=1, GetNumSkillLines() do
        local skillName, isHeader, _, skillRank = GetSkillLineInfo(i)
        if not isHeader then
            table.insert(skills, string.format('"%s":%d', Escape(skillName), skillRank))
        end
    end
    table.insert(parts, '"Skills":{'..table.concat(skills, ",")..'}')

    -- SPELLS
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
    table.insert(parts, '"Spells":['..table.concat(spells, ",")..']')

    -- TALENTS
    local tal = {}
    for t=1, GetNumTalentTabs() do
        local tabName, _, pointsSpent = GetTalentTabInfo(t)
        local t_build = {}
        for i=1, GetNumTalents(t) do
            local name, _, _, _, rank, maxRank = GetTalentInfo(t, i)
            if rank > 0 then table.insert(t_build, string.format('"%s":{"r":%d,"m":%d}', Escape(name), rank, maxRank)) end
        end
        table.insert(tal, string.format('"%s":{"pts":%d,"t":{%s}}', Escape(tabName), pointsSpent, table.concat(t_build, ",")))
    end
    table.insert(parts, '"Talents":{'..table.concat(tal, ",")..'}')

    -- GLYPHS
    local gly = {}
    for i=1, 6 do
        local enabled, glyphType, glyphSpellID, icon = GetGlyphSocketInfo(i) 
        if enabled then
            if glyphSpellID then
                local name = GetSpellInfo(glyphSpellID)
                if name then table.insert(gly, string.format('{"s":%d,"n":"%s"}', i, Escape(name))) end
            else
                table.insert(gly, string.format('{"s":%d,"n":"Empty"}', i))
            end
        end
    end
    table.insert(parts, '"Glyphs":['..table.concat(gly, ",")..']')

    -- MOUNTS
    local mnt = {}
    for i=1, GetNumCompanions("MOUNT") do
         local _, name, _, _, isSummoned = GetCompanionInfo("MOUNT", i)
         table.insert(mnt, string.format('{"n":"%s","s":%d}', Escape(name or "Unknown Mount"), isSummoned and 1 or 0))
    end
    table.insert(parts, '"Mounts":['..table.concat(mnt, ",")..']')

    -- PETS
    local pts = {}
    for i=1, GetNumCompanions("CRITTER") do
         local _, name, _, _, isSummoned = GetCompanionInfo("CRITTER", i)
         table.insert(pts, string.format('{"n":"%s","s":%d}', Escape(name or "Unknown Pet"), isSummoned and 1 or 0))
    end
    table.insert(parts, '"Pets":['..table.concat(pts, ",")..']')

    -- REPUTATION
    local rep = {}
    for i=1, GetNumFactions() do
        local name, _, standingID, bottomValue, topValue, earnedValue, _, _, isHeader = GetFactionInfo(i)
        if not isHeader then
            local standings = {[0]="Unknown", [1]="Hated", [2]="Hostile", [3]="Unfriendly", [4]="Neutral", [5]="Friendly", [6]="Honored", [7]="Revered", [8]="Exalted"}
            local current = earnedValue - bottomValue
            local max = topValue - bottomValue
            table.insert(rep, string.format('"%s":{"s":"%s","c":%d,"m":%d}', Escape(name), standings[standingID] or "Neutral", current, max))
        end
    end
    table.insert(parts, '"Reputation":{'..table.concat(rep, ",")..'}')

    -- RECIPES
    local r_list = {}
    if db.Recipes then
        for prof, list in pairs(db.Recipes) do
            local p_r = {}
            for _, r in ipairs(list) do table.insert(p_r, '"'..Escape(r)..'"') end
            table.insert(r_list, '"'..prof..'":['..table.concat(p_r, ",")..']')
        end
    end
    table.insert(parts, '"Recipes":{'..table.concat(r_list, ",")..'}')

    -- PROFESSION SKILLS (Names and Ranks)
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
    table.insert(parts, '"Professions":{'..table.concat(profs, ",")..'}')

    -- QUESTS
    local q_list = {}
    ExpandQuestHeader(0)
    for i=1, GetNumQuestLogEntries() do
        local title, level, _, _, isHeader, _, isComplete = GetQuestLogTitle(i)
        if not isHeader and title then
            local st = (isComplete == 1 and 1) or (isComplete == -1 and -1) or 0
            table.insert(q_list, string.format('{"t":"%s","l":%d,"s":%d}', Escape(title), level, st))
        end
    end
    table.insert(parts, '"Quests":['..table.concat(q_list, ",")..']')

    -- ADDONS (All addons with load status)
    local adds = {}
    for i=1, GetNumAddOns() do
        local name, title, _, loadable, reason, security, _ = GetAddOnInfo(i)
        local loaded = IsAddOnLoaded(i) and 1 or 0
        table.insert(adds, string.format('{"n":"%s","l":%d}', Escape(title or name), loaded))
    end
    table.insert(parts, '"Addons":['..table.concat(adds, ",")..']')

    -- ACHIEVEMENTS (Completed with ID and Points)
    local ach = {}
    local categories = GetCategoryList()
    for _, catId in ipairs(categories) do
        local numAch = GetCategoryNumAchievements(catId)
        for i=1, numAch do
            local id, name, points, completed = GetAchievementInfo(catId, i)
            if completed then
                table.insert(ach, string.format('{"id":%d,"n":"%s","p":%d}', id, Escape(name), points))
            end
        end
    end
    table.insert(parts, '"Achievements":['..table.concat(ach, ",")..']')

    -- PARTY/RAID
    local pr = {}
    local numMembers = GetNumPartyMembers() + GetNumRaidMembers()
    if numMembers > 0 then
        local inRaid = IsInRaid()
        table.insert(pr, '"inRaid":' .. (inRaid and 'true' or 'false'))
        
        local source = inRaid and "raid" or "party"
        local members = {}
        
        for i = 1, numMembers do
            local unit = source .. i
            if UnitExists(unit) then
                local buffs = {}
                for j = 1, 16 do
                    local buff = UnitBuff(unit, j)
                    if not buff then break end
                    table.insert(buffs, '"' .. Escape(buff) .. '"')
                end
                
                local debuffs = {}
                for j = 1, 16 do
                    local debuff = UnitDebuff(unit, j)
                    if not debuff then break end
                    table.insert(debuffs, '"' .. Escape(debuff) .. '"')
                end
                
                local role = UnitGroupRolesAssigned(unit)
                local buffList = #buffs > 0 and '[' .. table.concat(buffs, ',') .. ']' or '[]'
                local debuffList = #debuffs > 0 and '[' .. table.concat(debuffs, ',') .. ']' or '[]'
                
                table.insert(members, string.format(
                    '{"n":"%s","c":"%s","l":%d,"hp":%d,"mhp":%d,"pp":%d,"mpp":%d,"r":"%s","b":%s,"d":%s}',
                    Escape(UnitName(unit) or "Unknown"),
                    select(2, UnitClass(unit)) or "Unknown",
                    UnitLevel(unit) or 0,
                    UnitHealth(unit) or 0,
                    UnitHealthMax(unit) or 0,
                    UnitPower(unit) or 0,
                    UnitPowerMax(unit) or 0,
                    role or "NONE",
                    buffList,
                    debuffList
                ))
            end
        end
        table.insert(pr, '"members":[' .. table.concat(members, ',') .. ']')
    else
        table.insert(pr, '"error":"Not in party or raid"')
    end
    table.insert(parts, '"PartyRaid":{'..table.concat(pr, ",")..'}')

    return "{" .. table.concat(parts, ",") .. "}"
end