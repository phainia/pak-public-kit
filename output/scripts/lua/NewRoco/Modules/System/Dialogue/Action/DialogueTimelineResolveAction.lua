local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local rapidjson = require("rapidjson")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueTimelineResolveAction = Base:Extend("DialogueTimelineResolveAction")
FsmUtils.MergeMembers(Base, DialogueTimelineResolveAction, {
  {
    name = "CurrentDialogue",
    type = "var"
  },
  {
    name = "CurrentTimeline",
    type = "var"
  }
})

function DialogueTimelineResolveAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueTimelineResolveAction:OnEnter()
  self:InjectProperties()
  if self.CurrentDialogue then
    local File = string.format("%s/Data/Dialogue/Timelines/%d.non", UE4.UNRCStatics.ProjectScriptDir(), self.CurrentDialogue.id)
    File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
    if UE4.UBlueprintPathsLibrary.FileExists(File) then
      local timeline_config = self:LoadTimelineDataFromJson(tostring(self.CurrentDialogue.id))
      self:SetProperty("CurrentTimeline", timeline_config)
    else
      self:SetProperty("CurrentTimeline", nil)
    end
  end
  self:Finish()
end

function DialogueTimelineResolveAction:LoadTimelineDataFromJson(json_path)
  local File = string.format("%s/Data/Dialogue/Timelines/%s.non", UE4.UNRCStatics.ProjectScriptDir(), json_path)
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Result, Success = UE4.UNRCStatics.LoadToString(File)
  if Success then
    return rapidjson.decode(Result)
  else
    Log.Error("Fail to load timeline asset in " .. File)
  end
  return
end

return DialogueTimelineResolveAction
