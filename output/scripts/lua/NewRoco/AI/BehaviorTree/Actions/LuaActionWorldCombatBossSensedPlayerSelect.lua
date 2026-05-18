local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionWorldCombatBossSensedPlayerSelect = Base:Extend("LuaActionWorldCombatBossSensedPlayerSelect")

function LuaActionWorldCombatBossSensedPlayerSelect:OnStart(AIController, ...)
  self:Finish(true)
end

return LuaActionWorldCombatBossSensedPlayerSelect
