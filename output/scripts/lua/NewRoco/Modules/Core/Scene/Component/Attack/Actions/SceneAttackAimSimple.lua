local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.SceneAttackBase")
local SceneAttackAimSimple = Base:Extend("SceneAttackAimSimple")

function SceneAttackAimSimple:OnStart(target, hitbox)
  if target then
    hitbox:Abs_K2_SetActorLocation_WithoutHit(target:GetActorLocation())
  end
  self.comp:AimEnd()
  self:OnEnd()
  return true
end

return SceneAttackAimSimple
