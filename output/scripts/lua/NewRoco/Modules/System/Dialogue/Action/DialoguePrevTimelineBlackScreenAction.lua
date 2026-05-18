local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local DialoguePrevTimelineBlackScreenAction = Base:Extend("DialoguePrevTimelineBlackScreenAction")
FsmUtils.MergeMembers(Base, DialoguePrevTimelineBlackScreenAction, {
  {
    name = "CurrentTimeline",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  }
})

function DialoguePrevTimelineBlackScreenAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialoguePrevTimelineBlackScreenAction:OnEnter()
  self:InjectProperties()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
  if self.CurrentTimeline and self.CurrentTimeline.black_switch_in then
    local ParentModule = self:GetProperty("ParentModule")
    if ParentModule then
      ParentModule:RegisterEvent(self, DialogueModuleEvent.DialogueCameraBlackFadeInDone, self.BlackInFinish)
    end
    NRCModuleManager:DoCmd(DialogueModuleCmd.FadeInDialogueCameraBlack)
  else
    self:Finish()
  end
end

function DialoguePrevTimelineBlackScreenAction:BlackInFinish()
  self:Finish()
end

function DialoguePrevTimelineBlackScreenAction:OnFinish()
  if ParentModule then
    ParentModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueCameraBlackFadeInDone)
  end
end

return DialoguePrevTimelineBlackScreenAction
