local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineAction")
local DialogueTimelineActionEvent = Base:Extend("DialogueTimelineActionEvent")

function DialogueTimelineActionEvent:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

return DialogueTimelineActionEvent
