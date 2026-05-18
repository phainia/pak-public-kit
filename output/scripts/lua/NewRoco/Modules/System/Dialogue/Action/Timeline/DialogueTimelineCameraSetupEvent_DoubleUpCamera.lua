local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineCameraSetupEvent")
local DialogueTimelineCameraSetupEvent_DoubleUpCamera = Base:Extend("DialogueTimelineCameraSetupEvent_DoubleUpCamera")
FsmUtils.MergeMembers(Base, DialogueTimelineCameraSetupEvent_DoubleUpCamera, {
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
    name = "SpringArmLengthMultiplier",
    type = "float",
    default = 1.0,
    display_name = "\230\145\135\232\135\130\233\149\191\229\186\166\229\143\152\230\141\162\231\179\187\230\149\176"
  },
  {
    name = "PitchOffset",
    type = "float",
    display_name = "\230\145\135\232\135\130\229\158\130\231\155\180\230\150\185\229\144\145\230\151\139\232\189\172\232\167\146\229\186\166"
  }
})

function DialogueTimelineCameraSetupEvent_DoubleUpCamera:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.CameraType = Enum.NpcInteractCameraType.NIC_3
end

function DialogueTimelineCameraSetupEvent_DoubleUpCamera:FillCameraRequestParams(Config)
  Config.TargetActorID = self.TargetActorID
  Config.TargetActorID2nd = self.TargetActorID2nd
  Config.SpringArmLengthMultiplier = self.SpringArmLengthMultiplier
  Config.PitchOffset = self.PitchOffset
end

return DialogueTimelineCameraSetupEvent_DoubleUpCamera
