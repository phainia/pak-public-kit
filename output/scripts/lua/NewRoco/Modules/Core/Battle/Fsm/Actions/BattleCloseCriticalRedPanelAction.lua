local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = BattleActionBase
local BattleCloseCriticalRedPanelAction = Base:Extend("BattleCloseCriticalRedPanelAction")
FsmUtils.MergeMembers(Base, BattleCloseCriticalRedPanelAction, {})

function BattleCloseCriticalRedPanelAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleCloseCriticalRedPanelAction:OnEnter()
  self:HideUIPanel()
  self:Finish()
end

function BattleCloseCriticalRedPanelAction:ShowUIPanel()
end

function BattleCloseCriticalRedPanelAction:HideUIPanel()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.CloseBattleRedPanel)
end

function BattleCloseCriticalRedPanelAction:OnFinish()
end

function BattleCloseCriticalRedPanelAction:OnExit()
end

return BattleCloseCriticalRedPanelAction
