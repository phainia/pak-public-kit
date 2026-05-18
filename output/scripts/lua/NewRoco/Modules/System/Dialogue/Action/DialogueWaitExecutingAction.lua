local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueWaitExecutingAction = Base:Extend("DialogueWaitExecutingAction")
FsmUtils.MergeMembers(Base, DialogueWaitExecutingAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "Option", type = "var"},
  {name = "ConfID", type = "var"},
  {name = "Action", type = "var"},
  {name = "Restoring", type = "var"}
})

function DialogueWaitExecutingAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitExecutingAction:OnEnter()
  self:InjectProperties()
  self:Check()
end

function DialogueWaitExecutingAction:Check()
  local Found = self.ParentModule:FindAction(self.Option, self.ConfID, ProtoEnum.SpaceEnum_NpcActionStatus.ENUM.Executing, self.Restoring)
  if Found then
    self:SetProperty("Action", Found)
    self:SetProperty("ConfID", 0 == Found.bound_dialog_id and Found.dialog_id or Found.bound_dialog_id)
    self:Finish()
    return
  end
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.ForwardOptionChange)
    self.ParentModule:RegisterEvent(self, DialogueModuleEvent.ForwardOptionChange, self.Check)
  else
    Log.Error("We have serious problem")
  end
end

function DialogueWaitExecutingAction:OnFinish()
  self:SetProperty("Restoring", false)
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.ForwardOptionChange)
    local Conf = self.ParentModule:GetLastTalkedDialogue()
    if Conf then
      Log.Debug("Clear Last Talk Conf", Conf.id)
    end
  end
end

function DialogueWaitExecutingAction:OnExit()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.ForwardOptionChange)
  end
end

return DialogueWaitExecutingAction
