local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local WorldCombatModuleCmd = require("NewRoco.Modules.System.WorldCombat.WorldCombatModuleCmd")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = RocoSkillAction
local RocoWorldCombatJumpAction = Base:Extend("RocoWorldCombatJumpAction")

function RocoWorldCombatJumpAction:OnActionStart()
  Log.Debug("RocoWorldCombatJumpAction:OnActionStart")
  if self:IsSkillEditor() then
    local skillObj = self:GetSkill()
    local caster = skillObj:GetCaster()
    if not caster then
      return
    end
    local capsuleComp = caster:K2_GetRootComponent()
    local colResp = UE.ECollisionResponse.ECR_Ignore
    capsuleComp:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Pawn, colResp)
    Base.OnActionStart()
    return
  end
  self.pastTime = 0
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  local CasterView = self:GetCasterActor()
  local Caster = CasterView and CasterView.sceneCharacter
  if not Caster then
    return
  end
  self.caster = Caster
  self.moveComp = CasterView:GetComponentByClass(UE4.UCharacterNavMovementComponent)
  if not self.moveComp then
    return
  end
  self.capsuleComp = CasterView:K2_GetRootComponent()
  if not self.capsuleComp then
    return
  end
  self.startPos = self.caster:GetActorLocation()
  local target = self.Overridden.GetActorByActorInfo(self, self.TargetInfo.TargetActorInfo)
  target = target or self:GetDefaultTargetActor()
  if not target then
    return
  end
  self.endPos = target:Abs_K2_GetActorLocation()
  self.endPos = SceneUtils.GetPosInLand(self.endPos, self.caster:GetScaledHalfHeight(), self.caster:GetScaledHalfHeight() * 5, self.caster:GetScaledHalfHeight() * 3) or self.endPos
  self.moveComp:SetMovementMode(UE4.EMovementMode.MOVE_Flying, UE4.ERocoCustomMovementMode.MOVE_SkillJump)
  self:GenerateSkillJumpSpline(self.startPos, self.endPos, nil)
  self:ToggleCollisionBlockToCharacter(false)
end

function RocoWorldCombatJumpAction:OnActionTick(DeltaTime)
  if self:IsSkillEditor() then
    Base.OnActionTick(DeltaTime)
    return
  end
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  self.pastTime = self.pastTime + DeltaTime
  local newPos = self:EvalLocationByKey(self.pastTime)
  coroutine.resume(coroutine.create(self.MoveCaster), self, newPos)
end

function RocoWorldCombatJumpAction:MoveCaster(newPos)
  if not self.caster then
    return
  end
  self.caster:SetActorLocation(newPos)
end

function RocoWorldCombatJumpAction:OnActionEnd()
  Log.Debug("RocoWorldCombatJumpAction:OnActionEnd")
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  self:ClearSplinePoints(false)
  if self.moveComp then
    self.moveComp:SetMovementMode(UE.EMovementMode.MOVE_Falling, 0)
    self.moveComp = nil
  end
  if self.capsuleComp then
    self:ToggleCollisionBlockToCharacter(true)
    self.capsuleComp = nil
  end
  if self.caster then
    self.caster = nil
  end
end

function RocoWorldCombatJumpAction:ToggleCollisionBlockToCharacter(IsBlock)
  if not self.capsuleComp then
    return
  end
  local colResp = UE.ECollisionResponse.ECR_Block
  if not IsBlock then
    colResp = UE.ECollisionResponse.ECR_Ignore
  end
  self.capsuleComp:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Pawn, colResp)
end

return RocoWorldCombatJumpAction
