local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local EventDispatcher = require("Common.EventDispatcher")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleIncreaseBloodPlayer = BattlePlayerBase:Extend()
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")

function BattleIncreaseBloodPlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
end

function BattleIncreaseBloodPlayer:Play(performNode)
  self.performNode = performNode
  self.performInfo = performNode:GetInfo()
  self:PlayEscape()
end

function BattleIncreaseBloodPlayer:PlayEscape()
  local performInfo = self.performInfo
  if performInfo and performInfo.battler_heal_info then
    local RoleInfo = performInfo.battler_heal_info
    self.asyncData = {
      diePet = nil,
      isLast = false,
      isShowLetter = false
    }
    local player = _G.BattleManager.battlePawnManager:GetPlayerByGuid(RoleInfo.uin)
    if player then
      self.asyncData.player = player
    end
    if RoleInfo.hp_result then
      self.asyncData.hp_result = RoleInfo.hp_result
    end
    if RoleInfo.hp_change then
      self.asyncData.hp_change = RoleInfo.hp_change
    end
    if RoleInfo.black_hp_result then
      self.asyncData.black_hp_result = RoleInfo.black_hp_result
    end
    if RoleInfo.black_hp_change then
      self.asyncData.black_hp_change = RoleInfo.black_hp_change
    end
    _G.NRCModuleManager:DoCmdAsync(self.asyncData, BattleUIModuleCmd.OpenRoleHpDefeatedTipPanel)
    self.isRoleHpDefeated = false
    self:CheckRoleHp()
    _G.DelayManager:DelaySeconds(2, function()
      self:Clear()
    end)
  end
end

function BattleIncreaseBloodPlayer:CheckRoleHp()
  if not BattleUtils.IsTeam() then
    local myTeamPlayer = _G.BattleManager.battlePawnManager:GetPlayerMyTeam()
    local hp = 100
    if myTeamPlayer and myTeamPlayer.roleInfo and myTeamPlayer.roleInfo.base then
      hp = myTeamPlayer.roleInfo.base.hp or 100
    end
    local cards = _G.BattleManager.battlePawnManager.playerTeam:GetInBattleCards()
    local hp_need = 0
    for i, card in ipairs(cards) do
      local baseID = card.petInfo.battle_inside_pet_info.base_conf_id
      local baseConf = _G.DataConfigManager:GetPetbaseConf(baseID)
      if not baseConf then
        Log.Error("Pet base ID not found: ", baseID)
        self:Finish()
      else
        hp_need = hp_need + baseConf.consume_role_hp
      end
    end
    if hp > hp_need then
      _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseBattleRedPanel)
    else
      _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattleRedPanel)
    end
  end
end

function BattleIncreaseBloodPlayer:Clear()
  if BattleUtils.HasUI("BattleRoleHpDefeatedTipPanel") then
    _G.BattleEventCenter:Dispatch(BattleEvent.REFRESH_ROLE_HP_DEFEAT_TIP_END)
  else
    _G.NRCModuleManager:DoCmdAsync(nil, BattleUIModuleCmd.CloseRoleHpDefeatedTipPanel)
  end
  if self.performNode then
    self.performNode:PerformComplete()
  end
  self.asyncData = nil
  self.performNode = nil
  self.performInfo = nil
end

return BattleIncreaseBloodPlayer
