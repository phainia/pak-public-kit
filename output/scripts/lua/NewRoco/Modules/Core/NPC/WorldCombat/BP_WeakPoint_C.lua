require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local WeakPointRevealComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.WeakPointRevealComponent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local WorldCombatResLoadComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatResLoadComponent")
local BP_WeakPoint_C = Class()
local TestDirection = {
  UE4.FVector(0, 0, 0),
  UE4.FVector(0, 0, 1),
  UE4.FVector(0, 0, -1),
  UE4.FVector(0, 1, 0),
  UE4.FVector(0, -1, 0),
  UE4.FVector(1, 0, 0),
  UE4.FVector(-1, 0, 0)
}

function BP_WeakPoint_C:Initialize(Initializer)
  self.isHidden = false
  self.current_dir_index = 1
  self.max_dir_index = 7
  self.alpha = 1
  self.weakPointRadius = 100
end

function BP_WeakPoint_C:ReceiveBeginPlay()
  self:SetActorTickEnabled(true)
  self.isInitialized = false
  self.keepVisibleCountDown = 0
  self.AppearNiagaraSystem:SetLoadPriority(PriorityEnum.Passive_WorldCombat_Important)
  self.WeakPointNiagaraSystem:SetLoadPriority(PriorityEnum.Passive_WorldCombat_Important)
  self.parentActor = self:GetParentActor()
  if self.parentActor then
    self.weakPointComponent = self.parentActor.sceneCharacter:EnsureComponent(WeakPointRevealComponent)
    self.buffType = self.weakPointComponent:GetBuffTypeByComponent(self:GetParentComponent())
    self.WeakPointData = self.weakPointComponent:GetWeakPointDataByComponent(self:GetParentComponent())
    self.sceneCharacter = self.parentActor.sceneCharacter
    if self.WeakPointNiagaraSystem and UE.UObject.IsValid(self.WeakPointNiagaraSystem) then
      self.WeakPointNiagaraSystem:SetComponentActive(false)
    end
    if self.AppearNiagaraSystem and UE.UObject.IsValid(self.AppearNiagaraSystem) then
      self.AppearNiagaraSystem:SetComponentActive(false)
    end
    if self.WeakPointData.is_restore then
      self:InitWeakPoint()
    else
      self.DelayHandler = _G.DelayManager:DelayFrames(self.WeakPointData.delayFrame, self.InitWeakPoint, self)
    end
  end
  self.needTick = true
  self.weakPointRadius = self.WeakPointSphere:GetScaledSphereRadius()
end

function BP_WeakPoint_C:ReceiveEndPlay(Reason)
  if self.DelayHandler then
    _G.DelayManager:CancelDelayById(self.DelayHandler)
    self.DelayHandler = nil
  end
end

function BP_WeakPoint_C:InitWeakPoint()
  self.DelayHandler = nil
  if not self.isInitialized and UE.UObject.IsValid(self) then
    self.isInitialized = true
    self.WeakPointNiagaraSystem:SetComponentActive(true)
    if self.parentActor then
      if self.WeakPointData.is_restore then
        self.AppearNiagaraSystem:SetComponentActive(false)
      else
        self.AppearNiagaraSystem:SetPath("/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_Scene_BossBattle_RuoDian_New.NS_Scene_BossBattle_RuoDian_New")
        self.AppearNiagaraSystem:SetComponentActive(true)
      end
      self:InitWeakPointBuffFx()
      if not self.WeakPointData.is_restore then
        self.alpha = 1
        self.keepVisibleCountDown = 10
        self:SetOpacity(self.alpha)
      end
    else
      Log.Error("\230\156\137\233\151\174\233\162\152\239\188\140\229\175\132")
    end
  end
end

function BP_WeakPoint_C:InitWeakPointBuffFx()
  self.WeakPointNiagaraSystem:ClearAll()
  self.WeakPointNiagaraSystem:SetPath("/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_Scene_BossBattle_RuoDian_wushuxing1.NS_Scene_BossBattle_RuoDian_wushuxing1")
  Log.Debug(string.format("InitWeakPointBuffFx: %s, %s, %s", self, self.buffType, PetUtils.WorldCombatBuffToUIIdx(self.buffType)))
  self:SetPetType(PetUtils.WorldCombatBuffToUIIdx(self.buffType))
end

function BP_WeakPoint_C:ReceiveTick(DeltaSeconds)
end

function BP_WeakPoint_C:UpdateWeakPoint()
  local WeakPointLocation = self:Abs_K2_GetActorLocation()
  WeakPointLocation = WeakPointLocation + TestDirection[self.current_dir_index] * self.weakPointRadius
  local isHit, HitComponent = self:CheckIfHidden(WeakPointLocation)
  if isHit then
    if self.alpha > 0.0 and self.alpha <= 0.1 then
      if HitComponent and HitComponent.GetFullName then
        Log.Warning(string.format("\229\145\189\228\184\173: %s\229\175\188\232\135\180\229\188\177\231\130\185\228\184\141\229\143\175\232\167\129", HitComponent:GetFullName()))
      else
        Log.Warning(string.format("\229\133\182\228\187\150\229\142\159\229\155\160\229\175\188\232\135\180\229\188\177\231\130\185\228\184\141\229\143\175\232\167\129", HitComponent))
      end
    end
    self.alpha = math.max(self.alpha - 0.1, 0)
  else
    self.alpha = math.min(self.alpha + 0.1, 1)
  end
  if self.keepVisibleCountDown > 0 then
    self.keepVisibleCountDown = self.keepVisibleCountDown - 1
    self.alpha = 1
  end
  self:SetOpacity(self.alpha)
end

function BP_WeakPoint_C:CheckIfHidden(WeakPointLocation)
  local ProjectedLocation = self:GetProjectLocation(WeakPointLocation)
  if not ProjectedLocation then
    return false, "can't get location"
  end
  local Dir = ProjectedLocation - WeakPointLocation
  Dir:Normalize()
  local beginPoint = WeakPointLocation + Dir * (self.weakPointRadius or 100)
  ProjectedLocation = ProjectedLocation - Dir * 200
  local Hit, success
  Hit, success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(self, beginPoint, ProjectedLocation, UE.ETraceTypeQuery.Visibility, true, nil, UE4.EDrawDebugTrace.None, nil, true)
  if Hit and type(Hit) == "userdata" and Hit.Actor and Hit.bBlockingHit then
    return true, Hit.Actor
  else
    Hit, success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(self, ProjectedLocation, beginPoint, UE.ETraceTypeQuery.Visibility, true, nil, UE4.EDrawDebugTrace.None, nil, true)
    if Hit and type(Hit) == "userdata" and Hit.Actor and Hit.bBlockingHit then
      return true, Hit.Actor
    else
      return false, nil
    end
  end
end

function BP_WeakPoint_C:CanThrowInter(Item)
  return true
end

function BP_WeakPoint_C:CanEnterThrowInter(OtherComponent)
  local IsSelfInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsSelfInWorldCombat)
  if not IsSelfInWorldCombat then
    return false
  end
  if OtherComponent == self.WeakPointSphere then
    return true
  end
end

function BP_WeakPoint_C:OnThrowItemEnter(Item, OtherComponent)
  if self:CanEnterByWeakPoint(Item) then
    self:OnHitByPetBall(Item)
    self.parentActor:OnThrowItemEnter(Item, self:GetParentComponent())
  else
    local WeakPointComponent = self.parentActor.sceneCharacter:EnsureComponent(WeakPointRevealComponent)
    WeakPointComponent:OnThrowItemEnter(Item, OtherComponent)
  end
end

function BP_WeakPoint_C:CanEnterByWeakPoint(Item)
  if self.alpha < 0.3 then
    return false
  end
  return true
end

function BP_WeakPoint_C:OnHitByPetBall(Item)
  local NiagaraPath = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_Scene_BossBattle_Boom.NS_Scene_BossBattle_Boom'"
  local NiagaraTemplate = self.parentActor.sceneCharacter:EnsureComponent(WorldCombatResLoadComponent):GetResAssetByPath(NiagaraPath)
  if not NiagaraTemplate then
    Log.Debug("BP_WeakPoint_C:OnHitByPetBall, cannot find loaded HitFx!!!", NiagaraPath)
    NRCResourceManager:LoadResAsync(self, NiagaraPath, PriorityEnum.Active_World_Combat_Boss, 10, self.FxLoadSuccess, self.FxLoadFailed)
    return
  end
  self.parentActor.RocoFX:PlayFx_Location(NiagaraTemplate, self:GetTransform(), true, 1)
end

function BP_WeakPoint_C:FxLoadSuccess(req, asset)
  if not (UE.UObject.IsValid(self) and UE.UObject.IsValid(self.parentActor)) or not UE.UObject.IsValid(self.parentActor.RocoFX) then
    return
  end
  self.parentActor.RocoFX:PlayFx_Location(asset, self:GetTransform(), true, 1)
end

function BP_WeakPoint_C:FxLoadFailed(req, msg)
  Log.Error("BP_WeakPoint_C:FxLoadFailed: ", msg, req.assetPath)
end

function BP_WeakPoint_C:GetProjectLocation(Location)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return nil
  end
  local playerController = localPlayer:GetUEController()
  local ScreenPos = UE4.FVector2D()
  local InScreen = UE4.UGameplayStatics.Abs_ProjectWorldToScreen(playerController, Location, ScreenPos)
  if not InScreen then
    return nil
  end
  local worldLocation, CamDir = playerController:Abs_DeprojectScreenPositionToWorld(ScreenPos.X, ScreenPos.Y)
  return worldLocation
end

function BP_WeakPoint_C:CanEnterByWeakPointDoubleCheck(Item)
  if not self:CanEnterByWeakPoint(Item) then
    return false
  end
  local weakPointLocation = self:Abs_K2_GetActorLocation()
  local projectLocation = self:GetProjectLocation(weakPointLocation)
  if not projectLocation then
    return false
  end
  local Dir = projectLocation - weakPointLocation
  Dir:Normalize()
  local startPoint = weakPointLocation - Dir * (self.weakPointRadius or 100)
  local targetPoint = projectLocation
  local traceRadius = (self.weakPointRadius or 100) * 1.2
  local DrawDebugTraceType = UE4.EDrawDebugTrace.None
  if _G.GlobalConfig.DrawThrowDebug then
    DrawDebugTraceType = UE4.EDrawDebugTrace.ForDuration
    Log.Error("\229\176\157\232\175\149\231\156\139\231\156\139\232\131\189\228\184\141\232\131\189\229\145\189\228\184\173\229\188\177\231\130\185")
  end
  local hitResults, isHit = UE4.UKismetSystemLibrary.Abs_SphereTraceMultiForObjects(self, startPoint, targetPoint, traceRadius, {
    UE4.EObjectTypeQuery.ThrowedItem
  }, false, {}, DrawDebugTraceType, nil, true, UE4.FLinearColor(1, 0, 0, 1), UE4.FLinearColor(0, 0, 1, 0), 100)
  if isHit then
    for i = 1, hitResults:Length() do
      local hitResult = hitResults:Get(i)
      if hitResult.Actor == Item then
        local rootComp = Item:K2_GetRootComponent()
        if hitResult.Component == rootComp then
          Log.Debug("\229\145\189\228\184\173\228\186\134\239\188\129")
          self:OnHitByPetBall()
          return true
        end
      end
    end
  end
  return false
end

return BP_WeakPoint_C
