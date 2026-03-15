AIContext.Scripts["Addons"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local adds = {}
    for i=1, GetNumAddOns() do
        local name, title = GetAddOnInfo(i)
        table.insert(adds, '"'..Escape(title or name)..'"')
    end
    return '{"Addons":['..table.concat(adds, ",")..']}'
end
