local UMG_LobbyMainInner_Particle_C = _G.NRCPanelBase:Extend("UMG_LobbyMainInner_Particle_C")

function UMG_LobbyMainInner_Particle_C:OnActive()
end

function UMG_LobbyMainInner_Particle_C:OnDeactive()
end

function UMG_LobbyMainInner_Particle_C:OnAddEventListener()
end

function UMG_LobbyMainInner_Particle_C:RandomPlayParticle()
  self:StopAllAnimations()
  self:PlayAnimation(self.Loop, math.random(0, 6))
end

function UMG_LobbyMainInner_Particle_C:OnAnimationFinished(Animation)
  if self.Loop == Animation then
    self:PlayAnimation(self.Loop)
  end
end

return UMG_LobbyMainInner_Particle_C
