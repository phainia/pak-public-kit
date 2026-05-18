local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialoguePostTimelineWaitUserClickAction = Base:Extend("DialoguePostTimelineWaitUserClickAction")
FsmUtils.MergeMembers(Base, DialoguePostTimelineWaitUserClickAction, {
  {
    name = "CurrentDialogue",
    type = "var"
  },
  {
    name = "CurrentTimeline",
    type = "var"
  },
  {
    name = "UserClicked",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  },
  {
    name = "HasShowUIAction",
    type = "var"
  }
})

function DialoguePostTimelineWaitUserClickAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialoguePostTimelineWaitUserClickAction:OnEnter()
  self:InjectProperties()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
  if self.CurrentDialogue.ui_source_type == Enum.UIsourceType.UIT_BLACK_EXIT then
    self:Finish()
  elseif string.IsNilOrEmpty(self.CurrentDialogue.text) then
    self:Finish()
  end
  if self.ParentModule and not self.ParentModule.PanelOn then
    self:Finish()
    return
  end
  if not self.HasShowUIAction then
    self:Finish()
    return
  end
  self.fsm:Pause()
  local UserClicked = self.UserClicked
  Log.DebugFormat("[DialogueFlow] DialoguePostTimelineWaitUserClickAction:OnEnter, id = %d, fam var UserClicked = %s", self.CurrentDialogue.id, UserClicked)
  if not UserClicked then
    local CurPanel = self.ParentModule:GetPanel(self.ParentModule._currentMainPanel)
    if CurPanel then
      Log.DebugFormat("[DialogueFlow] DialoguePostTimelineWaitUserClickAction:OnEnter, CurPanel.clicked = %s", CurPanel.clicked)
      UserClicked = CurPanel.clicked
    end
  end
  if not UserClicked then
    local LastTalked = self.ParentModule:GetLastTalkedDialogue()
    if LastTalked and LastTalked.id == self.CurrentDialogue.id then
      Log.Error("Disaster recovered")
      UserClicked = true
    end
  end
  local wait_user_click_at_end = self.CurrentTimeline.wait_user_click_at_end == nil or self.CurrentTimeline.wait_user_click_at_end
  if wait_user_click_at_end and not UserClicked and self.ParentModule then
    self.ParentModule:RegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished, self.OnUserClick)
    return
  end
  self:Finish()
end

function DialoguePostTimelineWaitUserClickAction:OnUserClick(DialogueConfOnPanel)
  Log.Debug("DialoguePostTimelineWaitUserClickAction:OnUserClick", self.CurrentDialogue.id, DialogueConfOnPanel and DialogueConfOnPanel.id or "\230\178\161\230\156\137Dialogue")
  if DialogueConfOnPanel and DialogueConfOnPanel.id ~= self.CurrentDialogue.id then
    Log.Error("dialogue id mismatch", DialogueConfOnPanel.id, self.CurrentDialogue.id)
    return
  end
  self:Finish()
end

function DialoguePostTimelineWaitUserClickAction:OnFinish()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished)
  end
  self.fsm:Resume()
end

function DialoguePostTimelineWaitUserClickAction:OnExit()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished)
  end
end

return DialoguePostTimelineWaitUserClickAction
