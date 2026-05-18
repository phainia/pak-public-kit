local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineCameraSetupEvent")
local DialogueTimelineCameraSetupEvent_CloseUpCamera = Base:Extend("DialogueTimelineCameraSetupEvent_CloseUpCamera")
FsmUtils.MergeMembers(Base, DialogueTimelineCameraSetupEvent_CloseUpCamera, {
  {
    name = "TargetActorID",
    type = "SheetRef.NPC_CONF",
    default = -2,
    display_name = "\231\155\174\230\160\135\232\167\146\232\137\178ID"
  },
  {
    name = "TargetActorID2nd",
    type = "SheetRef.NPC_CONF",
    default = 0,
    display_name = "\231\172\172\228\184\137\232\167\146\232\137\178ID"
  },
  {
    name = "YawOffset",
    type = "float",
    display_name = "\230\145\135\232\135\130\230\176\180\229\185\179\230\151\139\232\189\172\229\186\166\230\149\176"
  },
  {
    name = "ZOffset",
    type = "float",
    display_name = "\231\155\184\230\156\186\233\171\152\229\186\166\228\191\174\230\173\163"
  }
})

function DialogueTimelineCameraSetupEvent_CloseUpCamera:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.CameraType = Enum.NpcInteractCameraType.NIC_1
end

function DialogueTimelineCameraSetupEvent_CloseUpCamera:FillCameraRequestParams(Config)
  Config.TargetActorID = self.TargetActorID
  Config.TargetActorID2nd = self.TargetActorID2nd
  Config.YawOffset = self.YawOffset
  Config.ZOffset = self.ZOffset
end

return DialogueTimelineCameraSetupEvent_CloseUpCamera
