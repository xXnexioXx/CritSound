local f=CreateFrame("Frame","CritSoundFrame",UIParent,"BackdropTemplate")
f:SetSize(250,150)f:SetPoint("CENTER")f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=1,tileSize=32,edgeSize=32,insets={left=8,right=8,top=8,bottom=8}})
f:EnableMouse(1)f:SetMovable(1)f:RegisterForDrag("LeftButton")f:SetScript("OnDragStart",f.StartMoving)f:SetScript("OnDragStop",f.StopMovingOrSizing)f:Hide()

CritSoundCharDB=CritSoundCharDB or{critNumber=420,sound="sound04.ogg"}
local sounds={"sound01.ogg","sound02.ogg","sound03.ogg","sound04.ogg","sound05.ogg","sound06.ogg","sound07.ogg","sound08.ogg","sound09.ogg","sound10.ogg"}

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

local function UpdateStatus()
    critStatus:SetText("Crit: "..CritSoundCharDB.critNumber)
    soundStatus:SetText("Sound: "..CritSoundCharDB.sound)
end

setBtn:SetScript("OnClick",function()
    CritSoundCharDB.critNumber=math.min(math.max(tonumber(critInput:GetText())or 1000,1),999999)
    UpdateStatus()
end)

testBtn:SetScript("OnClick",function()PlaySoundFile("Interface\\AddOns\\CritSound\\"..CritSoundCharDB.sound,"Master")end)

f:SetScript("OnShow",function()
    critInput:SetText(CritSoundCharDB.critNumber)
    UIDropDownMenu_Initialize(dropdown,function()
        for _,sound in ipairs(sounds)do
            local info=UIDropDownMenu_CreateInfo()
            info.text=sound
            info.func=function()CritSoundCharDB.sound=sound UIDropDownMenu_SetText(dropdown,sound)end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(dropdown,CritSoundCharDB.sound)
    UpdateStatus()
end)

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent",function()
    local e={CombatLogGetCurrentEventInfo()}
    local event,srcGUID,damage,crit=e[2],e[4],e[15],e[21]
    if(srcGUID==UnitGUID("player")and crit and damage and damage>=CritSoundCharDB.critNumber and(
        event=="SWING_DAMAGE"or event=="SPELL_DAMAGE"or event=="RANGE_DAMAGE"))then
        PlaySoundFile("Interface\\AddOns\\CritSound\\"..CritSoundCharDB.sound,"Master")
    end
end)

SLASH_CRITSOUND1,SLASH_CRITSOUND2="/critsound","/cs"
SlashCmdList["CRITSOUND"]=function()f:SetShown(not f:IsShown())end