AIContext.Scripts["Mounts"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local mnt = {}
    local numMounts = GetNumCompanions("MOUNT")
    for i=1, numMounts do
        local _, name, _, _, isSummoned = GetCompanionInfo("MOUNT", i)
        table.insert(mnt, string.format('{"n":"%s","s":%d}', Escape(name or "Unknown Mount"), isSummoned and 1 or 0))
    end
    return '{"Mounts":['..table.concat(mnt, ",")..']}'
end