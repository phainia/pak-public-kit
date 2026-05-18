local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local TurnoffCutsceneBlackScreenAction = Base:Extend("TurnoffCutsceneBlackScreenAction")
FsmUtils.MergeMembers(Base, TurnoffCutsceneBlackScreenAction, {})

function TurnoffCutsceneBlackScreenAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function TurnoffCutsceneBlackScreenAction:OnEnter()
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.CLOSE_BLACK_SCREEN)
  self:Finish()
end

function TurnoffCutsceneBlackScreenAction:OnExit()
end

return TurnoffCutsceneBlackScreenAction
