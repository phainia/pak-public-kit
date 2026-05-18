local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineCameraMoveState")
local DialogueTimelineCameraMoveState_Rotate = Base:Extend("DialogueTimelineCameraMoveState_Rotate")
FsmUtils.MergeMembers(Base, DialogueTimelineCameraMoveState_Rotate, {
  {
    name = "TargetActorID",
    type = "SheetRef.NPC_CONF",
    default = -1,
    display_name = "\230\156\157\229\144\145\231\155\174\230\160\135\231\142\169\229\174\182ID"
  },
  {
    name = "MoveDistance",
    type = "float",
    default = 20.0,
    display_name = "\231\167\187\229\138\168\232\183\157\231\166\187"
  }
})

function DialogueTimelineCameraMoveState_Rotate:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.CameraMotionType = Enum.NpcInteractCameraMoveType.CAMERA_MOVE_ROTATED
end

function DialogueTimelineCameraMoveState_Rotate:FillCameraMotionRequestParams(CameraMotionInfo)
  if not self.CameraComp then
    return false
  end
  local PlayerBp
  self.bInBattle = self.fsm:GetProperty("bInBattle")
  if self.bInBattle then
    PlayerBp = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  else
    PlayerBp = DialogueUtils.GetPlayer().viewObj
  end
  if -1 == self.TargetActorID then
    Target = PlayerBp
  elseif -2 == self.TargetActorID then
    Target = self.TargetNPC.viewObj
  else
    Target = self:FindTargetByName()
  end
  if not Target then
    return false
  end
  local CameraTransform = self.CameraComp:Abs_K2_GetComponentToWorld()
  local CameraRotator = CameraTransform.Rotation:ToRotator()
  local LookAtRot = UE.UKismetMathLibrary.FindLookAtRotation(CameraTransform.Translation, Target:Abs_K2_GetActorLocation())
  CameraMotionInfo.TargetCameraTransform = UE.FTransform(UE.FRotator(CameraRotator.Pitch, LookAtRot.Yaw, CameraRotator.Roll):ToQuat(), CameraTransform.Translation, UE.FVector(1, 1, 1))
  CameraMotionInfo.CameraMoveTime = self.EndTime - self.StartTime
  CameraMotionInfo.CameraMoveValue = self.MoveDistance
  CameraMotionInfo.CameraRotationAxis = nil
  CameraMotionInfo.CameraRotationValue = nil
  return true
end

function DialogueTimelineCameraMoveState_Rotate:FindTargetByName()
  local ActorType = tonumber(self.TargetActorID)
  local RangeRad = DialogueCameraSetupAction.DetectionSettings.near
  local ActorName = self.CameraSetting.MoveDirection
  local ActorName2 = "nada"
  local ActorName3 = "nada"
  local ActorName4 = "nada"
  if 1 == ActorType then
    ActorName = "Statue"
    ActorName2 = "Tree"
    ActorName4 = "Flower"
  end
  if not ActorType or 1 == ActorType then
    if not ActorType then
      RangeRad = DialogueCameraSetupAction.DetectionSettings.far
    end
    local Actors, Results = UE4.UKismetSystemLibrary.Abs_SphereOverlapActors(UE4Helper.GetCurrentWorld(), PlayerBp.CharacterMovement.UpdatedComponent:Abs_K2_GetComponentLocation(), RangeRad, nil, nil, nil)
    for i = 1, Actors:Length() do
      local Namo = Actors:Get(i):GetName()
      if Actors:Get(i).Overridden then
        Namo = Actors:Get(i).Overridden.GetName(Actors:Get(i))
      end
      if Namo then
        local foundIdx = string.find(Namo, ActorName)
        local foundIdx2 = string.find(Namo, ActorName2)
        local foundIdx3 = string.find(Namo, ActorName3)
        local foundIdx4 = string.find(Namo, ActorName4)
        if foundIdx and foundIdx >= 0 or foundIdx2 and foundIdx2 >= 0 or foundIdx3 and foundIdx3 >= 0 or foundIdx4 and foundIdx4 >= 0 then
          ActorFound = Actors:Get(i)
          break
        end
      end
    end
  else
    RangeRad = DialogueCameraSetupAction.DetectionSettings.far
    local Actors, Results = UE4.UNRCStatics.SphereOverlapActors(UE4Helper.GetCurrentWorld(), self.Player.viewObj:K2_GetActorLocation(), RangeRad, nil, nil)
    for i = 1, Actors:Length() do
      local SC = Actors:Get(i).sceneCharacter
      if SC and SC.config and ActorType == SC.config.id then
        ActorFound = Actors:Get(i)
        break
      end
    end
  end
  return ActorFound
end

return DialogueTimelineCameraMoveState_Rotate
