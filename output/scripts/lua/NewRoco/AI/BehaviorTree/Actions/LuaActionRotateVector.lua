local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionRotateVector = Base:Extend("LuaActionRotateVector")

function LuaActionRotateVector:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local angle = self.RotateAngle:GetValue(owner)
  if self.CounterClock:GetValue(owner) then
    angle = 360 - angle
  end
  self.OutputVector:SetValue(owner, self.InputVector:GetValue(owner):RotateAngleAxis(angle, UE4.FVector(0, 0, 1)))
  self:Finish(true)
end

return LuaActionRotateVector
