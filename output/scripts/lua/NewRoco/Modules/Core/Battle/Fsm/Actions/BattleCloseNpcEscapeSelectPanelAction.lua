local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleCloseNpcEscapeSelectPanelAction = Base:Extend("BattleCloseNpcEscapeSelectPanelAction")
FsmUtils.MergeMembers(Base, BattleCloseNpcEscapeSelectPanelAction, {})

function BattleCloseNpcEscapeSelectPanelAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleCloseNpcEscapeSelectPanelAction:OnEnter()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.CloseBattleNpcAutoEscapePanel)
  self:Finish()
end

function BattleCloseNpcEscapeSelectPanelAction:OnExit()
end

return BattleCloseNpcEscapeSelectPanelAction
