AIContext.Scripts["Basic"] = function()
    local name = UnitName("player")
    local level = UnitLevel("player")
    local _, race = UnitRace("player")
    local _, class = UnitClass("player")
    local realm = GetRealmName()
    
    SetMapToCurrentZone()
    local zone = GetRealZoneText() or "Unknown"
    local subzone = GetMinimapZoneText() or ""
    if subzone == "" then subzone = zone end
    
    local px, py = GetPlayerMapPosition("player")
    local coords = "Unknown"
    if px and py then
        coords = string.format("%.1f, %.1f", px * 100, py * 100)
    end

    return string.format('{"Basic":{"Name":"%s","Lvl":%d,"Race":"%s","Class":"%s","Realm":"%s","Zone":"%s","SubZone":"%s","Coords":"%s"}}', 
        name, level, race, class, realm, zone, subzone, coords)
end