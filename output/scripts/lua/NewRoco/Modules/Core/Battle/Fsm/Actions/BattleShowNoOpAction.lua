local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local Base = BattleActionBase
local BattleShowNoOpAction = Base:Extend("BattleShowNoOpAction")
FsmUtils.MergeMembers(Base, BattleShowNoOpAction, {})

function BattleShowNoOpAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleShowNoOpAction:OnEnter()
  if BattleUtils.IsPvp() and _G.BattleManager.ShowOpTips then
    local hasTips = false
    _G.BattleManager.ShowOpTips = false
    if _G.BattleManager.battlePawnManager.playerTeam and not _G.BattleManager.battlePawnManager:GetPlayerMyTeam():IsRoundDone() then
      hasTips = true
      self:ShowPopup(BattleEnum.Team.ENUM_TEAM)
    end
    if _G.BattleManager.battlePawnManager.enemyTeam and not _G.BattleManager.battlePawnManager:GetPlayerEnemyTeam():IsRoundDone() then
      hasTips = true
      self:ShowPopup(BattleEnum.Team.ENUM_ENEMY)
    end
    if hasTips then
      self:SafeDelaySeconds("d_Finish", 1, self.Finish, self)
    else
      self:Finish()
    end
  else
    self:Finish()
  end
end

function BattleShowNoOpAction:ShowPopup(teamEnum)
  local data = {teamEnm = teamEnum}
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_SHOW_INFO_POPUP, {
    BattleEnum.InfoPopupType.PVPNoOp,
    data
  }, self)
end

function BattleShowNoOpAction:HidePopup()
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, nil, self)
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, _G.BattleManager.battlePawnManager.TeamatePlayer, self)
end

function BattleShowNoOpAction:OnFinish()
  self:HidePopup()
end

return BattleShowNoOpAction
