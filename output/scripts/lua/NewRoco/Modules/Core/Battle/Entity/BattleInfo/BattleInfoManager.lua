local BattleInfoTypes = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Basic.BattleInfoTypes")
local BattleInfoContainer = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.BattleInfoContainer")
local EnemyReversePetInfo = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Pet.EnemyReversePetInfo")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleInfoManager = NRCClass("BattleInfoManager")

function BattleInfoManager:Ctor()
  self.enemyReversePetInfoContainers = {}
  self.petIdToPetInfoFromPushPopData = {}
  self.uinToRoleInfoFromPushPopData = {}
end

function BattleInfoManager:Clear()
  table.clear(self.enemyReversePetInfoContainers)
  table.clear(self.petIdToPetInfoFromPushPopData)
  table.clear(self.uinToRoleInfoFromPushPopData)
end

function BattleInfoManager:AddEnemyReversePetInfo(role_uin, server_pet_info)
  if self.enemyReversePetInfoContainers[role_uin] == nil then
    self.enemyReversePetInfoContainers[role_uin] = BattleInfoContainer(BattleInfoTypes.EFlags.Class4)
  end
  local infoContainer = self.enemyReversePetInfoContainers[role_uin]
  local client_pet_info = BattleInfoManager.Converter_BattlePetInfo_To_ReversPetInfo(role_uin, server_pet_info)
  infoContainer:AddInfo(client_pet_info)
end

function BattleInfoManager:FindEnemyReversePetInfo(role_uin, pet_id)
  local infoContainer = self.enemyReversePetInfoContainers[role_uin]
  if infoContainer then
    return infoContainer:FindInfo(pet_id)
  end
  return nil
end

function BattleInfoManager:FindEnemyReversePetInfos(role_uin)
  local infoContainer = self.enemyReversePetInfoContainers[role_uin]
  if infoContainer then
    return infoContainer:GetInfos()
  end
  return nil
end

function BattleInfoManager:ConditionalRemoveEnemyReversePetInfos(role_uin, except_pet_ids)
  local infoContainer = self.enemyReversePetInfoContainers[role_uin]
  if infoContainer then
    return infoContainer:ConditionalRemoveInfos(except_pet_ids)
  end
end

function BattleInfoManager:HandleBattleInitInfo(battleInitInfo)
  if battleInitInfo.others then
    for iOther = 1, #battleInitInfo.others do
      local other = battleInitInfo.others[iOther]
      local other_team_enum
      if BattleInfoManager._IsInTeam(other.role_uin, battleInitInfo.player_team) then
        other_team_enum = BattleEnum.Team.ENUM_TEAM
      elseif BattleInfoManager._IsInTeam(other.role_uin, battleInitInfo.enemy_team) then
        other_team_enum = BattleEnum.Team.ENUM_ENEMY
      else
        Log.Error("BattleInfoManager:HandleBattleInitInfo role_uin not in any team, role_uin:", role_uin)
        goto lbl_40
      end
      self:HandleBattleOtherRoleInfo(other, other_team_enum)
      ::lbl_40::
    end
  end
end

function BattleInfoManager:HandleBattleOtherRoleInfo(other, other_team_enum)
  if not other or not other_team_enum then
    return
  end
  if other.pets then
    local idsToKeep = {}
    for iPet = 1, #other.pets do
      local pet = other.pets[iPet]
      local bInBattle = -1 ~= pet.battle_inside_pet_info.pos
      if not bInBattle then
        local pet_id = pet.battle_inside_pet_info.pet_id
        table.insert(idsToKeep, pet_id)
      end
    end
    self:ConditionalRemoveEnemyReversePetInfos(other.role_uin, idsToKeep)
    for iPet = 1, #other.pets do
      local pet = other.pets[iPet]
      local pet_id = pet.battle_inside_pet_info.pet_id
      if other_team_enum == BattleEnum.Team.ENUM_TEAM then
        BattleDataCenter.WriteDataUpdate_Pet(pet)
      else
        local bInBattle = -1 ~= pet.battle_inside_pet_info.pos
        if bInBattle then
          BattleDataCenter.WriteDataUpdate_Pet(pet)
        else
          self:AddEnemyReversePetInfo(other.role_uin, pet)
        end
      end
    end
  end
end

function BattleInfoManager._IsInTeam(role_uin, teams)
  if role_uin and teams then
    for i = 1, #teams do
      local battleRoleInfo = teams[i]
      local uin = battleRoleInfo.base.role_uin
      if uin == role_uin then
        return true
      end
    end
  end
  return false
end

function BattleInfoManager.Converter_BattlePetInfo_To_ReversPetInfo(role_uin, server_pet_info)
  local ret = EnemyReversePetInfo(role_uin, server_pet_info.battle_common_pet_info, server_pet_info.battle_inside_pet_info)
  return ret
end

function BattleInfoManager:AddBattlePetInfoDataFromPushPop(petId, petInfo, roundIndex)
  local petInfoData = {}
  petInfoData.roundIndex = roundIndex
  petInfoData.petInfo = petInfo
  local petIdToPetInfoFromPushPopData = self.petIdToPetInfoFromPushPopData
  if petIdToPetInfoFromPushPopData and petId and roundIndex and petInfoData then
    petIdToPetInfoFromPushPopData[petId] = petInfoData
  end
end

function BattleInfoManager:GetBattlePetInfoFromPushPopByPetId(petId)
  local petIdToPetInfoFromPushPopData = self.petIdToPetInfoFromPushPopData
  local petInfoData = petIdToPetInfoFromPushPopData and petId and petIdToPetInfoFromPushPopData[petId]
  return petInfoData
end

function BattleInfoManager:ClearExpiredBattlePetInfoFromPushPopForRoundStart(roundIndex)
  self:ClearExpiredBattlePetInfoFromPushPopWithRoundIndex(roundIndex)
end

function BattleInfoManager:ClearExpiredBattlePetInfoFromPushPopForPerformStart(roundIndex)
  self:ClearExpiredBattlePetInfoFromPushPopWithRoundIndex(roundIndex + 1)
end

function BattleInfoManager:ClearExpiredBattlePetInfoFromPushPopWithRoundIndex(roundIndex)
  roundIndex = roundIndex or 9999
  local petIdToPetInfoFromPushPopData = self.petIdToPetInfoFromPushPopData or {}
  local petIdList = {}
  for petId, petInfoFromPushPopData in pairs(petIdToPetInfoFromPushPopData) do
    table.insert(petIdList, petId)
  end
  for i, petId in pairs(petIdList) do
    local petInfoFromPushPopData = petIdToPetInfoFromPushPopData[petId]
    local petInfoRoundIndex = petInfoFromPushPopData and petInfoFromPushPopData.roundIndex or 0
    if roundIndex > petInfoRoundIndex then
      petIdToPetInfoFromPushPopData[petId] = nil
    end
  end
end

function BattleInfoManager:AddBattleRoleInfoDataFromPushPop(uin, roleInfo, roundIndex)
  local roleInfoData = {}
  roleInfoData.roundIndex = roundIndex
  roleInfoData.roleInfo = roleInfo
  local uinToRoleInfoFromPushPopData = self.uinToRoleInfoFromPushPopData
  if uinToRoleInfoFromPushPopData and uin and roundIndex and roleInfoData then
    uinToRoleInfoFromPushPopData[uin] = roleInfoData
  end
end

function BattleInfoManager:GetBattleRoleInfoFromPushPopByUin(uin)
  local uinToRoleInfoFromPushPopData = self.uinToRoleInfoFromPushPopData
  local roleInfoData = uinToRoleInfoFromPushPopData and uin and uinToRoleInfoFromPushPopData[uin]
  return roleInfoData
end

function BattleInfoManager:ClearExpiredBattleRoleInfoFromPushPopForRoundStart(roundIndex)
  self:ClearExpiredBattleRoleInfoFromPushPopWithRoundIndex(roundIndex)
end

function BattleInfoManager:ClearExpiredBattleRoleInfoFromPushPopForPerformStart(roundIndex)
  self:ClearExpiredBattleRoleInfoFromPushPopWithRoundIndex(roundIndex + 1)
end

function BattleInfoManager:ClearExpiredBattleRoleInfoFromPushPopWithRoundIndex(roundIndex)
  roundIndex = roundIndex or 9999
  local uinToRoleInfoFromPushPopData = self.uinToRoleInfoFromPushPopData or {}
  local uinList = {}
  for uin, roleInfoFromPushPopData in pairs(uinToRoleInfoFromPushPopData) do
    table.insert(uinList, uin)
  end
  for i, uin in pairs(uinList) do
    local roleInfoFromPushPopData = uinToRoleInfoFromPushPopData[uin]
    local roleInfoRoundIndex = roleInfoFromPushPopData and roleInfoFromPushPopData.roundIndex or 0
    if roundIndex > roleInfoRoundIndex then
      uinToRoleInfoFromPushPopData[uin] = nil
    end
  end
end

function BattleInfoManager:ClearAllExpiredPushPopInfoForRoundStart(roundIndex)
  self:ClearExpiredBattlePetInfoFromPushPopForRoundStart(roundIndex)
  self:ClearExpiredBattleRoleInfoFromPushPopForRoundStart(roundIndex)
end

function BattleInfoManager:ClearAllExpiredPushPopInfoForPerformStart(roundIndex)
  self:ClearExpiredBattlePetInfoFromPushPopForPerformStart(roundIndex)
  self:ClearExpiredBattleRoleInfoFromPushPopForPerformStart(roundIndex)
end

return BattleInfoManager
