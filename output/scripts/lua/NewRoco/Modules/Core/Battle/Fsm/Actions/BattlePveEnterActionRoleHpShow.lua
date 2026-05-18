local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = BattleActionBase
local BattlePveEnterActionRoleHpShow = Base:Extend("BattlePveEnterActionRoleHpShow")
FsmUtils.MergeMembers(Base, BattlePveEnterActionRoleHpShow, {})

function BattlePveEnterActionRoleHpShow:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattlePveEnterActionRoleHpShow:OnEnter()
  self.isUINeed = false
  local initInfo = BattleUtils.GetBattleInitInfo()
  local battleConf = _G.DataConfigManager:GetBattleConf(initInfo.battle_cfg_id[1])
  if battleConf and battleConf.show_availableHP_rule and 1 == battleConf.show_availableHP_rule then
    self.isUINeed = true
  else
    self.isUINeed = false
  end
  if self.isUINeed then
    self:ShowUIPanel()
    _G.BattleEventCenter:Bind(self, BattleEvent.REFRESH_PVE_ENTER_ROLE_HP_END)
  else
    self:Finish()
  end
end

function BattlePveEnterActionRoleHpShow:ShowUIPanel()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenPveEnterRoleHpPanel)
end

function BattlePveEnterActionRoleHpShow:HideUIPanel()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.ClosePveEnterRoleHpPanel)
end

function BattlePveEnterActionRoleHpShow:OnFinish()
  if self.isUINeed then
    _G.BattleEventCenter:UnBind(self)
    self:HideUIPanel()
    self.isUINeed = false
  end
end

function BattlePveEnterActionRoleHpShow:OnExit()
end

function BattlePveEnterActionRoleHpShow:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.REFRESH_PVE_ENTER_ROLE_HP_END then
    self:Finish()
    return true
  end
end

return BattlePveEnterActionRoleHpShow
