require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local NpcOptionEvent = require("NewRoco.Modules.Core.NPC.Executors.NpcOptionEvent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local BP_NPCStatue_ATM_C = Base:Extend("BP_NPCStatue_ATM_C")

function BP_NPCStatue_ATM_C:Init()
  Base.Init(self)
  self.bShowing = false
end

function BP_NPCStatue_ATM_C:ReceiveDestroyed()
  Base.ReceiveDestroyed(self)
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
end

function BP_NPCStatue_ATM_C:OnOptionChange(Option, Action, BaseData)
  if not Action.act_info or 1 ~= Action.act_info.act_status then
    return
  end
  self:PlayActivatedShow()
end

function BP_NPCStatue_ATM_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    local Options = self.sceneCharacter.InteractionComponent:GetAllOptions()
    for _, Option in pairs(Options) do
      Option:AddEventListener(self, NpcOptionEvent.OptionChange, self.OnOptionChange)
    end
    if self.InitShowTime then
      self:InitShowTime()
    end
  else
    local Options = self.sceneCharacter.InteractionComponent:GetAllOptions()
    for _, Option in pairs(Options) do
      Option:RemoveEventListener(self, NpcOptionEvent.OptionChange, self.OnOptionChange)
    end
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_NPCStatue_ATM_C:UpdateData(ServerData, bIsReconnect)
  if bIsReconnect and not self.bShowing and self:CheckIsActivated() then
    self:PlayActivatedShow()
  end
end

function BP_NPCStatue_ATM_C:CheckIsActivated()
  local OptionInfos = self.sceneCharacter.InteractionComponent:GetAllOptions()
  for _, Option in ipairs(OptionInfos) do
    return not Option:IsOptionEnable(false)
  end
  return false
end

function BP_NPCStatue_ATM_C:PlayActivatedShow()
  if self.bShowing then
    return
  end
  self.bShowing = true
  self.sceneCharacter.InteractionComponent:SetInteractionEnable(false, NPCModuleEnum.NpcInteractDisableFlag.ANY, true)
  self:PlayDropCoins()
  self.DelayHandle = _G.DelayManager:DelaySeconds(self.ShowTime, self.OnShowFinished, self)
end

function BP_NPCStatue_ATM_C:OnShowFinished()
  self.bShowing = false
  self.sceneCharacter.InteractionComponent:SetInteractionEnable(true, NPCModuleEnum.NpcInteractDisableFlag.ANY, true)
  self.DelayHandle = nil
end

function BP_NPCStatue_ATM_C:GetMainOption()
  return self.sceneCharacter.InteractionComponent:GetFirstOption()
end

return BP_NPCStatue_ATM_C
