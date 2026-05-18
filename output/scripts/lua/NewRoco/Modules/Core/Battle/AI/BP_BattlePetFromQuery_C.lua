local BattleAIInputParams = require("NewRoco.Modules.Core.Battle.AI.BattleAIInputParams")
local BP_BattlePetFromQuery_C = _G.NRCClass:Extend("BP_BattlePetToQuery")

function BP_BattlePetFromQuery_C:Ctor()
  Log.Debug("BP_BattlePetToQuery_C initialize Ctor")
end

function BP_BattlePetFromQuery_C:Initialize()
  Log.Debug("BP_BattlePetFromQuery_C initialize")
  self.BattlePet = BattleAIInputParams.battlePetFrom
end

function BP_BattlePetToQuery_C:ProvideSingleActor(QuerierObject, QuerierActor, ResultingActor)
  Log.Debug("BP_BattlePetToQuery_C ProvideSingleActor")
  self.BattlePet = BattleAIInputParams.battlePetFrom
  return self.BattlePet
end

function BP_BattlePetFromQuery_C:Destruct()
  self:Release()
end

return BP_BattlePetFromQuery_C
