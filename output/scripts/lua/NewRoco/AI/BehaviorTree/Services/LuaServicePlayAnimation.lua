local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServicePlayAnimation = Base:Extend("LuaServicePlayAnimation")
local SceneAnimEnum = require("NewRoco.Modules.Core.Scene.Common.SceneAnimEnum")

function LuaServicePlayAnimation:OnStart(OwnerController, ...)
  local args = {
    ...
  }
  local owner = OwnerController
  local animName = ""
  if self.AnimationName.type == LuaParamType.String then
    animName = self.AnimationName:GetValue(owner)
  else
    animName = SceneAnimEnum.AnimationNameRev[self.AnimationName:GetValue(owner)]
  end
  self.animationName = animName
  local rate = self.PlayRate:GetValue(owner)
  local startPos = self.StartPos:GetValue(owner)
  local blendTime = self.StartPos:GetValue(owner)
  local blendOutTime = self.BlendOutTime:GetValue(owner)
  local loopCount = 99999
  local isAnimPlaying = owner.Npc.viewObj:IsAnimPlaying(animName)
  if isAnimPlaying then
    return
  end
  local task = LuaBTUtils.SPT_PlayAnimation
  task.Execute(owner, animName, rate, startPos, blendTime, blendOutTime, loopCount)
end

function LuaServicePlayAnimation:OnEnd(OwnerController, ...)
  local args = {
    ...
  }
  local owner = OwnerController
  owner.Npc.viewObj.animComponent:StopAnimByName(self.animationName)
end

return LuaServicePlayAnimation
