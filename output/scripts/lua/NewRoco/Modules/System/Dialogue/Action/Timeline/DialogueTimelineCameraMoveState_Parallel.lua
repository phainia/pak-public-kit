local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineCameraMoveState")
local DialogueTimelineCameraMoveState_Parallel = Base:Extend("DialogueTimelineCameraMoveState_Parallel")
FsmUtils.MergeMembers(Base, DialogueTimelineCameraMoveState_Parallel, {
  {
    name = "MoveDistance",
    type = "float",
    default = 20.0,
    display_name = "\231\167\187\229\138\168\232\183\157\231\166\187"
  },
  {
    name = "MoveDirection",
    type = "Enum.AxisType",
    default = 0,
    display_name = "\232\191\144\229\138\168\230\150\185\229\144\145"
  }
})

function DialogueTimelineCameraMoveState_Parallel:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.CameraMotionType = Enum.NpcInteractCameraMoveType.CAMERA_MOVE_PARALLEL
end

function DialogueTimelineCameraMoveState_Parallel:FillCameraMotionRequestParams(CameraMotionInfo)
  if not self.CameraComp then
    return false
  end
  if not self.MoveDistance or 0 == self.MoveDistance then
    self.MoveDistance = 20
  end
  local MoveForward
  if self.MoveDirection == Enum.AxisType.AT_X then
    MoveForward = self.CameraComp:GetForwardVector()
  elseif self.MoveDirection == Enum.AxisType.AT_Y then
    MoveForward = self.CameraComp:GetRightVector()
  else
    MoveForward = self.CameraComp:GetUpVector()
  end
  local CameraTransform = self.CameraComp:Abs_K2_GetComponentToWorld()
  local DestLocation = CameraTransform.Translation + MoveForward * self.MoveDistance
  CameraMotionInfo.TargetCameraTransform = UE.FTransform(CameraTransform.Rotation, DestLocation, UE.FVector(1, 1, 1))
  CameraMotionInfo.CameraMoveTime = self.EndTime - self.StartTime
  CameraMotionInfo.CameraMoveValue = self.MoveDistance
  CameraMotionInfo.CameraRotationAxis = nil
  CameraMotionInfo.CameraRotationValue = nil
  return true
end

return DialogueTimelineCameraMoveState_Parallel
