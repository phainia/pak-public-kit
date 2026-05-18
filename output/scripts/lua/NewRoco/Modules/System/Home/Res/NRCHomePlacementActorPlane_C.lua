local DoorProxy = require("NewRoco/Modules/System/Home/IndoorSandbox/Proxy/DoorProxy")
local StaticMeshProxy = require("NewRoco/Modules/System/Home/IndoorSandbox/Proxy/StaticMeshProxy")
local NRCHomePlacementActorPlane_C = Class("NRCHomePlacementActorPlane_C")

function NRCHomePlacementActorPlane_C:Ctor()
  self._ActorUniqueIdStr = false
  self._bIsPlacePlane = nil
  self._HomePlane = nil
  self._InsideNormals = {}
  self._HasBeginPlayed = false
  self._RoomId = nil
  self._OtherRoomId = nil
  self._LevelPackageName = nil
  self._BakedInfo = nil
  self._StaticMeshProxy = StaticMeshProxy()
end

function NRCHomePlacementActorPlane_C:GetSceneMainType()
  return self.Type
end

function NRCHomePlacementActorPlane_C:GetConfigMainType()
  return HomeIndoorSandbox.Utils.GetConfigMainTypeBySceneMainType(self:GetSceneMainType())
end

function NRCHomePlacementActorPlane_C:GetSubType()
  return self.SubTypeId
end

function NRCHomePlacementActorPlane_C:GetDesiredSubTypeByStyle(StyleId)
  local DesiredSubType = self.SubTypeId
  local SubTypeIdRedirection = self.SubTypeIdRedirection
  if SubTypeIdRedirection and StyleId then
    local Redirection = SubTypeIdRedirection:Find(StyleId)
    if Redirection then
      DesiredSubType = Redirection
    end
  end
  return DesiredSubType
end

function NRCHomePlacementActorPlane_C:OnInitialize()
  self._bMeshTextureChanged = nil
  self._ShowFlags = 0
  self._bIsCull = false
  local Super = self.Overridden.OnInitialize
  if Super then
    Super(self)
  end
  self:CollectOriginalMeshTextures()
  self:GetDoorProxy()
end

function NRCHomePlacementActorPlane_C:OnInitializedByRoom()
end

function NRCHomePlacementActorPlane_C:OnInitializedByWorld()
  if self._DoorProxy then
    local ActorArray = self._DoorProxy:GetOverlappingActors()
    for i, Actor in tpairs(ActorArray) do
      self:OnBeginDoorOverlap(Actor)
    end
  end
end

function NRCHomePlacementActorPlane_C:GetDoorProxy()
  if not self._DoorProxy and self.InitializeDoor then
    self:InitializeDoor()
    self._DoorProxy = DoorProxy(self)
  end
  return self._DoorProxy
end

function NRCHomePlacementActorPlane_C:OnUnInitialize()
  self._HomePlane = nil
  local Super = self.Overridden.OnUnInitialize
  if Super then
    Super(self)
  end
  if self._DoorProxy then
    self._DoorProxy:OnRelease()
  end
  if self._StaticMeshProxy then
    self._StaticMeshProxy:OnRelease()
  end
end

function NRCHomePlacementActorPlane_C:InitHomePlane(HomePlane)
  self._HomePlane = HomePlane
end

function NRCHomePlacementActorPlane_C:GetBakedInfoByStyleId(InteriorFinishConfId)
  local SceneStyleId = HomeIndoorSandbox.Utils.GetSceneStyleIdByConfId(InteriorFinishConfId)
  local DesiredSubType = self:GetDesiredSubTypeByStyle(SceneStyleId)
  local BakedInfo = HomeIndoorSandbox.World:GetStyleBakedInfoByMainSubType(self:GetSceneMainType(), DesiredSubType)
  return BakedInfo and BakedInfo[SceneStyleId]
end

function NRCHomePlacementActorPlane_C:GetHomePlane()
  return self._HomePlane
end

function NRCHomePlacementActorPlane_C:ReceiveEndPlay(EndPlayReason)
  assert(self._HasBeginPlayed)
  self._HasBeginPlayed = false
  self:OnUnInitialize()
  if self._DelayFrameMobility then
    DelayManager:CancelDelayById(self._DelayFrameMobility)
    self._DelayFrameMobility = nil
  end
  HomeIndoorSandbox:LogDebug("[ACTOR] ReceiveEndPlay", self:GetActorId(), EndPlayReason)
end

function NRCHomePlacementActorPlane_C:ReceiveBeginPlay()
  assert(not self._HasBeginPlayed)
  self._HasBeginPlayed = true
  self:OnInitialize()
  HomeIndoorSandbox:LogDebug("[ACTOR] ReceiveBeginPlay", self:GetActorId(), self:GetName(), self:GetLevelPackageName())
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnIndoorHardDecoActorSpawned, self)
end

function NRCHomePlacementActorPlane_C:OnBeginDoorOverlap(Actor)
  if self._DoorProxy and Actor and HomeIndoorSandbox and HomeIndoorSandbox:InHomeIndoor() and HomeIndoorSandbox.World:IsLoadEstablished() then
    HomeIndoorSandbox:LogDebug("OnBeginDoorOverlap", Actor and Actor:GetName())
    self._DoorProxy:ReqOpenByActor(Actor)
  end
end

function NRCHomePlacementActorPlane_C:OnEndDoorOverlap(Actor)
  if self._DoorProxy and Actor then
    HomeIndoorSandbox:LogDebug("OnEndDoorOverlap", Actor and Actor:GetName())
    self._DoorProxy:ReqCloseByActor(Actor)
  end
end

function NRCHomePlacementActorPlane_C:CollectOriginalMeshTextures()
  local Components = self:K2_GetComponentsByClass(UE4.UNRCHomeStaticMeshComponent):ToTable()
  self._StaticMeshProxy:OnInit(self, Components[1])
  if -1 ~= self.Rank then
    self._StaticMeshProxy:SyncLoadMesh()
    self:InitCollisionResponses()
  end
  local MeshComponent = Components[1]
  if MeshComponent then
    MeshComponent:SetCollisionObjectType(UE.ECollisionChannel.ECC_WorldStatic)
    if self:IsFloor() then
      MeshComponent:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_GameTraceChannel12, UE.ECollisionResponse.ECR_Block)
    end
  end
  if _G.RocoEnv.IS_EDITOR then
    local SurfaceComponents = self:K2_GetComponentsByClass(UE.UNRCHomePlaceableSurfaceComponent)
    if SurfaceComponents and SurfaceComponents:Num() > 0 then
      for i, SurfaceComponent in tpairs(SurfaceComponents) do
        SurfaceComponent:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
      end
    end
  end
end

function NRCHomePlacementActorPlane_C:ApplyOriginalMeshTextures()
  if self._StaticMeshProxy then
    self:InternalSetupApplyInterior(0)
    self._StaticMeshProxy:StartLoadResources()
  end
end

function NRCHomePlacementActorPlane_C:InternalSetupApplyInterior(StyleId)
  if self._DelayFrameMobility then
    DelayManager:CancelDelayById(self._DelayFrameMobility)
    self._DelayFrameMobility = nil
  end
  self._StaticMeshProxy:SetFinishDelegate(function()
    if not UE.UObject.IsValid(self) then
      return
    end
    local LightingChannelRedirection = self.LightingChannelRedirection
    local Channels = LightingChannelRedirection:Find(HomeIndoorSandbox.Utils.GetSceneStyleIdByConfId(StyleId))
    Channels = Channels or HomeIndoorSandbox.World.DefaultStructBuildingLightingChannels
    if self._StaticMeshProxy.MeshComponent then
      self._StaticMeshProxy.MeshComponent:SetSixLightingChannels(Channels.bChannel0, Channels.bChannel1, Channels.bChannel2, Channels.bChannel3, Channels.bChannel4, Channels.bChannel5)
    end
    local bNeedStaticMobility = not self._DoorProxy
    if bNeedStaticMobility then
      self._DelayFrameMobility = DelayManager:DelayFrames(1, function()
        self._DelayFrameMobility = nil
        if self._StaticMeshProxy.MeshComponent then
          self._StaticMeshProxy.MeshComponent:SetMobility(UE.EComponentMobility.Static)
        end
      end)
    end
  end)
end

function NRCHomePlacementActorPlane_C:ApplyInteriorFinish(StyleId)
  self:InternalSetupApplyInterior(StyleId)
  local BakedInfo = self:GetBakedInfoByStyleId(StyleId)
  if BakedInfo then
    HomeIndoorSandbox:LogInfo("ApplyInteriorFinish", StyleId, self:GetActorId(), self:GetName(), BakedInfo.MeshPath, BakedInfo.MaterialsDebugInfo)
    self._StaticMeshProxy:StartLoadResourceByPath(BakedInfo.MeshPath, BakedInfo.MaterialPaths)
  else
    HomeIndoorSandbox:LogWarn("cannot found style baked info, but conf indicated the main type", StyleId, self:GetSceneMainType(), self:GetActorId(), self:GetName())
    self:ApplyOriginalMeshTextures()
  end
end

function NRCHomePlacementActorPlane_C:UpdateNormals(RoomId)
  if self._StaticMeshProxy and self._StaticMeshProxy:HasMesh() and not self._InsideNormals[RoomId] then
    local Room = HomeIndoorSandbox.World:GetRoomById(RoomId)
    local WorldCenter = Room.WorldCenter
    local Center = Room.Bounds.Center
    self:PreCalcInsideNormals(RoomId, Center, WorldCenter)
  end
end

function NRCHomePlacementActorPlane_C:IsPlacePlane()
  if self._bIsPlacePlane == nil then
    if self.Type and self.Type == UE.ENRCHomeInteriorFinishType.IFT_WALL or self.Type == UE.ENRCHomeInteriorFinishType.IFT_FLOOR then
      self._bIsPlacePlane = true
    else
      self._bIsPlacePlane = false
    end
  end
  return self._bIsPlacePlane
end

function NRCHomePlacementActorPlane_C:IsFloor()
  return self.Type == UE.ENRCHomeInteriorFinishType.IFT_FLOOR
end

function NRCHomePlacementActorPlane_C:SetVisible(bVisible, Mask)
  Mask = Mask or 1
  if bVisible then
    self._ShowFlags = self._ShowFlags | Mask
  else
    self._ShowFlags = self._ShowFlags & ~Mask
  end
  if self._bIsCull then
    self:InternalSetActorHiddenInGame(true)
    return
  end
  self:InternalJudgeShowFlags()
end

function NRCHomePlacementActorPlane_C:InternalJudgeShowFlags()
  if 0 ~= self._ShowFlags then
    self:InternalSetActorHiddenInGame(false)
  else
    self:InternalSetActorHiddenInGame(true)
  end
end

function NRCHomePlacementActorPlane_C:SetBeCull(bCull)
  if self._bIsCull ~= bCull then
    self._bIsCull = bCull
    if bCull then
      self:InternalSetActorHiddenInGame(true)
    else
      self:InternalJudgeShowFlags()
    end
  end
end

function NRCHomePlacementActorPlane_C:InitCollisionResponses()
  if not self:IsFloor() and self.FaceType ~= UE.ENRCHomeBuildingFaceType.ForceVisible then
    self:SetVisibilityCollisionResponse(UE.ECollisionResponse.ECR_Overlap)
  end
end

function NRCHomePlacementActorPlane_C:InternalSetActorHiddenInGame(bHide)
  if bHide ~= self.bHidden then
    self:SetActorHiddenInGame(bHide)
    if bHide then
      self:SetVisibilityCollisionResponse(UE.ECollisionResponse.ECR_Ignore)
    elseif self:IsFloor() or self.FaceType == UE.ENRCHomeBuildingFaceType.ForceVisible then
      self:SetVisibilityCollisionResponse(UE.ECollisionResponse.ECR_Block)
    else
      self:SetVisibilityCollisionResponse(UE.ECollisionResponse.ECR_Overlap)
    end
  end
  self:RefreshRelativePropsVisibility()
  HomeIndoorSandbox:LogDebug("[Visibility] NRCHomePlacementActorPlane_C:", not bHide, self:GetName(), self:GetActorId())
end

function NRCHomePlacementActorPlane_C:RefreshRelativePropsVisibility()
  if self.bHidden then
    local Plane = self:GetHomePlane()
    if Plane then
      Plane:SetVisible(false)
    end
  else
    local Plane = self:GetHomePlane()
    if Plane then
      Plane:SetVisible(true)
    end
  end
end

function NRCHomePlacementActorPlane_C:SetCameraCollisionEnabled(bEnabled)
  if not self._StaticMeshProxy.MeshComponent then
    return
  end
  if bEnabled then
    self._StaticMeshProxy.MeshComponent:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Camera, UE.ECollisionResponse.ECR_Block)
  else
    self._StaticMeshProxy.MeshComponent:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Camera, UE.ECollisionResponse.ECR_Ignore)
  end
end

function NRCHomePlacementActorPlane_C:SetVisibilityCollisionResponse(Response)
  if not self._StaticMeshProxy.MeshComponent then
    return
  end
  self._StaticMeshProxy.MeshComponent:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Visibility, Response)
end

local DoorLocalLinkFaceDir = UE.FVector(0, 1, 0)

function NRCHomePlacementActorPlane_C:PreCalcInsideNormals(RoomId, Original, WorldCenter)
  local Normal = self._InsideNormals[RoomId]
  if not Normal then
    if 0 ~= (self:GetOtherRoomId() or 0) then
      local WorldLinkFaceDir = self:Abs_GetTransform():TransformVector(DoorLocalLinkFaceDir)
      if RoomId == self:GetBelongRoomId() then
        Normal = -WorldLinkFaceDir
      else
        Normal = WorldLinkFaceDir
      end
      self._InsideNormals[RoomId] = Normal
      HomeIndoorSandbox:LogDebug("RoomFace:", self:GetBelongRoomId(), self:GetOtherRoomId(), RoomId, Normal)
      return
    end
    if self.FaceType == UE.ENRCHomeBuildingFaceType.ForceVisible then
      return
    end
    if self.FaceType == UE.ENRCHomeBuildingFaceType.None then
      if self._HomePlane then
        Normal = self._HomePlane:Abs_GetTransform().Rotation:GetUpVector()
      end
    else
      Normal = HomeIndoorSandbox.Utils.GetFaceNormalByType(self.FaceType)
    end
    self._InsideNormals[RoomId] = Normal
  end
end

function NRCHomePlacementActorPlane_C:GetNormalByRoomId(RoomId)
  if not self._InsideNormals[RoomId] then
    self:UpdateNormals(RoomId)
  end
  return self._InsideNormals[RoomId]
end

function NRCHomePlacementActorPlane_C:GetActorId()
  local ActorGuid = self._ActorUniqueIdStr
  if not ActorGuid then
    ActorGuid = self.ActorUniqueId
    ActorGuid = UE.UKismetGuidLibrary.Conv_GuidToString(ActorGuid)
    self._ActorUniqueIdStr = ActorGuid
  end
  return ActorGuid
end

function NRCHomePlacementActorPlane_C:GetLevelPackageName()
  if not self._LevelPackageName then
    self._LevelPackageName = self:GetOuter():GetOuter():GetOuter():GetName()
  end
  return self._LevelPackageName
end

function NRCHomePlacementActorPlane_C:BuildBelongRoomId()
  local LevelPackageName = self:GetLevelPackageName()
  local Rank = HomeIndoorSandbox.Server.WorldData.RoomLevel
  local DesiredRoomId = HomeIndoorSandbox.World.RankLevelToRoomId[Rank][LevelPackageName]
  self._RoomId = DesiredRoomId or 0
  if 0 == self._RoomId then
    HomeIndoorSandbox:Ensure(false, "logical error", self:GetName(), self:GetActorId())
  end
  if not self._OtherRoomId then
    self._OtherRoomId = 0
    for _, Tag in tpairs(self.Tags) do
      for RoomId in string.gmatch(Tag, "DoorOpposeRoom_(%d+)") do
        RoomId = math.tointeger(RoomId)
        if RoomId and 0 ~= RoomId then
          self._OtherRoomId = RoomId
        end
      end
    end
    if self._DoorProxy and 0 == self._OtherRoomId then
      self._OtherRoomId = 1
    end
  end
end

function NRCHomePlacementActorPlane_C:GetBelongRoomId()
  if -1 == self.Rank then
    return 1
  end
  if not self._RoomId then
    self:BuildBelongRoomId()
  end
  return self._RoomId
end

function NRCHomePlacementActorPlane_C:GetOtherRoomId()
  return self._OtherRoomId
end

return NRCHomePlacementActorPlane_C
