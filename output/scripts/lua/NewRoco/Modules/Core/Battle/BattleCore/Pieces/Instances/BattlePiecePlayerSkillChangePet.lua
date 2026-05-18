local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattlePiecesBase = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.BattlePiecesBase")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePiecesBase
local BattlePiecePlayerSkillChangePet = Base:Extend("BattlePiecePlayerSkillChangePet")

function BattlePiecePlayerSkillChangePet:Ctor()
  Base.Ctor(self)
end

function BattlePiecePlayerSkillChangePet:Play(currentPlayer, rest_pet_id, battle_pet_id, player_id)
  local data = {}
  self.CurrentPlayer = currentPlayer
  data.rest_pet_id = rest_pet_id
  data.battle_pet_id = battle_pet_id
  data.player_id = player_id
  self:SetChangePet(data)
end

function BattlePiecePlayerSkillChangePet:Cancel()
  self.CurrentPlayer.team:ResumeRest()
end

function BattlePiecePlayerSkillChangePet:SetChangePet(data)
  local targetPet = BattleManager.battlePawnManager:GetPetByGuid(data.battle_pet_id)
  local restPet = BattleManager.battlePawnManager:GetPetByGuid(data.rest_pet_id)
  local restPets = self.CurrentPlayer.team.RestPets
  if not restPet then
    for i = 1, BattleManager.battleRuntimeData.playerPetNumber do
      if restPets[i] and restPets[i].guid == data.rest_pet_id then
        restPet = restPets[i]
      end
    end
  end
  restPet:SetOp(BattleEnum.Operation.ENUM_NONE)
  restPet:SetOpParam(data)
  if not restPet then
    Log.Error("\230\178\161\230\156\137\230\137\190\229\136\176\228\184\139\229\156\186\231\154\132\229\174\160\231\137\169\239\188\129\239\188\129 ", data.rest_pet_id)
    return
  end
  Log.Debug(restPets[restPet.card.pos], restPet.card.name, restPet.card.guid, "BattlePiecePlayerSkillChangePet:SetChangePet")
  if not restPets[restPet.card.pos] then
    restPets[restPet.card.pos] = restPet
    if restPet.model then
      restPet:ChangeBuffVisibility(false)
      restPet:HidePet()
    end
  end
  if restPet.card.guid ~= data.battle_pet_id then
    local fieldPet = self.CurrentPlayer.team.pets[restPet.card.pos]
    if fieldPet ~= restPet then
      fieldPet.card:SetInBattleField(false)
      fieldPet:Destroy()
    end
    local supplyInfo = _G.ProtoMessage:newBattleSupplyPetInfo()
    supplyInfo.pet_id = data.battle_pet_id
    supplyInfo.pet_pos = restPet.card.pos
    supplyInfo.posInField = restPet.card.posInField
    local battlePet = self.CurrentPlayer.deck:SummonPetOnce(BattleEnum.Team.ENUM_TEAM, self.CurrentPlayer.team, {supplyInfo})[1]
    battlePet:SetOp(BattleEnum.Operation.ENUM_NONE)
    battlePet:SetOpParam(data)
    restPet.card:SetInBattleField(false)
    return true
  end
end

return BattlePiecePlayerSkillChangePet
