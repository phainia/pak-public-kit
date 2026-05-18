local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local WorldCombatResLoadComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatResLoadComponent")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local HiddenEvent = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenEvent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local ShieldComponent = Base:Extend("ShieldComponent")
local ShieldState = {
  Normal = 1,
  Break = 2,
  Broken = 3,
  NotExist = 4
}

function ShieldComponent:Attach(owner)
  Base.Attach(self, owner)
  self.VisibleState = false
  self.weak_bone_list = {}
  self.cacheSkillIds = {}
  self.shieldSkillIds = {
    BossShieldNormal = 144,
    BossShieldBroken = 145,
    BossShieldHit = 155,
    NightMareBossShieldHit = 158,
    NightMareBossShieldNormal = 146,
    NightMareBossShieldBroken = 147
  }
  self.hitFxPaths = {
    ShieldHitNormal = "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_Shield_HitNormal.NS_BossBattle_Shield_HitNormal",
    ShieldHitCritical = "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_Shield_HitCritical.NS_BossBattle_Shield_HitCritical",
    NightMareShieldHitNormal = "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_EMShield_HitNormal.NS_BossBattle_EMShield_HitNormal",
    NightMareShieldHitCritical = "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_EMShield_HitCritical.NS_BossBattle_EMShield_HitCritical",
    ShieldHitImmune = "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_Shield_Invalid.NS_BossBattle_Shield_Invalid",
    NightMareShieldHitImmune = "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_EMShield_Invalid.NS_BossBattle_EMShield_Invalid"
  }
  SceneUtils.RegisterNPCVisibilityNotify(self, true)
end

function ShieldComponent:OnNormalSkillStart(skillId, skillObj)
  local ownerSkillComponent = self.owner:EnsureComponent(WorldCombatSkillComponent)
  if UE.UNRCStatics.CheckSkillContainsMaterialAction(ownerSkillComponent.skillObj) then
    Log.Debug("ShieldComponent:OnNormalSkillStart: current skillObj contains material action")
    local rocoSkillComp = self.owner.viewObj.RocoSkill
    if rocoSkillComp and ownerSkillComponent.skillObjPassive and (ownerSkillComponent:IsPlayHitShieldSkill() or ownerSkillComponent:IsPlayBrokenShieldSkill()) then
      rocoSkillComp:CancelSkill(ownerSkillComponent.skillObjPassive, UE4.ESkillActionResult.SkillActionResultInterrupted)
    end
    return
  end
end

function ShieldComponent:EnsureChildActorComponent()
  local viewObj = self:GetOwnerView()
  if viewObj and self.ChildActorComponent == nil then
    self.ChildActorComponent = viewObj:AddComponentByClass(UE4.UNRCChildActorComponent, false, UE4.FTransform(), false)
  end
end

function ShieldComponent:InitWeakPoint(weak_bone_list)
  self.weak_bone_list = weak_bone_list
end

function ShieldComponent:ShowShield()
  self.ShieldState = ShieldState.Normal
  self:UpdateShieldState()
  if not self.owner:HasListener(self, HiddenEvent.Hidden, self.OnHidden) then
    self.owner:AddEventListener(self, HiddenEvent.Hidden, self.OnHidden)
  end
  if not self.owner:HasListener(self, HiddenEvent.UnHidden, self.OnUnHidden) then
    self.owner:AddEventListener(self, HiddenEvent.UnHidden, self.OnUnHidden)
  end
end

function ShieldComponent:UpdateShieldState()
  if self.ShieldState == ShieldState.NotExist then
    self:ClearShield()
    return
  end
  if not self:GetOwnerView() then
    self.owner:AddEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.OnViewShellReady)
  end
  if self.VisibleState then
    if self.ShieldState == ShieldState.Normal then
      self:PlayNormalShield()
    elseif self.ShieldState == ShieldState.Break then
      self:PlayBrokenShield()
      self.ShieldState = ShieldState.Broken
    elseif self.ShieldState == ShieldState.Broken then
      self.ShieldState = ShieldState.NotExist
    else
      self:ClearShield(true)
    end
  elseif self.ChildActorComponent then
    self.ChildActorComponent:SetComponentActive(false)
  end
end

function ShieldComponent:OnViewShellReady()
  if self.ShieldState ~= ShieldState.Normal then
    self:ClearShield()
    return
  end
  self:ShowShield()
end

function ShieldComponent:HideShield()
  self.ShieldState = ShieldState.NotExist
  self:UpdateShieldState()
  local owner = self:GetOwner()
  if owner then
    owner:RemoveComponent(self)
  end
end

function ShieldComponent:OnBossShieldLoaded(Shield)
  self.Shield = Shield
  if self.ShieldState == ShieldState.Broken then
    self:BreakShield()
  end
end

function ShieldComponent:ClearShield(bDontPerformSkill)
  if not self then
    return
  end
  self.ShieldState = ShieldState.NotExist
  local ownerView = self:GetOwnerView()
  if UE4.UObject.IsValid(ownerView) and not bDontPerformSkill then
    self:StopShieldSkill()
    self.owner:RemoveEventListener(self, HiddenEvent.Hidden, self.OnHidden)
    self.owner:RemoveEventListener(self, HiddenEvent.UnHidden, self.OnUnHidden)
  end
end

function ShieldComponent:DeAttach()
  SceneUtils.UnregisterNPCVisibilityNotify(self)
  _G.DelayManager:CancelDelay(self.HideShield)
  if self.setMutationTimerId then
    _G.TimerManager:CancelDelayById(self.setMutationTimerId)
    self.setMutationTimerId = nil
  end
  self:ClearShield()
  self.cacheSkillIds = {}
  Base.DeAttach(self)
end

function ShieldComponent:OnVisible()
  self.VisibleState = true
  self:UpdateShieldState()
end

function ShieldComponent:OnInvisible()
  self.VisibleState = false
  self:UpdateShieldState()
end

function ShieldComponent:BreakShield()
  Log.DebugFormat("ShiedComponent:BreakShield %s", self.owner.config.name)
  local ownerPos = self.owner:GetActorLocation()
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.SendSenseEvent, ownerPos, Enum.DotsAIWorldEventType.DAWET_BOSS_SHIELD_BREAK)
  self.ShieldState = ShieldState.Break
  self:UpdateShieldState()
end

function ShieldComponent:IsCriticalBone(BoneName, chargeLevel)
  if self.ShieldState ~= ShieldState.Normal then
    Log.Debug("\230\138\164\231\155\190\231\160\180\228\186\134\228\185\159\229\176\177\230\178\161\230\156\137\229\188\177\231\130\185\229\145\189\228\184\173\228\186\134")
    return false, nil
  end
  local owner_view = self:GetOwnerView()
  local mesh = owner_view and owner_view.mesh
  if not mesh then
    return false, nil
  end
  local minChargeLevel = _G.DataConfigManager:GetGlobalConfigNumByKey("combat_star_magic_weak_hit_level", 2)
  if not chargeLevel or chargeLevel < minChargeLevel then
    return false, nil
  end
  local LogFunc = Log.Debug
  if _G.GlobalConfig.BossHitLog then
    LogFunc = Log.Error
  end
  for i, weak_bone_name in ipairs(self.weak_bone_list or {}) do
    LogFunc("ShieldComponent:IsCriticalBone check: ", weak_bone_name, BoneName)
    if string.StartsWith(weak_bone_name, "(") then
      local new_weak_bone_name = string.sub(weak_bone_name, 2, #weak_bone_name - 1)
      if string.lower(new_weak_bone_name) == string.lower(BoneName) then
        LogFunc("ShieldComponent:IsCriticalBone Yes it is: ", weak_bone_name, new_weak_bone_name)
        return true, weak_bone_name
      end
    elseif mesh:IsParentOfBone(BoneName, weak_bone_name) then
      LogFunc("ShieldComponent:IsCriticalBone Yes it is: ", weak_bone_name)
      return true, weak_bone_name
    end
  end
  LogFunc("ShieldComponent:IsCriticalBone Miss")
  return false, nil
end

function ShieldComponent:OnHit(HitLocation, isCritical, isImmune)
  if self.ShieldState ~= ShieldState.Normal then
    return
  end
  if not (self.owner and self.owner.viewObj) or not UE4.UObject.IsValid(self.owner.viewObj) then
    return
  end
  local resComp = self.owner:EnsureComponent(WorldCombatResLoadComponent)
  local transform = UE4.FTransform(UE4.FQuat(), HitLocation)
  local FxPath
  local useHitLocation = false
  local bInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsSelfInWorldCombat)
  if SceneUtils.IsLogicStatusNightmareBossActivated(self.owner) then
    FxPath = self.hitFxPaths.NightMareShieldHitNormal
    if isCritical and bInWorldCombat then
      FxPath = self.hitFxPaths.NightMareShieldHitCritical
    end
    if isImmune then
      FxPath = self.hitFxPaths.NightMareShieldHitImmune
      useHitLocation = true
    end
  else
    FxPath = self.hitFxPaths.ShieldHitNormal
    if isCritical and bInWorldCombat then
      FxPath = self.hitFxPaths.ShieldHitCritical
    end
    if isImmune then
      FxPath = self.hitFxPaths.ShieldHitImmune
      useHitLocation = true
    end
  end
  local NiagaraTemplate = resComp:GetResAssetByPath(FxPath)
  if not NiagaraTemplate then
    Log.Debug("ShieldComponent:OnHit, No loaded HitFx", FxPath)
    self.request = _G.NRCResourceManager:LoadResAsync(self, FxPath, PriorityEnum.Active_World_Combat_Boss, 10, self.FxLoadSuccess, self.FxLoadFailed)
    self.request.useHitLocation = useHitLocation
    self.request.HitLocation = HitLocation
  else
    local RocoFx = self.owner.viewObj.RocoFx
    if RocoFx then
      if useHitLocation then
        RocoFx:PlayFx_Location(NiagaraTemplate, transform, true, 1)
      else
        RocoFx:PlayFx_Type_Setting2(NiagaraTemplate, UE.EFXAttachPointType.Body, true, UE.FTransform(), true, true, 1)
      end
    end
  end
  _G.NRCAudioManager:PlaySound3DWithActorAuto(1220002134, self.parentActor, "BP_BossShield_C:ReceiveHit")
  self:PlayHitShield()
  if isCritical and bInWorldCombat and not isImmune then
    self.owner.viewObj:TriggerWeakPointHitAnim()
  end
end

function ShieldComponent:FxLoadSuccess(req, asset)
  if not (self.owner and self.owner.viewObj) or not UE4.UObject.IsValid(self.owner.viewObj) then
    return
  end
  local RocoFx = self.owner.viewObj.RocoFx
  if not UE.UObject.IsValid(RocoFx) then
    return
  end
  if req.assetPath ~= self.request.assetPath then
    return
  end
  local transform = UE4.FTransform(UE4.FQuat(), self.request.HitLocation or self.owner:GetActorLocation())
  if self.request.useHitLocation then
    RocoFx:PlayFx_Location(asset, transform, true, 1)
  else
    RocoFx:PlayFx_Type_Setting2(asset, UE.EFXAttachPointType.Body, true, UE.FTransform(), true, true, 1)
  end
end

function ShieldComponent:FxLoadFailed(req, msg)
  Log.Error("ShieldComponent:FxLoadFailed: ", msg, req.assetPath)
end

function ShieldComponent:IsShieldNormal()
  return self.ShieldState == ShieldState.Normal
end

function ShieldComponent:PlayNormalShield()
  local owner = self:GetOwner()
  if not owner or not UE.UObject.IsValid(owner.viewObj) then
    Log.Debug("ShieldComponent:PlayBrokenShield Owner is not valid!")
    return
  end
  local ownerSkillComponent = owner:EnsureComponent(WorldCombatSkillComponent)
  if UE.UNRCStatics.CheckSkillContainsMaterialAction(ownerSkillComponent.skillObj) then
    Log.Debug("ShieldComponent:PlayNormalShield: current skillObj contains material action")
    self.cacheSkillIds.Normal = ownerSkillComponent.skillObj:GetSkillID()
    if not owner:HasListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.InternalPlayNormalShield) then
      owner:AddEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.InternalPlayNormalShield)
    end
    return
  end
  self:InternalPlayNormalShield()
end

function ShieldComponent:InternalPlayNormalShield(skillIdIn)
  local owner = self:GetOwner()
  if not owner or not UE.UObject.IsValid(owner.viewObj) then
    Log.Debug("ShieldComponent:InternalPlayNormalShield Owner is not valid!")
    return
  end
  if skillIdIn and self.cacheSkillIds.Normal and skillIdIn ~= self.cacheSkillIds.Normal then
    owner:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.InternalPlayNormalShield)
    return
  end
  owner:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.InternalPlayNormalShield)
  if not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInWorldCombat) then
    Log.Debug("ShieldComponent:InternalPlayNormalShield Owner is not in world combat!")
    return
  end
  local HiddenComponent = owner.HiddenComponent
  if HiddenComponent and HiddenComponent:IsHidden() then
    Log.Debug("ShieldComponent:PlayNormalShield Owner is hidden!")
    return
  end
  local skillId = self.shieldSkillIds.BossShieldNormal
  if SceneUtils.IsLogicStatusNightmareBossActivated(owner) then
    skillId = self.shieldSkillIds.NightMareBossShieldNormal
  end
  owner:EnsureComponent(WorldCombatSkillComponent):TryCastPassiveSkill(skillId, nil, nil, nil, self)
end

function ShieldComponent:PlayBrokenShield()
  local owner = self:GetOwner()
  if not owner or not UE.UObject.IsValid(owner.viewObj) then
    Log.Debug("ShieldComponent:PlayBrokenShield Owner is not valid!")
    return
  end
  self:InternalPlayBrokenShield()
end

function ShieldComponent:InternalPlayBrokenShield()
  local owner = self:GetOwner()
  if not owner or not UE.UObject.IsValid(owner.viewObj) then
    Log.Debug("ShieldComponent:InternalPlayNormalShield Owner is not valid!")
    return
  end
  local skillId = self.shieldSkillIds.BossShieldBroken
  if SceneUtils.IsLogicStatusNightmareBossActivated(owner) then
    skillId = self.shieldSkillIds.NightMareBossShieldBroken
  end
  owner:EnsureComponent(WorldCombatSkillComponent):TryCastPassiveSkill(skillId, nil, nil, nil, self)
  self.ShieldState = ShieldState.NotExist
  owner:SendEvent(_G.WorldCombatModuleEvent.OnBossShieldBreak)
end

function ShieldComponent:PlayHitShield()
  if not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInWorldCombat) then
    return
  end
  local owner = self:GetOwner()
  if not owner or not UE.UObject.IsValid(owner.viewObj) then
    return
  end
  local ownerSkillComponent = owner:EnsureComponent(WorldCombatSkillComponent)
  if UE.UNRCStatics.CheckSkillContainsMaterialAction(ownerSkillComponent.skillObj) then
    Log.Debug("ShieldComponent:PlayHitShield: current skillObj contains material action")
    return
  end
  self:InternalPlayHitShield()
end

function ShieldComponent:InternalPlayHitShield(skillIdIn)
  local owner = self:GetOwner()
  if not owner or not UE.UObject.IsValid(owner.viewObj) then
    return
  end
  owner:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.InternalPlayHitShield)
  if self.ShieldState == ShieldState.NotExist then
    return
  end
  if skillIdIn and self.cacheSkillIds.Hit and skillIdIn ~= self.cacheSkillIds.Hit then
    return
  end
  if self.ShieldState ~= ShieldState.Normal then
    return
  end
  local HiddenComponent = owner.HiddenComponent
  if HiddenComponent and HiddenComponent:IsHidden() then
    Log.Debug("ShieldComponent:InternalPlayHitShield Owner is in hidden State!")
    return
  end
  if owner.IsVisible and not owner:IsVisible() then
    Log.Debug("ShieldComponent:InternalPlayHitShield Owner is not visible!")
    return
  end
  local skillId = self.shieldSkillIds.BossShieldHit
  if SceneUtils.IsLogicStatusNightmareBossActivated(owner) then
    skillId = self.shieldSkillIds.NightMareBossShieldHit
  end
  local ownerSkillComponent = owner:EnsureComponent(WorldCombatSkillComponent)
  if not ownerSkillComponent then
    return
  end
  if ownerSkillComponent:IsPlayBrokenShieldSkill() then
    return
  end
  if not self:IsShieldNormal() then
    Log.Debug("InternalPlayHitShield return when barrier broken")
    return
  end
  ownerSkillComponent:TryCastPassiveSkill(skillId, nil, nil, self.OnShieldSkillComplete, self)
end

function ShieldComponent:StopShieldSkill()
  self:PlayBrokenShield()
end

function ShieldComponent:OnShieldSkillComplete(skillId, bSuccess)
  if not self.owner or not UE.UObject.IsValid(self.owner.viewObj) then
    return
  end
  local targetSkillId = self.shieldSkillIds.BossShieldHit
  if self.ShieldState == ShieldState.Normal and skillId == targetSkillId then
    Log.Debug("ShieldComponent:OnShieldSkillComplete PlayNormalShield", self.ShieldState, skillId, targetSkillId)
    self:PlayNormalShield()
  else
    return
  end
  if SceneUtils.IsLogicStatusNightmareBossActivated(self.owner) then
    targetSkillId = self.shieldSkillIds.NightMareBossShieldHit
    if not self:IsShieldNormal() and (skillId == self.shieldSkillIds.NightMareBossShieldHit or skillId == self.shieldSkillIds.NightMareBossShieldBroken) and self.owner.viewObj.SetNightmare2Mutation then
      Log.Debug("ShieldComponent:OnShieldSkillComplete SetNightmare2Mutation", self.ShieldState, skillId, targetSkillId)
      if self.setMutationTimerId then
        _G.TimerManager:CancelDelayById(self.setMutationTimerId)
        self.setMutationTimerId = nil
      end
      self.setMutationTimerId = _G.DelayManager:DelaySeconds(0.01, self.OnSetNightmareSecondMutation, self)
    end
  end
end

function ShieldComponent:OnSetNightmareSecondMutation()
  if self.owner and UE.UObject.IsValid(self.owner.viewObj) then
    PetMutationUtils.SetNightmareSecondMutation(self.owner.viewObj)
  end
  self.setMutationTimerId = nil
end

function ShieldComponent:OnHidden()
  local ownerSkillComponent = self.owner:EnsureComponent(WorldCombatSkillComponent)
  if not ownerSkillComponent then
    return
  end
  ownerSkillComponent:ForceStopPassiveSkill()
end

function ShieldComponent:OnUnHidden()
  self:PlayNormalShield()
end

return ShieldComponent
