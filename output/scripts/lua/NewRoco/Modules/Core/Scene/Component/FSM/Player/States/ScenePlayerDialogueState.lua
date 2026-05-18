local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local ScenePlayerStateBase = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerStateBase")
local Base = ScenePlayerStateBase
local ScenePlayerDialogueState = Base:Extend("ScenePlayerDialogueState")

function ScenePlayerDialogueState:Ctor()
  Base.Ctor(self)
  self.InDialogue = false
end

function ScenePlayerDialogueState:OnEnter()
  _G.NRCEventCenter:RegisterEvent("ScenePlayerDialogueState", self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
  self.InDialogue = true
end

function ScenePlayerDialogueState:OnDialogueEnded()
  self.InDialogue = false
end

function ScenePlayerDialogueState:OnExit()
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
end

function ScenePlayerDialogueState:CanExit(nextState)
  return not self.InDialogue
end

return ScenePlayerDialogueState
