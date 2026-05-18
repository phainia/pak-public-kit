local BattlePetEQS = _G.NRCClass:Extend("BattlePetEQS")

function BattlePetEQS:Initialize()
  Log.Debug("BattlePetEQS initialize")
  local pet = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  local enemyPet = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  self.FromActor = pet
  self.ToActor = enemyPet
end

function BattlePetEQS:Destruct()
  self:Release()
end

return BattlePetEQS
