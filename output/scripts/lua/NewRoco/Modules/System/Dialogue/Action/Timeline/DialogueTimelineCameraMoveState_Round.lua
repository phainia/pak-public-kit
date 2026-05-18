local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineCameraMoveState")
local DialogueTimelineCameraMoveState_Round = Base:Extend("DialogueTimelineCameraMoveState_Round")
FsmUtils.MergeMembers(Base, DialogueTimelineCameraMoveState_Round, {
  {
    name = "RotateDirection",
    type = "Enum.AxisType",
    default = 2,
    display_name = "\231\142\175\231\187\149\230\150\185\229\144\145"
  },
  {
    name = "RotateAngle",
    type = "float",
    default = 5,
    display_name = "\232\191\144\229\138\168\232\167\146\229\186\166"
  }
})

function DialogueTimelineCameraMoveState_Round:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.CameraMotionType = Enum.NpcInteractCameraMoveType.CAMERA_MOVE_ROUNDED
end

function DialogueTimelineCameraMoveState_Round:FillCameraMotionRequestParams(CameraMotionInfo)
  if not self.CameraComp then
    return false
  end
  if not self.RotateAngle or 0 == self.RotateAngle then
    self.RotateAngle = 15
  end
  local RotateAxis
  if self.RotateDirection == Enum.AxisType.AT_Z then
    RotateAxis = self.CameraComp:GetRightVector()
  elseif self.RotateDirection == Enum.AxisType.AT_Y then
    RotateAxis = UE4Helper.UpVector
  else
    Log.Error("DialogueTimelineCameraMoveState_Round, cannot rotate around x axis!!!")
    return false
  end
  local ArmLength = self.SpringArmComp and self.SpringArmComp.TargetArmLength or 0
  local OriSpringArm = self.CameraComp:GetForwardVector() * ArmLength
  local DestSpringArm = OriSpringArm:RotateAngleAxis(self.RotateAngle, RotateAxis)
  local CameraLocation = self.CameraComp:Abs_K2_GetComponentLocation()
  local CameraRotation = self.CameraComp:K2_GetComponentRotation()
  local DestLocation = CameraLocation + DestSpringArm - OriSpringArm
  CameraMotionInfo.TargetCameraTransform = UE4.FTransform(CameraRotation:ToQuat(), DestLocation, UE.FVector(1, 1, 1))
  CameraMotionInfo.CameraMoveTime = self.EndTime - self.StartTime
  CameraMotionInfo.CameraMoveValue = self.RotateAngle
  CameraMotionInfo.CameraRotationAxis = RotateAxis
  CameraMotionInfo.CameraRotationValue = -self.RotateAngle
  return true
end

return DialogueTimelineCameraMoveState_Round
