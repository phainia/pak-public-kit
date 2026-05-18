local BattleModuleData = _G.NRCData:Extend("BattleModuleData")
BattleModuleData.BattleFieldLoadingState = {
  WAITING_FOR_LOAD = 0,
  LOADING = 1,
  SUCCESS = 2,
  ERROR = 3
}

function BattleModuleData:Ctor()
  NRCData.Ctor(self)
  self.battleFieldLevelLoadingState = BattleModuleData.BattleFieldLoadingState.WAITING_FOR_LOAD
  self.pvpConfIdToBattleConf = {}
  local PvpConfList = _G.DataConfigManager:GetAllByName("PVP_CONF") or {}
  for pvpConfId, pvpConf in pairs(PvpConfList) do
    local battleConfId = pvpConf and pvpConf.battle_config
    local battleConf = _G.DataConfigManager:GetBattleConf(battleConfId, true)
    if pvpConfId and battleConf then
      self.pvpConfIdToBattleConf[pvpConfId] = battleConf
    end
  end
end

return BattleModuleData
