local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleSpecialDelayPveShowMovieAction = Base:Extend("BattleSpecialDelayPveShowMovieAction")
FsmUtils.MergeMembers(Base, BattleSpecialDelayPveShowMovieAction, {})

function BattleSpecialDelayPveShowMovieAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleSpecialDelayPveShowMovieAction:OnEnter()
  Log.Debug("BattleSpecialDelayPveShowMovieAction OnEnter")
  local param = {}
  param.action = nil
  param.file_path = "Movies/cg001.mp4"
  local DialogueModule = NRCModuleManager:GetModule("DialogueModule")
  DialogueModule:OpenPanel("DialogueVideo", param)
  self:Finish()
end

function BattleSpecialDelayPveShowMovieAction:OnExit()
end

return BattleSpecialDelayPveShowMovieAction
