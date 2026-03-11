AIContext.Scripts["Reputation"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local rep = {}
    local numFactions = GetNumFactions()
    for i=1, numFactions do
        local name, _, standingID, bottomValue, topValue, earnedValue, _, _, isHeader = GetFactionInfo(i)
        if not isHeader then
            local standings = {[0]="Unknown", [1]="Hated", [2]="Hostile", [3]="Unfriendly", [4]="Neutral", [5]="Friendly", [6]="Honored", [7]="Revered", [8]="Exalted"}
            local current = earnedValue - bottomValue
            local max = topValue - bottomValue
            table.insert(rep, string.format('"%s":{"s":"%s","c":%d,"m":%d}', Escape(name), standings[standingID] or "Unknown", current, max))
        end
    end
    return '{"Reputation":{'..table.concat(rep, ",")..'}}'
end