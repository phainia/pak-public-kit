local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueCameraSetupAction = require("NewRoco.Modules.System.Dialogue.Action.DialogueCameraSetupAction")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local CameraModuleCmd = reload("NewRoco.Modules.System.Camera.CameraModuleCmd")
local Base = DialogueActionBase
local UnskippableCameraMotionAction = Base:Extend("UnskippableCameraMotionAction")
FsmUtils.MergeMembers(Base, UnskippableCameraMotionAction, {
  {
    name = "CameraSetting",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  },
  {
    name = "SideOfTarget",
    type = "var"
  },
  {
    name = "SideOfCamera",
    type = "var"
  },
  {name = "TargetNPC", type = "var"},
  {
    name = "TargetValue",
    type = "var"
  },
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "isLast", type = "boolean"},
  {name = "Center", type = "boolean"}
})

function UnskippableCameraMotionAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:InitVariables()
end

function UnskippableCameraMotionAction:OnEnter()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  else
    DelayManager:DelayFrames(1, self.OnEnterExecute, self)
  end
end

function UnskippableCameraMotionAction:OnEnterExecute()
  self:InjectProperties()
  self.bInBattle = self:GetProperty("bInBattle")
  self.bUseBattleCamera = self:GetProperty("bUseBattleCamera")
  self.CameraSetting = self:GetProperty("CameraSetting")
  if self.bInBattle then
    self:Finish()
    return
  end
  self:InitVariables()
  if self.DialogueConf.ui_source_type == Enum.UIsourceType.UIT_BLACK_EXIT then
    self:OnDialogueFinish()
  elseif string.IsNilOrEmpty(self.DialogueConf.text) then
    self:OnDialogueFinish()
  else
    self:AddListener()
  end
  if self.ParentModule.CameraBlackScreen then
    self.CameraSetting.unskippable_duration = 0
  end
  self:Initiate()
end

function UnskippableCameraMotionAction:InitVariables()
  self.elapsedTime = 0
  self.deltaX = 0
  self.deltaY = 0
  self.Hit = false
  self.deltaZ = 0
  self.deltaPRot = 0
  self.deltaYRot = 0
  self.deltaRRot = 0
  self.Coefficient = 1
  self.PrevLoc = nil
  self.TarLoc = nil
  self.CameraMoveComplete = true
  self.Skipped = false
  self.AdjustAccumulate = UE.FVector(0, 0, 0)
end

function UnskippableCameraMotionAction:IsMaintainCamera()
  return 1 == self.CameraSetting.CameraNumber and self.DialogueConf.interact_camera_type_2 == nil or 2 == self.CameraSetting.CameraNumber
end

function UnskippableCameraMotionAction:Initiate()
  if self.CameraSetting.unskippable_duration > 0 then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenInputBlocker, "DialogueModule.BlockInputAction")
    self.blocker = true
  end
  if self.CameraSetting.camera_motion_type then
    self.Player = DialogueUtils.GetPlayer()
    local CameraActor
    local CameraHolder = _G.NRCModuleManager:DoCmd(CameraModuleCmd.GetCameraHolder)
    if CameraHolder then
      CameraActor = CameraHolder:GetCurrentCamera()
    end
    if not CameraActor or not UE.UObject.IsValid(CameraActor) then
      CameraActor = DialogueUtils.GetController(self.Player).CameraActor
    end
    if CameraActor then
      self.CameraComp = CameraActor:GetComponentByClass(UE4.UCameraComponent)
      self.SPComp = CameraActor:GetComponentByClass(UE4.URocoSpringArmComponent)
      self.CamForward = self.CameraComp:GetForwardVector()
      self.CamRight = self.CameraComp:GetRightVector()
      self.KamLoc = self.CameraComp:Abs_K2_GetComponentToWorld()
      self.TarLoc = self.KamLoc
    else
      Log.Warning("UnskippableCameraMotionAction:Initiate no CameraActor found")
    end
    self:ProcessMoveFunction()
  end
  UpdateManager:Register(self)
end

function UnskippableCameraMotionAction:OnTick(DeltaTime)
  self.bInBattle = self:GetProperty("bInBattle")
  if self.bInBattle or not self.CameraSetting then
    return
  end
  if not self.elapsedTime then
    Log.Error("UnskippableCameraMotionAction:OnTick tick without initialize?")
    return
  end
  self.elapsedTime = DeltaTime + self.elapsedTime
  if self.MoveTime and self.elapsedTime / self.MoveTime >= 1 then
    self.CameraMoveComplete = true
  end
  if self.elapsedTime >= self.CameraSetting.unskippable_duration then
    self:CloseBlocker()
    self:FinishActual()
  end
end

function UnskippableCameraMotionAction:OnExit()
end

function UnskippableCameraMotionAction:IsMoveCameraType()
  local IsMoveType = self.CameraSetting.interact_camera_type == nil
  IsMoveType = IsMoveType or self.CameraSetting.interact_camera_type == Enum.NpcInteractCameraType.NIC_OVERSHOULDER
  IsMoveType = IsMoveType or self.CameraSetting.interact_camera_type == Enum.NpcInteractCameraType.NIC_MIDSYMMETRY
  IsMoveType = IsMoveType or self.CameraSetting.interact_camera_type == Enum.NpcInteractCameraType.NIC_SIDECHESTSHOT
  IsMoveType = IsMoveType or self.CameraSetting.interact_camera_type == Enum.NpcInteractCameraType.NIC_OBJECTIVESHOT
  IsMoveType = IsMoveType or self.CameraSetting.interact_camera_type == Enum.NpcInteractCameraType.NIC_4
  IsMoveType = IsMoveType or self.CameraSetting.interact_camera_type == Enum.NpcInteractCameraType.NIC_3
  IsMoveType = IsMoveType or self.CameraSetting.interact_camera_type == Enum.NpcInteractCameraType.NIC_2
  IsMoveType = IsMoveType or self.CameraSetting.interact_camera_type == Enum.NpcInteractCameraType.NIC_1
  return IsMoveType
end

function UnskippableCameraMotionAction:ProcessMoveFunction()
  if not self:IsMoveCameraType() then
    return
  end
  self.CameraMoveComplete = false
  self.MoveValue = self.CameraSetting.camera_motion_distance
  self.MoveTime = self.CameraSetting.camera_motion_time
  if self.CameraSetting.camera_motion_type == Enum.NpcInteractCameraMoveType.CAMERA_MOVE_PARALLEL then
    if not self.MoveValue or 0 == self.MoveValue then
      self.MoveValue = 20
    end
    if not self.MoveTime or 0 == self.MoveTime then
      self.MoveTime = 15
    end
    if string.find(self.CameraSetting.camera_motion_direction, "Y") then
      local Target = tonumber(self:GetProperty("TargetValue"))
      local sideTar = self:GetProperty("SideOfTarget") or 1
      if -2 == Target and sideTar <= 0 then
        self.Coefficient = 1
      elseif -2 == Target and sideTar > 0 then
        self.Coefficient = -1
      elseif -1 == Target and sideTar <= 0 then
        self.Coefficient = -1
      elseif -1 == Target and sideTar > 0 then
        self.Coefficient = 1
      elseif sideTar > 0 then
        self.Coefficient = 1
      elseif sideTar <= 0 then
        self.Coefficient = -1
      end
      self.deltaY = self.MoveValue
    else
      if string.find(self.CameraSetting.camera_motion_direction, "+") then
        self.Coefficient = 1
      elseif string.find(self.CameraSetting.camera_motion_direction, "-") then
        self.Coefficient = -1
      end
      if string.find(self.CameraSetting.camera_motion_direction, "X") then
        self.deltaX = self.MoveValue
      elseif string.find(self.CameraSetting.camera_motion_direction, "Z") then
        self.deltaZ = self.MoveValue
      end
    end
    local ldx = self.CamForward * self.deltaX * self.Coefficient
    local ldy = self.CamRight * self.deltaY * self.Coefficient
    local ldz = self.deltaZ * self.Coefficient
    local LocTemp = UE.FVector(self.KamLoc.Translation.X, self.KamLoc.Translation.Y, self.KamLoc.Translation.Z)
    LocTemp.Z = LocTemp.Z + ldz
    local RotatorTemp = self.KamLoc.Rotation:ToRotator()
    local ldpr = self.deltaPRot + RotatorTemp.Pitch
    local ldyr = self.deltaYRot + RotatorTemp.Yaw
    local ldrr = self.deltaRRot + RotatorTemp.Roll
    local RotTemp = UE.FRotator(ldpr, ldyr, ldrr)
    self.TarLoc = UE.FTransform(RotTemp:ToQuat(), LocTemp + ldx + ldy, UE.FVector(1, 1, 1))
  elseif self.CameraSetting.camera_motion_type == Enum.NpcInteractCameraMoveType.CAMERA_MOVE_ROTATED then
    if not self.MoveTime or 0 == self.MoveTime then
      self.MoveTime = 0.8
    end
    local Target
    local All = false
    local PlayerBp
    if self.bInBattle then
      PlayerBp = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
    else
      PlayerBp = DialogueUtils.GetPlayer().viewObj
    end
    if self.CameraSetting.camera_motion_direction == "-1" then
      Target = PlayerBp
    elseif self.CameraSetting.camera_motion_direction == "-2" then
      Target = self.TargetNPC.viewObj
    else
      local Param1 = tonumber(self.CameraSetting.camera_motion_direction)
      local ActorType = 20075
      local RangeRad = DialogueCameraSetupAction.DetectionSettings.near
      ActorType = Param1
      local ActorName = self.CameraSetting.camera_motion_direction
      local ActorName2 = "nada"
      local ActorName3 = "nada"
      local ActorName4 = "nada"
      local ActorFound
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
      Target = ActorFound
    end
    if not Target then
      self.TarLoc = self.KamLoc
      return
    end
    local TargetLoc = Target:Abs_K2_GetActorLocation()
    local LookAtRot = UE.UKismetMathLibrary.FindLookAtRotation(self.KamLoc.Translation, TargetLoc)
    local RotatorTemp = self.KamLoc.Rotation:ToRotator()
    local ldpr = self.deltaPRot + RotatorTemp.Pitch
    local ldyr = LookAtRot.Yaw
    local ldrr = self.deltaRRot + RotatorTemp.Roll
    local RotTemp = UE.FRotator(ldpr, ldyr, ldrr)
    if All then
      self.TarLoc = UE.FTransform(LookAtRot:ToQuat(), self.KamLoc.Translation, UE.FVector(1, 1, 1))
    else
      self.TarLoc = UE.FTransform(RotTemp:ToQuat(), self.KamLoc.Translation, UE.FVector(1, 1, 1))
    end
  elseif self.CameraSetting.camera_motion_type == Enum.NpcInteractCameraMoveType.CAMERA_MOVE_ROUNDED then
    if not self.MoveValue or 0 == self.MoveValue then
      self.MoveValue = 5
    end
    if not self.MoveTime or 0 == self.MoveTime then
      self.MoveTime = 15
    end
    local ArmLength = self.SPComp and self.SPComp.TargetArmLength or 0
    local SPVector = self.KamLoc.Translation + self.CamForward * ArmLength
    local Dir = SPVector - self.KamLoc.Translation
    self.SPVector = SPVector
    if self.CameraSetting.camera_motion_direction then
      if string.find(self.CameraSetting.camera_motion_direction, "0") then
        local Target = tonumber(self:GetProperty("TargetValue"))
        local sideTar = self:GetProperty("SideOfTarget") or 1
        if -2 == Target and sideTar <= 0 then
          self.Coefficient = 1
        elseif -2 == Target and sideTar > 0 then
          self.Coefficient = -1
        elseif -1 == Target and sideTar <= 0 then
          self.Coefficient = -1
        elseif -1 == Target and sideTar > 0 then
          self.Coefficient = 1
        elseif sideTar > 0 then
          self.Coefficient = 1
        elseif sideTar <= 0 then
          self.Coefficient = -1
        end
        if self.ParentModule.MoveDir then
          self.Coefficient = self.ParentModule.MoveDir
        end
        self.MoveMax = self.Coefficient * self.MoveValue
        self.RotVec = UE4Helper.UpVector
        local Rotated = Dir:RotateAngleAxis(self.MoveMax, UE4Helper.UpVector)
        self.TarLoc = UE.FTransform(self.KamLoc.Rotation, self.KamLoc.Translation + Rotated - Dir, UE.FVector(1, 1, 1))
      else
        if string.find(self.CameraSetting.camera_motion_direction, "+") then
          self.Coefficient = -1
        elseif string.find(self.CameraSetting.camera_motion_direction, "-") then
          self.Coefficient = 1
        end
        self.MoveMax = self.Coefficient * self.MoveValue
        self.RotVec = self.CamRight
        if self.CamRight == nil then
          self.CamRight = UE.FVector(0, 1, 0)
          Log.Error("CamRight\231\169\186\229\149\166\239\188\129\239\188\129\239\188\129")
        end
        local Rotated = Dir:RotateAngleAxis(self.MoveMax, self.CamRight)
        self.TarLoc = UE.FTransform(self.KamLoc.Rotation, self.KamLoc.Translation + Rotated - Dir, UE.FVector(1, 1, 1))
      end
    else
    end
  end
  if 0 == self.MoveTime then
    return
  end
  local CameraMotionInfo = NRCModuleManager:DoCmd(CameraModuleCmd.FillCameraMotionInfo, self.CameraSetting.camera_motion_type)
  CameraMotionInfo.TargetCameraTransform = self.TarLoc
  CameraMotionInfo.CameraMoveTime = self.MoveTime
  CameraMotionInfo.CameraMoveValue = self.MoveValue
  CameraMotionInfo.CameraRotationAxis = self.RotVec
  CameraMotionInfo.CameraRotationValue = self.MoveMax
  NRCModuleManager:DoCmd(CameraModuleCmd.StartCameraMotion, CameraMotionInfo)
end

function UnskippableCameraMotionAction:OnFinish()
  self:RemoveListener()
end

function UnskippableCameraMotionAction:OnExit()
  self:RemoveListener()
  UpdateManager:UnRegister(self)
end

function UnskippableCameraMotionAction:OnDialogueFinish(Dialogue)
  if Dialogue and Dialogue.id ~= self.DialogueConf.id then
    Log.Error("dialogue id mismatch", Dialogue.id, self.DialogueConf.id)
    return
  end
  self.Skipped = true
  self:FinishActual()
end

function UnskippableCameraMotionAction:FinishActual()
  if not self.finished then
    UpdateManager:UnRegister(self)
    self:Finish()
  end
end

function UnskippableCameraMotionAction:CloseBlocker()
  if self.blocker then
    self.blocker = false
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "DialogueModule.BlockInputAction")
  end
end

function UnskippableCameraMotionAction:AddListener()
  local ParentModule = self:GetProperty("ParentModule")
  if ParentModule then
    ParentModule:RegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished, self.OnDialogueFinish)
  end
end

function UnskippableCameraMotionAction:RemoveListener()
  local ParentModule = self:GetProperty("ParentModule")
  if ParentModule then
    ParentModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished)
  end
end

return UnskippableCameraMotionAction
