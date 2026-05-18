local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattleActionBase
local HideBattleMainWindowAction = Base:Extend("HideBattleMainWindowAction")
FsmUtils.MergeMembers(Base, HideBattleMainWindowAction, {})

function HideBattleMainWindowAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function HideBattleMainWindowAction:OnEnter()
  local hideType = self:GetProperty("HideType")
  hideType = hideType or BattleEnum.MainWindowHideAllType.Default
  local option = {type = hideType}
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindowWithOption, option)
  self:Finish()
end

function HideBattleMainWindowAction:OnExit()
end

return HideBattleMainWindowAction
