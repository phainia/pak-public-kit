local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceLocalControl = Base:Extend("LuaServiceLocalControl")

function LuaServiceLocalControl:OnStart(OwnerController, ...)
  local args = {
    ...
  }
  local owner = OwnerController
  self.TempBool:SetValue(owner, true)
end

function LuaServiceLocalControl:OnEnd(OwnerController, ...)
  local args = {
    ...
  }
  local owner = OwnerController
  self.TempBool:SetValue(owner, false)
end

return LuaServiceLocalControl
