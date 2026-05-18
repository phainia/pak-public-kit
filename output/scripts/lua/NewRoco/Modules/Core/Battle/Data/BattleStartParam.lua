local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleStartParam = NRCClass()

function BattleStartParam:Ctor()
  self.battle_mode = 0
  self.battleInitInfo = nil
  self.encountered = false
  self.series_index = nil
end

function BattleStartParam:SetBattleInitInfo(ZoneBattleEnterNotify)
  self.battle_mode = ZoneBattleEnterNotify.battle_mode
  self.battleInitInfo = ZoneBattleEnterNotify.init_info
  self.battleCfg = _G.DataConfigManager:GetBattleConf(self.battleInitInfo.battle_cfg_id[1])
  self.battleCfgIds = self.battleInitInfo.battle_cfg_id
  self.encountered = ZoneBattleEnterNotify.encountered
  self.isReconnect = ZoneBattleEnterNotify.is_reconnect
  self:RecordPlayerPetData()
  local nonZeroCount = 0
  for _, v in ipairs(self.battleInitInfo.battle_cfg_id) do
    if 0 ~= v then
      nonZeroCount = nonZeroCount + 1
    end
  end
  self.isSeriesFight = nonZeroCount > 1
  self.battleOvertimeLimit = _G.DataConfigManager:GetGlobalConfigNumByKeyType("battle_overtime_limit", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG, 300)
end

function BattleStartParam:Reset()
  self.battleInitInfo = nil
  self.petDatas = nil
  self.battleCfgIds = nil
end

function BattleStartParam:RecordPlayerPetData()
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetData()
  self.petDatas = {}
  if petData then
    for i, data in ipairs(petData) do
      self.petDatas[i] = data
    end
  end
end

function BattleStartParam:IsReconnectCatch()
  if self.isReconnect then
    return self.battleInitInfo.battle_state == ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_CATCH
  end
  return false
end

function BattleStartParam:IsReconnect()
  return self.isReconnect
end

function BattleStartParam:IsHitLeaderWeakPoint()
  return self:CheckInitState(ProtoEnum.BATTLEFIELD_BIT_TYPE.BT_BOSS_WEAK_HIT)
end

function BattleStartParam:CheckInitState(index)
  if _G.GlobalConfig.DebugOpenUI then
    return false
  end
  if not self.battleInitInfo then
    return false
  end
  return BattleUtils.GetBit(self.battleInitInfo.state_bit, index)
end

function BattleStartParam:GetLeaderStunType()
  for playerIdx, enemyPlayer in ipairs(self.battleInitInfo.enemy_team) do
    for petIdx, enemyPet in ipairs(enemyPlayer.pets or {}) do
      if enemyPet.battle_inside_pet_info.buffs then
        for buffIdx, buff in ipairs(enemyPet.battle_inside_pet_info.buffs) do
          if buff.buff_id == BattleConst.BuffId.LeaderStun1 then
            return BattleEnum.LeaderStunState.OneStar
          end
          if buff.buff_id == BattleConst.BuffId.LeaderStun2 then
            return BattleEnum.LeaderStunState.TwoStar
          end
          if buff.buff_id == BattleConst.BuffId.LeaderStun3 then
            return BattleEnum.LeaderStunState.ThreeStar
          end
          if buff.buff_id == BattleConst.BuffId.LeaderStun4 then
            return BattleEnum.LeaderStunState.FourStar
          end
        end
      end
    end
  end
  return BattleEnum.LeaderStunState.Normal
end

function BattleStartParam:SetOnlooker(onlooker_a, onlooker_b)
  self.battleInitInfo.onlooker_a = onlooker_a
  self.battleInitInfo.onlooker_b = onlooker_b
end

return BattleStartParam
