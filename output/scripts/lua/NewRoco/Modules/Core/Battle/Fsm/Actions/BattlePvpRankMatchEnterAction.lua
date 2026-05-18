local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local Base = _G.BattleActionBase
local BattlePvpRankMatchEnterAction = Base:Extend("BattlePvpRankMatchEnterAction")

function BattlePvpRankMatchEnterAction:OnEnter()
  if _G.BattleManager.battleRuntimeData:IsInReplayMode() then
    self:Finish()
    return
  end
  _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.HIDE_ALL, true)
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.OpenPVPCutto, "BattlePvpRankMatchEnterAction", self, self.OpenPVPCuttoCallBack, true, false)
end

function BattlePvpRankMatchEnterAction:OpenPVPCuttoCallBack()
  Log.Debug("SeasonOpen Progress: BattlePvpRankMatchEnterAction:OpenPVPCuttoCallBack")
  _G.NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.WaitBattleEndShowRankedMatchUi)
  self:Finish()
end

return BattlePvpRankMatchEnterAction
