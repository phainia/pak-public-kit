local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueStopCurAudioAction = Base:Extend("DialogueStopCurAudioAction")

function DialogueStopCurAudioAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueStopCurAudioAction:OnEnter()
  local ParentModule = self.fsm:GetProperty("ParentModule")
  if ParentModule then
    ParentModule:StopCurDialogueAudio()
  end
  self:Finish()
end

return DialogueStopCurAudioAction
