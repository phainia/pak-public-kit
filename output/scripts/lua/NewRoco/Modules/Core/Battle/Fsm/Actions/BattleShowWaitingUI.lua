local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleShowWaitingUI = Base:Extend("BattleShowWaitingUI")
FsmUtils.MergeMembers(Base, BattleShowWaitingUI, {})

function BattleShowWaitingUI:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleShowWaitingUI:OnEnter()
  NRCModeManager:DoCmd(BattleUIModuleCmd.ShowWaiting)
  self:Finish()
end

return BattleShowWaitingUI
