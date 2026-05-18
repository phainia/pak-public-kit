local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleCloseBagPanelAction = Base:Extend("BattleCloseBagPanelAction")
FsmUtils.MergeMembers(Base, BattleCloseBagPanelAction, {})

function BattleCloseBagPanelAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleCloseBagPanelAction:OnEnter()
  _G.NRCModuleManager:DoCmd(BagModuleCmd.CloseBagMainPanel)
  self:Finish()
end

function BattleCloseBagPanelAction:OnExit()
end

return BattleCloseBagPanelAction
