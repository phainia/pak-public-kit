local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionSetNavFilter = Base:Extend("LuaActionSetNavFilter")

function LuaActionSetNavFilter:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local SetMode = self.SetMode:GetValue(owner)
  local Flag = self.Flag:GetValue(owner)
  owner:SetNavFlagFilter(Flag, 0 == SetMode)
  self:Finish(true)
end

return LuaActionSetNavFilter
