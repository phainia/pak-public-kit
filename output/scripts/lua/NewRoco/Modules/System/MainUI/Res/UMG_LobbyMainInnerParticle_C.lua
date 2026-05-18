local UMG_LobbyMainInnerParticle_C = _G.NRCViewBase:Extend("UMG_LobbyMainInnerParticle_C")

function UMG_LobbyMainInnerParticle_C:OnActive()
  Log.Debug("UMG_LobbyMainInner_Particle_C:OnActive")
  _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainInnerIconLoaded, self)
end

function UMG_LobbyMainInnerParticle_C:OnDeactive()
end

function UMG_LobbyMainInnerParticle_C:OnAddEventListener()
end

function UMG_LobbyMainInnerParticle_C:PlayStart()
  self:StopAllAnimations()
  self:PlayAnimation(self.Start)
end

function UMG_LobbyMainInnerParticle_C:PlayExpand()
  self:StopAllAnimations()
  self:PlayAnimation(self.Start_2)
end

function UMG_LobbyMainInnerParticle_C:PlayCollapse()
  self:StopAllAnimations()
  self:PlayAnimation(self.Close)
end

function UMG_LobbyMainInnerParticle_C:PlayLoop()
  self:StopAllAnimations()
  self:PlayAnimation(self.Loop)
end

function UMG_LobbyMainInnerParticle_C:OnAnimationFinished(Anim)
  if Anim == self.Start or Anim == self.Start_2 then
    self:PlayAnimation(self.Loop)
  end
end

return UMG_LobbyMainInnerParticle_C
