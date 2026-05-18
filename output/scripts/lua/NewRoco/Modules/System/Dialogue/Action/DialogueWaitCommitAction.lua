local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueWaitCommitAction = Base:Extend("DialogueWaitCommitAction")
FsmUtils.MergeMembers(Base, DialogueWaitCommitAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "Option", type = "var"},
  {name = "ConfID", type = "var"}
})

function DialogueWaitCommitAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitCommitAction:OnEnter()
  self:InjectProperties()
  self:Check()
end

function DialogueWaitCommitAction:Check()
  local Found = self.ParentModule:FindAction(self.Option, self.DialogueConf.id, ProtoEnum.SpaceEnum_NpcActionStatus.ENUM.Commited)
  if Found then
    if 0 == Found.next_dialog_id then
      self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
      return
    end
    self:SetProperty("ConfID", Found.next_dialog_id)
    self:Finish()
    return
  end
  self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.ForwardOptionChange)
  self.ParentModule:RegisterEvent(self, DialogueModuleEvent.ForwardOptionChange, self.Check)
end

function DialogueWaitCommitAction:OnFinish()
  self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.ForwardOptionChange)
end

function DialogueWaitCommitAction:OnExit()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.ForwardOptionChange)
  end
end

return DialogueWaitCommitAction
