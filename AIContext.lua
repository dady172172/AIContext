-- *************************************************************
-- AI CONTEXT CORE
-- *************************************************************
AIContext = {}
AIContext.Scripts = {} 

-- 1. DATABASE & EVENT HANDLING
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("BANKFRAME_OPENED")
EventFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
EventFrame:RegisterEvent("TRADE_SKILL_SHOW")
EventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
EventFrame:RegisterEvent("PLAYER_MONEY")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("GUILDBANKFRAME_OPENED")
EventFrame:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")

function AIContext.GetDB()
    local realm = GetRealmName()
    local char = UnitName("player")
    if not AIContextDB then AIContextDB = {} end
    if not AIContextDB[realm] then AIContextDB[realm] = {} end
    if not AIContextDB[realm][char] then 
        AIContextDB[realm][char] = { Bank = {}, Recipes = {}, Gold = 0 }
    end
    return AIContextDB[realm][char]
end

function AIContext.ScanBank()
    local db = AIContext.GetDB()
    db.Bank = {} 
    local bagList = {-1, 5, 6, 7, 8, 9, 10, 11}
    local itemCounter = 0
    for _, bagID in ipairs(bagList) do
        local numSlots = GetContainerNumSlots(bagID)
        if numSlots > 0 then
            for slot = 1, numSlots do
                local link = GetContainerItemLink(bagID, slot)
                if link then
                    local _, count = GetContainerItemInfo(bagID, slot)
                    table.insert(db.Bank, {bag=bagID, slot=slot, link=link, count=(count or 1)})
                    itemCounter = itemCounter + 1
                end
            end
        end
    end
    print("|cff00ff00[AI Context]|r: Bank Scanned! Saved " .. itemCounter .. " items.")
end

function AIContext.ScanProfession()
    local tradeName = GetTradeSkillLine()
    local db = AIContext.GetDB()
    if tradeName and tradeName ~= "UNKNOWN" then
        if not db.Recipes then db.Recipes = {} end
        db.Recipes[tradeName] = {}
        for i=1, GetNumTradeSkills() do
            local recipeName, recipeType = GetTradeSkillInfo(i)
            if recipeType ~= "header" then
                table.insert(db.Recipes[tradeName], recipeName)
            end
        end
        print("|cff00ff00[AI Context]|r: Saved " .. tradeName .. ".")
    end
end

function AIContext.ScanGuildBank()
    local db = AIContext.GetDB()
    if not db.GuildBank then db.GuildBank = {} end
    
    local totalItems = 0
    local numTabs = GetNumGuildBankTabs()
    
    for tab = 1, numTabs do
        local tabName, tabIcon = GetGuildBankTabInfo(tab)
        if not db.GuildBank[tab] then db.GuildBank[tab] = {} end
        db.GuildBank[tab].name = tabName
        db.GuildBank[tab].icon = tabIcon
        db.GuildBank[tab].items = {}
        
        -- Scan each slot in the tab (98 slots per tab in WotLK)
        for slot = 1, 98 do
            local link = GetGuildBankItemLink(tab, slot)
            local texture, count = GetGuildBankItemInfo(tab, slot)
            if link then
                table.insert(db.GuildBank[tab].items, {slot=slot, link=link, count=(count or 1)})
                totalItems = totalItems + 1
            end
        end
    end
    print("|cff00ff00[AI Context]|r: Guild Bank Scanned! Saved " .. totalItems .. " items across " .. numTabs .. " tabs.")
end

EventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "AIContext" then AIContext.GetDB()
    elseif event == "BANKFRAME_OPENED" or event == "PLAYERBANKSLOTS_CHANGED" then AIContext.ScanBank()
    elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" then AIContext.ScanProfession()
    elseif event == "GUILDBANKFRAME_OPENED" or event == "GUILDBANKBAGSLOTS_CHANGED" then AIContext.ScanGuildBank()
    end
end)

-- 2. UI GENERATION
local mainFrame = CreateFrame("Frame", "AIContextFrame", UIParent)
mainFrame:SetSize(400, 500)
mainFrame:SetPoint("CENTER")
mainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:Hide()

local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -20)
title:SetText("AIContext")

local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

-- COPY WINDOW
local CopyFrame = CreateFrame("Frame", "AIContextCopyFrame", UIParent)
CopyFrame:SetSize(600, 500)
CopyFrame:SetPoint("CENTER")
CopyFrame:SetFrameStrata("DIALOG")
CopyFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
CopyFrame:Hide()
local ScrollArea = CreateFrame("ScrollFrame", "AIContextScroll", CopyFrame, "UIPanelScrollFrameTemplate")
ScrollArea:SetPoint("TOPLEFT", 20, -30)
ScrollArea:SetPoint("BOTTOMRIGHT", -40, 40)
local EditBox = CreateFrame("EditBox", nil, ScrollArea)
EditBox:SetMultiLine(true)
EditBox:SetMaxLetters(999999)
EditBox:SetFontObject(ChatFontNormal)
EditBox:SetWidth(500)
ScrollArea:SetScrollChild(EditBox)
local CloseCopyBtn = CreateFrame("Button", nil, CopyFrame, "UIPanelButtonTemplate")
CloseCopyBtn:SetPoint("BOTTOM", 0, 10)
CloseCopyBtn:SetSize(100, 25)
CloseCopyBtn:SetText("Close")
CloseCopyBtn:SetScript("OnClick", function() CopyFrame:Hide() end)

function AIContext.Export(category)
    local scriptFunc = AIContext.Scripts[category]
    if scriptFunc then
        local output = scriptFunc()
        CopyFrame:Show()
        EditBox:SetText(output)
        EditBox:HighlightText()
        EditBox:SetFocus()
    else
        print("No script found for: " .. category)
    end
end

-- 3. CREATE BUTTONS
local function CreateBtn(text, x, y, width, cat)
    local btn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    btn:SetSize(width, 25)
    btn:SetPoint("TOPLEFT", x, y)
    btn:SetText(text)
    btn:SetScript("OnClick", function() AIContext.Export(cat) end)
end

-- A. The Master Button (Full Width)
CreateBtn(">> AI DATA (EXPORT ALL) <<", 20, -45, 360, "AI")

-- B. Left Column (Character & Inventory)
local leftCol = {
    {"Basic Info", "Basic"},
    {"Stats", "Stats"},
    {"Talents", "Talents"},
    {"Glyphs", "Glyphs"},
    {"Equipment", "Equipment"},
    {"Bags", "Bags"},
    {"Bank", "Bank"},
    {"Guild Bank", "GuildBank"},
    {"Key Ring", "KeyRing"},
    {"Currency", "Currency"}
}

local yPos = -80
for _, b in ipairs(leftCol) do
    CreateBtn(b[1], 20, yPos, 175, b[2])
    yPos = yPos - 30
end

-- C. Right Column (World & Skills)
local rightCol = {
    {"Skills", "Skills"},
    {"Professions", "Professions"},
    {"Spells", "Spells"},
    {"Quests", "Quests"},
    {"Reputation", "Reputation"},
    {"Mounts", "Mounts"},
    {"Pets", "Companions"},
    {"Achievements", "Achievements"},
    {"Addons", "Addons"},
    {"Party/Raid", "PartyRaid"}
}

yPos = -80
for _, b in ipairs(rightCol) do
    CreateBtn(b[1], 205, yPos, 175, b[2])
    yPos = yPos - 30
end

SLASH_AICONTEXT1 = "/aic"
SLASH_AICONTEXT2 = "/ac"
SLASH_AICONTEXT3 = "/gc"
SlashCmdList["AICONTEXT"] = function() 
    if mainFrame:IsShown() then mainFrame:Hide() else mainFrame:Show() end
end

-- 4. MINIMAP BUTTON
local miniBtn = CreateFrame("Button", "AIContextMiniBtn", Minimap)
miniBtn:SetSize(32, 32)
miniBtn:SetFrameStrata("MEDIUM")
miniBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

-- Create a circular icon texture
local miniBtnTex = miniBtn:CreateTexture(nil, "BACKGROUND")
miniBtnTex:SetSize(20, 20)
miniBtnTex:SetPoint("CENTER", 0, 0)
miniBtnTex:SetTexCoord(0.1, 0.9, 0.1, 0.9)

-- Try to load the texture, fallback to a generic one
local texture = GetItemIcon(2070) -- Use a default item icon as fallback
if texture then
    miniBtnTex:SetTexture(texture)
else
    miniBtnTex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
end

-- Create border
local miniBtnBorder = miniBtn:CreateTexture(nil, "OVERLAY")
miniBtnBorder:SetSize(32, 32)
miniBtnBorder:SetPoint("CENTER", 0, 0)
miniBtnBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

-- Set position on minimap (default: top-right area)
miniBtn:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -10, -10)

-- Enable dragging for repositioning
miniBtn:RegisterForDrag("LeftButton")
miniBtn:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
miniBtn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Click to toggle main window
miniBtn:SetScript("OnClick", function()
    if mainFrame:IsShown() then 
        mainFrame:Hide() 
    else 
        mainFrame:Show() 
    end
end)

-- Tooltip
miniBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("AIContext", 1, 1, 1)
    GameTooltip:AddLine("Click to open/close", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Drag to reposition", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
miniBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Show the button (hidden by default until positioned)
miniBtn:Show()
