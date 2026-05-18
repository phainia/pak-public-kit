local BattleAIInputParams = require("NewRoco.Modules.Core.Battle.AI.BattleAIInputParams")
local BP_BattleEllipticCenter_C = _G.NRCClass:Extend("BP_BattleEllipticCenter_C")

function BP_BattleEllipticCenter_C:Ctor()
  Log.Debug("BP_BattleEllipticCenter_C initialize Ctor")
end

function BP_BattleEllipticCenter_C:Initialize()
  Log.Debug("BP_BattleEllipticCenter_C initialize")
end

function BP_BattleEllipticCenter_C:Destruct()
  self:Release()
end

return BP_BattleEllipticCenter_C
