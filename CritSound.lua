local f=CreateFrame("Frame","CritSoundFrame",UIParent,"BackdropTemplate")
f:SetSize(280,180)f:SetPoint("CENTER")f:SetBackdrop{bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=1,tileSize=32,edgeSize=32,insets={8,8,8,8}}
f:EnableMouse(true)f:SetMovable(true)f:RegisterForDrag("LeftButton")f:SetScript("OnDragStart",f.StartMoving)f:SetScript("OnDragStop",f.StopMovingOrSizing)f:Hide()

CritSoundCharDB=CritSoundCharDB or{critNumber=420,sound="sound04.ogg",enabled=true}
local P=(...)and select(2,...):match("(.+\\)")or""
local s={"sound01.ogg","sound02.ogg","sound03.ogg","sound04.ogg","sound05.ogg","sound06.ogg","sound07.ogg","sound08.ogg","sound09.ogg","sound10.ogg"}
local q,last= {},0

CreateFrame("Frame"):SetScript("OnUpdate",function()
 if#q>0 and GetTime()-last>=math.random(300,800)/1000 then
  PlaySoundFile(P..table.remove(q,1),"Master")last=GetTime()
 end
end)

local function add(sound)if CritSoundCharDB.enabled and#q<15 then tinsert(q,sound)end end

CreateFrame("Button",nil,f,"UIPanelCloseButton"):SetPoint("TOPRIGHT",-5,-5):SetScale(0.8)

local ec=CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate")ec:SetPoint("TOPLEFT",20,-20)
ec:SetScript("OnClick",function(self)CritSoundCharDB.enabled=self:GetChecked()upd()end)
local el=f:CreateFontString(nil,"OVERLAY","GameFontNormal")el:SetPoint("LEFT",ec,"RIGHT",5,0)el:SetText("Enabled")

local l=f:CreateFontString(nil,"OVERLAY","GameFontNormal")l:SetPoint("TOPLEFT",20,-50)l:SetText("Min Crit:")
local i=CreateFrame("EditBox",nil,f,"InputBoxTemplate")i:SetSize(80,20)i:SetPoint("LEFT",l,"RIGHT",10,0)i:SetAutoFocus(false)i:SetNumeric(true)i:SetMaxLetters(7)

local sl=f:CreateFontString(nil,"OVERLAY","GameFontNormal")sl:SetPoint("TOPLEFT",l,"BOTTOMLEFT",0,-25)sl:SetText("Sound:")
local dd=CreateFrame("Frame",nil,f,"UIDropDownMenuTemplate")dd:SetPoint("LEFT",sl,"RIGHT",-10,-2)UIDropDownMenu_SetWidth(dd,150)

local b=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")b:SetSize(70,22)b:SetPoint("TOPLEFT",sl,"BOTTOMLEFT",0,-25)b:SetText("Set")
local t=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")t:SetSize(70,22)t:SetPoint("LEFT",b,"RIGHT",10,0)t:SetText("Test")
local r=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")r:SetSize(70,22)r:SetPoint("LEFT",t,"RIGHT",10,0)r:SetText("Reset")

local c=f:CreateFontString(nil,"OVERLAY","GameFontNormal")c:SetPoint("BOTTOMLEFT",20,30)
local s2=f:CreateFontString(nil,"OVERLAY","GameFontNormal")s2:SetPoint("BOTTOMRIGHT",-20,30)
local qt=f:CreateFontString(nil,"OVERLAY","GameFontNormal")qt:SetPoint("BOTTOM",0,15)

function upd()
 c:SetText("Crit: "..CritSoundCharDB.critNumber)
 s2:SetText("Sound: "..CritSoundCharDB.sound)
 qt:SetText("Queue: "..#q.."/15")
 el:SetTextColor(CritSoundCharDB.enabled and 0 or 0.5,CritSoundCharDB.enabled and 1 or 0.5,0.5)
end

b:SetScript("OnClick",function()
 local n=tonumber(i:GetText())
 if n and n>=1 and n<=999999 then CritSoundCharDB.critNumber=n upd() end
end)
t:SetScript("OnClick",function() add(CritSoundCharDB.sound) end)
r:SetScript("OnClick",function() q={} upd() end)

f:SetScript("OnShow",function()
 i:SetText(CritSoundCharDB.critNumber)ec:SetChecked(CritSoundCharDB.enabled)
 if not dd.init then
  UIDropDownMenu_Initialize(dd,function()
   for _,v in ipairs(s)do
    local info=UIDropDownMenu_CreateInfo()
    info.text=v info.func=function()CritSoundCharDB.sound=v UIDropDownMenu_SetText(dd,v) upd() end
    UIDropDownMenu_AddButton(info)
   end
  end)
  dd.init=true
 end
 UIDropDownMenu_SetText(dd,CritSoundCharDB.sound) upd()
end)

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent",function()
 if not CritSoundCharDB.enabled then return end
 local e={CombatLogGetCurrentEventInfo()}
 local ev,g,a,crit=e[2],e[4],e[15],e[21]
 if g==UnitGUID("player") and crit and a and a>=CritSoundCharDB.critNumber and (ev=="SWING_DAMAGE" or ev=="SPELL_DAMAGE" or ev=="RANGE_DAMAGE" or ev=="SPELL_PERIODIC_DAMAGE") then
  add(CritSoundCharDB.sound)
 end
end)

C_Timer.NewTicker(0.5,function()if f:IsShown()then upd()end end)

SLASH_CRITSOUND1,SLASH_CRITSOUND2,SLASH_CRITSOUND3="/critsound","/cs","/crit"
SlashCmdList.CRITSOUND=function(msg)
 if msg=="toggle" then
  CritSoundCharDB.enabled=not CritSoundCharDB.enabled
  print("CritSound: "..(CritSoundCharDB.enabled and "On" or "Off"))
 elseif msg=="clear" then
  q={}
  print("CritSound: Queue cleared")
 else
  f:SetShown(not f:IsShown())
 end
end
