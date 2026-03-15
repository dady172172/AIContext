AIContext.Scripts["Equipment"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    
    -- Translation table for internal stat names to readable format
    local statNameMap = {
        -- Primary stats
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
        -- Combat stats
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
        ["ITEM_MOD_RANGED_ATTACK_POWER_SHORT"] = "Ranged Attack Power",
        ["ITEM_MOD_MANA_REGEN_SHORT"] = "Mana Regen",
        ["ITEM_MOD_MANA_REGEN_INTERRUPT_SHORT"] = "Mana Regen",
        ["ARMOR"] = "Armor",
        ["ARMOR_BONUS"] = "Armor",
        -- Resistances
        ["ITEM_MOD_RESISTANCE_FIRE_SHORT"] = "Fire Resistance",
        ["ITEM_MOD_RESISTANCE_NATURE_SHORT"] = "Nature Resistance",
        ["ITEM_MOD_RESISTANCE_FROST_SHORT"] = "Frost Resistance",
        ["ITEM_MOD_RESISTANCE_SHADOW_SHORT"] = "Shadow Resistance",
        ["ITEM_MOD_RESISTANCE_ARCANE_SHORT"] = "Arcane Resistance",
        -- Other
        ["ITEM_MOD_HEALTH_SHORT"] = "Health",
        ["ITEM_MOD_MANA_SHORT"] = "Mana",
        ["ITEM_MOD_CRITICAL_STRIKE_RATING_SHORT"] = "Crit",
        ["ITEM_MOD_SPEED_SHORT"] = "Speed",
        ["ITEM_MOD_SPELL_PENETRATION_SHORT"] = "Spell Penetration",
        ["ITEM_MOD_RESILIENCE_RATING_SHORT"] = "Resilience",
        -- Enchantment stats
        ["+7 Stamina"] = "+7 Stamina",
        ["+10 Stats"] = "+10 Stats",
        ["+12 Stamina"] = "+12 Stamina",
        ["+20 Stamina"] = "+20 Stamina",
        ["+22 Stamina"] = "+22 Stamina",
        ["+23 Stamina"] = "+23 Stamina",
        ["+30 Stamina"] = "+30 Stamina",
        ["+37 Stamina"] = "+37 Stamina",
        ["+40 Stamina"] = "+40 Stamina",
        ["+41 Stamina"] = "+41 Stamina",
        ["+8 Agility"] = "+8 Agility",
        ["+10 Agility"] = "+10 Agility",
        ["+12 Agility"] = "+12 Agility",
        ["+15 Agility"] = "+15 Agility",
        ["+16 Agility"] = "+16 Agility",
        ["+20 Agility"] = "+20 Agility",
        ["+22 Agility"] = "+22 Agility",
        ["+25 Agility"] = "+25 Agility",
        ["+30 Agility"] = "+30 Agility",
        ["+35 Agility"] = "+35 Agility",
        ["+40 Agility"] = "+40 Agility",
        ["+41 Agility"] = "+41 Agility",
        ["+45 Agility"] = "+45 Agility",
        ["+50 Agility"] = "+50 Agility",
        ["+8 Strength"] = "+8 Strength",
        ["+10 Strength"] = "+10 Strength",
        ["+12 Strength"] = "+12 Strength",
        ["+15 Strength"] = "+15 Strength",
        ["+20 Strength"] = "+20 Strength",
        ["+22 Strength"] = "+22 Strength",
        ["+25 Strength"] = "+25 Strength",
        ["+30 Strength"] = "+30 Strength",
        ["+35 Strength"] = "+35 Strength",
        ["+40 Strength"] = "+40 Strength",
        ["+41 Strength"] = "+41 Strength",
        ["+45 Strength"] = "+45 Strength",
        ["+50 Strength"] = "+50 Strength",
        ["+8 Intellect"] = "+8 Intellect",
        ["+10 Intellect"] = "+10 Intellect",
        ["+12 Intellect"] = "+12 Intellect",
        ["+15 Intellect"] = "+15 Intellect",
        ["+20 Intellect"] = "+20 Intellect",
        ["+22 Intellect"] = "+22 Intellect",
        ["+25 Intellect"] = "+25 Intellect",
        ["+30 Intellect"] = "+30 Intellect",
        ["+35 Intellect"] = "+35 Intellect",
        ["+40 Intellect"] = "+40 Intellect",
        ["+41 Intellect"] = "+41 Intellect",
        ["+45 Intellect"] = "+45 Intellect",
        ["+50 Intellect"] = "+50 Intellect",
        ["+8 Spirit"] = "+8 Spirit",
        ["+10 Spirit"] = "+10 Spirit",
        ["+12 Spirit"] = "+12 Spirit",
        ["+20 Spirit"] = "+20 Spirit",
        ["+22 Spirit"] = "+22 Spirit",
        ["+25 Spirit"] = "+25 Spirit",
        ["+30 Spirit"] = "+30 Spirit",
        ["+35 Spirit"] = "+35 Spirit",
        ["+40 Spirit"] = "+40 Spirit",
        ["+41 Spirit"] = "+41 Spirit",
        ["+45 Spirit"] = "+45 Spirit",
        ["+50 Spirit"] = "+50 Spirit",
        ["+12 Spell Power"] = "+12 Spell Power",
        ["+14 Spell Power"] = "+14 Spell Power",
        ["+15 Spell Power"] = "+15 Spell Power",
        ["+18 Spell Power"] = "+18 Spell Power",
        ["+19 Spell Power"] = "+19 Spell Power",
        ["+20 Spell Power"] = "+20 Spell Power",
        ["+22 Spell Power"] = "+22 Spell Power",
        ["+23 Spell Power"] = "+23 Spell Power",
        ["+24 Spell Power"] = "+24 Spell Power",
        ["+25 Spell Power"] = "+25 Spell Power",
        ["+27 Spell Power"] = "+27 Spell Power",
        ["+28 Spell Power"] = "+28 Spell Power",
        ["+29 Spell Power"] = "+29 Spell Power",
        ["+30 Spell Power"] = "+30 Spell Power",
        ["+31 Spell Power"] = "+31 Spell Power",
        ["+32 Spell Power"] = "+32 Spell Power",
        ["+33 Spell Power"] = "+33 Spell Power",
        ["+34 Spell Power"] = "+34 Spell Power",
        ["+35 Spell Power"] = "+35 Spell Power",
        ["+36 Spell Power"] = "+36 Spell Power",
        ["+37 Spell Power"] = "+37 Spell Power",
        ["+38 Spell Power"] = "+38 Spell Power",
        ["+39 Spell Power"] = "+39 Spell Power",
        ["+40 Spell Power"] = "+40 Spell Power",
        ["+44 Spell Power"] = "+44 Spell Power",
        ["+47 Spell Power"] = "+47 Spell Power",
        ["+50 Spell Power"] = "+50 Spell Power",
        ["+55 Spell Power"] = "+55 Spell Power",
        ["+63 Spell Power"] = "+63 Spell Power",
        ["+70 Spell Power"] = "+70 Spell Power",
        ["+81 Spell Power"] = "+81 Spell Power",
        ["+86 Spell Power"] = "+86 Spell Power",
        ["+100 Spell Power"] = "+100 Spell Power",
        ["+127 Spell Power"] = "+127 Spell Power",
        ["Attack Power"] = "Attack Power",
        ["+22 Attack Power"] = "+22 Attack Power",
        ["+24 Attack Power"] = "+24 Attack Power",
        ["+28 Attack Power"] = "+28 Attack Power",
        ["+40 Attack Power"] = "+40 Attack Power",
        ["+44 Attack Power"] = "+44 Attack Power",
        ["+50 Attack Power"] = "+50 Attack Power",
        ["+52 Attack Power"] = "+52 Attack Power",
        ["+54 Attack Power"] = "+54 Attack Power",
        ["+55 Attack Power"] = "+55 Attack Power",
        ["+56 Attack Power"] = "+56 Attack Power",
        ["+58 Attack Power"] = "+58 Attack Power",
        ["+60 Attack Power"] = "+60 Attack Power",
        ["+70 Attack Power"] = "+70 Attack Power",
        ["+72 Attack Power"] = "+72 Attack Power",
        ["+74 Attack Power"] = "+74 Attack Power",
        ["+76 Attack Power"] = "+76 Attack Power",
        ["+80 Attack Power"] = "+80 Attack Power",
        ["+88 Attack Power"] = "+88 Attack Power",
        ["+90 Attack Power"] = "+90 Attack Power",
        ["+100 Attack Power"] = "+100 Attack Power",
        ["+110 Attack Power"] = "+110 Attack Power",
        ["+120 Attack Power"] = "+120 Attack Power",
        ["+130 Attack Power"] = "+130 Attack Power",
        ["+140 Attack Power"] = "+140 Attack Power",
        ["+150 Attack Power"] = "+150 Attack Power",
        ["+160 Attack Power"] = "+160 Attack Power",
        ["+170 Attack Power"] = "+170 Attack Power",
        ["+180 Attack Power"] = "+180 Attack Power",
        ["+190 Attack Power"] = "+190 Attack Power",
        ["+200 Attack Power"] = "+200 Attack Power",
        ["+1 All"] = "+1 All Stats",
        ["+2 All"] = "+2 All Stats",
        ["+3 All"] = "+3 All Stats",
        ["+4 All"] = "+4 All Stats",
        ["+5 All"] = "+5 All Stats",
        ["+6 All"] = "+6 All Stats",
        ["+7 All"] = "+7 All Stats",
        ["+8 All"] = "+8 All Stats",
        ["+9 All"] = "+9 All Stats",
        ["+10 All"] = "+10 All Stats",
    }
    
    -- Convert internal stat name to readable format
    local function GetReadableStatName(internalName)
        if statNameMap[internalName] then
            return statNameMap[internalName]
        end
        -- Try to extract just the stat name from internal names like "ITEM_MOD_X_SHORT"
        local readable = string.gsub(internalName, "ITEM_MOD_", "")
        readable = string.gsub(readable, "_", " ")
        readable = string.gsub(readable, " SHORT$", "")
        return readable
    end
    
    -- Helper function to parse item link and extract detailed info
    local function GetItemDetails(link)
        if not link then return nil end
        
        -- Extract item ID from link (format: |c|Hitem:itemID:...)
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
        
        -- Get item info for name, rarity, and item level
        local itemName, _, itemRarity, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(link)
        if itemName then details.name = itemName end
        if itemRarity then details.rarity = itemRarity end
        if itemLevel then details.itemLevel = itemLevel end
        if itemEquipLoc then details.slot = itemEquipLoc end
        
        -- Get durability for this slot
        local currentDurability, maxDurability = GetInventoryItemDurability(i)
        if currentDurability and maxDurability and maxDurability > 0 then
            details.durability = {current = currentDurability, max = maxDurability}
        end
        
        -- Parse the item link for enchantments and sockets
        -- Format: item:itemID:enchant:gem1:gem2:gem3:gem4:randomProp:suffix:unique:level:reforge:upgrade
        local enchantID, gem1, gem2, gem3, gem4 = string.match(link, "item:%d+:(%d+):(%d+):(%d+):(%d+):(%d+)")
        enchantID = tonumber(enchantID)
        
        -- Get item stats using GetItemStats
        local itemStats = GetItemStats(link)
        if itemStats then
            for stat, value in pairs(itemStats) do
                local readableName = GetReadableStatName(stat)
                table.insert(details.stats, {name = readableName, value = value, internal = stat})
            end
        end
        
        -- Handle enchantments
        if enchantID and enchantID > 0 then
            local enchantStats = {}
            
            -- GetItemStats should include enchantment stats too
            if itemStats then
                -- Known enchantment stat names
                local enchantStatsToCheck = {
                    "Enchantment - +7 Stamina",
                    "Enchantment - +10 Stats",
                    "Enchantment - +12 Stamina",
                    "Enchantment - +20 Stamina",
                    "Enchantment - +22 Stamina",
                    "Enchantment - +23 Stamina",
                    "Enchantment - +30 Stamina",
                    "Enchantment - +37 Stamina",
                    "Enchantment - +40 Stamina",
                    "Enchantment - +41 Stamina",
                    "Enchantment - +8 Agility",
                    "Enchantment - +10 Agility",
                    "Enchantment - +12 Agility",
                    "Enchantment - +15 Agility",
                    "Enchantment - +16 Agility",
                    "Enchantment - +18 Agility",
                    "Enchantment - +20 Agility",
                    "Enchantment - +22 Agility",
                    "Enchantment - +25 Agility",
                    "Enchantment - +26 Agility",
                    "Enchantment - +30 Agility",
                    "Enchantment - +35 Agility",
                    "Enchantment - +36 Agility",
                    "Enchantment - +37 Agility",
                    "Enchantment - +40 Agility",
                    "Enchantment - +41 Agility",
                    "Enchantment - +44 Agility",
                    "Enchantment - +45 Agility",
                    "Enchantment - +50 Agility",
                    "Enchantment - +8 Strength",
                    "Enchantment - +10 Strength",
                    "Enchantment - +12 Strength",
                    "Enchantment - +15 Strength",
                    "Enchantment - +16 Strength",
                    "Enchantment - +20 Strength",
                    "Enchantment - +22 Strength",
                    "Enchantment - +25 Strength",
                    "Enchantment - +30 Strength",
                    "Enchantment - +35 Strength",
                    "Enchantment - +37 Strength",
                    "Enchantment - +40 Strength",
                    "Enchantment - +41 Strength",
                    "Enchantment - +44 Strength",
                    "Enchantment - +45 Strength",
                    "Enchantment - +50 Strength",
                    "Enchantment - +8 Intellect",
                    "Enchantment - +10 Intellect",
                    "Enchantment - +12 Intellect",
                    "Enchantment - +15 Intellect",
                    "Enchantment - +20 Intellect",
                    "Enchantment - +22 Intellect",
                    "Enchantment - +25 Intellect",
                    "Enchantment - +30 Intellect",
                    "Enchantment - +35 Intellect",
                    "Enchantment - +37 Intellect",
                    "Enchantment - +40 Intellect",
                    "Enchantment - +41 Intellect",
                    "Enchantment - +44 Intellect",
                    "Enchantment - +45 Intellect",
                    "Enchantment - +50 Intellect",
                    "Enchantment - +8 Spirit",
                    "Enchantment - +10 Spirit",
                    "Enchantment - +12 Spirit",
                    "Enchantment - +20 Spirit",
                    "Enchantment - +22 Spirit",
                    "Enchantment - +25 Spirit",
                    "Enchantment - +30 Spirit",
                    "Enchantment - +35 Spirit",
                    "Enchantment - +37 Spirit",
                    "Enchantment - +40 Spirit",
                    "Enchantment - +41 Spirit",
                    "Enchantment - +44 Spirit",
                    "Enchantment - +45 Spirit",
                    "Enchantment - +50 Spirit",
                    "Enchantment - +12 Spell Power",
                    "Enchantment - +13 Spell Power",
                    "Enchantment - +14 Spell Power",
                    "Enchantment - +15 Spell Power",
                    "Enchantment - +16 Spell Power",
                    "Enchantment - +17 Spell Power",
                    "Enchantment - +18 Spell Power",
                    "Enchantment - +19 Spell Power",
                    "Enchantment - +20 Spell Power",
                    "Enchantment - +21 Spell Power",
                    "Enchantment - +22 Spell Power",
                    "Enchantment - +23 Spell Power",
                    "Enchantment - +24 Spell Power",
                    "Enchantment - +25 Spell Power",
                    "Enchantment - +26 Spell Power",
                    "Enchantment - +27 Spell Power",
                    "Enchantment - +28 Spell Power",
                    "Enchantment - +29 Spell Power",
                    "Enchantment - +30 Spell Power",
                    "Enchantment - +31 Spell Power",
                    "Enchantment - +32 Spell Power",
                    "Enchantment - +33 Spell Power",
                    "Enchantment - +34 Spell Power",
                    "Enchantment - +35 Spell Power",
                    "Enchantment - +36 Spell Power",
                    "Enchantment - +37 Spell Power",
                    "Enchantment - +38 Spell Power",
                    "Enchantment - +39 Spell Power",
                    "Enchantment - +40 Spell Power",
                    "Enchantment - +41 Spell Power",
                    "Enchantment - +42 Spell Power",
                    "Enchantment - +43 Spell Power",
                    "Enchantment - +44 Spell Power",
                    "Enchantment - +45 Spell Power",
                    "Enchantment - +46 Spell Power",
                    "Enchantment - +47 Spell Power",
                    "Enchantment - +48 Spell Power",
                    "Enchantment - +49 Spell Power",
                    "Enchantment - +50 Spell Power",
                    "Enchantment - +55 Spell Power",
                    "Enchantment - +63 Spell Power",
                    "Enchantment - +70 Spell Power",
                    "Enchantment - +81 Spell Power",
                    "Enchantment - +86 Spell Power",
                    "Enchantment - +100 Spell Power",
                    "Enchantment - +127 Spell Power",
                    "Enchantment - +81 Spell Power",
                    "Enchantment - +86 Spell Power",
                    "Enchantment - +100 Spell Power",
                    "Enchantment - +127 Spell Power",
                    "Enchantment - +129 Spell Power",
                    "Enchantment - Attack Power",
                    "Enchantment - +22 Attack Power",
                    "Enchantment - +24 Attack Power",
                    "Enchantment - +28 Attack Power",
                    "Enchantment - +32 Attack Power",
                    "Enchantment - +34 Attack Power",
                    "Enchantment - +40 Attack Power",
                    "Enchantment - +42 Attack Power",
                    "Enchantment - +44 Attack Power",
                    "Enchantment - +46 Attack Power",
                    "Enchantment - +50 Attack Power",
                    "Enchantment - +52 Attack Power",
                    "Enchantment - +54 Attack Power",
                    "Enchantment - +55 Attack Power",
                    "Enchantment - +56 Attack Power",
                    "Enchantment - +58 Attack Power",
                    "Enchantment - +60 Attack Power",
                    "Enchantment - +64 Attack Power",
                    "Enchantment - +70 Attack Power",
                    "Enchantment - +72 Attack Power",
                    "Enchantment - +74 Attack Power",
                    "Enchantment - +76 Attack Power",
                    "Enchantment - +80 Attack Power",
                    "Enchantment - +82 Attack Power",
                    "Enchantment - +88 Attack Power",
                    "Enchantment - +90 Attack Power",
                    "Enchantment - +92 Attack Power",
                    "Enchantment - +100 Attack Power",
                    "Enchantment - +110 Attack Power",
                    "Enchantment - +120 Attack Power",
                    "Enchantment - +130 Attack Power",
                    "Enchantment - +140 Attack Power",
                    "Enchantment - +150 Attack Power",
                    "Enchantment - +160 Attack Power",
                    "Enchantment - +170 Attack Power",
                    "Enchantment - +180 Attack Power",
                    "Enchantment - +190 Attack Power",
                    "Enchantment - +200 Attack Power",
                    "Enchantment - +220 Attack Power",
                    "Enchantment - +240 Attack Power",
                    "Enchantment - +250 Attack Power",
                    "Enchantment - +260 Attack Power",
                    "Enchantment - +280 Attack Power",
                    "Enchantment - +300 Attack Power",
                    "Enchantment - +320 Attack Power",
                    "Enchantment - +340 Attack Power",
                    "Enchantment - +360 Attack Power",
                    "Enchantment - +380 Attack Power",
                    "Enchantment - +400 Attack Power",
                    "Enchantment - +420 Attack Power",
                    "Enchantment - +440 Attack Power",
                    "Enchantment - +460 Attack Power",
                    "Enchantment - +480 Attack Power",
                    "Enchantment - +500 Attack Power",
                    "Enchantment - Mongoose",
                    "Enchantment - Executioner",
                    "Enchantment - Berserking",
                    "Enchantment - Black Magic",
                    "Enchantment - Blood Draining",
                    "Enchantment - Blade Ward",
                    "Enchantment - Greater Assault",
                    "Enchantment - Giant Slayer",
                    "Enchantment - Huntsman",
                    "Enchantment - Major Agility",
                    "Enchantment - Major Intellect",
                    "Enchantment - Major Strength",
                    "Enchantment - Major Tactics",
                    "Enchantment - Mighty Spirit",
                    "Enchantment - Potency",
                    "Enchantment - Superior Agility",
                    "Enchantment - Superior Intellect",
                    "Enchantment - Superior Primary",
                    "Enchantment - Superior Strength",
                    "Enchantment -Superior Striking",
                    "Enchantment -泰坦",
                    "Enchantment - Torrent",
                    "Enchantment - Unholy",
                    "Enchantment - Weapon Skill",
                    "Enchantment - +1 All",
                    "Enchantment - +2 All",
                    "Enchantment - +3 All",
                    "Enchantment - +4 All",
                    "Enchantment - +5 All",
                    "Enchantment - +6 All",
                    "Enchantment - +7 All",
                    "Enchantment - +8 All",
                    "Enchantment - +9 All",
                    "Enchantment - +10 All",
                    "Enchantment - Accuracy",
                    "Enchantment - Aggro",
                    "Enchantment - Arcane Resist",
                    "Enchantment - Berserking",
                    "Enchantment - Block",
                    "Enchantment - Defense",
                    "Enchantment - Dodge",
                    "Enchantment - Expertise",
                    "Enchantment - Fire Resist",
                    "Enchantment - Frag Belt",
                    "Enchantment - Frost Resist",
                    "Enchantment - Greater Dodge",
                    "Enchantment - Greater Parry",
                    "Enchantment - Health",
                    "Enchantment - Healing",
                    "Enchantment - Health Steal",
                    "Enchantment - Hit",
                    "Enchantment - Hit (Def)",
                    "Enchantment - Intellect",
                    "Enchantment - Lesser Accuracy",
                    "Enchantment - Lesser Attack Speed",
                    "Enchantment - Lesser Spirit",
                    "Enchantment - Life Steal",
                    "Enchantment - Mana",
                    "Enchantment - Mana Regen",
                    "Enchantment - Minor Haste",
                    "Enchantment - Minor Speed",
                    "Enchantment - Movement",
                    "Enchantment - Nature Resist",
                    "Enchantment - Parry",
                    "Enchantment - Penetration",
                    "Enchantment - Potion",
                    "Enchantment - Power",
                    "Enchantment - Regen",
                    "Enchantment - Resilience",
                    "Enchantment - Shadow Resist",
                    "Enchantment - Speed",
                    "Enchantment - Spirit",
                    "Enchantment - Stamina",
                    "Enchantment - Strength",
                    "Enchantment - Striking",
                    "Enchantment - Super Health",
                    "Enchantment - Vitality",
                }
                
                -- Check known enchantment stats in the item stats table
                local knownEnchantStats = {
                    ["+7 Stamina"] = true,
                    ["+10 Stats"] = true,
                    ["+12 Stamina"] = true,
                    ["+20 Stamina"] = true,
                    ["+22 Stamina"] = true,
                    ["+23 Stamina"] = true,
                    ["+30 Stamina"] = true,
                    ["+37 Stamina"] = true,
                    ["+40 Stamina"] = true,
                    ["+41 Stamina"] = true,
                    ["+8 Agility"] = true,
                    ["+10 Agility"] = true,
                    ["+12 Agility"] = true,
                    ["+15 Agility"] = true,
                    ["+16 Agility"] = true,
                    ["+18 Agility"] = true,
                    ["+20 Agility"] = true,
                    ["+22 Agility"] = true,
                    ["+25 Agility"] = true,
                    ["+26 Agility"] = true,
                    ["+30 Agility"] = true,
                    ["+35 Agility"] = true,
                    ["+36 Agility"] = true,
                    ["+37 Agility"] = true,
                    ["+40 Agility"] = true,
                    ["+41 Agility"] = true,
                    ["+44 Agility"] = true,
                    ["+45 Agility"] = true,
                    ["+50 Agility"] = true,
                    ["+8 Strength"] = true,
                    ["+10 Strength"] = true,
                    ["+12 Strength"] = true,
                    ["+15 Strength"] = true,
                    ["+16 Strength"] = true,
                    ["+20 Strength"] = true,
                    ["+22 Strength"] = true,
                    ["+25 Strength"] = true,
                    ["+30 Strength"] = true,
                    ["+35 Strength"] = true,
                    ["+37 Strength"] = true,
                    ["+40 Strength"] = true,
                    ["+41 Strength"] = true,
                    ["+44 Strength"] = true,
                    ["+45 Strength"] = true,
                    ["+50 Strength"] = true,
                    ["+8 Intellect"] = true,
                    ["+10 Intellect"] = true,
                    ["+12 Intellect"] = true,
                    ["+15 Intellect"] = true,
                    ["+20 Intellect"] = true,
                    ["+22 Intellect"] = true,
                    ["+25 Intellect"] = true,
                    ["+30 Intellect"] = true,
                    ["+35 Intellect"] = true,
                    ["+37 Intellect"] = true,
                    ["+40 Intellect"] = true,
                    ["+41 Intellect"] = true,
                    ["+44 Intellect"] = true,
                    ["+45 Intellect"] = true,
                    ["+50 Intellect"] = true,
                    ["+8 Spirit"] = true,
                    ["+10 Spirit"] = true,
                    ["+12 Spirit"] = true,
                    ["+20 Spirit"] = true,
                    ["+22 Spirit"] = true,
                    ["+25 Spirit"] = true,
                    ["+30 Spirit"] = true,
                    ["+35 Spirit"] = true,
                    ["+37 Spirit"] = true,
                    ["+40 Spirit"] = true,
                    ["+41 Spirit"] = true,
                    ["+44 Spirit"] = true,
                    ["+45 Spirit"] = true,
                    ["+50 Spirit"] = true,
                    ["+12 Spell Power"] = true,
                    ["+13 Spell Power"] = true,
                    ["+14 Spell Power"] = true,
                    ["+15 Spell Power"] = true,
                    ["+16 Spell Power"] = true,
                    ["+17 Spell Power"] = true,
                    ["+18 Spell Power"] = true,
                    ["+19 Spell Power"] = true,
                    ["+20 Spell Power"] = true,
                    ["+21 Spell Power"] = true,
                    ["+22 Spell Power"] = true,
                    ["+23 Spell Power"] = true,
                    ["+24 Spell Power"] = true,
                    ["+25 Spell Power"] = true,
                    ["+26 Spell Power"] = true,
                    ["+27 Spell Power"] = true,
                    ["+28 Spell Power"] = true,
                    ["+29 Spell Power"] = true,
                    ["+30 Spell Power"] = true,
                    ["+31 Spell Power"] = true,
                    ["+32 Spell Power"] = true,
                    ["+33 Spell Power"] = true,
                    ["+34 Spell Power"] = true,
                    ["+35 Spell Power"] = true,
                    ["+36 Spell Power"] = true,
                    ["+37 Spell Power"] = true,
                    ["+38 Spell Power"] = true,
                    ["+39 Spell Power"] = true,
                    ["+40 Spell Power"] = true,
                    ["+41 Spell Power"] = true,
                    ["+42 Spell Power"] = true,
                    ["+43 Spell Power"] = true,
                    ["+44 Spell Power"] = true,
                    ["+45 Spell Power"] = true,
                    ["+46 Spell Power"] = true,
                    ["+47 Spell Power"] = true,
                    ["+48 Spell Power"] = true,
                    ["+49 Spell Power"] = true,
                    ["+50 Spell Power"] = true,
                    ["+55 Spell Power"] = true,
                    ["+63 Spell Power"] = true,
                    ["+70 Spell Power"] = true,
                    ["+81 Spell Power"] = true,
                    ["+86 Spell Power"] = true,
                    ["+100 Spell Power"] = true,
                    ["+127 Spell Power"] = true,
                    ["+129 Spell Power"] = true,
                    ["Attack Power"] = true,
                    ["+22 Attack Power"] = true,
                    ["+24 Attack Power"] = true,
                    ["+28 Attack Power"] = true,
                    ["+32 Attack Power"] = true,
                    ["+34 Attack Power"] = true,
                    ["+40 Attack Power"] = true,
                    ["+42 Attack Power"] = true,
                    ["+44 Attack Power"] = true,
                    ["+46 Attack Power"] = true,
                    ["+50 Attack Power"] = true,
                    ["+52 Attack Power"] = true,
                    ["+54 Attack Power"] = true,
                    ["+55 Attack Power"] = true,
                    ["+56 Attack Power"] = true,
                    ["+58 Attack Power"] = true,
                    ["+60 Attack Power"] = true,
                    ["+64 Attack Power"] = true,
                    ["+70 Attack Power"] = true,
                    ["+72 Attack Power"] = true,
                    ["+74 Attack Power"] = true,
                    ["+76 Attack Power"] = true,
                    ["+80 Attack Power"] = true,
                    ["+82 Attack Power"] = true,
                    ["+88 Attack Power"] = true,
                    ["+90 Attack Power"] = true,
                    ["+92 Attack Power"] = true,
                    ["+100 Attack Power"] = true,
                    ["+110 Attack Power"] = true,
                    ["+120 Attack Power"] = true,
                    ["+130 Attack Power"] = true,
                    ["+140 Attack Power"] = true,
                    ["+150 Attack Power"] = true,
                    ["+160 Attack Power"] = true,
                    ["+170 Attack Power"] = true,
                    ["+180 Attack Power"] = true,
                    ["+190 Attack Power"] = true,
                    ["+200 Attack Power"] = true,
                    ["+220 Attack Power"] = true,
                    ["+240 Attack Power"] = true,
                    ["+250 Attack Power"] = true,
                    ["+260 Attack Power"] = true,
                    ["+280 Attack Power"] = true,
                    ["+300 Attack Power"] = true,
                    ["+320 Attack Power"] = true,
                    ["+340 Attack Power"] = true,
                    ["+360 Attack Power"] = true,
                    ["+380 Attack Power"] = true,
                    ["+400 Attack Power"] = true,
                    ["+420 Attack Power"] = true,
                    ["+440 Attack Power"] = true,
                    ["+460 Attack Power"] = true,
                    ["+480 Attack Power"] = true,
                    ["+500 Attack Power"] = true,
                    ["+1 All"] = true,
                    ["+2 All"] = true,
                    ["+3 All"] = true,
                    ["+4 All"] = true,
                    ["+5 All"] = true,
                    ["+6 All"] = true,
                    ["+7 All"] = true,
                    ["+8 All"] = true,
                    ["+9 All"] = true,
                    ["+10 All"] = true,
                }
                
                -- Build enchantment info from stats
                local enchantStatsList = {}
                for stat, value in pairs(itemStats) do
                    if knownEnchantStats[stat] then
                        table.insert(enchantStatsList, {name = stat, value = value})
                    end
                end
                
                if #enchantStatsList > 0 or enchantID then
                    details.enchant = {
                        id = enchantID,
                        stats = enchantStatsList
                    }
                end
            end
        end
        
        -- Handle sockets (gems)
        local gems = {tonumber(gem1) or 0, tonumber(gem2) or 0, tonumber(gem3) or 0, tonumber(gem4) or 0}
        for i, gemID in ipairs(gems) do
            if gemID and gemID > 0 then
                local socketInfo = {gemID = gemID}
                
                -- Get gem info
                local gemName, gemLink = GetItemInfo(gemID)
                if gemName then
                    socketInfo.name = gemName
                    
                    -- Determine socket color based on gem name patterns
                    local lowerName = string.lower(gemName)
                    if string.find(lowerName, "diamond") then
                        if string.find(lowerName, "meta") then
                            socketInfo.color = "meta"
                        else
                            socketInfo.color = "prismatic"
                        end
                    elseif string.find(lowerName, "ruby") or string.find(lowerName, "red") then
                        socketInfo.color = "red"
                    elseif string.find(lowerName, "sapphire") or string.find(lowerName, "blue") then
                        socketInfo.color = "blue"
                    elseif string.find(lowerName, "emerald") or string.find(lowerName, "green") then
                        socketInfo.color = "green"
                    elseif string.find(lowerName, "topaz") or string.find(lowerName, "yellow") then
                        socketInfo.color = "yellow"
                    elseif string.find(lowerName, "amethyst") or string.find(lowerName, "purple") then
                        socketInfo.color = "purple"
                    elseif string.find(lowerName, "cobalt") then
                        socketInfo.color = "cobalt"
                    elseif string.find(lowerName, "twilight") then
                        socketInfo.color = "twilight"
                    elseif string.find(lowerName, "autumn") then
                        socketInfo.color = "autumn"
                    elseif string.find(lowerName, "forest") then
                        socketInfo.color = "forest"
                    elseif string.find(lowerName, "dragon's eye") then
                        socketInfo.color = "prismatic"
                    end
                end
                
                -- Get gem stats
                if gemLink then
                    local gemStats = GetItemStats(gemLink)
                    if gemStats then
                        local gemStatsList = {}
                        for stat, value in pairs(gemStats) do
                            table.insert(gemStatsList, {name = stat, value = value})
                        end
                        if #gemStatsList > 0 then
                            socketInfo.stats = gemStatsList
                        end
                    end
                end
                
                table.insert(details.sockets, socketInfo)
            end
        end
        
        return details
    end
    
    -- Main equipment scanning
    local g = {}
    for i=1, 19 do
        local link = GetInventoryItemLink("player", i)
        if link then
            local details = GetItemDetails(link)
            if details then
                local slotData = {}
                
                -- Add item ID
                table.insert(slotData, '"id":' .. details.itemID)
                
                -- Add link
                table.insert(slotData, '"link":"' .. Escape(details.link) .. '"')
                
                -- Add name
                if details.name then
                    table.insert(slotData, '"name":"' .. Escape(details.name) .. '"')
                end
                
                -- Add rarity (item quality: 0=poor, 1=common, 2=uncommon, 3=rare, 4=epic, 5=legendary)
                if details.rarity then
                    table.insert(slotData, '"rarity":' .. details.rarity)
                end
                
                -- Add item level
                if details.itemLevel then
                    table.insert(slotData, '"iLvl":' .. details.itemLevel)
                end
                
                -- Add slot/equip location
                if details.slot then
                    table.insert(slotData, '"slot":"' .. details.slot .. '"')
                end
                
                -- Add durability
                if details.durability then
                    table.insert(slotData, '"durability":[' .. details.durability.current .. ',' .. details.durability.max .. ']')
                end
                
                -- Add stats
                if details.stats and #details.stats > 0 then
                    local statsList = {}
                    for _, stat in ipairs(details.stats) do
                        table.insert(statsList, '"' .. Escape(stat.name) .. '":' .. stat.value)
                    end
                    table.insert(slotData, '"stats":{' .. table.concat(statsList, ',') .. '}')
                else
                    table.insert(slotData, '"stats":{}')
                end
                
                -- Add enchantment
                if details.enchant then
                    local enchantParts = {}
                    if details.enchant.id then
                        table.insert(enchantParts, '"id":' .. details.enchant.id)
                    end
                    if details.enchant.stats and #details.enchant.stats > 0 then
                        local enchantStatsList = {}
                        for _, stat in ipairs(details.enchant.stats) do
                            table.insert(enchantStatsList, '"' .. Escape(stat.name) .. '":' .. stat.value)
                        end
                        table.insert(enchantParts, '"stats":{' .. table.concat(enchantStatsList, ',') .. '}')
                    end
                    table.insert(slotData, '"enchant":{' .. table.concat(enchantParts, ",") .. '}')
                else
                    table.insert(slotData, '"enchant":null')
                end
                
                -- Add sockets
                if details.sockets and #details.sockets > 0 then
                    local socketsList = {}
                    for _, socket in ipairs(details.sockets) do
                        local socketParts = {}
                        if socket.gemID then
                            table.insert(socketParts, '"id":' .. socket.gemID)
                        end
                        if socket.name then
                            table.insert(socketParts, '"name":"' .. Escape(socket.name) .. '"')
                        end
                        if socket.color then
                            table.insert(socketParts, '"color":"' .. socket.color .. '"')
                        end
                        if socket.stats and #socket.stats > 0 then
                            local socketStatsList = {}
                            for _, stat in ipairs(socket.stats) do
                                table.insert(socketStatsList, '"' .. Escape(stat.name) .. '":' .. stat.value)
                            end
                            table.insert(socketParts, '"stats":{' .. table.concat(socketStatsList, ',') .. '}')
                        end
                        table.insert(socketsList, '{' .. table.concat(socketParts, ",") .. '}')
                    end
                    table.insert(slotData, '"sockets":[' .. table.concat(socketsList, ",") .. ']')
                else
                    table.insert(slotData, '"sockets":[]')
                end
                
                table.insert(g, string.format('"%d":{%s}', i, table.concat(slotData, ",")))
            else
                -- Fallback to just link if details parsing fails
                table.insert(g, string.format('"%d":"%s"', i, Escape(link)))
            end
        end
    end
    return '{"Equipment":{'..table.concat(g, ",")..'}}'
end
