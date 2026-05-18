local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionStopAnimation = Base:Extend("LuaActionStopAnimation")
local SceneAnimEnum = require("NewRoco.Modules.Core.Scene.Common.SceneAnimEnum")

function LuaActionStopAnimation:OnStart(AIController, ...)
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
  owner.Npc.viewObj:GetAnimComponent():StopAnimByName(animName)
  self:Finish(true)
end

return LuaActionStopAnimation
