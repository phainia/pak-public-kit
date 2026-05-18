local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetForwardPos = Base:Extend("LuaActionGetForwardPos")

function LuaActionGetForwardPos:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local targetActor = self.Actor:GetValue(owner)
  local position, forward
  if targetActor.GetActorLocation then
    position = targetActor:GetActorLocation()
    forward = targetActor:GetForwardVector()
  else
    position = targetActor:Abs_K2_GetActorLocation()
    forward = targetActor:GetActorForwardVector()
  end
  local result = position + forward * 100
  result.Z = 0
  self.OutForwardPos:SetValue(owner, result)
  if self.OutForwardDir and self.OutForwardDir.useBlackboardKey then
    self.OutForwardDir:SetValue(owner, forward)
  end
  self:Finish(true)
end

return LuaActionGetForwardPos
