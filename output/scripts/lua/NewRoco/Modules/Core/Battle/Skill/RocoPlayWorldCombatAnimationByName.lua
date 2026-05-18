local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local OverlapAwareVisibilityComponent = require("NewRoco.Modules.Core.Scene.Component.Visibility.OverlapAwareVisibilityComponent")
local Base = RocoSkillAction
local RocoPlayWorldCombatAnimationByName = Base:Extend("RocoPlayWorldCombatAnimationByName")

function RocoPlayWorldCombatAnimationByName:Ctor()
  self.skipFinalizePosition = false
end

function RocoPlayWorldCombatAnimationByName:OnActionEnd(reason)
  if self.InitFailed then
    return
  end
  Log.DebugFormat("RocoPlayuWorldCombatAnimationAction:OnActionEnd, reason: %s, animation: %s", tostring(reason), tostring(self.AnimationNameNew))
  self.AnimComponent:StopAnimByName(self.AnimationNameNew)
  if not self.skipFinalizePosition then
    self:ApplyFinalTransform()
  end
  self:ResumeMovement()
  local caster = self:GetSkill():GetCaster().sceneCharacter
  if caster then
    caster:EnsureComponent(OverlapAwareVisibilityComponent):CheckInBoundAndMarkHidden(true, true, false, -5, true)
  end
end

return RocoPlayWorldCombatAnimationByName
