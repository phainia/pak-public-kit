local BattleAIInputParams = require("NewRoco.Modules.Core.Battle.AI.BattleAIInputParams")
local BP_BattlePlayerToQuery_C = _G.NRCClass:Extend("BP_BattlePlayerToQuery_C")

function BP_BattlePlayerToQuery_C:Ctor()
  Log.Debug("BP_BattlePetToQuery_C initialize Ctor")
end

function BP_BattlePlayerToQuery_C:Initialize()
  Log.Debug("BP_BattlePlayerToQuery_C initialize")
end

function BP_BattlePlayerToQuery_C:ProvideSingleActor(QuerierObject, QuerierActor, ResultingActor)
  Log.Debug("BP_BattlePlayerToQuery_C ProvideSingleActor")
end

function BP_BattlePlayerToQuery_C:Destruct()
end

return BP_BattlePlayerToQuery_C
