local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = BattleActionBase
local BattleRoleShowCriticalTipAction = Base:Extend("BattleRoleShowCriticalTipAction")
FsmUtils.MergeMembers(Base, BattleRoleShowCriticalTipAction, {})

function BattleRoleShowCriticalTipAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleRoleShowCriticalTipAction:OnEnter()
  self.isUINeed = false
  local isBattleValid = false
  local battleType = _G.BattleManager.battleRuntimeData.battleType
  Log.Debug("BattleRoleShowCriticalTipAction battleType=", battleType)
  if battleType == Enum.BattleType.BT_PVE or battleType == Enum.BattleType.BT_PVESPECIAL then
    self.battleCfg = BattleUtils.GetBattleConfig()
    local oppositeType = self.battleCfg.opposite_type
    Log.Debug("BattleRoleShowCriticalTipAction oppositeType=", oppositeType)
    if not oppositeType or oppositeType == Enum.OppositeType.OT_NONE then
      isBattleValid = true
    end
  elseif battleType == Enum.BattleType.BT_1VN or battleType == Enum.BattleType.BT_1V1V1 or battleType == Enum.BattleType.BT_LEGENDARY_BATTLE or battleType == Enum.BattleType.BT_WORLDLEADER or battleType == Enum.BattleType.BT_BOSS_CHALLENGE or battleType == Enum.BattleType.BT_CRUCIAL then
    isBattleValid = true
  end
  if not isBattleValid then
    self:Finish()
    return
  end
  local MyPlayer = _G.BattleManager.battlePawnManager:GetPlayerMyTeam()
  if not MyPlayer then
    self:Finish()
    return
  end
  local hp = MyPlayer.roleInfo.base.battle_hp_max
  local cards = self.BattleManager.battlePawnManager.playerTeam:GetInBattleCards()
  local hp_need = 0
  local petNum = 0
  for i, card in ipairs(cards) do
    local baseID = card.petInfo.battle_inside_pet_info.base_conf_id
    local baseConf = _G.DataConfigManager:GetPetbaseConf(baseID)
    if not baseConf then
      Log.Error("Pet base ID not found: ", baseID)
      self:Finish()
      return
    end
    petNum = petNum + 1
    hp_need = hp_need + baseConf.consume_role_hp
  end
  if 1 == petNum then
    if hp <= hp_need then
      self.isUINeed = true
    end
  elseif hp < hp_need then
    self.isUINeed = true
  end
  Log.Debug("BattleRoleShowCriticalTipAction petNum=", petNum, "hp_need=", hp_need, "hp=", hp, "self.isUINeed=", self.isUINeed)
  if self.isUINeed then
    self:ShowUIPanel()
    _G.BattleEventCenter:Bind(self, BattleEvent.REFRESH_ROLE_HP_CRITICAL_TIP_END)
  else
    self:Finish()
  end
end

function BattleRoleShowCriticalTipAction:ShowUIPanel()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenRoleHpCriticalTipPanel)
end

function BattleRoleShowCriticalTipAction:HideUIPanel()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseRoleHpCriticalTipPanel)
end

function BattleRoleShowCriticalTipAction:OnFinish()
  if self.isUINeed then
    _G.BattleEventCenter:UnBind(self)
    self:HideUIPanel()
    self.isUINeed = false
  end
end

function BattleRoleShowCriticalTipAction:OnExit()
end

function BattleRoleShowCriticalTipAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.REFRESH_ROLE_HP_CRITICAL_TIP_END then
    self:Finish()
    return true
  end
end

return BattleRoleShowCriticalTipAction
