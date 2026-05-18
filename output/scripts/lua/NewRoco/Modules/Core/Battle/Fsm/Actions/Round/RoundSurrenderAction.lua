local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleRoundAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Round.BattleRoundAction")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local Base = BattleRoundAction
local RoundSurrenderAction = Base:Extend("RoundSurrenderAction")
FsmUtils.MergeMembers(Base, RoundSurrenderAction, {})

function RoundSurrenderAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientPlayerSelectAction)
end

function RoundSurrenderAction:OnEnter()
  Base.OnEnter(self)
  self.SelectMarkerManager:ClearSelection()
  if self.CurrentEnemyPets and self.CurrentPlayer then
    for _, v in ipairs(self.CurrentEnemyPets) do
      v:SetLookAt(self.CurrentPlayer.model)
    end
  end
  if self.CurrentPlayer then
    self.CurrentPlayer:RunAway(true)
  end
  self:OpenSurrenderPanel()
end

function RoundSurrenderAction:OpenSurrenderPanel()
  NRCModeManager:DoCmd(BattleUIModuleCmd.Open_SurrenderPanel)
end

function RoundSurrenderAction:OnExit()
  if self.CurrentPlayer then
    self.CurrentPlayer:RunAway(false)
  end
  Base.OnExit(self)
end

return RoundSurrenderAction
