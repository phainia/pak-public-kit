local TripodController = Class("TripodController")

function TripodController:Ctor(TripodMode)
  self.TripodMode = TripodMode
  self.TripodSpawnTransform = nil
  self.FloorZ = 0
  self.CreateHeightConfig = TakePhotosEnum.TPGlobalNum("takephoto_camera_create_height", 100)
  self.CreateDistanceConfig = TakePhotosEnum.TPGlobalNum("takephoto_camera_create_distance", 200)
  self.MaxiHeightConfig = TakePhotosEnum.TPGlobalNum("takephoto_camera_up", 300)
  self.MiniHeightConfig = TakePhotosEnum.TPGlobalNum("takephoto_camera_down", 100)
  self.HorizontalConfig = TakePhotosEnum.TPGlobalNum("takephoto_tripod_horizontal_offset", 300)
  self.TraceObjectTypes = {
    UE.EObjectTypeQuery.WorldDynamic,
    UE.EObjectTypeQuery.WorldStatic,
    UE.EObjectTypeQuery.Character,
    UE.EObjectTypeQuery.Visibility,
    UE.EObjectTypeQuery.WaterSurface,
    UE.EObjectTypeQuery.Pawn
  }
  self.DeltaToleranceVec = UE.FVector(0, 0, 5)
  self.RightVec = UE.FVector(0, 1, 0)
  self.LeftVec = UE.FVector(0, -1, 0)
  self.UpVec = UE.FVector(0, 0, 1)
  self.DownVec = UE.FVector(0, 0, -1)
  self.ElapsedMovementInput = FVectorZero
  self.bMovementInput = false
  self.IgnoreActors = {}
end

function TripodController:GetSettings()
  return NRCModuleManager:GetModule("TakePhotosModule").Controller.TakePhotoSettings
end

function TripodController:TryLocTripodSpawnTransform()
  local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerLocation = Player.viewObj:Abs_K2_GetActorLocation()
  local FloorZ = PlayerLocation.Z - Player:GetHalfHeight()
  local SpawnLocation = UE.FVector(PlayerLocation.X, PlayerLocation.Y, FloorZ + self.CreateHeightConfig)
  local PlayerRotation = Player.viewObj:K2_GetActorRotation()
  local Forward = UE.UKismetMathLibrary.GetForwardVector(UE.FRotator(0, PlayerRotation.Yaw, 0))
  local Distance = self.CreateDistanceConfig
  if Player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
    local Pet = Player.viewObj.BP_RideComponent.RidePet
    if Pet then
      local CapsuleComponent = Pet.CapsuleComponent
      if CapsuleComponent then
        local Width = CapsuleComponent:GetScaledCapsuleRadius()
        Distance = Distance + Width
      end
    end
  end
  SpawnLocation = SpawnLocation + Forward * Distance
  local SpawnRotation = (-Forward):ToQuat()
  local SpawnTransform = UE.FTransform(SpawnRotation, SpawnLocation, UE.FVector(1, 1, 1))
  self.IgnoreActors = {}
  local CollisionActor = self:TraceCamera(SpawnLocation + self.DeltaToleranceVec, SpawnLocation - self.DeltaToleranceVec)
  if not CollisionActor then
    local IgnoreActors = {
      Player.viewObj
    }
    self.TripodMode:AttachIgnoreActors(IgnoreActors)
    local HitResult, bHitMiddle = UE.UKismetSystemLibrary.Abs_LineTraceSingle(UE4Helper.GetCurrentWorld(), PlayerLocation, SpawnLocation, UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_Camera), false, IgnoreActors, UE4.EDrawDebugTrace.None, nil, true, UE4.FLinearColor.Red, UE4.FLinearColor.Green, 10)
    if bHitMiddle then
      CollisionActor = HitResult.Actor
      Log.Warning("[TakePhoto] \228\184\173\233\151\180\230\156\137\233\152\187\230\140\161", CollisionActor and CollisionActor:GetName())
      return
    end
    self.TripodSpawnTransform = SpawnTransform
    self.FloorZ = FloorZ
    return self.TripodSpawnTransform
  else
    Log.Warning("[TakePhoto] \228\189\141\231\189\174\230\156\137\233\152\187\230\140\161", CollisionActor and CollisionActor:GetName())
  end
end

function TripodController:ChangeRoll(Roll)
  local TripodNpc = self.TripodMode.TripodNpc
  if TripodNpc then
    local ActorRotation = TripodNpc:K2_GetActorRotation()
    ActorRotation.Roll = Roll
    TripodNpc:K2_SetActorRotation(ActorRotation, true)
  end
end

function TripodController:TraceCamera(Start, End)
  local IgnoreActors = self.IgnoreActors
  if self.TripodMode.TripodNpc and UE.UObject.IsValid(self.TripodMode.TripodNpc) then
    IgnoreActors[1] = self.TripodMode.TripodNpc
  end
  self.TripodMode:AttachIgnoreActors(IgnoreActors)
  local HitResults, bHit = UE.UKismetSystemLibrary.Abs_SphereTraceMultiForObjects(UE4Helper.GetCurrentWorld(), Start, End, 60, self.TraceObjectTypes, false, IgnoreActors, UE4.EDrawDebugTrace.None, nil, true, UE4.FLinearColor.Red, UE4.FLinearColor.Green, 10)
  local CollisionActor
  if bHit then
    for _, Result in tpairs(HitResults) do
      local Component = Result.Component
      if not Component then
      else
        local Channel = UE.UNRCStatics.ConvertToCollisionChannel(UE.EObjectTypeQuery.Character)
        local Response = Component:GetCollisionResponseToChannel(Channel)
        if Response == UE.ECollisionResponse.ECR_Block then
          CollisionActor = Result.Actor
          if CollisionActor then
            break
          end
        end
        Channel = UE.UNRCStatics.ConvertToCollisionChannel(UE.EObjectTypeQuery.Pawn)
        Response = Component:GetCollisionResponseToChannel(Channel)
        if Response == UE.ECollisionResponse.ECR_Block then
          CollisionActor = Result.Actor
          if CollisionActor then
            break
          end
        end
        Channel = UE.ECollisionChannel.ECC_Camera
        Response = Component:GetCollisionResponseToChannel(Channel)
        if Response == UE.ECollisionResponse.ECR_Block then
          CollisionActor = Result.Actor
          if CollisionActor then
            break
          end
        end
      end
    end
  end
  return CollisionActor
end

function TripodController:MoveRight()
  return self:MoveDir(self.RightVec)
end

function TripodController:MoveLeft()
  return self:MoveDir(self.LeftVec)
end

function TripodController:MoveDown()
  return self:MoveDir(self.DownVec)
end

function TripodController:MoveUp()
  return self:MoveDir(self.UpVec)
end

function TripodController:OnTick(Dt)
  if self.bMovementInput then
    self.bMovementInput = false
    local ElapsedMovementInput = self.ElapsedMovementInput
    self.ElapsedMovementInput = FVectorZero
    self:ApplyMovement(ElapsedMovementInput * Dt * 120)
  end
end

function TripodController:ApplyRotation(InputDir)
  local TripodNpc = self.TripodMode.TripodNpc
  if TripodNpc and UE.UObject.IsValid(TripodNpc) then
    local Yaw = InputDir.X
    local Pitch = InputDir.Y
    local ActorRotation = TripodNpc:K2_GetActorRotation()
    local WorldRotation = UE.FRotator(ActorRotation.Pitch - Pitch * 3.5, ActorRotation.Yaw + Yaw * 3.5, ActorRotation.Roll):ToQuat():ToRotator()
    WorldRotation.Pitch = math.clamp(WorldRotation.Pitch, -80, 80)
    TripodNpc:K2_SetActorRotation(WorldRotation, true)
  end
end

function TripodController:ApplyMovement(InputMovement)
  local TripodNpc = self.TripodMode.TripodNpc
  if TripodNpc and UE.UObject.IsValid(TripodNpc) then
    local Rotator = TripodNpc:K2_GetActorRotation()
    Rotator = UE.FRotator(0, Rotator.Yaw, 0)
    local RightVec = UE.UKismetMathLibrary.GetRightVector(Rotator)
    local RightMovement = RightVec * InputMovement.Y
    local UpMovement = FVectorUp * InputMovement.Z
    local WorldMovement = RightMovement + UpMovement
    local Location = TripodNpc:Abs_K2_GetActorLocation()
    local Height = WorldMovement.Z + Location.Z - self.FloorZ
    if Height > self.MaxiHeightConfig then
      WorldMovement.Z = self.MaxiHeightConfig - Location.Z + self.FloorZ
    elseif Height < self.MiniHeightConfig then
      WorldMovement.Z = self.MiniHeightConfig - Location.Z + self.FloorZ
    end
    local DestLocation = Location + WorldMovement
    local InitLocation = self.TripodSpawnTransform.Translation
    local Horizontal = UE.FVector2D(DestLocation.X, DestLocation.Y) - UE.FVector2D(InitLocation.X, InitLocation.Y)
    local Length = Horizontal:Size()
    local Dir = Horizontal / Length
    Length = math.min(Length, self.HorizontalConfig)
    Horizontal = Dir * Length
    local Dest = Horizontal + UE.FVector2D(InitLocation.X, InitLocation.Y)
    DestLocation.X = Dest.X
    DestLocation.Y = Dest.Y
    if not self:TraceCamera(Location, DestLocation) then
      TripodNpc:Abs_K2_SetActorLocation_WithoutHit(DestLocation, false, true)
    end
  end
end

function TripodController:MoveDir(Dir)
  self.bMovementInput = true
  self.ElapsedMovementInput = self.ElapsedMovementInput + Dir
end

return TripodController
