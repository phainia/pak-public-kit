local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = RocoSkillAction
local RocoWorldCombatCrushAction = Base:Extend("RocoWorldCombatCrushAction")

function RocoWorldCombatCrushAction:OnActionStart()
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  Log.Debug("RocoWorldCombatCrushAction:OnActionStart")
  self.caster = self:GetSkill():GetCaster().sceneCharacter
  if not self.caster or not UE.UObject.IsValid(self.caster.viewObj) then
    return
  end
  local CapsuleComponent = self.caster.viewObj:GetComponentByClass(UE4.UCapsuleComponent)
  if nil ~= CapsuleComponent then
    self.OldCollisionProfileName = CapsuleComponent:GetCollisionProfileName()
    CapsuleComponent:SetCollisionProfileName("NPCCharacterFree")
  end
  local AnimComp = self.caster:GetAnimComponent()
  if AnimComp then
    self.crushMontage = AnimComp:PrepareMontageByName(self.CrushAnim)
    AnimComp:PlayAnimByName(self.CrushAnim, 1, 0, 0.1, 0.0, -1)
  end
  self.pastTime = 0
  self.crushDir = self.caster:GetForwardVector()
  self.speed = self.CrushDistance / self:GetActionLength()
end

function RocoWorldCombatCrushAction:OnActionTick(DeltaTime)
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  if not self.caster or not UE.UObject.IsValid(self.caster.viewObj) then
    return
  end
  self.pastTime = self.pastTime + DeltaTime
  local nextPos = self.caster:GetActorLocation() + self.crushDir * (self.speed * DeltaTime)
  nextPos = not self.IsNotForceFixToFloor and SceneUtils.GetPosInLand(nextPos, self.caster:GetScaledHalfHeight(), 500) or nextPos
  self.caster:SetActorLocation(nextPos)
end

function RocoWorldCombatCrushAction:OnActionEnd()
  if not _G.WorldCombatModuleCmd or not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  Log.Debug("RocoWorldCombatCrushAction:OnActionEnd")
  if not self.caster or not UE.UObject.IsValid(self.caster.viewObj) then
    return
  end
  local CapsuleComponent = self.caster.viewObj:GetComponentByClass(UE4.UCapsuleComponent)
  if nil ~= CapsuleComponent then
    CapsuleComponent:SetCollisionProfileName(self.OldCollisionProfileName)
  end
  local AnimComp = self.caster:GetAnimComponent()
  if AnimComp then
    AnimComp:StopAnim(self.crushMontage)
  end
end

function RocoWorldCombatCrushAction:ResolveCollideResult(HitActor)
  local SceneCharacter = HitActor.sceneCharacter
  if not SceneCharacter then
    return 1
  end
  if SceneCharacter.name == "SceneLocalPlayer" then
    return 2
  else
    return 0
  end
end

return RocoWorldCombatCrushAction
