local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionPlayAnimation = Base:Extend("LuaActionPlayAnimation")
local SceneAnimEnum = require("NewRoco.Modules.Core.Scene.Common.SceneAnimEnum")

function LuaActionPlayAnimation:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local animName = ""
  if self.AnimationName.type == LuaParamType.String then
    animName = self.AnimationName:GetValue(owner)
  else
    animName = SceneAnimEnum.AnimationNameRev[self.AnimationName:GetValue(owner)]
  end
  self.animationName = animName
  local rate = self.PlayRate:GetValue(owner)
  local startPos = self.StartPos:GetValue(owner)
  local blendTime = self.BlendInTime:GetValue(owner)
  local blendOutTime = self.BlendOutTime:GetValue(owner)
  local loopCount = self.LoopCount:GetValue(owner)
  local Model = owner.Npc.viewObj
  local isAnimPlaying = Model:GetAnimComponent():IsAnimPlaying(animName)
  if isAnimPlaying then
    owner.Npc:OverrideCurrentAnimRate(rate)
    self:Finish(true)
    return
  end
  local ApplyRootZ = self.ApplyRootZ and self.ApplyRootZ:GetValue(owner)
  local bIsUsingFlyAnim = ApplyRootZ
  if bIsUsingFlyAnim and Model then
    Model.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Flying)
  end
  local task = LuaBTUtils.SPT_PlayAnimation
  self.leftAnimLen = task.Execute(owner, animName, rate, startPos, blendTime, blendOutTime, loopCount) or 0
  self.nonBlock = self.NonBlock:GetValue(owner)
  if self.nonBlock then
    self:Finish(true)
  end
end

function LuaActionPlayAnimation:OnUpdate(AIController, DeltaTime, ...)
  if not self.nonBlock then
    self.leftAnimLen = self.leftAnimLen - DeltaTime
    if self.leftAnimLen < 0 then
      self:Finish(true)
    end
  end
end

function LuaActionPlayAnimation:OnInterrupt(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  if self.StopIfExit and self.StopIfExit:GetValue(owner) then
    owner.Npc.viewObj:GetAnimComponent():StopAnimByName(self.animationName, self.BlendOutTime:GetValue(owner))
  end
  self:Finish(false)
end

return LuaActionPlayAnimation
