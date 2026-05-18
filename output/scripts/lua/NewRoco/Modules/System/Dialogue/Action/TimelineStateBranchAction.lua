local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local TimelineStateBranchAction = Base:Extend("TimelineStateBranchAction")
FsmUtils.MergeMembers(Base, TimelineStateBranchAction, {
  {
    name = "DialogueConf",
    type = "var"
  }
})

function TimelineStateBranchAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function TimelineStateBranchAction:OnEnter()
  self:InjectProperties()
  self.fsm:SetProperty("LastTimeline", self.fsm:GetProperty("CurrentTimeline", nil))
  self.fsm:SetProperty("CurrentTimeline", nil)
  if self.DialogueConf then
    local File = string.format("%s/Data/Dialogue/Timelines/%d.non", UE4.UNRCStatics.ProjectScriptDir(), self.DialogueConf.id)
    File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
    if UE4.UBlueprintPathsLibrary.FileExists(File) then
      self.fsm:SendEvent(DialogueModuleEvent.EnterTimelineState, self)
      return
    else
      Log.DebugFormat("TimelineStateBranchAction: cant find timeline json file at [%s], fall back to default dialogue fsm", File)
    end
  end
  self:Finish()
end

function TimelineStateBranchAction:OnExit()
end

return TimelineStateBranchAction
