local BattleAIInputParams = require("NewRoco.Modules.Core.Battle.AI.BattleAIInputParams")
local BP_BattlePlayerFromQuery_C = _G.NRCClass:Extend("BP_BattlePlayerFromQuery_C")

function BP_BattlePlayerFromQuery_C:Ctor()
  Log.Debug("BP_BattlePetToQuery_C initialize Ctor")
end

function BP_BattlePlayerFromQuery_C:Initialize()
  Log.Debug("BP_BattlePlayerFromQuery_C initialize")
end

function BP_BattlePlayerFromQuery_C:ProvideSingleActor(QuerierObject, QuerierActor, ResultingActor)
  Log.Debug("BP_BattlePlayerFromQuery_C ProvideSingleActor")
end

function BP_BattlePlayerFromQuery_C:Destruct()
end

return BP_BattlePlayerFromQuery_C
