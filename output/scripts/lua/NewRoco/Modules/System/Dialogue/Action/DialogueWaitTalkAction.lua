local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueWaitTalkAction = Base:Extend("DialogueWaitTalkAction")
FsmUtils.MergeMembers(Base, DialogueWaitTalkAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  }
})

function DialogueWaitTalkAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitTalkAction:OnEnter()
  self:InjectProperties()
  if DialogueUtils.SkipDialogue then
    self.fsm:Pause()
    if self.DialogueConf.select_ids and 0 ~= #self.DialogueConf.select_ids then
      DelayManager:DelayFrames(2, function(this)
        this:OnDialogueFinish()
      end, self)
    else
      self:OnDialogueFinish()
    end
    return
  end
  self.fsm:Pause()
  if self.DialogueConf.ui_source_type == Enum.UIsourceType.UIT_BLACK_EXIT then
    self:OnDialogueFinish()
    return
  elseif string.IsNilOrEmpty(self.DialogueConf.text) then
    self:OnDialogueFinish()
    return
  end
  local UserClicked = self.UserClicked
  Log.DebugFormat("[DialogueFlow] DialogueWaitTalkAction:OnEnter, id = %d, fam var UserClicked = %s", self.DialogueConf.id, UserClicked)
  if not UserClicked then
    local CurPanel = self.ParentModule:GetPanel(self.ParentModule._currentMainPanel)
    if CurPanel then
      Log.DebugFormat("[DialogueFlow] DialogueWaitTalkAction:OnEnter, CurPanel.clicked = %s", CurPanel.clicked)
      UserClicked = CurPanel.clicked
    end
  end
  if not UserClicked then
    local LastTalked = self.ParentModule:GetLastTalkedDialogue()
    if LastTalked and LastTalked.id == self.DialogueConf.id then
      Log.Error("[DialogueFlow] DialogueWaitTalkAction:OnEnter, Disaster recovered")
      UserClicked = true
    end
  end
  if UserClicked then
    self:Finish()
    return
  end
  self:AddListener()
end

function DialogueWaitTalkAction:OnDialogueFinish(Dialogue)
  Log.Debug("DialogueWaitTalkAction:OnDialogueFinish", self.DialogueConf.id, Dialogue and Dialogue.id or "\230\178\161\230\156\137Dialogue")
  if Dialogue and Dialogue.id ~= self.DialogueConf.id then
    Log.Error("dialogue id mismatch", Dialogue.id, self.DialogueConf.id)
    return
  end
  self:Finish()
end

function DialogueWaitTalkAction:OnFinish()
  self.fsm:Resume()
  self:RemoveListener()
end

function DialogueWaitTalkAction:OnExit()
  self:RemoveListener()
end

function DialogueWaitTalkAction:AddListener()
  local ParentModule = self:GetProperty("ParentModule")
  if ParentModule then
    ParentModule:RegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished, self.OnDialogueFinish)
  end
end

function DialogueWaitTalkAction:RemoveListener()
  local ParentModule = self:GetProperty("ParentModule")
  if ParentModule then
    ParentModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished)
  end
end

return DialogueWaitTalkAction
