local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.SceneAttackBase")
local SceneAttackActionCrush = Base:Extend("SceneAttackActionCrush")
local TickingHitBox = true

function SceneAttackActionCrush:Ctor()
  Base.Ctor(self)
  self.skillClass = nil
  self.target = nil
  self.hitbox = nil
  self.hitActors = {}
  MakeWeakTable(self.hitActors)
  self.HitHandler = _G.SimpleDelegateFactory:CreateCallback(self, self.OnHit)
end

function SceneAttackActionCrush:Init(inComp)
  Base.Init(self, inComp)
end

function SceneAttackActionCrush:OnStart(target, hitbox)
  local hitboxPos = hitbox:K2_GetActorLocation()
  local selfPos = self.owner.viewObj:K2_GetActorLocation()
  local dir = hitboxPos - selfPos
  local dist = dir:Size()
  dir:Normalize()
  dir = dir * math.clamp(dist, 10, 600)
  hitbox:K2_SetActorLocation(selfPos + dir, false, nil, false)
  table.clear(self.hitActors)
  self.target = target
  self.hitbox = hitbox
  self:SetTickEnable(true)
  self:RegisterHitEvent()
  return true
end

function SceneAttackActionCrush:RegisterHitEvent()
  local moveComp = self.owner.viewObj:GetMovementComponent()
  local prim = moveComp and moveComp.UpdatedPrimitive
  if prim then
    prim.OnComponentHit:Add(self.owner.viewObj, self.HitHandler)
  end
end

function SceneAttackActionCrush:UnRegisterHitEvent()
  local moveComp = self.owner.viewObj:GetMovementComponent()
  local prim = moveComp and moveComp.UpdatedPrimitive
  if prim then
    prim.OnComponentHit:Remove(self.owner.viewObj, self.HitHandler)
  end
end

function SceneAttackActionCrush:OnHit(HitComponent, OtherActor, OtherComp, NormalImpulse, HitResult)
  if OtherComp:GetCollisionResponseToChannel(UE.ECollisionChannel.ECC_GameTraceChannel5) ~= UE.ECollisionResponse.ECR_Block then
    return
  end
  local fwd = HitComponent:GetForwardVector()
  local nor = HitResult.ImpactNormal
  local hit_pos = HitResult.ImpactPoint
  if nor:Dot(fwd) < -0.9 then
    self.owner:SendEvent(NPCModuleEvent.BE_COLLIDE_WHILE_ATTACK, hit_pos, nor)
  end
end

function SceneAttackActionCrush:UpdateHitbox()
  if self.hitbox then
    self.hitbox:Abs_K2_SetActorLocation_WithoutHit(self.owner:GetActorLocation())
  end
end

function SceneAttackActionCrush:AttackHitEvent()
  if not self.owner or not self.comp then
    return
  end
  local hitboxPos = self.hitbox:Abs_K2_GetActorLocation()
  local hit = false
  local overlapSceneActors = self.hitbox.GetOverlapSceneActors and self.hitbox:GetOverlapSceneActors() or {}
  for _, sceneActor in ipairs(overlapSceneActors) do
    if not table.contains(self.hitActors, sceneActor) then
      if self.comp:OnHit(sceneActor) then
        hit = true
      elseif sceneActor ~= self.owner then
        sceneActor:SendEvent(NPCModuleEvent.BE_ATTACKED, self.owner)
      end
      table.insert(self.hitActors, sceneActor)
    end
  end
  if GlobalConfig.DebugLuaBTree then
    local radius = self.comp.AttackParam.Radius
    UE4.UKismetSystemLibrary.Abs_DrawDebugArrow(self.owner.viewObj, self.target:GetActorLocation(), hitboxPos, 10, UE4.FLinearColor(1, 1, 1), 0.5, 1)
    if hit then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, hitboxPos, radius, 10, UE4.FLinearColor(1.0, 0.1, 0.1), 0.5, 1)
    else
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, hitboxPos, radius, 10, UE4.FLinearColor(0.1, 1.0, 0.1), 0.5, 1)
    end
  end
end

local debugColor_1 = UE4.FLinearColor(0, 1, 0, 1)
local debugColor_2 = UE4.FLinearColor(1, 1, 0, 1)
local traceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel5)

function SceneAttackActionCrush:OnTick(deltaTime)
  if not (self.owner and self.comp) or not self.comp:IsAttacking() then
    self:OnEnd()
    return
  end
  local view = self.owner.viewObj
  if not view then
    return
  end
  self:UpdateHitbox()
  self:AttackHitEvent()
end

function SceneAttackActionCrush:CheckCollide(deltaTime)
  local view = self.owner.viewObj
  if not view then
    return
  end
  local vel = 0
  local moveComp = view:GetMovementComponent()
  vel = moveComp and moveComp.Velocity or UE4Helper.ZeroVector
  local velSize = vel:Size2D()
  if velSize < 10 then
    return
  end
  local selfRadius = self.owner:GetScaledRadius()
  local debugType = GlobalConfig.DebugLuaBTree and 2 or 0
  local selfPos = self.owner:GetActorLocation()
  local selfFwd = self.owner:GetForwardVector()
  local checkLength = 30 + selfRadius
  selfFwd = selfFwd * checkLength
  local hitResult, isHit = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(view, selfPos, selfPos + selfFwd, traceChannel, false, nil, debugType, nil, true, debugColor_1, debugColor_2, 10)
  if isHit then
    local hitPos = hitResult.ImpactPoint
    local hitNor = hitResult.ImpactNormal
    self.owner:SendEvent(NPCModuleEvent.BE_COLLIDE_WHILE_ATTACK, hitPos, hitNor)
    self:OnEnd()
  end
end

function SceneAttackActionCrush:OnEnd()
  self:SetTickEnable(false)
  if self.owner == nil then
    return
  end
  self:UnRegisterHitEvent()
  self.target = nil
  self.hitbox = nil
  self.comp:ActEnd()
  Base.OnEnd(self)
end

function SceneAttackActionCrush:OnInterrupt()
  if self.owner then
    self.owner:StopAllMontage(0.05)
  end
  self:OnEnd()
end

function SceneAttackActionCrush:SetTickEnable(enable)
  if TickingHitBox and self.ticking ~= enable then
    if enable then
      _G.UpdateManager:Register(self)
    else
      _G.UpdateManager:UnRegister(self)
    end
    self.ticking = enable
  end
end

return SceneAttackActionCrush
