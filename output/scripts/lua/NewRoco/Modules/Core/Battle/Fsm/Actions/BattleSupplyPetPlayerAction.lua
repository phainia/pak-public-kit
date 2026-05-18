local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleSupplyPetPlayer = require("NewRoco.Modules.Core.Battle.Players.BattleSupplyPetPlayer")
local Base = BattleActionBase
local BattleSupplyPetPlayerAction = Base:Extend("BattleSupplyPetPlayerAction")
FsmUtils.MergeMembers(Base, BattleSupplyPetPlayerAction, {
  {name = "Infos", type = "table"}
})

function BattleSupplyPetPlayerAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.SupplyPlayer = BattleSupplyPetPlayer()
end

function BattleSupplyPetPlayerAction:OnEnter()
  local Infos = self:GetProperty("Infos")
  if Infos then
    if BattleUtils.IsFinalBattleP1() then
      self.SupplyPlayer:RunSupply(self:PreProcessSupplyMergeNoSuit(Infos), self, self.FinishCallBack)
    else
      self.SupplyPlayer:RunSupply(self:PreProcessSupplyMerge(Infos), self, self.FinishCallBack)
    end
  else
    Log.Error("BattleSupplyPetPlayerAction:OnEnter ", "SupplyInfo Is Nil")
    self:Finish()
  end
end

function BattleSupplyPetPlayerAction:FinishCallBack()
  self:Finish()
end

function BattleSupplyPetPlayerAction:PreProcessSupplyMerge(Infos)
  local newInfos = {}
  for i = 1, #Infos do
    local curInfo = Infos[i]
    if curInfo.pet_infos and #curInfo.pet_infos > 1 then
      local newInfo = {
        player_id = curInfo.player_id,
        pet_infos = {}
      }
      table.insert(newInfos, newInfo)
      for j = 1, #curInfo.pet_infos do
        local suit = BattleManager.battlePawnManager:GetPetChangeSuitIdByGuid(curInfo.pet_infos[j].pet_id)
        if suit > 0 then
          table.insert(newInfos, {
            player_id = curInfo.player_id,
            pet_infos = {
              curInfo.pet_infos[j]
            }
          })
          if j < #curInfo.pet_infos then
            newInfo = {
              player_id = curInfo.player_id,
              pet_infos = {}
            }
            table.insert(newInfos, newInfo)
          end
        else
          table.insert(newInfo.pet_infos, curInfo.pet_infos[j])
        end
      end
    else
      table.insert(newInfos, curInfo)
    end
  end
  for i = 1, #newInfos do
    local curInfo = newInfos[i]
    while i + 1 <= #newInfos and newInfos[i + 1].player_id == curInfo.player_id do
      if 1 == #newInfos[i + 1].pet_infos then
        local suit = BattleManager.battlePawnManager:GetPetChangeSuitIdByGuid(newInfos[i + 1].pet_infos[1].pet_id)
        if suit > 0 then
          break
        end
      end
      for j = 1, #newInfos[i + 1].pet_infos do
        table.insert(curInfo.pet_infos, newInfos[i + 1].pet_infos[j])
      end
      newInfos[i + 1].pet_infos = nil
      i = i + 1
    end
  end
  for i = #newInfos, 1 do
    if not newInfos[i].pet_infos or 0 == #newInfos[i].pet_infos then
      table.remove(newInfos, i)
    end
  end
  return newInfos
end

function BattleSupplyPetPlayerAction:PreProcessSupplyMergeNoSuit(Infos)
  for i = 1, #Infos do
    local curInfo = Infos[i]
    while i + 1 <= #Infos and Infos[i + 1].player_id == curInfo.player_id do
      for j = 1, #Infos[i + 1].pet_infos do
        table.insert(curInfo.pet_infos, Infos[i + 1].pet_infos[j])
      end
      Infos[i + 1].pet_infos = nil
      i = i + 1
    end
  end
  for i = #Infos, 1 do
    if not Infos[i].pet_infos then
      table.remove(Infos, i)
    end
  end
  return Infos
end

function BattleSupplyPetPlayerAction:PreProcessSupplySplit(Infos)
  local splitSupplys = {}
  local player = _G.BattleManager.battlePawnManager:GetPlayerByGuid(Infos[1].player_id)
  for i, playerInfos in ipairs(Infos) do
    for i, petInfo in ipairs(playerInfos.pet_infos) do
      player.deck:AddPetDynamic(petInfo.pet_info)
      table.insert(splitSupplys, {
        player_id = playerInfos.player_id,
        pet_infos = {petInfo}
      })
    end
  end
  Log.Warning("BattleSupplyPetPlayerAction:PreProcessSupplySplit", #splitSupplys)
  return splitSupplys
end

function BattleSupplyPetPlayerAction:OnExit()
end

return BattleSupplyPetPlayerAction
