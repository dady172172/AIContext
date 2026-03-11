AIContext.Scripts["Addons"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local adds = {}
    for i=1, GetNumAddOns() do
        local name, title, _, loadable, reason, security, _ = GetAddOnInfo(i)
        local loaded = IsAddOnLoaded(i) and 1 or 0
        table.insert(adds, string.format('{"n":"%s","l":%d}', Escape(title or name), loaded))
    end
    return '{"Addons":['..table.concat(adds, ",")..']}'
end