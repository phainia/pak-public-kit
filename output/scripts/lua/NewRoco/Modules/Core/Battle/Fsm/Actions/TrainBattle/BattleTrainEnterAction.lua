local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePlayAnimBaseAction
local BattleTrainEnterAction = Base:Extend("BattleTrainEnterAction")
FsmUtils.MergeMembers(Base, BattleTrainEnterAction, {})

function BattleTrainEnterAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleTrainEnterAction:OnEnter()
  _G.NRCModeManager:DoCmd(_G.MagicManualModuleCmd.CmdCloseMagicManual)
  self:Finish()
end

return BattleTrainEnterAction
