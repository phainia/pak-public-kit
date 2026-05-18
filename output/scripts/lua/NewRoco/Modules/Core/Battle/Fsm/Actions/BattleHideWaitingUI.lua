local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleHideWaitingUI = Base:Extend("BattleHideWaitingUI")
FsmUtils.MergeMembers(Base, BattleHideWaitingUI, {})

function BattleHideWaitingUI:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleHideWaitingUI:OnEnter()
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideWaiting)
  self:Finish()
end

return BattleHideWaitingUI
