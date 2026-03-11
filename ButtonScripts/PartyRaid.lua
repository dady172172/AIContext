AIContext.Scripts["PartyRaid"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local parts = {}
    
    local numMembers = GetNumPartyMembers() + GetNumRaidMembers()
    
    if numMembers == 0 then
        return '{"PartyRaid":{"error":"Not in party or raid"}}'
    end
    
    -- Check if in raid
    local inRaid = IsInRaid()
    table.insert(parts, '"inRaid":' .. (inRaid and 'true' or 'false'))
    
    -- Get party/raid members
    local members = {}
    local source = inRaid and "raid" or "party"
    
    -- Start from 1 for party (player is 0) or raid
    for i = 1, numMembers do
        local unit = source .. i
        if UnitExists(unit) then
            local member = {}
            member.name = UnitName(unit) or "Unknown"
            member.class = select(2, UnitClass(unit)) or "Unknown"
            member.level = UnitLevel(unit) or 0
            member.health = UnitHealth(unit) or 0
            member.maxHealth = UnitHealthMax(unit) or 0
            member.power = UnitPower(unit) or 0
            member.maxPower = UnitPowerMax(unit) or 0
            member.powerType = UnitPowerType(unit) or 0
            
            -- Get unit's role (DPS/TANK/HEALER)
            local role = UnitGroupRolesAssigned(unit)
            member.role = role or "NONE"
            
            -- Buffs
            local buffs = {}
            for j = 1, 32 do
                local buff = UnitBuff(unit, j)
                if not buff then break end
                table.insert(buffs, Escape(buff))
            end
            member.buffs = buffs
            
            -- Debuffs
            local debuffs = {}
            for j = 1, 32 do
                local debuff = UnitDebuff(unit, j)
                if not debuff then break end
                table.insert(debuffs, Escape(debuff))
            end
            member.debuffs = debuffs
            
            -- Is pet active
            member.hasPet = UnitExists(unit .. "pet") and 1 or 0
            
            table.insert(members, member)
        end
    end
    
    -- Build member arrays
    local memberList = {}
    for _, m in ipairs(members) do
        local buffList = #m.buffs > 0 and '[' .. table.concat(m.buffs, ',') .. ']' or '[]'
        local debuffList = #m.debuffs > 0 and '[' .. table.concat(m.debuffs, ',') .. ']' or '[]'
        table.insert(memberList, string.format(
            '{"n":"%s","c":"%s","l":%d,"hp":%d,"mhp":%d,"pp":%d,"mpp":%d,"pt":%d,"r":"%s","b":%s,"d":%s,"p":%d}',
            m.name, m.class, m.level, m.health, m.maxHealth, m.power, m.maxPower, m.powerType,
            m.role, buffList, debuffList, m.hasPet
        ))
    end
    
    table.insert(parts, '"members":[' .. table.concat(memberList, ',') .. ']')
    
    return '{"PartyRaid":{' .. table.concat(parts, ',') .. '}}'
end
