local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueSyncDispatchAction = Base:Extend("DialogueSyncDispatchAction")
FsmUtils.MergeMembers(Base, DialogueSyncDispatchAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "Options", type = "var"},
  {
    name = "NextSelectIDs",
    type = "var"
  }
})

function DialogueSyncDispatchAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueSyncDispatchAction:OnEnter()
  self:InjectProperties()
  local SelectInfos = self.NextSelectIDs
  local SelectConfs = {}
  if SelectInfos then
    for _, select_id in ipairs(SelectInfos) do
      local Conf = _G.DataConfigManager:GetSelectConf(select_id)
      if not Conf then
        Log.Error("\230\137\190\228\184\141\229\136\176\233\128\137\233\161\185\233\133\141\231\189\174", Info.select_id)
      else
        table.insert(SelectConfs, Conf)
      end
    end
  end
  if #SelectConfs > 0 then
    self:SetProperty("Options", SelectConfs)
    self.fsm:SendEvent(DialogueModuleEvent.EnterSelectState, self)
    return
  end
  self:Finish()
end

function DialogueSyncDispatchAction:OnFinish()
  self.fsm:SetProperty("SelectIDs", nil)
end

function DialogueSyncDispatchAction:OnExit()
  self.fsm:SetProperty("SelectIDs", nil)
end

return DialogueSyncDispatchAction
