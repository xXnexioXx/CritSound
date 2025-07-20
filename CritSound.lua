local f=CreateFrame("Frame","CritSoundFrame",UIParent,"BackdropTemplate")
f:SetSize(250,150)f:SetPoint("CENTER")f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=1,tileSize=32,edgeSize=32,insets={left=8,right=8,top=8,bottom=8}})
f:EnableMouse(true)f:SetMovable(true)f:RegisterForDrag("LeftButton")f:SetScript("OnDragStart",f.StartMoving)f:SetScript("OnDragStop",f.StopMovingOrSizing)f:Hide()

CritSoundCharDB=CritSoundCharDB or{critNumber=420,sound="sound04.ogg"}
local s={"sound01.ogg","sound02.ogg","sound03.ogg","sound04.ogg","sound05.ogg","sound06.ogg","sound07.ogg","sound08.ogg","sound09.ogg","sound10.ogg"}
local l=0

CreateFrame("Button",nil,f,"UIPanelCloseButton"):SetPoint("TOPRIGHT",-5,-5):SetScale(0.8)

local c=f:CreateFontString(nil,"OVERLAY","GameFontNormal")c:SetPoint("TOPLEFT",20,-30)c:SetText("Min Crit:")
local i=CreateFrame("EditBox",nil,f,"InputBoxTemplate")i:SetSize(70,20)i:SetPoint("LEFT",c,"RIGHT",10,0)i:SetAutoFocus(false)i:SetNumeric(true)i:SetMaxLetters(6)

local sl=f:CreateFontString(nil,"OVERLAY","GameFontNormal")sl:SetPoint("TOPLEFT",c,"BOTTOMLEFT",0,-20)sl:SetText("Sound:")
local dd=CreateFrame("Frame",nil,f,"UIDropDownMenuTemplate")dd:SetPoint("LEFT",sl,"RIGHT",-10,-2)UIDropDownMenu_SetWidth(dd,140)

local sb=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")sb:SetSize(70,22)sb:SetPoint("TOPLEFT",sl,"BOTTOMLEFT",0,-20)sb:SetText("Set")
local tb=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")tb:SetSize(70,22)tb:SetPoint("LEFT",sb,"RIGHT",10,0)tb:SetText("Test")

local cs=f:CreateFontString(nil,"OVERLAY","GameFontNormal")cs:SetPoint("BOTTOMLEFT",20,20)
local ss=f:CreateFontString(nil,"OVERLAY","GameFontNormal")ss:SetPoint("BOTTOMRIGHT",-20,20)

local u=function()cs:SetText("Crit: "..CritSoundCharDB.critNumber)ss:SetText("Sound: "..CritSoundCharDB.sound)end
sb:SetScript("OnClick",function()CritSoundCharDB.critNumber=math.min(math.max(tonumber(i:GetText())or 1000,1),999999)u()end)
tb:SetScript("OnClick",function()PlaySoundFile("Interface\\AddOns\\CritSound\\"..CritSoundCharDB.sound,"Master")end)

f:SetScript("OnShow",function()
    i:SetText(CritSoundCharDB.critNumber)
    UIDropDownMenu_Initialize(dd,function()
        for _,v in ipairs(s)do
            local info=UIDropDownMenu_CreateInfo()
            info.text=v
            info.func=function()CritSoundCharDB.sound=v UIDropDownMenu_SetText(dd,v)end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(dd,CritSoundCharDB.sound)
    u()
end)

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent",function()
    local e={CombatLogGetCurrentEventInfo()}
    local ev,g,d,c=e[2],e[4],e[15],e[21]
    if g==UnitGUID("player")and c and d and d>=CritSoundCharDB.critNumber and(ev=="SWING_DAMAGE"or ev=="SPELL_DAMAGE"or ev=="RANGE_DAMAGE")then
        local t=GetTime()local cd=math.random(300,800)/1000
        if t-l>=cd then PlaySoundFile("Interface\\AddOns\\CritSound\\"..CritSoundCharDB.sound,"Master")l=t end
    end
end)

SLASH_CRITSOUND1,SLASH_CRITSOUND2="/critsound","/cs"
SlashCmdList["CRITSOUND"]=function()f:SetShown(not f:IsShown())end
