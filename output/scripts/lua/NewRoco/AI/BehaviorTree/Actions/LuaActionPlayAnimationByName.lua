local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionPlayAnimationByName = Base:Extend("LuaActionPlayAnimationByName")
local SceneAnimEnum = require("NewRoco.Modules.Core.Scene.Common.SceneAnimEnum")

function LuaActionPlayAnimationByName:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local animName = self.AnimationName:GetValue(owner)
  self.animationName = animName
  self.leftAnimLen = 0
  local rate = self.PlayRate:GetValue(owner)
  local startPos = self.StartPos:GetValue(owner)
  local blendTime = self.BlendInTime:GetValue(owner)
  local blendOutTime = self.BlendOutTime:GetValue(owner)
  local loopCount = self.LoopCount:GetValue(owner)
  local ApplyRootZ = self.ApplyRootZ and self.ApplyRootZ:GetValue(owner)
  local Model = owner.Npc.viewObj
  local isAnimPlaying = false
  if Model then
    isAnimPlaying = owner.Npc.viewObj:GetAnimComponent():IsAnimPlaying(animName)
  end
  if isAnimPlaying then
    owner.Npc:OverrideCurrentAnimRate(rate)
    self:Finish(true)
    return
  end
  local bIsUsingFlyAnim = ApplyRootZ
  if bIsUsingFlyAnim and Model then
    Model.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Flying)
  end
  local task = LuaBTUtils.SPT_PlayAnimation
  self.leftAnimLen = task.Execute(owner, animName, rate, startPos, blendTime, blendOutTime, loopCount) or 0
  if 0 == self.leftAnimLen then
    return self:Finish(false)
  end
  self.nonBlock = self.NonBlock:GetValue(owner)
  if self.nonBlock then
    self:Finish(true)
  end
end

function LuaActionPlayAnimationByName:OnUpdate(AIController, DeltaTime, ...)
  local owner = AIController
  if not self.nonBlock then
    self.leftAnimLen = self.leftAnimLen - DeltaTime
    if self.leftAnimLen < 0 then
      local Model = owner.Npc.viewObj
      if Model then
        Model.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Walking)
      end
      self:Finish(true)
    end
  end
end

function LuaActionPlayAnimationByName:OnInterrupt(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  if self.StopIfExit and self.StopIfExit:GetValue(owner) then
    owner.Npc.viewObj:GetAnimComponent():StopAnimByName(self.animationName, self.BlendOutTime:GetValue(owner))
  end
  self:Finish(false)
end

return LuaActionPlayAnimationByName
