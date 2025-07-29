local f=CreateFrame("Frame","CritSoundFrame",UIParent,"BackdropTemplate")
f:SetSize(250,150)f:SetPoint("CENTER")f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=1,tileSize=32,edgeSize=32,insets={left=8,right=8,top=8,bottom=8}})
f:EnableMouse(1)f:SetMovable(1)f:RegisterForDrag("LeftButton")f:SetScript("OnDragStart",f.StartMoving)f:SetScript("OnDragStop",f.StopMovingOrSizing)f:Hide()

CritSoundCharDB=CritSoundCharDB or {critNumber=420, sound="sound04.ogg"}
local sounds={"sound01.ogg","sound02.ogg","sound03.ogg","sound04.ogg","sound05.ogg","sound06.ogg","sound07.ogg","sound08.ogg","custom01.ogg","custom02.ogg"}

local close=CreateFrame("Button",nil,f,"UIPanelCloseButton")close:SetPoint("TOPRIGHT",-5,-5)close:SetScale(0.8)
local critLabel=f:CreateFontString(nil,"OVERLAY","GameFontNormal")critLabel:SetPoint("TOPLEFT",20,-30)critLabel:SetText("Min Crit:")
local critInput=CreateFrame("EditBox",nil,f,"InputBoxTemplate")critInput:SetSize(70,20)critInput:SetPoint("LEFT",critLabel,"RIGHT",10,0)
critInput:SetAutoFocus(false)critInput:SetNumeric(true)critInput:SetMaxLetters(6)

local soundLabel=f:CreateFontString(nil,"OVERLAY","GameFontNormal")soundLabel:SetPoint("TOPLEFT",critLabel,"BOTTOMLEFT",0,-20)soundLabel:SetText("Sound:")
local dropdown=CreateFrame("Frame",nil,f,"UIDropDownMenuTemplate")dropdown:SetPoint("LEFT",soundLabel,"RIGHT",-10,-2)UIDropDownMenu_SetWidth(dropdown,140)

local setBtn=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")setBtn:SetSize(70,22)setBtn:SetPoint("TOPLEFT",soundLabel,"BOTTOMLEFT",0,-20)setBtn:SetText("Set")
local testBtn=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")testBtn:SetSize(70,22)testBtn:SetPoint("LEFT",setBtn,"RIGHT",10,0)testBtn:SetText("Test")
local critStatus=f:CreateFontString(nil,"OVERLAY","GameFontNormal")critStatus:SetPoint("BOTTOMLEFT",20,20)
local soundStatus=f:CreateFontString(nil,"OVERLAY","GameFontNormal")soundStatus:SetPoint("BOTTOMRIGHT",-20,20)

local function tContains(tbl, item)
    for _, v in ipairs(tbl) do
        if v == item then return true end
    end
    return false
end

local soundQueue = {}
local isPlaying = false
local function PlayNextSound()
    if #soundQueue == 0 then
        isPlaying = false
        return
    end
    isPlaying = true
    local nextSound = table.remove(soundQueue, 1)
    PlaySoundFile(nextSound, "Master")
    C_Timer.After(0.4, PlayNextSound)
end

local function QueueSound(path)
    table.insert(soundQueue, path)
    if not isPlaying then
        PlayNextSound()
    end
end

local addonName = ...
local function GetSoundPath()
    return "Interface\\AddOns\\"..addonName.."\\"..CritSoundCharDB.sound
end

local function UpdateStatus()
    critStatus:SetText("Crit: "..CritSoundCharDB.critNumber)
    soundStatus:SetText("Sound: "..CritSoundCharDB.sound)
end

setBtn:SetScript("OnClick",function()
    local input = tonumber(critInput:GetText())
    if not input or input < 1 then input = 420 end
    CritSoundCharDB.critNumber = math.min(math.max(input, 1), 999999)
    critInput:SetText(CritSoundCharDB.critNumber)
    UpdateStatus()
end)

testBtn:SetScript("OnClick",function()
    QueueSound(GetSoundPath())
end)

f:SetScript("OnShow",function()
    if not CritSoundCharDB.critNumber then CritSoundCharDB.critNumber = 420 end
    if not CritSoundCharDB.sound or not tContains(sounds, CritSoundCharDB.sound) then
        CritSoundCharDB.sound = "sound04.ogg"
    end

    critInput:SetText(CritSoundCharDB.critNumber)

    UIDropDownMenu_Initialize(dropdown,function(self, level)
        for _,sound in ipairs(sounds) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = sound
            info.func = function()
                CritSoundCharDB.sound = sound
                UIDropDownMenu_SetText(dropdown, sound)
                UpdateStatus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    UIDropDownMenu_SetText(dropdown, CritSoundCharDB.sound)
    UpdateStatus()
end)

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent",function()
    local e={CombatLogGetCurrentEventInfo()}
    local event, srcGUID = e[2], e[4]
    local damage, crit

    if event == "SWING_DAMAGE" then
        damage = e[15]
        crit = e[18]
    elseif event == "SPELL_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" then
        damage = e[15]
        crit = e[21]
    else
        return
    end

    if srcGUID == UnitGUID("player") and tonumber(damage) and crit and tonumber(damage) >= CritSoundCharDB.critNumber then
        QueueSound(GetSoundPath())
    end
end)

SLASH_CRITSOUND1,SLASH_CRITSOUND2="/critsound","/cs"
SlashCmdList["CRITSOUND"]=function()f:SetShown(not f:IsShown())end
