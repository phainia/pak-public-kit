local NPCActionEvent = require("NewRoco.Modules.Core.NPC.Actions.NPCActionEvent")
local NPCActionFactory = require("NewRoco.Modules.Core.NPC.Actions.NPCActionFactory")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueWaitLocalActionAction = Base:Extend("DialogueWaitLocalActionAction")
FsmUtils.MergeMembers(Base, DialogueWaitLocalActionAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {
    name = "DialogueConf",
    type = "var"
  }
})

function DialogueWaitLocalActionAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitLocalActionAction:OnEnter()
  self:InjectProperties()
  if not self.DialogueConf then
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
    return
  end
  local Action = NPCActionFactory:Get(nil, self.DialogueConf.action, nil, true)
  local IsClientCommit = DialogueUtils.IsClientCommit(self.DialogueConf.action.action_type)
  if IsClientCommit and Action then
    if not self.ParentModule:IsInBlackScreen() and Action:IsNeedCloseDialogueUI() then
      self.ParentModule:OnCloseMainPanel()
    end
    self.Action = Action
    self.Action.DialogueConf = self.DialogueConf
    self:SetProperty("ClientAction", Action)
    self.Action.SkipSubmit = true
    self.Action.SkipCommit = true
    self.Action:AddEventListener(self, NPCActionEvent.OnFinish, self.OnClientActionFinish)
    self.Action:Execute()
    self.fsm:Pause()
  elseif IsClientCommit and not Action then
  elseif not IsClientCommit and Action then
    if not self.ParentModule:IsInBlackScreen() and Action:IsNeedCloseDialogueUI() then
      self.ParentModule:OnCloseMainPanel()
    end
    Action:OnDialogueAction()
    self:DoNextDialogue(self.DialogueConf.action.success_dialogue)
  else
    self:DoNextDialogue(self.DialogueConf.action.success_dialogue)
  end
end

function DialogueWaitLocalActionAction:OnClientActionFinish(Rsp, Success)
  self:CleanupAction()
  if Success then
    self:DoNextDialogue(self.DialogueConf.action.success_dialogue)
  else
    self:DoNextDialogue(self.DialogueConf.action.failure_dialogue)
  end
end

function DialogueWaitLocalActionAction:DoNextDialogue(ConfID)
  self.fsm:Resume()
  if not ConfID or 0 == ConfID then
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
    return
  end
  self:SetProperty("ConfID", ConfID)
  self:Finish()
end

function DialogueWaitLocalActionAction:CleanupAction()
  if not self.Action then
    return
  end
  if self.Action:HasListener(self, NPCActionEvent.OnFinish, self.OnClientActionFinish) then
    self.Action:RemoveEventListener(self, NPCActionEvent.OnFinish, self.OnClientActionFinish)
  end
  self.Action = nil
end

function DialogueWaitLocalActionAction:OnExit()
  self:CleanupAction()
end

return DialogueWaitLocalActionAction
