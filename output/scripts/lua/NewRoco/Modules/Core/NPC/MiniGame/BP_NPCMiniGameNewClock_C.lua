local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCMiniGameNewClock_C = Base:Extend("BP_NPCMiniGameNewClock_C")

function BP_NPCMiniGameNewClock_C:RedLightGreenDark()
  if not self.Dark or not self.Light then
    Log.Error("BP_NPCMiniGameNewClock_C:RedLightGreenDark: self.Dark or self.Light is nil")
    return
  end
  if self.StaticMesh:GetMaterial(0) and self.StaticMesh:GetMaterial(1) and self.StaticMesh:GetMaterial(2) then
    self.StaticMesh:SetMaterial(0, self.Dark)
    self.StaticMesh:SetMaterial(1, self.Light)
    self.StaticMesh:SetMaterial(2, self.Dark)
  end
  self:ShowIcon()
end

function BP_NPCMiniGameNewClock_C:RedDarkGreenLight()
  if not self.Dark or not self.Light then
    Log.Error("BP_NPCMiniGameNewClock_C:RedDarkGreenLight: self.Dark or self.Light is nil")
    return
  end
  if self.StaticMesh:GetMaterial(0) and self.StaticMesh:GetMaterial(1) and self.StaticMesh:GetMaterial(2) then
    self.StaticMesh:SetMaterial(0, self.Light)
    self.StaticMesh:SetMaterial(1, self.Dark)
    self.StaticMesh:SetMaterial(2, self.Light)
  end
  self:ShowIcon()
end

function BP_NPCMiniGameNewClock_C:AllDark()
  self:CloseIcon()
  self:CloseLight()
  if not self.Dark or not self.Light then
    Log.Error("BP_NPCMiniGameNewClock_C:AllDark: self.Dark or self.Light is nil")
    return
  end
  if self.StaticMesh:GetMaterial(0) and self.StaticMesh:GetMaterial(1) and self.StaticMesh:GetMaterial(2) then
    self.StaticMesh:SetMaterial(0, self.Dark)
    self.StaticMesh:SetMaterial(1, self.Dark)
  end
end

function BP_NPCMiniGameNewClock_C:OnLoadResource()
  Base.OnLoadResource(self)
  local OptionID = self.sceneCharacter.config.option_id
  if next(OptionID) == nil then
    return
  end
  local OptionConf = _G.DataConfigManager:GetNpcOptionConf(OptionID[1])
  if OptionConf and OptionConf.action and OptionConf.action.action_param1 then
    self.sceneCharacter.MiniGameID = tonumber(OptionConf.action.action_param1)
  end
  self.FinishFlag = self.sceneCharacter.luaObj.Finished
  if self.FinishFlag then
    self:AllDark()
  end
end

function BP_NPCMiniGameNewClock_C:OnVisible()
  local Character = self.sceneCharacter
  if not (Character and Character.MiniGameID) or Character.MiniGameID ~= Character.luaObj.ConfigId then
    return
  end
  local Status
  if MiniGameModuleCmd then
    Status = _G.NRCModuleManager:DoCmd(MiniGameModuleCmd.GetState)
  else
    Log.Error("MiniGameModuleCmd is missing, \231\150\145\228\188\188\230\168\161\229\157\151\229\176\154\230\156\170\229\144\175\229\138\168")
  end
  if Status == ProtoEnum.MinigameStatus.MS_OPEN then
    self:RedLightGreenDark()
  elseif self.FinishFlag or Status == ProtoEnum.MinigameStatus.MS_FINISH then
    self:AllDark()
  end
  self.sceneCharacter.luaObj:ApplySettings()
  if MiniGameModuleCmd then
    NRCModuleManager:DoCmd(MiniGameModuleCmd.AddClock, self)
  else
    Log.Error("MiniGameModuleCmd is missing, \231\150\145\228\188\188\230\168\161\229\157\151\229\176\154\230\156\170\229\144\175\229\138\168")
  end
  _G.NRCEventCenter:RegisterEvent("BP_NPCMiniGameClock_C", self, MiniGameModuleEvent.Start, self.MiniGameStart)
  Base.OnVisible(self)
end

function BP_NPCMiniGameNewClock_C:OnInVisible()
  _G.NRCEventCenter:UnRegisterEvent(self, MiniGameModuleEvent.Start, self.MiniGameStart)
  Base.OnInVisible(self)
end

function BP_NPCMiniGameNewClock_C:MiniGameStart()
  if MiniGameModuleCmd then
    NRCModuleManager:DoCmd(MiniGameModuleCmd.AddClock, self)
  end
end

function BP_NPCMiniGameNewClock_C:SetFinished()
end

function BP_NPCMiniGameNewClock_C:Poof()
  self.sceneCharacter.luaObj.BlockUpdate = false
  self.Overridden.Poof(self)
end

function BP_NPCMiniGameNewClock_C:SetClockLevelByStatus()
  local Comp = self.sceneCharacter.LogicStatusComponent
  if not Comp or Comp:GetStatus(Enum.SpaceActorLogicStatus.SALS_BRONZE_MINIGAME) then
  elseif Comp:GetStatus(Enum.SpaceActorLogicStatus.SALS_SILVER_MINIGAME) then
  elseif Comp:GetStatus(Enum.SpaceActorLogicStatus.SALS_GOLD_MINIGAME) then
  end
end

return BP_NPCMiniGameNewClock_C
