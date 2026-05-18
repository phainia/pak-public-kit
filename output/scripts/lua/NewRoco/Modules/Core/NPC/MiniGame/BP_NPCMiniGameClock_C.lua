local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCMiniGameClock_C = Base:Extend("BP_NPCMiniGameClock_C")

function BP_NPCMiniGameClock_C:RefreshStarScale()
  self:SetCaughtStarNum(0)
  if self.sceneCharacter.luaObj.Finished then
    self:SetCaughtStarNum(5)
  end
end

function BP_NPCMiniGameClock_C:OnLoadResource()
  Base.OnLoadResource(self)
  self:UpdateStartCount()
end

function BP_NPCMiniGameClock_C:OnVisible()
  self.sceneCharacter.luaObj:ApplySettings()
  if MiniGameModuleCmd then
    NRCModuleManager:DoCmd(MiniGameModuleCmd.AddClock, self)
  else
    Log.Error("MiniGameModuleCmd is missing, \231\150\145\228\188\188\230\168\161\229\157\151\229\176\154\230\156\170\229\144\175\229\138\168")
  end
  self:RefreshStarScale()
  _G.NRCEventCenter:RegisterEvent("BP_NPCMiniGameClock_C", self, MiniGameModuleEvent.Start, self.MiniGameStart)
  Base.OnVisible(self)
  self:UpdateStartCount()
end

function BP_NPCMiniGameClock_C:OnInVisible()
  _G.NRCEventCenter:UnRegisterEvent(self, MiniGameModuleEvent.Start, self.MiniGameStart)
  Base.OnInVisible(self)
end

function BP_NPCMiniGameClock_C:MiniGameStart()
  if MiniGameModuleCmd then
    NRCModuleManager:DoCmd(MiniGameModuleCmd.AddClock, self)
  end
end

function BP_NPCMiniGameClock_C:UpdateStartCount()
  local MiniGameModule = _G.NRCModuleManager:GetModule("MiniGameModule")
  if MiniGameModule then
    self:SetCaughtStarNum(MiniGameModule:GetStarCount(self.sceneCharacter:GetServerId()))
  else
    self:SetCaughtStarNum(0)
  end
end

function BP_NPCMiniGameClock_C:SetCaughtStarNum(ProgressValue)
  if not self.sceneCharacter then
    Log.Error("BP_NPCMiniGameClock_C SceneCharacter is nil")
    return
  end
  if self.sceneCharacter.luaObj.Finished then
    ProgressValue = 5
  end
  self.LightProgressMap = {
    1.1,
    0.6,
    0.25,
    0.06,
    0.02,
    0
  }
  if ProgressValue >= 0 and ProgressValue < 6 then
    self:SetStarLight(self.LightProgressMap[ProgressValue + 1])
  end
end

function BP_NPCMiniGameClock_C:SetFinished()
end

function BP_NPCMiniGameClock_C:Poof()
  self.sceneCharacter.luaObj.BlockUpdate = false
  self.Overridden.Poof(self)
end

function BP_NPCMiniGameClock_C:SetClockLevelByStatus()
  local Comp = self.sceneCharacter.LogicStatusComponent
  if not Comp or Comp:GetStatus(Enum.SpaceActorLogicStatus.SALS_BRONZE_MINIGAME) then
  elseif Comp:GetStatus(Enum.SpaceActorLogicStatus.SALS_SILVER_MINIGAME) then
  elseif Comp:GetStatus(Enum.SpaceActorLogicStatus.SALS_GOLD_MINIGAME) then
  end
end

return BP_NPCMiniGameClock_C
