AIContext.Scripts["Companions"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local pts = {}
    local numPets = GetNumCompanions("CRITTER")
    for i=1, numPets do
        local _, name, _, _, isSummoned = GetCompanionInfo("CRITTER", i)
        table.insert(pts, string.format('"%s"', Escape(name or "Unknown Pet")))
    end
    return '{"Pets":['..table.concat(pts, ",")..']}'
end