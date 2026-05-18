local BattleSwitchConfigAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleSwitchConfigAction")
local Base = BattleSwitchConfigAction
local BattleB1P2SwitchToP3Action = Base:Extend("BattleB1P2SwitchToP3Action")

function BattleB1P2SwitchToP3Action:OnEnter()
  if not BattleUtils.IsB1FinalBattleP2() then
    self:Finish()
    return
  end
  _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.HideMainWindow, false, false)
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.HideBattlePopupPanel)
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenPetTheFinalBattle)
  Base.OnEnter(self)
  self:Finish()
end

return BattleB1P2SwitchToP3Action
