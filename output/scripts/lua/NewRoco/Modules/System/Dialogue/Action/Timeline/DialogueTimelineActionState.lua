local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineAction")
local Base = DialogueActionBase
local DialogueTimelineActionState = Base:Extend("DialogueTimelineActionState")
FsmUtils.MergeMembers(Base, DialogueTimelineActionState, {
  {
    name = "EndTime",
    type = "float",
    default = 1.0,
    display_name = "\231\187\147\230\157\159\230\151\182\233\151\180"
  },
  {
    name = "MinimalDuration",
    type = "float",
    default = 0.1,
    display_name = "\230\156\128\229\176\143\230\151\182\233\151\180\233\151\180\233\154\148"
  }
})

function DialogueTimelineActionState:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

return DialogueTimelineActionState
