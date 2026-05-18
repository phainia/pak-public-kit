local BattleSettleData = NRCClass()

function BattleSettleData:Ctor()
  self.data = nil
  self.IsReceiveFinish = false
end

function BattleSettleData:SetBattlerInfo(infos)
  for i, v in ipairs(infos or {}) do
    local player = BattleManager.battlePawnManager:GetPlayerByGuid(v.id)
    if player then
      player.FashionData.LastHitPetBaseId = v.last_damage_pet
      player.FashionData.LastHitGID = v.last_damage_pet_gid
    end
  end
end

function BattleSettleData:SetData(ZoneBattleFinishNotify)
  self.IsReceiveFinish = true
  self.data = ZoneBattleFinishNotify
  self:SetBattlerInfo(ZoneBattleFinishNotify.settle_info.battler_info)
  if self:BattleIsWin() then
    local localPlayer = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer and localPlayer.serverData then
      local player = BattleManager.battlePawnManager:GetPlayerByGuid(localPlayer.serverData.base.logic_id)
      if player == BattleManager.battlePawnManager.TeamatePlayer and ZoneBattleFinishNotify.fashion_suit_info then
        _G.DataModelMgr.PlayerDataModel:UpdatePlayerSuitInfo(ZoneBattleFinishNotify.fashion_suit_info)
      end
    end
  end
end

function BattleSettleData:Reset()
  self.data = nil
end

function BattleSettleData:BattleResult()
  if self.data and self.data.settle_info then
    return self.data.settle_info.result
  end
end

function BattleSettleData:GetBattleSettleRemainHp()
  if self.data and self.data.settle_info then
    return self.data.settle_info.pve_add_info.battler_remain_hp
  end
end

function BattleSettleData:BattleIsWin()
  if self.data and self.data.settle_info then
    local result = self.data.settle_info.result
    return result & ProtoEnum.BATTLE_RESULT_TYPE.TRUE_BATTLE_RESULT_WIN > 0
  end
  return false
end

function BattleSettleData:BattleIsWinByEscape()
  if self.data and self.data.settle_info then
    local result = self.data.settle_info.result
    return result == ProtoEnum.BATTLE_RESULT_TYPE.TRUE_BATTLE_RESULT_MONSTER_RUNAWAY
  end
  return false
end

function BattleSettleData:BattleRewardData()
  if self.data and self.data.ret_info then
    return self.data.ret_info.goods_reward
  end
end

function BattleSettleData:BattleNpcLevel()
  if self.data and self.data.ret_info then
    return self.data.settle_info.flower_npc_level
  end
end

function BattleSettleData:BattlePrivilegeCliChannel()
  if self.data and self.data.cli_startup_channel then
    return self.data.cli_startup_channel
  end
  return Enum.CliLoginChannel.CLC_NONE
end

function BattleSettleData:BattleMedal()
  if self.data then
    return self.data.obtain_medal_info
  end
end

function BattleSettleData:GetRideId()
  if self.data and self.data.settle_info then
    return self.data.settle_info.ride_id or 0
  end
  return 0
end

return BattleSettleData
