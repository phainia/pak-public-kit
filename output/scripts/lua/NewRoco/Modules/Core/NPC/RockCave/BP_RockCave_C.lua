require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local HoldingItemComponent = require("NewRoco.Modules.Core.Scene.Component.Show.HoldingItemComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_RockCave_C = Base:Extend("BP_RockCave_C")
local RockCaveState = {
  NONE = 1,
  NORMAL = 2,
  ACTIVATED = 3
}

function BP_RockCave_C:OnVisible()
  Base.OnVisible(self)
  self.state = RockCaveState.NONE
  if not self.sceneCharacter then
    Log.Error("BP_RockCave_C:OnVisible without sceneCharacter")
    return
  end
  self.sceneCharacter:EnsureComponent(HoldingItemComponent)
  self.sceneCharacter.HoldingItemComponent:ClearAllItem()
  if self:IsActivated() then
    self:SetActiveState()
  else
    self:SetNormalState()
  end
end

function BP_RockCave_C:UpdateState()
  if self:IsActivated() then
    if self.state ~= RockCaveState.ACTIVATED then
      self:SetActiveState()
    end
  else
    self:SetNormalState()
  end
end

function BP_RockCave_C:OnLogicStatusChanged()
  if self:IsActivated() then
    self:Broken()
  else
    self:SetNormalState()
  end
end

function BP_RockCave_C:OnInVisible()
  _G.NRCAudioManager:StopAllForActor(self)
  Base.OnInVisible(self)
  if self.sceneCharacter then
    self.sceneCharacter:EnsureComponent(HoldingItemComponent)
    self.sceneCharacter.HoldingItemComponent:ClearAllItem()
  end
  self.state = RockCaveState.NONE
end

function BP_RockCave_C:IsActivated()
  return SceneUtils.IsLogicStatusTriggerOn(self.sceneCharacter)
end

function BP_RockCave_C:GetWindOption()
  for _, option in pairs(self.sceneCharacter.InteractionComponent._options) do
    if option.CurrentMagicActions then
      for _, magic_action in pairs(option.CurrentMagicActions) do
        if magic_action.Config.action_type == _G.Enum.ActionType.ACT_WIND_TUNNEL then
          return option
        end
      end
    end
  end
  return nil
end

function BP_RockCave_C:SetNormalState()
  if self.state == RockCaveState.NORMAL then
    return
  end
  self.state = RockCaveState.NORMAL
  _G.NRCAudioManager:StopAllForActor(self)
  local performConf = _G.DataConfigManager:GetPerformConf(201)
  self.sceneCharacter:PlayShowById(performConf)
  self.SkeletalMesh:SetCollisionEnabled(UE4.ECollisionEnabled.QueryAndPhysics)
end

function BP_RockCave_C:Broken()
  if self.state == RockCaveState.ACTIVATED then
    return
  end
  _G.NRCAudioManager:PlaySound3DWithActorAuto(101002801, self)
  self.state = RockCaveState.ACTIVATED
  local performConf = _G.DataConfigManager:GetPerformConf(202)
  self.sceneCharacter:PlayShowById(performConf)
  self.SkeletalMesh:SetCollisionEnabled(UE4.ECollisionEnabled.NoCollision)
end

function BP_RockCave_C:SetActiveState()
  if self.state == RockCaveState.ACTIVATED then
    return
  end
  _G.NRCAudioManager:PlaySound3DWithActorAuto(101002802, self)
  self.state = RockCaveState.ACTIVATED
  local performConf = _G.DataConfigManager:GetPerformConf(203)
  self.sceneCharacter:PlayShowById(performConf)
  self.SkeletalMesh:SetCollisionEnabled(UE4.ECollisionEnabled.NoCollision)
end

return BP_RockCave_C
