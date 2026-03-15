AIContext.Scripts["Glyphs"] = function()
    local function Escape(s) return string.gsub(s or "", '"', '\\"') end
    local gly = {}
    for i = 1, 6 do
        local enabled, glyphType, glyphSpellID, icon = GetGlyphSocketInfo(i)
        if enabled then
            if glyphSpellID then
                local name = GetSpellInfo(glyphSpellID)
                if not name then name = "Unknown ID: " .. tostring(glyphSpellID) end
                table.insert(gly, string.format('"%s"', Escape(name)))
            else
                table.insert(gly, '"Empty"')
            end
        end
    end
    return '{"Glyphs":['..table.concat(gly, ",")..']}'
end