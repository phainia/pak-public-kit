local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialoguePrepareAction = Base:Extend("DialoguePrepareAction")
FsmUtils.MergeMembers(Base, DialoguePrepareAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "Options", type = "var"},
  {name = "Option", type = "var"}
})

function DialoguePrepareAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialoguePrepareAction:OnEnter()
  self:InjectProperties()
  self:Finish()
end

function DialoguePrepareAction:OnExit()
end

return DialoguePrepareAction
