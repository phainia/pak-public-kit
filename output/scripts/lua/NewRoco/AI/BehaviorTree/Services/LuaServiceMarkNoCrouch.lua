local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceMarkNoCrouch = Base:Extend("LuaServiceMarkNoCrouch")

function LuaServiceMarkNoCrouch:OnStart(OwnerController, ...)
  NRCModuleManager:DoCmd(PlayerModuleCmd.MarkNoCrouch, true)
end

function LuaServiceMarkNoCrouch:OnEnd(OwnerController, ...)
  NRCModuleManager:DoCmd(PlayerModuleCmd.MarkNoCrouch, false)
end

return LuaServiceMarkNoCrouch
