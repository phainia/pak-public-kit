local ProtoMessage = require("Data.PB.ProtoMessage")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local SendBattleFinishAction = BattleActionBase:Extend("SendBattleFinishAction")
FsmUtils.MergeMembers(BattleActionBase, SendBattleFinishAction, {})

function SendBattleFinishAction:OnEnter()
  _G.NRCEventCenter:DispatchEvent(_G.WorldCombatModuleEvent.OnBattleRealEnd)
  _G.BattleManager:AfterBattleOver(true)
  self:Finish()
end

return SendBattleFinishAction
