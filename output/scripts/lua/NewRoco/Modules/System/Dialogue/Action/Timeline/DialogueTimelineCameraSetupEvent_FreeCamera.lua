local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineCameraSetupEvent")
local DialogueTimelineCameraSetupEvent_FreeCamera = Base:Extend("DialogueTimelineCameraSetupEvent_FreeCamera")
FsmUtils.MergeMembers(Base, DialogueTimelineCameraSetupEvent_FreeCamera, {
  {
    name = "TargetActorID",
    type = "SheetRef.NPC_CONF",
    default = -6,
    display_name = "\231\155\174\230\160\135\232\167\146\232\137\178ID"
  },
  {
    name = "RelativeLocation",
    type = "Vector",
    default = "(X=0,Y=0,Z=0)",
    display_name = "\231\155\184\229\175\185\228\189\141\231\189\174\229\129\143\231\167\187"
  },
  {
    name = "RelativeRotation",
    type = "Rotator",
    default = "(Pitch=0,Yaw=0,Roll=0)",
    display_name = "\231\155\184\229\175\185\230\151\139\232\189\172\229\129\143\231\167\187"
  },
  {name = "FOV", type = "float"}
})

function DialogueTimelineCameraSetupEvent_FreeCamera:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.CameraType = Enum.NpcInteractCameraType.NIC_4
end

function DialogueTimelineCameraSetupEvent_FreeCamera:FillCameraRequestParams(Config)
  Config.TargetActorID = self.TargetActorID
  if math.abs(self.RelativeLocation.X or 0) + math.abs(self.RelativeLocation.Y or 0) + math.abs(self.RelativeLocation.Z or 0) > 0 then
    Config.RelativeLocation = UE4.FVector(self.RelativeLocation.X, self.RelativeLocation.Y, self.RelativeLocation.Z)
    Config.RelativeRotation = UE4.FRotator(self.RelativeRotation.Pitch, self.RelativeRotation.Yaw, self.RelativeRotation.Roll)
  end
  Config.FOV = self.FOV
end

return DialogueTimelineCameraSetupEvent_FreeCamera
