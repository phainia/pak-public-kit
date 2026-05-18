local HomeEditEnv = Class("HomeEditEnv")

function HomeEditEnv:Ctor(World)
  self.World = World
  self.bEnabled = false
  self.ControlPawn = nil
  self.PlaceStatus = nil
  self.ControlCam = nil
  self.OutlineHighLightMat = nil
  self.OutlineHighLightMatRef = nil
  self.FurnitureCam = nil
end

function HomeEditEnv:OnExitHome()
  self.bEnabled = false
  self.ControlPawn = nil
  self.ControlCam = nil
  self.PlaceStatus = nil
  self.OutlineHighLightMat = nil
  self.OutlineHighLightMatRef = nil
  self.FurnitureCam = nil
end

function HomeEditEnv:PreEnterCheck()
  if HomeIndoorSandbox:Ensure(self.World.UEWorld and UE.UObject.IsValid(self.World.UEWorld), "invalid world") and HomeIndoorSandbox:Ensure(not _G.ZoneServer:IsUpstreamLocked(), "upstream locked") then
    local ControlPawnClassPath = HomeIndoorSandbox.ResMgr:TryGetResource(HomeIndoorSandbox.Define.ControlPawnClassPath)
    if HomeIndoorSandbox:Ensure(ControlPawnClassPath and UE.UObject.IsValid(ControlPawnClassPath), "invalid pawn class") then
      local PropsStatusClassPath = HomeIndoorSandbox.ResMgr:TryGetResource(HomeIndoorSandbox.Define.PropsStatusClassPath)
      if HomeIndoorSandbox:Ensure(PropsStatusClassPath and UE.UObject.IsValid(PropsStatusClassPath), "invalid place status class") then
        local Pawn = self:GetOrSpawnControlPawn()
        if HomeIndoorSandbox:Ensure(Pawn and UE.UObject.IsValid(Pawn), "invalid spawn pawn") then
          local Status = self:GetOrSpawnPlaceStatus()
          if HomeIndoorSandbox:Ensure(Status and UE.UObject.IsValid(Status), "invalid spawn status") then
            return true
          end
        end
      end
    end
  end
  return false
end

function HomeEditEnv:SpawnFurnitureCamera(Callback)
  self.bEnableFurnitureCam = true
  if self.FurnitureCam then
    Callback(self.FurnitureCam)
    return
  end
  local Sandbox = HomeIndoorSandbox
  local FurnitureCameraClass = Sandbox.ResMgr:TryGetResource(Sandbox.Define.FurnitureCameraPath)
  
  local function OnLoad(InFurnitureCameraClass)
    local World = self.World.UEWorld
    if self.bEnableFurnitureCam and InFurnitureCameraClass and World then
      self.FurnitureCam = World:Abs_SpawnActor(InFurnitureCameraClass, UE.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    end
    Callback(self.FurnitureCam)
  end
  
  if FurnitureCameraClass then
    OnLoad(FurnitureCameraClass)
  else
    Sandbox.ResMgr:ReqResource(OnLoad, Sandbox.Define.FurnitureCameraPath)
  end
end

function HomeEditEnv:RecycleFurnitureCamera()
  self.bEnableFurnitureCam = false
  if self.FurnitureCam then
    self.FurnitureCam:K2_DestroyActor()
  end
end

function HomeEditEnv:GetOrSpawnControlPawn()
  local Sandbox = HomeIndoorSandbox
  local Instance = self.ControlPawn
  if not Instance then
    local ControlPawnClassPath = Sandbox.ResMgr:TryGetResource(Sandbox.Define.ControlPawnClassPath)
    local World = self.World.UEWorld
    Instance = World:Abs_SpawnActor(ControlPawnClassPath, UE.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    if not Instance then
      return
    end
    Instance:SetActorHiddenInGame(true)
    Instance:SetActorEnableCollision(false)
    Instance.CharacterMovement.GravityScale = 0
    Instance.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_Flying)
    self.ControlPawn = Instance
    self.ControlRadius = self.ControlPawn.CapsuleComponent:GetScaledCapsuleRadius()
    self.ControlHeight = self.ControlPawn.CapsuleComponent:GetScaledCapsuleHalfHeight()
  end
  return Instance
end

function HomeEditEnv:GetOrSpawnPlaceStatus()
  local Sandbox = HomeIndoorSandbox
  local Instance = self.PlaceStatus
  if not Instance then
    local PropsStatusClassPath = Sandbox.ResMgr:TryGetResource(Sandbox.Define.PropsStatusClassPath)
    local World = self.World.UEWorld
    Instance = World:Abs_SpawnActor(PropsStatusClassPath, UE.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    if not Instance then
      return
    end
    Instance:SetActorHiddenInGame(true)
    Instance:SetActorEnableCollision(false)
    self.PlaceStatus = Instance
  end
  return Instance
end

function HomeEditEnv:EnsureGetOutlineHighLightMat()
  local Sandbox = HomeIndoorSandbox
  local Instance = self.OutlineHighLightMat
  if not Instance then
    Instance = Sandbox.ResMgr:TryGetResource(Sandbox.Define.OutlineHighLight)
    if not Instance then
      Instance = UE.UObject.Load(Sandbox.Define.OutlineHighLight)
      Instance = UE4.UKismetMaterialLibrary.CreateDynamicMaterialInstance(UE4Helper.GetCurrentWorld(), Instance)
      self.OutlineHighLightMat = Instance
      self.OutlineHighLightMatRef = UnLua.Ref(Instance)
    else
      Instance = UE4.UKismetMaterialLibrary.CreateDynamicMaterialInstance(UE4Helper.GetCurrentWorld(), Instance)
      self.OutlineHighLightMat = Instance
      self.OutlineHighLightMatRef = UnLua.Ref(Instance)
    end
    Instance:SetScalarParameterValue("DistanceUniform", 0)
    Instance:SetScalarParameterValue("OutlineWidth", 1.5)
    Instance:SetScalarParameterValue("OutlineOffset", 25)
    Instance:SetScalarParameterValue("CustomClip", 1)
  end
  return Instance
end

function HomeEditEnv:SetEditEnvironmentEnabled(bEnable)
  if self.bEnabled ~= bEnable then
    self.bEnabled = bEnable
    if bEnable then
      self:GetOrSpawnControlPawn()
      self:GetOrSpawnPlaceStatus()
    else
      self:RecycleControlPawn()
      self:RecyclePlaceStatus()
      self:RecycleControlCam()
    end
  end
end

function HomeEditEnv:ModifyControlCamPitch(DesiredPitch, Percent)
  if self.ControlCam then
    local Rot = self.ControlCam:K2_GetActorRotation()
    if math.abs(DesiredPitch - Rot.Pitch) <= 1 then
      return true
    end
    local DesiredRot = UE.FRotator(DesiredPitch, Rot.Yaw, Rot.Roll)
    local NewRot = UE.FQuat.Slerp(Rot:ToQuat(), DesiredRot:ToQuat(), Percent)
    self.ControlCam:K2_SetActorRotation(NewRot:ToRotator(), false)
    return false
  end
  return true
end

function HomeEditEnv:ModifyFOV(FOV)
  if self.ControlCam then
    local Camera = self.ControlCam.Camera
    Camera.FieldOfView = FOV
  end
end

function HomeEditEnv:GetFOV()
  if self.ControlCam then
    return self.ControlCam.Camera.FieldOfView
  end
  return 90
end

function HomeEditEnv:ReqUseControlCam(ViewportLoc, ViewportRot, EditPointLoc, SpringArmLength, EditSocketOffset)
  if not self.ControlCam then
    local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    self.ControlCam = Player:GetUEController():RequestRocoCamera()
  end
  self:ReqUseControlPawn()
  local SpringArm = self.ControlCam.BP_RocoSpringArmComponent
  local ControlHeight = self.ControlHeight
  SpringArm:SetTargetOffset(EditSocketOffset - UE.FVector(0, 0, ControlHeight), true)
  SpringArm:SetArmLength(SpringArmLength or 475, true)
  SpringArm.bUsePawnControlRotation = false
  SpringArm.bDoCollisionTest = true
  SpringArm.bEnableCameraLag = false
  SpringArm.bEnableCameraRotationLag = false
  local Loc = EditPointLoc + UE.FVector(0, 0, ControlHeight)
  self.ControlPawn:Abs_K2_SetActorLocationAndRotation(Loc, UE.FRotator(0, ViewportRot.Yaw, 0), false, nil, true)
  self.ControlCam:Abs_K2_SetActorLocationAndRotation(Loc, ViewportRot, false, nil, true)
  self.ControlCam:K2_AttachToActor(self.ControlPawn, nil, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld)
  DelayManager:DelayFrames(1, function()
    if self.ControlCam then
      SpringArm.bEnableCameraLag = true
      SpringArm.bEnableCameraRotationLag = true
    end
  end)
  return self.ControlCam
end

function HomeEditEnv:RecycleControlCam()
  if not self.ControlCam then
    return
  end
  if not UE.UObject.IsValid(self.ControlCam) then
    self.ControlCam = nil
    return
  end
  local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.ControlCam:K2_DetachFromActor(UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld)
  local SpringArm = self.ControlCam.BP_RocoSpringArmComponent
  SpringArm.bDoCollisionTest = true
  self:ModifyFOV(90)
  local Controller = Player and Player:GetUEController()
  if Controller and UE4.UObject.IsValid(Controller) and Controller:IsCurrentViewTarget(self.ControlCam) then
    Player:GetUEController():ReleaseRocoCamera()
  end
  self.ControlCam = nil
end

function HomeEditEnv:ReqUseControlPawn()
  self.ControlPawn:SetActorHiddenInGame(false)
  return self.ControlPawn
end

function HomeEditEnv:RecycleControlPawn()
  if not self.ControlPawn then
    return
  end
  if not UE.UObject.IsValid(self.ControlPawn) then
    return
  end
  self.ControlPawn:SetActorHiddenInGame(true)
end

function HomeEditEnv:ReqUsePlaceStatus()
  self.PlaceStatus:SetActorHiddenInGame(false)
  return self.PlaceStatus
end

function HomeEditEnv:RecyclePlaceStatus()
  if not self.PlaceStatus then
    return
  end
  if not UE.UObject.IsValid(self.PlaceStatus) then
    return
  end
  self.PlaceStatus:SetActorHiddenInGame(true)
end

return HomeEditEnv
