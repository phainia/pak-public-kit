local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local OpenBattleFailedUIAction = BattleActionBase:Extend("OpenBattleFailedUIAction")

function OpenBattleFailedUIAction:OnEnter()
  if _G.BattleManager.battleRuntimeData:IsInReplayMode() or _G.BattleAutoTest.IsAutoBattle then
    self:Finish()
    _G.BattleEventCenter:Dispatch(BattleEvent.Replay_Exit)
    return
  end
  if not _G.BattleManager.battleRuntimeData.battleSettleData.data.need_teleport then
    if BattleUtils.HasUI("BattleLoading") then
      self:Finish()
    else
      self:Finish()
    end
    return
  end
  Log.Debug("OpenBattleFailedUIAction:OnEnter and need teleport!!!")
  NRCEventCenter:RegisterEvent("OpenBattleFailedUIAction", self, BattleEvent.LoadingBattleFailedUIComplete, self.OnUIShow)
  NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattleFailedUI)
  Log.Debug("OpenBattleFailedUIAction:OnEnter finish!!!")
  self.fsm:Pause()
end

function OpenBattleFailedUIAction:OnUIShow()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseLoading)
  self.fsm:Resume()
  self:Finish()
end

function OpenBattleFailedUIAction:OnBlackScreenRemoved()
  self:Finish()
end

function OpenBattleFailedUIAction:OnExit()
end

function OpenBattleFailedUIAction:OnFinish()
  NRCEventCenter:UnRegisterEvent(self, BattleEvent.LoadingBattleFailedUIComplete, self.OnUIShow)
end

return OpenBattleFailedUIAction
