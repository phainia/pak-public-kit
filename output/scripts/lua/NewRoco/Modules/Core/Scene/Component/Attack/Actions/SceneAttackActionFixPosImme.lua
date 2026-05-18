local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.SceneAttackBase")
local SceneAttackActionFixPosImme = Base:Extend("SceneAttackActionFixPosImme")

function SceneAttackActionFixPosImme:Ctor()
  Base.Ctor(self)
end

function SceneAttackActionFixPosImme:Init(inComp)
  self.comp = inComp
  self.owner = inComp.owner
  self.target = nil
  self.hitbox = nil
  self.comp:LoadFinished(true)
end

function SceneAttackActionFixPosImme:OnStart(target, hitbox)
  self.hitbox = hitbox
  if self.d_TriggetHit then
    DelayManager:CancelDelay(self.d_TriggetHit)
  end
  self.d_TriggetHit = DelayManager:DelayFrames(1, self.AttackHitEvent, self)
  return true
end

function SceneAttackActionFixPosImme:AttackHitEvent()
  self.d_TriggetHit = nil
  local hitboxPos
  if UE.UObject.IsValid(self.hitbox) and self.hitbox.K2_GetActorLocation then
    hitboxPos = self.hitbox:Abs_K2_GetActorLocation()
  else
    self:OnEnd()
    return
  end
  local hit = false
  local radius = self.comp.AttackParam.Radius
  local outActors, result = UE4.UKismetSystemLibrary.Abs_SphereOverlapActors(self.owner.viewObj, hitboxPos, radius, nil, nil, nil)
  if result then
    for i = 1, outActors:Length() do
      local curActor = outActors:Get(i)
      local sceneCharacter = curActor and curActor.sceneCharacter
      if sceneCharacter then
        if self.comp:OnHit(sceneCharacter) then
          hit = true
        elseif sceneCharacter ~= self.owner then
          sceneCharacter:SendEvent(NPCModuleEvent.BE_ATTACKED, self.owner)
        end
      end
    end
  end
  if GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugArrow(self.owner.viewObj, self.hitbox:Abs_K2_GetActorLocation(), hitboxPos, 10, UE4.FLinearColor(1, 1, 1), 1, 1)
    if hit then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, hitboxPos, radius, 10, UE4.FLinearColor(1.0, 0.1, 0.1), 1, 1)
    else
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, hitboxPos, radius, 10, UE4.FLinearColor(0.1, 1.0, 0.1), 1, 1)
    end
  end
  self:OnEnd()
end

function SceneAttackActionFixPosImme:OnEnd()
  self.comp:ActEnd()
  self.hitbox = nil
  Base.OnEnd(self)
end

function SceneAttackActionFixPosImme:OnInterrupt()
  DelayManager:CancelDelayById(self.d_TriggetHit)
  self.d_TriggetHit = nil
  self:OnEnd()
end

return SceneAttackActionFixPosImme
