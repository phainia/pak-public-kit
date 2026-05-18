local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueDispatchAction = Base:Extend("DialogueDispatchAction")
FsmUtils.MergeMembers(Base, DialogueDispatchAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "Options", type = "var"},
  {name = "Action", type = "var"}
})

function DialogueDispatchAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueDispatchAction:OnEnter()
  self:InjectProperties()
  if not self.Action then
    Log.Error("\230\137\190\228\184\141\229\136\176\229\144\136\231\144\134\231\154\132Action")
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
    return
  end
  local SelectInfos = self.Action.select_infos
  local SelectConfs = {}
  if SelectInfos then
    for _, Info in ipairs(SelectInfos) do
      if not Info.enabled then
      else
        local Conf = _G.DataConfigManager:GetSelectConf(Info.select_id)
        if not Conf then
          Log.Error("\230\137\190\228\184\141\229\136\176\233\128\137\233\161\185\233\133\141\231\189\174", Info.select_id)
        else
          table.insert(SelectConfs, Conf)
        end
      end
    end
    if 0 == #SelectConfs then
      self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
      return
    end
  end
  if #SelectConfs > 0 then
    self:SetProperty("Options", SelectConfs)
    self.fsm:SendEvent(DialogueModuleEvent.EnterSelectState, self)
    return
  end
  local ActionType = self.DialogueConf.action.action_type or Enum.ActionType.ACT_NONE
  if ActionType ~= Enum.ActionType.ACT_NONE then
    self.fsm:SendEvent(DialogueModuleEvent.EnterActionState, self)
    return
  end
  self:Finish()
end

function DialogueDispatchAction:OnFinish()
  self.Action = nil
end

function DialogueDispatchAction:OnExit()
  self.Action = nil
end

return DialogueDispatchAction
