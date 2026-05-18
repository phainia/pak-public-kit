require("UnLuaEx")
local ShieldComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.ShieldComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local WorldCombatResLoadComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatResLoadComponent")
local OnHitFxPath = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_Scene_BossBattle_ShieldHit.NS_Scene_BossBattle_ShieldHit'"
local OnHitNightmareFxPath = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NMBoss/NS_Scene_NSBoss_ShieldHit.NS_Scene_NSBoss_ShieldHit'"
local NormalShieldLoop = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_Scene_BossBattle_ShieldLoop.NS_Scene_BossBattle_ShieldLoop'"
local NightmareShieldLoop = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NMBoss/NS_Scene_NSBoss_ShieldLoop.NS_Scene_NSBoss_ShieldLoop'"
local NormalShieldEnd = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_Scene_BossBattle_ShieldEnd.NS_Scene_BossBattle_ShieldEnd'"
local NightmareShieldEnd = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NMBoss/NS_Scene_NSBoss_ShieldEnd.NS_Scene_NSBoss_ShieldEnd'"
local BP_BossShield_C = Class()

function BP_BossShield_C:Initialize(Initializer)
end

function BP_BossShield_C:ReceiveBeginPlay()
  self.parentActor = self:GetParentActor()
  self.sceneCharacter = self.parentActor.sceneCharacter
  self.ShieldComponent = self.parentActor.sceneCharacter:EnsureComponent(ShieldComponent)
  self.ShieldComponent:OnBossShieldLoaded(self)
  local CapsuleComponent = self.parentActor:GetComponentByClass(UE4.UCapsuleComponent)
  local radius = CapsuleComponent:GetScaledCapsuleRadius()
  local halfHeight = CapsuleComponent:GetScaledCapsuleHalfHeight()
  radius = math.max(radius, halfHeight)
  self.scale = radius / 100
  self.DelayHandler = nil
  self:SetActorScale3D(UE4.FVector(self.scale, self.scale, self.scale))
  self:Show()
end

function BP_BossShield_C:ReceiveEndPlay(Reason)
  if self.DelayHandler then
    _G.DelayManager:CancelDelayById(self.DelayHandler)
    self.DelayHandler = nil
  end
end

function BP_BossShield_C:Show()
  if self.NRCNiagaraSystem then
    self.DelayHandler = _G.DelayManager:DelaySeconds(0.5, self.SetShieldRes, self)
  end
  self.ShieldSphere:SetVisibility(true, true)
  self:SetActorEnableCollision(true)
end

function BP_BossShield_C:SetShieldRes()
  self.DelayHandler = nil
  _G.NRCAudioManager:PlaySound3DWithActorAuto(1220002139, self.parentActor, "BP_BossShield_C:SetShieldRes")
  if not UE.UObject.IsValid(self) then
    return
  end
  if self.NRCNiagaraSystem then
    if SceneUtils.IsLogicStatusNightmareBossActivated(self.sceneCharacter) then
      self.NRCNiagaraSystem:SetPath(NightmareShieldLoop)
    else
      self.NRCNiagaraSystem:SetPath(NormalShieldLoop)
    end
  end
  if SceneUtils.IsLogicStatusNightmareBossActivated(self.sceneCharacter) then
    self.parentActor:HideNightmareBossEffect(false)
  end
end

function BP_BossShield_C:Break()
  if not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInWorldCombat) then
    return
  end
  if self.NRCNiagaraSystem then
    if SceneUtils.IsLogicStatusNightmareBossActivated(self.sceneCharacter) then
      self.NRCNiagaraSystem:SetPath(NightmareShieldEnd)
    else
      self.NRCNiagaraSystem:SetPath(NormalShieldEnd)
    end
  end
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Jineng/BossBattle/G6_BossBattle_Shield_END.G6_BossBattle_Shield_END"
  local SkillProxy = RocoSkillProxy.Create(skillPath, self.parentActor.RocoSkill, PriorityEnum.Passive_WorldCombat_Important)
  SkillProxy:SetCaster(self.parentActor)
  SkillProxy:SetPassive(true)
  SkillProxy:RegisterEventCallback("ShieldBreak", self, self.ShieldBreak)
  SkillProxy:PlaySkill()
  self:SetActorEnableCollision(false)
  if self.ShieldSphere then
    self.ShieldSphere:SetVisibility(false, true)
  end
  if self.DelayHandler then
    _G.DelayManager:CancelDelayById(self.DelayHandler)
    self.DelayHandler = nil
  end
end

function BP_BossShield_C:ShieldBreak()
  if not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInWorldCombat) then
    return
  end
  if self.parentActor and self.parentActor.sceneCharacter then
    self.parentActor.sceneCharacter:SendEvent(_G.WorldCombatModuleEvent.OnBossShieldBreak)
  end
end

function BP_BossShield_C:ReceiveHit(MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
  self:OnHit(Other)
end

function BP_BossShield_C:OnHit(Other)
  if Other and Other.ThrowSession and Other.StarLevelData then
    self:HitShield(Other:K2_GetActorLocation())
    local transform = UE4.FTransform(_G.FVectorZero, _G.FVectorZero, UE4.FVector(1.25, 1.25, 1.25))
    if SceneUtils.IsLogicStatusNightmareBossActivated(self.sceneCharacter) then
      local NiagaraTemplate = self.parentActor.sceneCharacter:EnsureComponent(WorldCombatResLoadComponent):GetResAssetByPath(OnHitNightmareFxPath)
      if not NiagaraTemplate then
        Log.Debug("BP_BossShield_C:OnHit, cannot find loaded HitFx!!!", OnHitNightmareFxPath)
        NRCResourceManager:LoadResAsync(self, OnHitNightmareFxPath, PriorityEnum.Active_World_Combat_Boss, 10, self.FxLoadSuccess, self.FxLoadFailed)
      else
        self.RocoFX:PlayFx_Type_Setting2(NiagaraTemplate, UE.EFXAttachPointType.Actor, true, transform, true, true, 1)
      end
    else
      local NiagaraTemplate = self.parentActor.sceneCharacter:EnsureComponent(WorldCombatResLoadComponent):GetResAssetByPath(OnHitFxPath)
      if not NiagaraTemplate then
        Log.Debug("BP_BossShield_C:OnHit, cannot find loaded HitFx!!!", OnHitFxPath)
        NRCResourceManager:LoadResAsync(self, OnHitFxPath, PriorityEnum.Active_World_Combat_Boss, 10, self.FxLoadSuccess, self.FxLoadFailed)
      else
        self.RocoFX:PlayFx_Type_Setting2(NiagaraTemplate, UE.EFXAttachPointType.Actor, true, transform, true, true, 1)
      end
    end
    _G.NRCAudioManager:PlaySound3DWithActorAuto(1220002134, self.parentActor, "BP_BossShield_C:ReceiveHit")
  end
end

function BP_BossShield_C:FxLoadSuccess(req, asset)
  if not UE.UObject.IsValid(self) or not UE.UObject.IsValid(self.RocoFX) then
    return
  end
  local transform = UE4.FTransform(_G.FVectorZero, _G.FVectorZero, UE4.FVector(1.25, 1.25, 1.25))
  self.RocoFX:PlayFx_Type_Setting2(asset, UE.EFXAttachPointType.Actor, true, transform, true, true, 1)
end

function BP_BossShield_C:FxLoadFailed(req, msg)
  Log.Error("BP_BossShield_C:FxLoadFailed: ", msg, req.assetPath)
end

return BP_BossShield_C
