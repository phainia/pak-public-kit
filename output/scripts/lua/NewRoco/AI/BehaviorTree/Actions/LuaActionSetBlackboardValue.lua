local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaAcionSetBlackboardValue = Base:Extend("LuaAcionSetBlackboardValue")

function LuaAcionSetBlackboardValue:Ctor(LuaBTNodeBase)
  Base.Ctor(self, LuaBTNodeBase)
end

function LuaAcionSetBlackboardValue:OnStart(AIController, ...)
  Base.OnStart(self, ...)
  local aiController = AIController
  if self.OldValue:GetType() ~= self.NewValue:GetType() then
    Log.Error("Can't set value on different type")
    self:Finish(false)
    return
  end
  local newValue = self.NewValue:GetValue(aiController)
  self.OldValue:SetValue(aiController, newValue)
  self:Finish(true)
end

return LuaAcionSetBlackboardValue
