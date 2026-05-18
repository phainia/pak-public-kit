local SceneAttackBase = Class("SceneAttackBase")

function SceneAttackBase:Ctor()
  self.comp = nil
  self.owner = nil
  self.frameInterrupt = false
end

function SceneAttackBase:Init(inComp)
  self.comp = inComp
  self.owner = inComp.owner
  self.comp:LoadFinished(true)
end

function SceneAttackBase:Release()
end

function SceneAttackBase:OnStart(target, hitbox)
  return false
end

function SceneAttackBase:OnEnd()
  self.comp = nil
  self.owner = nil
  self.frameInterrupt = false
end

function SceneAttackBase:OnInterrupt()
  self:OnEnd()
end

return SceneAttackBase
