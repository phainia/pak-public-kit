local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = DebugTabBase
local DebugTabPetUI = Base:Extend("DebugTabPetUI")

function DebugTabPetUI:Ctor()
  Base.Ctor(self)
end

function DebugTabPetUI:SetupTabs()
  self:Add("\229\133\179\233\151\173\231\178\190\231\129\181\231\188\150\233\152\159\231\149\140\233\157\162", self.ClosePetTeam, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173\231\178\190\231\129\181\229\191\171\233\128\159\231\188\150\233\152\159\231\149\140\233\157\162", self.ClosePetTeamReplace, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128\230\150\176\231\154\132\231\178\190\231\129\181\231\188\150\233\152\159\229\141\143\232\174\174", self.OpenNewPetTeamReplaceMessage, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabPetUI:ShowReadMe(name, panel)
  UE4.UKismetSystemLibrary.LaunchURL("https://iwiki.woa.com/pages/viewpage.action?pageId=827460344")
end

function DebugTabPetUI:OnSetPercentage(name, panel, InputNumber)
  local num
  if panel then
    num = tonumber(panel.InputBox:GetText())
  else
    num = tonumber(InputNumber)
  end
  NRCEventCenter:DispatchEvent(PetUIModuleEvent.DebugPetUIPercentage, num)
end

function DebugTabPetUI:OnSetPosOffset(name, panel, InputText)
  local Numa
  if panel then
    Numa = self:Split(panel.InputBox:GetText(), ",")
  else
    Numa = self:Split(InputText, ",")
  end
  local x = tonumber(Numa[1])
  local y = tonumber(Numa[2])
  local z = tonumber(Numa[3])
  NRCEventCenter:DispatchEvent(PetUIModuleEvent.DebugPetPosOffset, x, y, z)
end

function DebugTabPetUI:OnSetCameraSpin(name, panel, InputText)
  local Numa
  if panel then
    Numa = self:Split(panel.InputBox:GetText(), ",")
  else
    Numa = self:Split(InputText, ",")
  end
  local x = tonumber(Numa[1])
  local y = tonumber(Numa[2])
  local z = tonumber(Numa[3])
  NRCEventCenter:DispatchEvent(PetUIModuleEvent.DebugCameraSpin, x, y, z)
end

function DebugTabPetUI:OnShowDebug()
  NRCEventCenter:DispatchEvent(PetUIModuleEvent.ShowDebug)
end

function DebugTabPetUI:OnUseZ()
  NRCEventCenter:DispatchEvent(PetUIModuleEvent.UseAnimZ)
end

function DebugTabPetUI:Split(s, delimiter)
  local result = {}
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

function DebugTabPetUI:OnApplyChanges()
  NRCEventCenter:DispatchEvent(PetUIModuleEvent.ApplyPetUIParameters)
end

function DebugTabPetUI:ClosePetTeam()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.ClosePetTeamPanel)
end

function DebugTabPetUI:ClosePetTeamReplace()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.ClosePetTeamReplacePanel)
end

function DebugTabPetUI:OpenNewPetTeamReplaceMessage()
  _G.IsOpenNewPetTeamReplaceMessage = true
end

return DebugTabPetUI
