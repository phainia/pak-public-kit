local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueLocalDispatchAction = Base:Extend("DialogueLocalDispatchAction")
FsmUtils.MergeMembers(Base, DialogueLocalDispatchAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "Options", type = "var"},
  {name = "ConfID", type = "var"}
})

function DialogueLocalDispatchAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueLocalDispatchAction:OnEnter()
  self:InjectProperties()
  if not self.DialogueConf then
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
    return
  end
  if self.DialogueConf.select_ids and #self.DialogueConf.select_ids > 0 then
    local Options = {}
    for _, ID in ipairs(self.DialogueConf.select_ids) do
      local Conf = _G.DataConfigManager:GetSelectConf(ID)
      if Conf then
        table.insert(Options, Conf)
      end
    end
    if 0 == #Options then
      self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
      return
    end
    self:SetProperty("Options", Options)
    self.fsm:SendEvent(DialogueModuleEvent.EnterSelectState, self)
    return
  end
  local ActionType = self.DialogueConf.action and self.DialogueConf.action.action_type or Enum.ActionType.ACT_NONE
  if ActionType ~= Enum.ActionType.ACT_NONE then
    self.fsm:SendEvent(DialogueModuleEvent.EnterActionState, self)
    return
  end
  if self.DialogueConf.next_dialog_id > 0 then
    self:SetProperty("ConfID", self.DialogueConf.next_dialog_id)
    self.fsm:SendEvent(DialogueModuleEvent.EnterNextState, self)
    return
  end
  self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
end

function DialogueLocalDispatchAction:OnExit()
end

return DialogueLocalDispatchAction
