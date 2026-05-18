local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetPosition = Base:Extend("LuaActionGetPosition")

function LuaActionGetPosition:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local target = self.Target:GetValue(owner)
  local outPoint
  if target.GetActorLocation then
    outPoint = target:GetActorLocation()
  else
    outPoint = target:Abs_K2_GetActorLocation()
  end
  self.OutPosition:SetValue(owner, outPoint)
  self:Finish(true)
end

return LuaActionGetPosition
