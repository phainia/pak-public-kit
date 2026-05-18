local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineCameraMoveState")
local DialogueTimelineCameraMoveState_RoundAroundCenter = Base:Extend("DialogueTimelineCameraMoveState_RoundAroundCenter")
FsmUtils.MergeMembers(Base, DialogueTimelineCameraMoveState_RoundAroundCenter, {
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
  },
  {
    name = "DefaultRotateCenterLength",
    type = "float",
    default = 10000,
    display_name = "\233\187\152\232\174\164\230\151\139\232\189\172\228\184\173\229\191\131\232\183\157\231\166\187"
  },
  {
    name = "MaxTraceLength",
    type = "float",
    default = 10000,
    display_name = "\230\156\128\229\164\167Trace\232\183\157\231\166\187"
  }
})

function DialogueTimelineCameraMoveState_RoundAroundCenter:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.CameraMotionType = Enum.NpcInteractCameraMoveType.CAMERA_MOVE_ROUNDED
end

function DialogueTimelineCameraMoveState_RoundAroundCenter:FillCameraMotionRequestParams(CameraMotionInfo)
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
    Log.Error("DialogueTimelineCameraMoveState_RoundAroundCenter, cannot rotate around x axis!!!")
    return false
  end
  local TraceStart = self.CameraComp:Abs_K2_GetComponentLocation()
  local TraceEnd = TraceStart + self.CameraComp:GetForwardVector() * self.MaxTraceLength
  local HitResult, bHit = UE.UKismetSystemLibrary.Abs_LineTraceSingle(self.CameraComp, TraceStart, TraceEnd, UE.ETraceTypeQuery.Visibility, false, nil, UE.EDrawDebugTrace.ForDuration, nil, true)
  local ArmLength = self.DefaultRotateCenterLength
  if HitResult and bHit then
    ArmLength = self.CameraComp:GetForwardVector():Dot(UE.FVector(HitResult.Translation.X - TraceStart.X, HitResult.Translation.Y - TraceStart.Y, HitResult.Translation.Z - TraceStart.Z))
  end
  UE.UKismetSystemLibrary.Abs_DrawDebugSphere(self.CameraComp, TraceStart + self.CameraComp:GetForwardVector() * ArmLength, 20.0, 12, UE.FLinearColor(0, 0, 1), 4.0)
  local OriSpringArm = self.CameraComp:GetForwardVector() * ArmLength
  local DestSpringArm = OriSpringArm:RotateAngleAxis(self.RotateAngle, RotateAxis)
  local CameraLocation = self.CameraComp:Abs_K2_GetComponentLocation()
  local CameraRotation = self.CameraComp:K2_GetComponentRotation()
  local DestLocation = CameraLocation + DestSpringArm - OriSpringArm
  CameraMotionInfo.TargetCameraTransform = UE.FTransform(CameraRotation:ToQuat(), DestLocation, UE.FVector(1, 1, 1))
  CameraMotionInfo.CameraMoveTime = self.EndTime - self.StartTime
  CameraMotionInfo.CameraMoveValue = self.RotateAngle
  CameraMotionInfo.CameraRotationAxis = RotateAxis
  CameraMotionInfo.CameraRotationValue = -self.RotateAngle
  return true
end

return DialogueTimelineCameraMoveState_RoundAroundCenter
