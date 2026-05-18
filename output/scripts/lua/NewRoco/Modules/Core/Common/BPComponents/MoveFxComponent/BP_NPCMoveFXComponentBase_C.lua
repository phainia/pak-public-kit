require("UnLuaEx")
local BP_NPCMoveFXComponentBase_C = NRCClass:Extend("BP_NPCMoveFXComponentBase_C")
BP_NPCMoveFXComponentBase_C.CachedFxAssetObjs = {}
BP_NPCMoveFXComponentBase_C.CachedRequestAssetSateIDMap = {}

function BP_NPCMoveFXComponentBase_C:ApplySwimming()
  self:CachedAllFxObjsByAllSoftPaths()
  if self.IsSwimming and self.FxVisible then
    self:OnEnterSwimming()
    self.IsPlayingFx = true
  elseif self.IsPlayingFx then
    self:OnLeftSwimming()
    self.IsPlayingFx = false
  end
end

function BP_NPCMoveFXComponentBase_C:SetFxVisible(Visible)
  self.FxVisible = Visible
end

function BP_NPCMoveFXComponentBase_C:StopSwimFx()
  for i = 1, self.SwimFxInstanceIDs:Length() do
    local SwimFxInstanceID = self.SwimFxInstanceIDs:Get(i)
    self.FxComponent:StopFx(SwimFxInstanceID)
  end
  self.SwimFxInstanceIDs:Clear()
end

function BP_NPCMoveFXComponentBase_C:CollectFxPaths()
  if self.state_collected_path then
    return
  end
  self.FxSwimIdlePath = tostring(self.FxSwimIdle)
  self.FxSwimMovePath = tostring(self.FxSwimMove)
  self.FxSwimJumpPath = tostring(self.FxSwimJump)
  self.FxBattleSwimPath = tostring(self.FxBattleSwim)
  self.FxSwimDivePath = tostring(self.FxSwimDive)
  self.state_collected_path = true
end

function BP_NPCMoveFXComponentBase_C:TryLoadAsset(path)
  if not BP_NPCMoveFXComponentBase_C.CachedFxAssetObjs[path] and (not BP_NPCMoveFXComponentBase_C.CachedRequestAssetSateIDMap[path] or 0 == BP_NPCMoveFXComponentBase_C.CachedRequestAssetSateIDMap[path]) then
    _G.NRCResourceManager:LoadResAsync(self, path, PriorityEnum.Passive_World_AI_HeadEffect, 10, self.LoadFXAssetSuccess, self.LoadFXAssetFailed)
    BP_NPCMoveFXComponentBase_C.CachedRequestAssetSateIDMap[path] = 1
  end
end

function BP_NPCMoveFXComponentBase_C:CachedAllFxObjsByAllSoftPaths()
  self:CollectFxPaths()
  self:TryLoadAsset(self.FxSwimIdlePath)
  self:TryLoadAsset(self.FxSwimMovePath)
  self:TryLoadAsset(self.FxSwimJumpPath)
  self:TryLoadAsset(self.FxBattleSwimPath)
  self:TryLoadAsset(self.FxSwimDivePath)
end

function BP_NPCMoveFXComponentBase_C:GetFxFromSoftPath(FxSoft)
  return BP_NPCMoveFXComponentBase_C.CachedFxAssetObjs[tostring(FxSoft)]
end

function BP_NPCMoveFXComponentBase_C:IsOwnerMeshReady()
  local Owner = self:GetOwner()
  return Owner:IsA(UE4.ACharacter)
end

function BP_NPCMoveFXComponentBase_C:GetWaterSurfacePos()
  local SurfacePos = UE4.FVector(100, 0, 0)
  if self.CharacterMovement:IsA(UE4.UCharacterNavMovementComponent) then
    SurfacePos = self.CharacterMovement.CacheWaterSurfacePos
  end
  return SurfacePos
end

function BP_NPCMoveFXComponentBase_C:TryPlayOrStopSwimEffect(FxComp, Partical, StartOrStop, OffsetTransform)
  local RetComp = FxComp
  if not UE.UObject.IsValid(self.FxComponent) or not UE.UObject.IsValid(Partical) then
    return RetComp
  end
  OffsetTransform = OffsetTransform or UE4.UKismetMathLibrary.MakeTransform(UE4.FVector(0, 0, 0), UE4.FRotator(0, 0, 0), UE4.FVector(1, 1, 1))
  local EffectPos = self:GetWaterSurfacePos()
  if not UE.UObject.IsValid(RetComp) then
    local OwnerWorldPos = self:GetOwner().RootComponent:K2_GetComponentLocation()
    local EffectFromSelfDis = UE4.UKismetMathLibrary.Vector_Distance(EffectPos, OwnerWorldPos)
    if EffectFromSelfDis < 1000 and StartOrStop and self:IsOwnerMeshReady() then
      local InstanceId = self.FxComponent:PlayFx_Type_Setting(Partical, self.SwimFxAttachType, self.SwimFxSetting, true, -1)
      self.SwimFxInstanceIDs:Add(InstanceId)
      RetComp = self.FxComponent:GetFxSystemComponentById(InstanceId)
      RetComp:K2_SetWorldLocation(EffectPos, false, nil, false)
    end
  end
  if UE.UObject.IsValid(RetComp) then
    if self:IsOwnerMeshReady() then
      local FxCompTrans = RetComp:K2_GetComponentToWorld()
      local FxCompRot = FxCompTrans.Rotation:ToRotator()
      local FxCompScale = FxCompTrans.Scale3D
      local tmpTrans = UE4.UKismetMathLibrary.MakeTransform(EffectPos, FxCompRot, FxCompScale)
      local NewTrans = UE4.UKismetMathLibrary.ComposeTransforms(OffsetTransform, tmpTrans)
      NewTrans.Translation.Z = EffectPos.Z
      RetComp:K2_SetWorldTransform(NewTrans, false, nil, false)
    end
    UE4.UNewRocoHelperLibrary.SetEmitterEnable(RetComp, StartOrStop)
  else
    RetComp = nil
  end
  return RetComp
end

function BP_NPCMoveFXComponentBase_C:UpdateSwimState()
  local CharacterMovement = self.CharacterMovement
  local CapsuleComponent = self.Character:GetComponentByClass(UE4.UCapsuleComponent)
  if not CharacterMovement:IsA(UE4.UCharacterNavMovementComponent) then
    return
  end
  local Owner = self:GetOwner()
  local IsIdle_Loc = false
  local IsSwim_Loc = false
  local Velocity = Owner:GetVelocity()
  local VelocitySize = Velocity:Size()
  if VelocitySize > 50 and CharacterMovement:IsSwimming() then
    IsSwim_Loc = true
  end
  if VelocitySize <= 50 and CharacterMovement:IsSwimming() then
    IsIdle_Loc = true
  end
  local CapsuleHalfHeight = CapsuleComponent:GetScaledCapsuleHalfHeight()
  local CapsuleRadius = CapsuleComponent:GetScaledCapsuleRadius()
  local CapsuleHalfHeight_Abs = math.abs(CapsuleHalfHeight)
  local SwimPosOffsetZ = CharacterMovement:GetSwimPosOffsetZ()
  local AdditionalSwimPosOffsetZ = CharacterMovement:GetAdditionalSwimPosOffsetZ()
  local SwimPosOffsetZ_Abs = math.abs(SwimPosOffsetZ)
  local bNewCloseSurface = CapsuleHalfHeight_Abs > SwimPosOffsetZ_Abs
  self.CloseToWaterSurface = bNewCloseSurface
  local bAdditionalSwimPosOffsetZ_Zero = 0 == AdditionalSwimPosOffsetZ
  if self.ZeroSwimOffset ~= bAdditionalSwimPosOffsetZ_Zero then
    self.ZeroSwimOffset = bAdditionalSwimPosOffsetZ_Zero
    local FxSwimAsset_Dive = self:GetFxFromSoftPath(self.FxSwimDive)
    local DiveAssetScale = CapsuleRadius / 70
    local DiveAssetTrans = UE4.UKismetMathLibrary.MakeTransform(UE4.FVector(0, 0, 0), UE4.FRotator(0, 0, 0), UE4.FVector(DiveAssetScale, DiveAssetScale, DiveAssetScale))
    self:TryPlayOrStopSwimEffect(self.FxSwimDiveComp, FxSwimAsset_Dive, true, DiveAssetTrans)
  end
  local FxSwimAsset_Idle = self:GetFxFromSoftPath(self.FxSwimIdle)
  local bStartOrStop_Idle = IsIdle_Loc and self.EnableSwimFx and self.CloseToWaterSurface
  self.FxSwimIdleComp = self:TryPlayOrStopSwimEffect(self.FxSwimIdleComp, FxSwimAsset_Idle, bStartOrStop_Idle)
  local FxSwimAsset_Move = self:GetFxFromSoftPath(self.FxSwimMove)
  local bStartOrStop_Move = IsSwim_Loc and self.EnableSwimFx and self.CloseToWaterSurface
  self.FxSwimMoveComp = self:TryPlayOrStopSwimEffect(self.FxSwimMoveComp, FxSwimAsset_Move, bStartOrStop_Move)
end

function BP_NPCMoveFXComponentBase_C:OnLeftSwimming()
  UE4.UKismetSystemLibrary.K2_ClearTimer(self, "UpdateSwimState")
  self:StopSwimFx()
  self.LastSwimTime = UE4.UNRCStatics.GetTimestampMS()
end

function BP_NPCMoveFXComponentBase_C:OnEnterSwimming()
  UE4.UKismetSystemLibrary.K2_SetTimer(self, "UpdateSwimState", 0.25, true, 0.1, 0)
  local CurTime = UE4.UNRCStatics.GetTimestampMS()
  if CurTime - self.LastSwimTime > 500 then
    local FxSwimJumpAsset = self:GetFxFromSoftPath(self.FxSwimJump)
    local Owner = self:GetOwner()
    local Velocity = Owner:GetVelocity()
    local StartOrStop = Velocity.Z < -5
    self:TryPlayOrStopSwimEffect(self.FxSwimJumpComp, FxSwimJumpAsset, StartOrStop)
  end
end

function BP_NPCMoveFXComponentBase_C:MovementModeChangedDelegate_Event_0(Character, PrevMovementMode, PreviousCustomMode)
  local CurMovementMode = Character.CharacterMovement.MovementMode
  if CurMovementMode == PrevMovementMode then
    return
  end
  if PrevMovementMode == UE4.EMovementMode.MOVE_Swimming then
    self.IsSwimming = false
    self:ApplySwimming()
  end
  if CurMovementMode == UE4.EMovementMode.MOVE_Swimming then
    self.IsSwimming = true
    self:ApplySwimming()
  end
end

function BP_NPCMoveFXComponentBase_C:ReceiveBeginPlay()
  local Owner = self:GetOwner()
  self.AudioComp = Owner:GetComponentByClass(UE4.URocoAudioComponent)
  self.CharacterMovement = Owner:GetComponentByClass(UE4.UCharacterNavMovementComponent)
  self.FxComponent = Owner:GetComponentByClass(UE4.URocoFXComponent)
  self.Character = Owner
  self.Character.MovementModeChangedDelegate:Add(self, self.MovementModeChangedDelegate_Event_0)
end

function BP_NPCMoveFXComponentBase_C:ReceiveEndPlay(EndPlayReason)
  self.Character.MovementModeChangedDelegate:Remove(self, self.MovementModeChangedDelegate_Event_0)
end

function BP_NPCMoveFXComponentBase_C:LoadFXAssetSuccess(Request, Object)
  local AssetPath = Request.assetPath
  BP_NPCMoveFXComponentBase_C.CachedFxAssetObjs[AssetPath] = Object
  BP_NPCMoveFXComponentBase_C.CachedRequestAssetSateIDMap[AssetPath] = 2
end

function BP_NPCMoveFXComponentBase_C:LoadFXAssetFailed(Request, Object)
  local AssetPath = Request.assetPath
  BP_NPCMoveFXComponentBase_C.CachedRequestAssetSateIDMap[AssetPath] = -1
  Log.Error(string.format("\230\184\184\230\179\179\231\137\185\230\149\136\232\181\132\228\186\167\239\188\154[%s]\229\138\160\232\189\189\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165\230\152\175\229\144\166\233\133\141\231\189\174\230\173\163\231\161\174", AssetPath))
end

return BP_NPCMoveFXComponentBase_C
