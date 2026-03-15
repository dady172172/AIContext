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

    -- STATS (Enhanced from Stats.lua)
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
    stats.ArmorPen = GetArmorPenetration() or 0
    stats.MeleeHit = GetCombatRating(6)
    stats.MeleeCrit = math.floor(GetCritChance() * 100) / 100
    stats.MeleeHaste = GetCombatRating(18)
    stats.Expertise = GetExpertise() or 0
    
    -- 4. Ranged Stats
    local baseRAP, posBuffRAP, negBuffRAP = UnitRangedAttackPower("player")
    stats.RangedAP = baseRAP + posBuffRAP + negBuffRAP
    stats.RangedHit = GetCombatRating(7)
    stats.RangedCrit = math.floor(GetRangedCritChance() * 100) / 100
    stats.RangedHaste = GetCombatRating(19)
    
    -- 5. Spell Stats
    local maxSpellPower = 0
    for i=1, 7 do
        local sp = GetSpellBonusDamage(i)
        if sp > maxSpellPower then maxSpellPower = sp end
    end
    stats.SpellPower = maxSpellPower
    stats.BonusHealing = GetSpellBonusHealing() or 0
    stats.SpellHit = GetCombatRating(8)
    -- Loop through magic schools to find the highest Spell Crit (2=Holy, 3=Fire, 4=Nature, 5=Frost, 6=Shadow, 7=Arcane)
    local maxSpellCrit = 0
    for i=2, 7 do
        local crit = GetSpellCritChance(i)
        if crit > maxSpellCrit then maxSpellCrit = crit end
    end
    stats.SpellCrit = math.floor(maxSpellCrit * 100) / 100
    stats.SpellHaste = GetCombatRating(20)
    stats.SpellPen = GetSpellPenetration() or 0
    
    local baseRegen, castingRegen = GetManaRegen()
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
    stats.ResistFire = select(2, UnitResistance("player", 2)) or 0
    stats.ResistNature = select(2, UnitResistance("player", 3)) or 0
    stats.ResistFrost = select(2, UnitResistance("player", 4)) or 0
    stats.ResistShadow = select(2, UnitResistance("player", 5)) or 0
    stats.ResistArcane = select(2, UnitResistance("player", 6)) or 0
    
    -- Format stats into JSON
    local s = {}
    for k, v in pairs(stats) do
        table.insert(s, string.format('"%s":%s', k, tostring(v)))
    end
    table.insert(parts, '"Stats":{' .. table.concat(s, ",") .. '}')

    -- GEAR (Enhanced with item ID, stats, enchantments, sockets)
    local function GetReadableStatName(internalName)
        local statNameMap = {
            ["ITEM_MOD_STRENGTH_SHORT"] = "Strength",
            ["ITEM_MOD_AGILITY_SHORT"] = "Agility",
            ["ITEM_MOD_STAMINA_SHORT"] = "Stamina",
            ["ITEM_MOD_INTELLECT_SHORT"] = "Intellect",
            ["ITEM_MOD_SPIRIT_SHORT"] = "Spirit",
            ["STRENGTH"] = "Strength",
            ["AGILITY"] = "Agility",
            ["STAMINA"] = "Stamina",
            ["INTELLECT"] = "Intellect",
            ["SPIRIT"] = "Spirit",
            ["ITEM_MOD_CR_DEFENSE_SKILL_SHORT"] = "Defense",
            ["ITEM_MOD_DODGE_RATING_SHORT"] = "Dodge",
            ["ITEM_MOD_PARRY_RATING_SHORT"] = "Parry",
            ["ITEM_MOD_BLOCK_RATING_SHORT"] = "Block",
            ["ITEM_MOD_BLOCK_VALUE_SHORT"] = "Block Value",
            ["ITEM_MOD_HIT_RATING_SHORT"] = "Hit",
            ["ITEM_MOD_CRIT_RATING_SHORT"] = "Crit",
            ["ITEM_MOD_HASTE_RATING_SHORT"] = "Haste",
            ["ITEM_MOD_EXPERTISE_RATING_SHORT"] = "Expertise",
            ["ITEM_MOD_SPELL_POWER_SHORT"] = "Spell Power",
            ["ITEM_MOD_ATTACK_POWER_SHORT"] = "Attack Power",
            ["ARMOR"] = "Armor",
            ["ARMOR_BONUS"] = "Armor",
            ["ITEM_MOD_RESISTANCE_FIRE_SHORT"] = "Fire Resistance",
            ["ITEM_MOD_RESISTANCE_NATURE_SHORT"] = "Nature Resistance",
            ["ITEM_MOD_RESISTANCE_FROST_SHORT"] = "Frost Resistance",
            ["ITEM_MOD_RESISTANCE_SHADOW_SHORT"] = "Shadow Resistance",
            ["ITEM_MOD_RESISTANCE_ARCANE_SHORT"] = "Arcane Resistance",
            ["ITEM_MOD_HEALTH_SHORT"] = "Health",
            ["ITEM_MOD_MANA_SHORT"] = "Mana",
            ["ITEM_MOD_RESILIENCE_RATING_SHORT"] = "Resilience",
        }
        if statNameMap[internalName] then return statNameMap[internalName] end
        local readable = string.gsub(internalName, "ITEM_MOD_", "")
        readable = string.gsub(readable, "_", " ")
        readable = string.gsub(readable, " SHORT$", "")
        return readable
    end
    local function GetItemDetailsForAIData(link, slot)
        if not link then return nil end
        local itemID = tonumber(string.match(link, "item:(%d+)"))
        if not itemID then return nil end
        local details = {
            itemID = itemID,
            link = link,
            name = nil,
            rarity = nil,
            itemLevel = nil,
            slot = nil,
            durability = nil,
            stats = {},
            enchant = nil,
            sockets = {}
        }
        local enchantID, gem1, gem2, gem3, gem4 = string.match(link, "item:%d+:(%d+):(%d+):(%d+):(%d+):(%d+)")
        enchantID = tonumber(enchantID)
        
        -- Get item info for name, rarity, item level
        local itemName, _, itemRarity, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(link)
        if itemName then details.name = itemName end
        if itemRarity then details.rarity = itemRarity end
        if itemLevel then details.itemLevel = itemLevel end
        if itemEquipLoc then details.slot = itemEquipLoc end
        
        -- Get durability for this slot
        if slot then
            local currentDurability, maxDurability = GetInventoryItemDurability(slot)
            if currentDurability and maxDurability and maxDurability > 0 then
                details.durability = {current = currentDurability, max = maxDurability}
            end
        end
        
        local itemStats = GetItemStats(link)
        if itemStats then
            for stat, value in pairs(itemStats) do
                local readableName = GetReadableStatName(stat)
                table.insert(details.stats, {name = readableName, value = value, internal = stat})
            end
        end
        if enchantID and enchantID > 0 then
            local knownEnchantStats = {
                ["+7 Stamina"] = true, ["+10 Stats"] = true, ["+12 Stamina"] = true, ["+20 Stamina"] = true,
                ["+22 Stamina"] = true, ["+23 Stamina"] = true, ["+30 Stamina"] = true, ["+37 Stamina"] = true,
                ["+40 Stamina"] = true, ["+41 Stamina"] = true, ["+8 Agility"] = true, ["+10 Agility"] = true,
                ["+12 Agility"] = true, ["+15 Agility"] = true, ["+16 Agility"] = true, ["+18 Agility"] = true,
                ["+20 Agility"] = true, ["+22 Agility"] = true, ["+25 Agility"] = true, ["+26 Agility"] = true,
                ["+30 Agility"] = true, ["+35 Agility"] = true, ["+36 Agility"] = true, ["+37 Agility"] = true,
                ["+40 Agility"] = true, ["+41 Agility"] = true, ["+44 Agility"] = true, ["+45 Agility"] = true,
                ["+50 Agility"] = true, ["+8 Strength"] = true, ["+10 Strength"] = true, ["+12 Strength"] = true,
                ["+15 Strength"] = true, ["+16 Strength"] = true, ["+20 Strength"] = true, ["+22 Strength"] = true,
                ["+25 Strength"] = true, ["+30 Strength"] = true, ["+35 Strength"] = true, ["+37 Strength"] = true,
                ["+40 Strength"] = true, ["+41 Strength"] = true, ["+44 Strength"] = true, ["+45 Strength"] = true,
                ["+50 Strength"] = true, ["+8 Intellect"] = true, ["+10 Intellect"] = true, ["+12 Intellect"] = true,
                ["+15 Intellect"] = true, ["+20 Intellect"] = true, ["+22 Intellect"] = true, ["+25 Intellect"] = true,
                ["+30 Intellect"] = true, ["+35 Intellect"] = true, ["+37 Intellect"] = true, ["+40 Intellect"] = true,
                ["+41 Intellect"] = true, ["+44 Intellect"] = true, ["+45 Intellect"] = true, ["+50 Intellect"] = true,
                ["+8 Spirit"] = true, ["+10 Spirit"] = true, ["+12 Spirit"] = true, ["+20 Spirit"] = true,
                ["+22 Spirit"] = true, ["+25 Spirit"] = true, ["+30 Spirit"] = true, ["+35 Spirit"] = true,
                ["+37 Spirit"] = true, ["+40 Spirit"] = true, ["+41 Spirit"] = true, ["+44 Spirit"] = true,
                ["+45 Spirit"] = true, ["+50 Spirit"] = true
            }
            local enchantStatsList = {}
            if itemStats then
                for stat, value in pairs(itemStats) do
                    if knownEnchantStats[stat] then
                        table.insert(enchantStatsList, {name = stat, value = value})
                    end
                end
            end
            if #enchantStatsList > 0 or enchantID then
                details.enchant = {id = enchantID, stats = enchantStatsList}
            end
        end
        local gems = {tonumber(gem1) or 0, tonumber(gem2) or 0, tonumber(gem3) or 0, tonumber(gem4) or 0}
        for i, gemID in ipairs(gems) do
            if gemID and gemID > 0 then
                local socketInfo = {gemID = gemID}
                local gemName = GetItemInfo(gemID)
                if gemName then
                    socketInfo.name = gemName
                    local lowerName = string.lower(gemName)
                    if string.find(lowerName, "meta") then socketInfo.color = "meta"
                    elseif string.find(lowerName, "prismatic") then socketInfo.color = "prismatic"
                    elseif string.find(lowerName, "ruby") or string.find(lowerName, "red") then socketInfo.color = "red"
                    elseif string.find(lowerName, "sapphire") or string.find(lowerName, "blue") then socketInfo.color = "blue"
                    elseif string.find(lowerName, "emerald") or string.find(lowerName, "green") then socketInfo.color = "green"
                    elseif string.find(lowerName, "topaz") or string.find(lowerName, "yellow") then socketInfo.color = "yellow"
                    elseif string.find(lowerName, "amethyst") or string.find(lowerName, "purple") then socketInfo.color = "purple"
                    elseif string.find(lowerName, "cobalt") then socketInfo.color = "cobalt"
                    elseif string.find(lowerName, "twilight") then socketInfo.color = "twilight"
                    elseif string.find(lowerName, "autumn") then socketInfo.color = "autumn"
                    elseif string.find(lowerName, "forest") then socketInfo.color = "forest"
                    elseif string.find(lowerName, "dragon's eye") then socketInfo.color = "prismatic"
                    end
                end
                local gemLink = select(2, GetItemInfo(gemID))
                if gemLink then
                    local gemStats = GetItemStats(gemLink)
                    if gemStats then
                        local gemStatsList = {}
                        for stat, value in pairs(gemStats) do
                            table.insert(gemStatsList, {name = stat, value = value})
                        end
                        if #gemStatsList > 0 then socketInfo.stats = gemStatsList end
                    end
                end
                table.insert(details.sockets, socketInfo)
            end
        end
        return details
    end
    local g = {}
    for i=1, 19 do
        local link = GetInventoryItemLink("player", i)
        if link then
            local details = GetItemDetailsForAIData(link, i)
            if details then
                local slotData = {}
                table.insert(slotData, '"id":' .. details.itemID)
                table.insert(slotData, '"link":"' .. Escape(details.link) .. '"')
                if details.name then
                    table.insert(slotData, '"name":"' .. Escape(details.name) .. '"')
                end
                if details.rarity then
                    table.insert(slotData, '"rarity":' .. details.rarity)
                end
                if details.itemLevel then
                    table.insert(slotData, '"iLvl":' .. details.itemLevel)
                end
                if details.slot then
                    table.insert(slotData, '"slot":"' .. details.slot .. '"')
                end
                if details.durability then
                    table.insert(slotData, '"durability":[' .. details.durability.current .. ',' .. details.durability.max .. ']')
                end
                if details.stats and #details.stats > 0 then
                    local statsList = {}
                    for _, stat in ipairs(details.stats) do
                        table.insert(statsList, '"' .. Escape(stat.name) .. '":' .. stat.value)
                    end
                    table.insert(slotData, '"stats":{' .. table.concat(statsList, ',') .. '}')
                else
                    table.insert(slotData, '"stats":{}')
                end
                if details.enchant then
                    local enchantParts = {}
                    if details.enchant.id then table.insert(enchantParts, '"id":' .. details.enchant.id) end
                    if details.enchant.stats and #details.enchant.stats > 0 then
                        local enchantStatsList = {}
                        for _, stat in ipairs(details.enchant.stats) do
                            table.insert(enchantStatsList, '"' .. Escape(stat.name) .. '":' .. stat.value)
                        end
                        table.insert(enchantParts, '"stats":{' .. table.concat(enchantStatsList, ',') .. '}')
                    end
                    table.insert(slotData, '"enchant":{' .. table.concat(enchantParts, ',') .. '}')
                else
                    table.insert(slotData, '"enchant":null')
                end
                if details.sockets and #details.sockets > 0 then
                    local socketsList = {}
                    for _, socket in ipairs(details.sockets) do
                        local socketParts = {}
                        if socket.gemID then table.insert(socketParts, '"id":' .. socket.gemID) end
                        if socket.name then table.insert(socketParts, '"name":"' .. Escape(socket.name) .. '"') end
                        if socket.color then table.insert(socketParts, '"color":"' .. socket.color .. '"') end
                        if socket.stats and #socket.stats > 0 then
                            local socketStatsList = {}
                            for _, stat in ipairs(socket.stats) do
                                table.insert(socketStatsList, '"' .. Escape(stat.name) .. '":' .. stat.value)
                            end
                            table.insert(socketParts, '"stats":{' .. table.concat(socketStatsList, ',') .. '}')
                        end
                        table.insert(socketsList, '{' .. table.concat(socketParts, ',') .. '}')
                    end
                    table.insert(slotData, '"sockets":[' .. table.concat(socketsList, ',') .. ']')
                else
                    table.insert(slotData, '"sockets":[]')
                end
                table.insert(g, string.format('"%d":{%s}', i, table.concat(slotData, ',')))
            else
                table.insert(g, string.format('"%d":"%s"', i, Escape(link)))
            end
        end
    end
    table.insert(parts, '"Gear":{'..table.concat(g, ",")..'}')

    -- BAGS
    local bagsResult = AIContext.Scripts["Bags"]()
    local bagsMatch = string.match(bagsResult, '"Bags":{%w*')
    if bagsMatch then
        table.insert(parts, string.match(bagsResult, '"Bags":.*'))
    end
    
    -- KEYRING
    local keyring = {}
    local keyringBag = -2
    local keyringSlots = GetContainerNumSlots(keyringBag)
    if keyringSlots > 0 then
        for slot=1, keyringSlots do
            local link = GetContainerItemLink(keyringBag, slot)
            if link then
                local itemName = GetItemInfo(link)
                if itemName then
                    table.insert(keyring, string.format('"%s"', Escape(itemName)))
                end
            end
        end
    end
    table.insert(parts, '"KeyRing":['..table.concat(keyring, ",")..']')

    -- BANK
    local bankResult = AIContext.Scripts["Bank"]()
    local bankMatch = string.match(bankResult, '"Bank":{%w*')
    if bankMatch then
        table.insert(parts, string.match(bankResult, '"Bank":.*'))
    end

    -- GUILD BANK
    local gbkResult = AIContext.Scripts["GuildBank"]()
    local gbkMatch = string.match(gbkResult, '"GuildBank":.*')
    if gbkMatch then
        table.insert(parts, string.match(gbkResult, '"GuildBank":.*'))
    end

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
        local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
        if not isHeader then
            table.insert(skills, string.format('"%s":"%d/%d"', Escape(skillName), skillRank, skillMaxRank))
        end
    end
    table.insert(parts, '"Skills":{'..table.concat(skills, ",")..'}')

    -- SPELLS
    local spellsResult = AIContext.Scripts["Spells"]()
    local spellsMatch = string.match(spellsResult, '"Spells":%[%w*')
    if spellsMatch then
        table.insert(parts, string.match(spellsResult, '"Spells":.*'))
    end

    -- TALENTS
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
    table.insert(parts, '"Talents":{'..table.concat(tal, ",")..'}')

    -- GLYPHS
    local gly = {}
    for i=1, 6 do
        local enabled, glyphType, glyphSpellID, icon = GetGlyphSocketInfo(i) 
        if enabled then
            if glyphSpellID then
                local name = GetSpellInfo(glyphSpellID)
                if name then table.insert(gly, string.format('"%s"', Escape(name))) end
            else
                table.insert(gly, '"Empty"')
            end
        end
    end
    table.insert(parts, '"Glyphs":['..table.concat(gly, ",")..']')

    -- MOUNTS
    local mnt = {}
    for i=1, GetNumCompanions("MOUNT") do
         local _, name, _, _, isSummoned = GetCompanionInfo("MOUNT", i)
         table.insert(mnt, string.format('"%s"', Escape(name or "Unknown Mount")))
    end
    table.insert(parts, '"Mounts":['..table.concat(mnt, ",")..']')

    -- PETS
    local pts = {}
    for i=1, GetNumCompanions("CRITTER") do
         local _, name, _, _, isSummoned = GetCompanionInfo("CRITTER", i)
         table.insert(pts, string.format('"%s"', Escape(name or "Unknown Pet")))
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
            table.insert(rep, string.format('"%s":"%s %d/%d"', Escape(name), standings[standingID] or "Neutral", current, max))
        end
    end
    table.insert(parts, '"Reputation":{'..table.concat(rep, ",")..'}')

    -- RECIPES
    local recipesResult = AIContext.Scripts["Recipes"]()
    local recipesMatch = string.match(recipesResult, '"Recipes":{%w*')
    if recipesMatch then
        table.insert(parts, string.match(recipesResult, '"Recipes":.*'))
    end

    -- QUESTS
    local q_list = {}
    ExpandQuestHeader(0)
    local numEntries = GetNumQuestLogEntries()
    for i = 1, numEntries do
        local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)
        if not isHeader then
            local safeTitle = string.gsub(title or "", '"', '\\"')
            local statusText = ""
            
            if isComplete == 1 then
                statusText = " (Complete)"
            elseif isComplete == -1 then
                statusText = " (Failed)"
            else
                local numObjectives = GetNumQuestLeaderBoards(i)
                if numObjectives and numObjectives > 0 then
                    local objList = {}
                    for j = 1, numObjectives do
                        local objText, objType, objFinished = GetQuestLogLeaderBoard(j, i)
                        if objText then
                            local safeObjText = string.gsub(objText, '"', '\\"')
                            table.insert(objList, safeObjText)
                        end
                    end
                    if #objList > 0 then
                        statusText = " (" .. table.concat(objList, ", ") .. ")"
                    end
                end
            end
            
            local formattedQuest = string.format('"[%d] %s%s"', level, safeTitle, statusText)
            table.insert(q_list, formattedQuest)
        end
    end
    table.insert(parts, '"Quests":['..table.concat(q_list, ",")..']')

    -- ADDONS
    local addonsResult = AIContext.Scripts["Addons"]()
    local addonsMatch = string.match(addonsResult, '"Addons":%[%w*')
    if addonsMatch then
        table.insert(parts, string.match(addonsResult, '"Addons":.*'))
    end

    -- ACHIEVEMENTS
    local achResult = AIContext.Scripts["Achievements"]()
    local achMatch = string.match(achResult, '"Achievements":%[%w*')
    if achMatch then
        table.insert(parts, string.match(achResult, '"Achievements":.*'))
    end

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