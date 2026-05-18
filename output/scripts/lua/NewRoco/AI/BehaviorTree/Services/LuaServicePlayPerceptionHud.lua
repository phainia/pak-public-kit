local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local SceneEnum = require("NewRoco.Modules.Core.Scene.Common.SceneEnum")
local LuaServicePlayPerceptionHud = Base:Extend("LuaActionPlayPerceptionHud")

function LuaServicePlayPerceptionHud:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  self.waitingGroupTarget = false
  self.attempCount = 20
  local PerceptionLevel = self.Level:GetValue(owner)
  if PerceptionLevel == SceneEnum.PerceptionHudType.GroupTarget then
    self.waitingGroupTarget = owner:SendGetDynamicGroupTargetEvent()
    if self.waitingGroupTarget then
      self.delayHandle = DelayManager:DelaySeconds(0.2, self.CheckGroupTarget, self, owner)
    end
  elseif owner.Npc and owner.Npc.PetHUDComponent then
    local PetHudComp = owner.Npc.PetHUDComponent
    PetHudComp:SetPerceptionTargetingNpc(nil)
    PetHudComp:SetMainHudPerception(PerceptionLevel)
  end
end

function LuaServicePlayPerceptionHud:OnEnd(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  if owner.Npc and owner.Npc.PetHUDComponent then
    owner.Npc.PetHUDComponent:SetMainHudPerception(SceneEnum.PerceptionHudType.None)
  end
  if self.delayHandle then
    DelayManager:CancelDelayById(self.delayHandle)
    self.delayHandle = nil
  end
end

function LuaServicePlayPerceptionHud:CheckGroupTarget(owner)
  self.delayHandle = nil
  if self.waitingGroupTarget and self.attempCount > 0 then
    local viewObj = owner:GetDynamicGroupTarget()
    if viewObj and viewObj.sceneCharacter then
      local PetHudComp = owner.Npc.PetHUDComponent
      PetHudComp:SetPerceptionTargetingNpc(viewObj.sceneCharacter)
      PetHudComp:SetMainHudPerception(SceneEnum.PerceptionHudType.GroupTarget)
    else
      self.delayHandle = DelayManager:DelaySeconds(0.2, self.CheckGroupTarget, self, owner)
      self.attempCount = self.attempCount - 1
    end
  end
end

return LuaServicePlayPerceptionHud
