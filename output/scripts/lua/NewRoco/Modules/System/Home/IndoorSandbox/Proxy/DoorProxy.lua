local DoorProxy = Class("DoorProxy")

function DoorProxy:Ctor(DoorActor)
  self.DoorActor = DoorActor
  self.DoorMesh = self.DoorActor._StaticMeshProxy.MeshComponent
  self.DoorTrans = nil
  self.OverlapActors = {}
  if self.DoorMesh and not self.DoorTrans then
    self.DoorTrans = UE.UNRCStatics.Abs_GetComponentTransform(self.DoorMesh)
  end
  self.Inside_SeqPlayer = (self.DoorActor.Inside_SeqPlayer or {}).SequencePlayer
  self.Outside_SeqPlayer = (self.DoorActor.Outside_SeqPlayer or {}).SequencePlayer
  self.DoorCloseThresholdSeconds = DataConfigManager:GetHomeGlobalConfig("door_close_time").num / 10000
  local Sphere = self.DoorActor.Sphere_Trigger
  local Distance = DataConfigManager:GetHomeGlobalConfig("door_open_distance").num or 250
  Sphere:SetSphereRadius(Distance, false)
  self:SetNavLinkEnabled(true)
  self.SphereTrigger = Sphere
  self.SphereDistance = Distance
  if Sphere then
    Sphere:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Visibility, UE.ECollisionResponse.ECR_Ignore)
  end
end

function DoorProxy:GetOpposeRoomId()
  local TheRoomId = HomeIndoorSandbox.World:GetPlayerRoomId()
  local BelongId = self.DoorActor:GetBelongRoomId()
  local OtherId = self.DoorActor:GetOtherRoomId()
  if 0 == BelongId or 0 == OtherId then
    HomeIndoorSandbox:Ensure(false, "Invalid door, cannot found other space id in tags", self.DoorActor:GetName(), self.DoorActor:GetActorId())
    return 0
  end
  if TheRoomId == BelongId then
    return OtherId
  else
    return BelongId
  end
end

local TempActors = UE.TArray(UE.AActor)

function DoorProxy:GetOverlappingActors()
  self.SphereTrigger:GetOverlappingActors(TempActors, UE.AActor)
  return TempActors
end

function DoorProxy:IsPendingInside(AbsLoc)
  if self.DoorTrans then
    local LocalLoc = self.DoorTrans:InverseTransformPosition(AbsLoc)
    return LocalLoc.Y >= 0
  end
  return false
end

function DoorProxy:IsPlaying()
  if self.DoorActor then
    local SeqPlayer = self.Inside_SeqPlayer
    if SeqPlayer and UE.UObject.IsValid(SeqPlayer) and SeqPlayer:IsPlaying() then
      return true, SeqPlayer, true
    end
    SeqPlayer = self.Outside_SeqPlayer
    if SeqPlayer and UE.UObject.IsValid(SeqPlayer) and SeqPlayer:IsPlaying() then
      return true, SeqPlayer
    end
  end
  return false, nil
end

function DoorProxy:PlayInsideAnim(bOpen)
  if self.DoorActor then
    if bOpen then
      self.DoorActor:PlayOpenDoor_Inside()
    else
      self.DoorActor:PlayCloseDoor_Inside()
    end
  end
end

function DoorProxy:PlayOutsideAnim(bOpen)
  if self.DoorActor then
    if bOpen then
      self.DoorActor:PlayOpenDoor_Outside()
    else
      self.DoorActor:PlayCloseDoor_Outside()
    end
  end
end

function DoorProxy:ReqOpenByActor(Player)
  if self.OverlapActors[Player] then
    HomeIndoorSandbox.World:SignalDoorTrigger(self.DoorActor, Player)
    return
  end
  local bHeadTrigger = not next(self.OverlapActors)
  self.OverlapActors[Player] = true
  self:SetWaitForCloseSilent(false)
  local bPlaying, SeqPlayer, bInside = self:IsPlaying()
  HomeIndoorSandbox.World:SignalDoorOpened(self.DoorActor, Player)
  self:SetNavLinkEnabled(true)
  if bPlaying then
    if SeqPlayer:IsReversed() then
      if bInside then
        self:PlayInsideAnim(true)
      else
        self:PlayOutsideAnim(true)
      end
    else
    end
  elseif bHeadTrigger and self:IsClosed() then
    local bIsPendingInside = self:IsPendingInside(Player:Abs_K2_GetActorLocation())
    if bIsPendingInside then
      self:PlayInsideAnim(true)
    else
      self:PlayOutsideAnim(true)
    end
  end
end

function DoorProxy:ReqCloseByActor(Player)
  if not self.OverlapActors[Player] then
    return
  end
  self.OverlapActors[Player] = nil
  local bTailTrigger = not next(self.OverlapActors)
  if bTailTrigger then
    self:SetWaitForCloseSilent(true)
  end
end

function DoorProxy:OnRelease()
  if self._CloseSilentHandle then
    DelayManager:CancelDelayById(self._CloseSilentHandle)
    self._CloseSilentHandle = nil
  end
  if self._OnDoorClosedHandle then
    DelayManager:CancelDelayById(self._OnDoorClosedHandle)
    self._OnDoorClosedHandle = nil
  end
end

function DoorProxy:SetWaitForCloseSilent(bEnable)
  if self._CloseSilentHandle then
    DelayManager:CancelDelayById(self._CloseSilentHandle)
    self._CloseSilentHandle = nil
  end
  if self._OnDoorClosedHandle then
    DelayManager:CancelDelayById(self._OnDoorClosedHandle)
    self._OnDoorClosedHandle = nil
  end
  if bEnable then
    self._CloseSilentHandle = DelayManager:DelaySeconds(self.DoorCloseThresholdSeconds, FPartial(self.OnCloseDoorSilent, self))
  end
end

function DoorProxy:IsClosed()
  if not self.DoorMesh or not self.DoorMesh:IsValid() then
    return true
  end
  return math.abs(self.DoorMesh.RelativeRotation.Yaw) < 2
end

function DoorProxy:OnCloseDoorSilent()
  self._CloseSilentHandle = nil
  if not self.DoorActor or not self.DoorActor:IsValid() then
    return
  end
  if not self:IsClosed() then
    if self.DoorMesh.RelativeRotation.Yaw > 0 then
      self:PlayInsideAnim(false)
    else
      self:PlayOutsideAnim(false)
    end
  end
  self._OnDoorClosedHandle = DelayManager:DelaySeconds(1.5, function()
    self._OnDoorClosedHandle = nil
    if self.DoorActor:IsValid() then
      self:SetNavLinkEnabled(true)
      HomeIndoorSandbox.World:SignalDoorClosed(self.DoorActor)
    end
  end)
end

function DoorProxy:SetNavLinkEnabled(bEnabled)
  local NavLink = self:EnsureNavLinkComp()
  if not NavLink then
    return
  end
  NavLink:SetNavLinkEnabled(bEnabled)
end

local DummyTransform = UE.FTransform()
DummyTransform.Translation.Z = -200

function DoorProxy:EnsureNavLinkComp()
  if self.DoorActor.NavLink then
    return self.DoorActor.NavLink
  end
  if self.DoorActor:IsValid() then
    local NavLink = self.DoorActor:AddComponentByClass(UE.UNRCNavLinkComponent, false, DummyTransform, true)
    NavLink:BuildUniqueNavLink(UE.FVector(-80, 120, 0), UE.FVector(-80, -120, 0), 500, 60, UE.UNRCNavArea_Doorframe)
    self.DoorActor:FinishAddComponent(NavLink, true, DummyTransform)
    NavLink:K2_AttachToComponent(self.DoorActor:K2_GetRootComponent(), nil, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.KeepWorld, false)
    self.DoorActor.NavLink = NavLink
    return NavLink
  end
end

return DoorProxy
