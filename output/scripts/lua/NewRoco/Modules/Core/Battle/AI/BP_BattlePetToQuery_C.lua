local BattleAIInputParams = require("NewRoco.Modules.Core.Battle.AI.BattleAIInputParams")
local BP_BattlePetToQuery_C = _G.NRCClass:Extend("BP_BattlePetToQuery")

function BP_BattlePetToQuery_C:Ctor()
  Log.Debug("BP_BattlePetToQuery_C initialize Ctor")
end

function BP_BattlePetToQuery_C:Initialize()
  Log.Debug("BP_BattlePetToQuery_C initialize")
  self.BattlePet = BattleAIInputParams.battlePetTo
end

function BP_BattlePetToQuery_C:ProvideSingleActor(QuerierObject, QuerierActor, ResultingActor)
  Log.Debug("BP_BattlePetToQuery_C ProvideSingleActor")
  self.BattlePet = BattleAIInputParams.battlePetTo
  return self.BattlePet
end

function BP_BattlePetToQuery_C:Destruct()
  self:Release()
end

return BP_BattlePetToQuery_C
