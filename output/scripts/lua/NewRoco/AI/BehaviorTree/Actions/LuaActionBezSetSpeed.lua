local BezierFlyComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.BezierFlyComponent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionBezSetSpeed = Base:Extend("LuaActionBezSetSpeed")

function LuaActionBezSetSpeed:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local npc = owner.Npc
  local flyComp = npc:EnsureComponent(BezierFlyComponent)
  if flyComp then
    flyComp.speedBase = self.NewSpeed:GetValue(owner)
  end
  self:Finish(true)
end

return LuaActionBezSetSpeed
