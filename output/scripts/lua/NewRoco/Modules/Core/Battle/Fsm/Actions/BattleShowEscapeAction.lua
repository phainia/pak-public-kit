local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local Base = BattleActionBase
local BattleShowEscapeAction = Base:Extend("BattleShowEscapeAction")
FsmUtils.MergeMembers(Base, BattleShowEscapeAction, {})

function BattleShowEscapeAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleShowEscapeAction:OnEnter()
  local hideType = BattleEnum.MainWindowHideAllType.Custom
  local customOption = {
    excludeDeck = false,
    excludeSkillTransmissionItems = false,
    withAnim = true
  }
  local option = {type = hideType, customOption = customOption}
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindowWithOption, option)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
  if BattleUtils.IsPvp() and _G.BattleManager.battleRuntimeData.battleSettleData:BattleIsWinByEscape() then
    self:ShowPopup()
    self:SafeDelaySeconds("d_Finish", 1, self.Finish, self)
  else
    self:Finish()
  end
end

function BattleShowEscapeAction:ShowPopup()
  local data = {
    teamEnm = BattleEnum.Team.ENUM_ENEMY
  }
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_SHOW_INFO_POPUP, {
    BattleEnum.InfoPopupType.EnemyEscape,
    data
  }, self)
end

function BattleShowEscapeAction:HidePopup()
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, nil, self)
end

function BattleShowEscapeAction:OnFinish()
  self:HidePopup()
end

return BattleShowEscapeAction
