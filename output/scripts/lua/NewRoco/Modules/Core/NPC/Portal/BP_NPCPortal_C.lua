require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCPortal_C = Base:Extend("BP_NPCPortal_C")

function BP_NPCPortal_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  local GetHasActorBegunPlay = UE.NPCUtils.GetHasActorBegunPlay
  if GetHasActorBegunPlay and GetHasActorBegunPlay(self) then
    self:ReceiveBeginPlay()
  else
    self:ClearTimer()
    self.BeginPlayCheckTimer = _G.TimerManager:CreateTimer(self, "BeginPlayCheckTimer", 60, self.OnTimerUpdate, self.OnTimerComplete, 10)
  end
  Log.Debug("BP_NPCPortal_C:Initialize", UE.UObject.GetFullName(self), tostring(self))
end

function BP_NPCPortal_C:OnTimerComplete()
  if not UE.UObject.IsValid(self) then
    return
  end
  Log.Error("BP_NPCPortal_C:OnTimerComplete i didnt receive any begin play!!!!", UE.UObject.GetFullName(self), tostring(self))
  self:ClearTimer()
  self:ReceiveBeginPlay()
  if not RocoEnv.IS_EDITOR then
    local ErrorMessage = string.format("BP_NPCPortal_C\229\156\168Initialize\228\185\139\229\144\142\231\154\13260\231\167\146\229\134\133\230\178\161\230\156\137\230\148\182\229\136\176ReceiveBeginPlay:%s %s", UE.UObject.GetFullName(self), tostring(self))
    _G.NRCSDKManager:CrashSightReportExceptionWithReason("Actor\231\148\159\229\145\189\229\145\168\230\156\159\229\188\130\229\184\184", ErrorMessage, "")
  end
end

function BP_NPCPortal_C:OnTimerUpdate()
  if not self.BeginPlayCheckTimer then
    Log.Error("BP_NPCPortal_C:OnTimerUpdate where does this come from????", UE.UObject.GetFullName(self), tostring(self))
    return
  end
  Log.Debug("BP_NPCPortal_C:OnTimerUpdate wait for begin play", self.BeginPlayCheckTimer.elapsedTime, UE.UObject.GetFullName(self), tostring(self))
end

function BP_NPCPortal_C:ClearTimer()
  if not self.BeginPlayCheckTimer then
    return
  end
  _G.TimerManager:RemoveTimer(self.BeginPlayCheckTimer)
  self.BeginPlayCheckTimer = nil
  Log.Debug("BP_NPCPortal_C:ClearTimer", UE.UObject.GetFullName(self), tostring(self))
end

function BP_NPCPortal_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
  Log.Debug("BP_NPCPortal_C:ReceiveBeginPlay", self.sceneCharacter and self.sceneCharacter:DebugNPCNameAndID() or "no scene character", UE.UObject.GetFullName(self), self.PlaceableId, tostring(self))
  self:ClearTimer()
end

function BP_NPCPortal_C:ReceiveEndPlay()
  Base.ReceiveEndPlay(self)
  self:ClearTimer()
end

function BP_NPCPortal_C:Init()
  Base.Init(self)
end

function BP_NPCPortal_C:OnVisible()
  Base.OnVisible(self)
  self:UpdateState()
end

function BP_NPCPortal_C:OnInVisible()
  _G.NRCAudioManager:StopAllForActor(self)
end

function BP_NPCPortal_C:UpdateState()
  if self.sceneCharacter and SceneUtils.IsLogicStatusUnlock(self.sceneCharacter) then
    self:Opened()
    self.opened = true
  else
    self:Close()
    self.opened = false
  end
end

function BP_NPCPortal_C:SetSceneCharacter(sceneCharacter)
  Base.SetSceneCharacter(self, sceneCharacter)
  if sceneCharacter then
    self:UpdateState()
  end
end

function BP_NPCPortal_C:LoadLockEffect()
end

function BP_NPCPortal_C:PreOpen()
  _G.NRCAudioManager:PlaySound3DWithActorAuto(121000101, self)
end

function BP_NPCPortal_C:OnBoxCheck(OtherNPCCharacter)
  local HalfHeight = 60
  if OtherNPCCharacter.GetHalfHeight then
    HalfHeight = OtherNPCCharacter:GetHalfHeight()
  end
  local LandPos = SceneUtils.GetPosInLand(OtherNPCCharacter:Abs_K2_GetActorLocation(), HalfHeight, 100)
  OtherNPCCharacter:Abs_K2_SetActorLocation_WithoutHit(LandPos, false)
end

function BP_NPCPortal_C:CheckIfNpcInside()
  local World = _G.UE4Helper.GetCurrentWorld()
  local QueryPos = self:Abs_K2_GetActorLocation()
  local QueryExtent = UE.FVector(400, 400, 200)
  local OverlapResults = UE.TArray(UE.AActor)
  local Success = UE.UKismetSystemLibrary.Abs_BoxOverlapActors(World, QueryPos, QueryExtent, {
    UE.EObjectTypeQuery.Character
  }, UE.ARocoCharacter, nil, OverlapResults)
  if Success then
    for _, Actor in tpairs(OverlapResults) do
      if Actor:IsA(UE.ANPCBaseCharacter) or Actor:IsA(UE.ARocoLocalPlayer) then
        Log.Debug("CheckIfNpcInside:", Actor:GetName())
        self:OnBoxCheck(Actor)
      end
    end
    OverlapResults:Clear()
  end
end

return BP_NPCPortal_C
