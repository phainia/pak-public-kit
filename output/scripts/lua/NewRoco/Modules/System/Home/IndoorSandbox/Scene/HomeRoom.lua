local HomeRoom = Class("HomeRoom")
local HomePlane = require("NewRoco/Modules/System/Home/IndoorSandbox/Scene/HomePlane")

function HomeRoom:Ctor(RoomId, World)
  self.RoomId = RoomId
  self.World = World
  self.RoomInfo = nil
  self.HardDecoActors = {}
  self.AllDecoActors = {}
  self.MainSubActors = {}
  self.LinkDecoActors = {}
  self.HomePlanes = {}
  self.Bounds = {
    Min = nil,
    Max = nil,
    Range = nil,
    Center = nil,
    Extent = nil
  }
  self.bRoomStaticActorVisible = true
  self.bRoomDynamicActorVisible = false
  self.bRoomCollisionEnabled = true
  self.BoundsTriggerBox = nil
  self.BoundsTriggerBoxRef = nil
end

function HomeRoom:Destroy()
  self:DestroyBoundTrigger()
  self.HardDecoActors = {}
  self.HomePlanes = {}
  self.MainSubActors = {}
  self.AllDecoActors = {}
  self.LinkDecoActors = {}
  self.RoomInfo = nil
  self.World = nil
  if self._DelaySecondsOnDynamicVisible then
    DelayManager:CancelDelayById(self._DelaySecondsOnDynamicVisible)
    self._DelaySecondsOnDynamicVisible = nil
  end
end

function HomeRoom:Instantiate(RoomInfo, WorldCenter)
  assert(self.RoomId == RoomInfo.RoomId)
  self.WorldCenter = WorldCenter
  self.RoomInfo = RoomInfo
  local RoomId = RoomInfo.RoomId
  local GroundPlane
  for PlaneId, PlaneInfo in pairs(self.RoomInfo.PlaneMap) do
    local LoginPlane = HomePlane(WorldCenter, RoomId, PlaneId, PlaneInfo.PlaneMin, PlaneInfo.PlaneMax, PlaneInfo.Rotator, PlaneInfo.InvalidAreas, PlaneInfo.PlaneMasterId)
    self.HomePlanes[PlaneId] = LoginPlane
    if not self.Bounds.Min then
      self.Bounds.Min = UE.FVector(PlaneInfo.PlaneMin.X, PlaneInfo.PlaneMin.Y, PlaneInfo.PlaneMin.Z)
      self.Bounds.Max = UE.FVector(PlaneInfo.PlaneMax.X, PlaneInfo.PlaneMax.Y, PlaneInfo.PlaneMax.Z)
    else
      self.Bounds.Min.X = math.min(self.Bounds.Min.X, PlaneInfo.PlaneMin.X)
      self.Bounds.Min.Y = math.min(self.Bounds.Min.Y, PlaneInfo.PlaneMin.Y)
      self.Bounds.Min.Z = math.min(self.Bounds.Min.Z, PlaneInfo.PlaneMin.Z)
      self.Bounds.Max.X = math.max(self.Bounds.Max.X, PlaneInfo.PlaneMax.X)
      self.Bounds.Max.Y = math.max(self.Bounds.Max.Y, PlaneInfo.PlaneMax.Y)
      self.Bounds.Max.Z = math.max(self.Bounds.Max.Z, PlaneInfo.PlaneMax.Z)
    end
    HomeIndoorSandbox:LogInfo("PlaneInfo:", self.RoomInfo.Name, PlaneInfo.PlaneMin, PlaneInfo.PlaneMax, PlaneInfo.bIsGround)
    if not LoginPlane:IsWall() then
      GroundPlane = LoginPlane
    end
  end
  self.GroundPlane = GroundPlane
  self.Bounds.Range = (self.Bounds.Max - self.Bounds.Min):Size()
  self.Bounds.Extent = (self.Bounds.Max - self.Bounds.Min) / 2
  self.Bounds.Center = self.Bounds.Min + self.Bounds.Extent
  HomeIndoorSandbox:LogInfo("Room Center", self.RoomInfo.RoomId, self.Bounds.Center, self.Bounds.Center - self.WorldCenter)
  if GroundPlane then
    local ViewDir = UE4.UKismetMathLibrary.GetForwardVector(self.RoomInfo.ViewpointRot)
    local Length = self.Bounds.Range + 475
    local LineStart = self.RoomInfo.ViewpointLoc - ViewDir * 475 - WorldCenter
    local LineEnd = LineStart + ViewDir * Length - WorldCenter
    local PlaneOrigin = GroundPlane.Min - WorldCenter
    local PlaneNormal = FVectorUp
    local T, Intersection = UE.UKismetMathLibrary.LinePlaneIntersection_OriginNormal(LineStart, LineEnd, PlaneOrigin, PlaneNormal)
    if T > 0 then
      local SpringArmLength = T / 2 * Length
      self.RoomInfo.EditPointLoc = LineStart + ViewDir * SpringArmLength + WorldCenter
      self.RoomInfo.SpringArmLength = SpringArmLength
      self.RoomInfo.EditSocketOffset = UE.FVector(0, 0, self.RoomInfo.EditPointLoc.Z)
      self.RoomInfo.EditPointLoc.Z = GroundPlane.Min
      HomeIndoorSandbox:LogInfo("Room EditPoint:", self.RoomInfo.Name, self.RoomInfo.SpringArmLength, self.RoomInfo.EditPointLoc)
    else
      self.RoomInfo.EditViewportErr = string.format("\230\136\191\233\151\180\239\188\154%s, \233\148\153\232\175\175\239\188\154%s", self.RoomInfo.Name, "\227\128\144\228\184\141\229\144\136\230\179\149\227\128\145\230\136\191\233\151\180\233\149\156\229\164\180\229\146\140\229\156\176\233\157\162\230\178\161\230\156\137\231\132\166\231\130\185")
      HomeIndoorSandbox:Ensure(false, self.RoomInfo.EditViewportErr)
    end
  else
    self.RoomInfo.EditViewportErr = string.format("\230\136\191\233\151\180\239\188\154%s, \233\148\153\232\175\175\239\188\154%s", self.RoomInfo.Name, "\227\128\144\228\184\141\229\144\136\230\179\149\227\128\145\230\137\190\228\184\141\229\136\176\229\156\176\233\157\162")
    HomeIndoorSandbox:Ensure(false, self.RoomInfo.EditViewportErr)
  end
  HomeIndoorSandbox:LogInfo("Room Bounds:", self.RoomInfo.Name, self.RoomInfo.RoomId, self.Bounds.Min, self.Bounds.Max)
  HomeIndoorSandbox:LogInfo("Room Viewport:", self.RoomInfo.Name, self.RoomInfo.ViewpointLoc)
  if HomeIndoorSandbox.Utils.EnableDebugDraw then
    local Extent = (self.Bounds.Max - self.Bounds.Min) / 2
    local Point = (self.Bounds.Max + self.Bounds.Min) / 2
    local Color = {
      UE4.FLinearColor(1, 0, 0, 1),
      UE4.FLinearColor(0, 1, 0, 1),
      UE4.FLinearColor(0, 0, 1, 1),
      UE4.FLinearColor(1, 1, 0, 1),
      UE4.FLinearColor(0, 1, 1, 1)
    }
    UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), Point, Extent, Color[self.RoomId], FRotatorZero, 600, 30)
  end
  self:CreateBoundTrigger()
end

function HomeRoom:GetGroundPlane()
  return self.GroundPlane
end

function HomeRoom:GetViewportInfo()
  return self.RoomInfo.ViewpointLoc, self.RoomInfo.ViewpointRot, self.RoomInfo.EditPointLoc, self.RoomInfo.SpringArmLength, self.RoomInfo.EditSocketOffset, self.RoomInfo.EditViewportErr
end

function HomeRoom:ClearRoomProps()
  if not self.RoomInfo then
    HomeIndoorSandbox:Ensure(false, "logical error", self.RoomId)
    return
  end
  local RoomData = HomeIndoorSandbox.Server.WorldData:GetRoomData(self.RoomInfo.RoomId)
  for PlaneId, Plane in pairs(self.HomePlanes) do
    Plane:ClearPlaneProps(RoomData)
  end
end

function HomeRoom:GetRoomData()
  return HomeIndoorSandbox.Server.WorldData:GetOrCreateRoomData(self.RoomInfo.RoomId)
end

function HomeRoom:GetPlaneById(PlaneId)
  return self.HomePlanes[PlaneId]
end

function HomeRoom:GetPlaneByActorId(ActorId)
  return self:GetPlaneById(self.RoomInfo.ActorIdToPlaneId[ActorId])
end

function HomeRoom:JoinHardDecoActor(HardDecoActor)
  local ActorId = HardDecoActor:GetActorId()
  local OldActor = self.HardDecoActors[ActorId]
  if OldActor and OldActor ~= HardDecoActor then
    HomeIndoorSandbox:Ensure(false, "duplicate static deco actor", ActorId, HardDecoActor:GetName(), OldActor and OldActor:GetName())
  end
  local bExists = self.AllDecoActors[HardDecoActor]
  HomeIndoorSandbox:Ensure(not bExists)
  self.AllDecoActors[HardDecoActor] = ActorId
  self.HardDecoActors[ActorId] = HardDecoActor
  if not bExists then
    local MainType = HardDecoActor:GetConfigMainType()
    local SubType = HardDecoActor:GetSubType()
    local SubActors = self.MainSubActors[MainType]
    SubActors = SubActors or {}
    self.MainSubActors[MainType] = SubActors
    local Actors = SubActors[SubType]
    if not Actors then
      Actors = {}
      SubActors[SubType] = Actors
    end
    table.insert(Actors, HardDecoActor)
  end
  HardDecoActor:InitHomePlane(self:GetPlaneByActorId(ActorId), self.RoomInfo.Levels)
  HardDecoActor:SetVisible(self.bRoomStaticActorVisible)
end

function HomeRoom:LinkDecoActor(Actor)
  local RoomId = Actor:GetBelongRoomId()
  HomeIndoorSandbox:LogDebug("LinkDecoActor: Link from", RoomId, Actor:GetActorId(), Actor:GetName(), "to", self.RoomId)
  self.LinkDecoActors[Actor] = true
end

function HomeRoom:SyncLinkVisible(bVisible, ExcludeRoomId)
  for Link, _ in pairs(self.LinkDecoActors) do
    if not ExcludeRoomId or Link:GetBelongRoomId() ~= ExcludeRoomId then
      Link:SetVisible(bVisible)
    end
  end
end

function HomeRoom:IterActorByMainType(MainType, Func)
  if MainType and Func then
    local SubActors = self.MainSubActors[MainType]
    if SubActors then
      for SubType, Actors in pairs(SubActors) do
        for _, Actor in ipairs(Actors) do
          Func(Actor)
        end
      end
    end
  end
end

function HomeRoom:SetVisible(bVisible)
  HomeIndoorSandbox:LogInfo("[Visibility] HomeRoom:SetVisible", bVisible, "Room:", self.RoomId)
  self:SetStaticVisible(bVisible)
  self:SetDynamicVisible(bVisible)
end

function HomeRoom:SetStaticVisible(bVisible)
  HomeIndoorSandbox:LogInfo("[Visibility] HomeRoom:SetStaticVisible", bVisible, "Cache Changed:", bVisible ~= self.bRoomStaticActorVisible, "Room:", self.RoomId)
  if bVisible ~= self.bRoomStaticActorVisible then
    self.bRoomStaticActorVisible = bVisible
    self:InternalSetStaticVisible(bVisible)
  end
end

function HomeRoom:SetDynamicVisible(bVisible, DelaySeconds)
  HomeIndoorSandbox:LogInfo("[Visibility] HomeRoom:SetDynamicVisible", bVisible, DelaySeconds, "Cache Changed:", bVisible ~= self.bRoomDynamicActorVisible, "Room:", self.RoomId)
  if bVisible ~= self.bRoomDynamicActorVisible then
    self.bRoomDynamicActorVisible = bVisible
    if self._DelaySecondsOnDynamicVisible then
      DelayManager:CancelDelayById(self._DelaySecondsOnDynamicVisible)
      self._DelaySecondsOnDynamicVisible = nil
    end
    if DelaySeconds then
      local function OnVisibleControl()
        self._DelaySecondsOnDynamicVisible = nil
        
        self:InternalSetDynamicVisible(self.bRoomDynamicActorVisible)
      end
      
      self._DelaySecondsOnDynamicVisible = DelayManager:DelaySeconds(DelaySeconds, OnVisibleControl)
    else
      self:InternalSetDynamicVisible(bVisible)
    end
  end
end

function HomeRoom:InternalSetStaticVisible(bVisible)
  HomeIndoorSandbox:LogInfo("[Visibility] \232\174\190\231\189\174\230\136\191\233\151\180\229\134\133\231\161\172\232\163\133\229\143\175\232\167\129\230\128\167\239\188\154", self.RoomInfo.RoomId, bVisible)
  for Actor, Id in pairs(self.AllDecoActors) do
    if Actor:IsValid() then
      Actor:SetVisible(bVisible)
    end
  end
end

function HomeRoom:SetStaticCameraCollisionEnabled(bEnabled)
  for Actor, Id in pairs(self.AllDecoActors) do
    if Actor:IsValid() then
      Actor:SetCameraCollisionEnabled(bEnabled)
    end
  end
end

function HomeRoom:SetPropsCameraCollisionEnabled(bEnabled)
  for Id, Plane in pairs(self.HomePlanes) do
    Plane:SetPropsCameraCollisionEnabled(bEnabled)
  end
end

function HomeRoom:InternalSetDynamicVisible(bVisible)
  if not self.RoomInfo then
    HomeIndoorSandbox:Ensure(false, "logical error", self.RoomId)
    return
  end
  if self.RoomInfo then
    HomeIndoorSandbox:LogInfo("[Visibility] \232\174\190\231\189\174\230\136\191\233\151\180\229\134\133\230\145\134\228\187\182\229\143\175\232\167\129\230\128\167: ", self.RoomInfo.RoomId, bVisible)
  end
  for Id, Plane in pairs(self.HomePlanes) do
    Plane:SetVisible(bVisible, true)
  end
end

function HomeRoom:CreateBoundTrigger()
  if self.BoundsTriggerBox == nil then
    local World = self.World.UEWorld
    local SpawnTrans = UE4.FTransform(UE4.FQuat(), self.Bounds.Center or FVectorZero)
    local NewBox = World:Abs_SpawnActor(UE.ATriggerBox, SpawnTrans, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    if NewBox then
      local CollisionComponent = NewBox:GetComponentByClass(UE.UBoxComponent)
      local EnterDelegate = _G.SimpleDelegateFactory:CreateCallback(self, self.OnBoundTriggerEnter)
      local LeaveDelegate = _G.SimpleDelegateFactory:CreateCallback(self, self.OnBoundTriggerLeave)
      CollisionComponent.OnComponentBeginOverlap:Add(NewBox, EnterDelegate)
      CollisionComponent.OnComponentEndOverlap:Add(NewBox, LeaveDelegate)
      CollisionComponent:SetCollisionProfileName("PlayerCharacterTrigger", false)
      CollisionComponent:SetBoxExtent(self.Bounds.Extent, true)
      self.BoundsTriggerBox = NewBox
      self.BoundsTriggerBoxRef = UnLua.Ref(NewBox)
    end
  end
end

function HomeRoom:DestroyBoundTrigger()
  if self.BoundsTriggerBox then
    self.BoundsTriggerBoxRef = nil
    if UE.UObject.IsValid(self.BoundsTriggerBox) then
      self.BoundsTriggerBox:K2_DestroyActor()
    end
    self.BoundsTriggerBox = nil
  end
end

function HomeRoom:OnBoundTriggerEnter(selfComp, otherActor, otherComp, otherBodyIndex, bFromSweep, result)
  if otherActor and otherActor.sceneCharacter then
    local sc = otherActor.sceneCharacter
    if sc.isLocal then
      HomeIndoorSandbox.HomeAIServ:OnLocalPlayerEnterRoom(self)
    end
  end
end

function HomeRoom:OnBoundTriggerLeave(selfComp, otherActor, otherComp, otherBodyIndex, bFromSweep, result)
  if otherActor and otherActor.sceneCharacter then
    local sc = otherActor.sceneCharacter
    if sc.isLocal then
      HomeIndoorSandbox.HomeAIServ:OnLocalPlayerLeaveRoom(self)
    end
  end
end

function HomeRoom:IsPosInBound(Pos)
  local Bounds = self.Bounds
  return UE.UKismetMathLibrary.IsPointInBox(Pos, Bounds.Center, Bounds.Extent)
end

function HomeRoom:MarkRoomPlaneDirty()
  for k, v in pairs(self.HomePlanes) do
    v:MarkRuntimeGraphDirty()
  end
end

return HomeRoom
