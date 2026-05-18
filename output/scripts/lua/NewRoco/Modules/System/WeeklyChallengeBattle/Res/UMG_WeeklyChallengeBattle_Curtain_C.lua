local UMG_WeeklyChallengeBattle_Curtain_C = _G.NRCPanelBase:Extend("UMG_WeeklyChallengeBattle_Curtain_C")
local TIMEOUT_DURATION = 5

function UMG_WeeklyChallengeBattle_Curtain_C:CancelDelay(handleName)
  if self[handleName] then
    _G.DelayManager:CancelDelayById(self[handleName])
    self[handleName] = nil
  end
end

function UMG_WeeklyChallengeBattle_Curtain_C:OnActive(caller, callback)
  Log.Info("UMG_WeeklyChallengeBattle_Curtain_C:TryClose \230\137\147\229\188\128Curtain")
  _G.NRCAudioManager:PlaySound2DAuto(40130001, "UMG_WeeklyChallengeBattle_Curtain_C:OnActive")
  self:StopAllAnimations()
  self:PlayAnimation(self.Close)
  self.caller = caller
  self.callback = callback
  self:CancelDelay("closeTimeoutHandle")
  self.closeTimeoutHandle = _G.DelayManager:DelaySeconds(TIMEOUT_DURATION, self.OnCloseAnimTimeout, self)
end

function UMG_WeeklyChallengeBattle_Curtain_C:OnCloseAnimTimeout()
  Log.Warning("UMG_WeeklyChallengeBattle_Curtain_C: Close animation timeout! Force executing callback.")
  self.closeTimeoutHandle = nil
  self:StopAllAnimations()
  if self.callback and self.caller then
    self.callback(self.caller)
  elseif self.callback then
    local callback = self.callback
    callback()
  end
  if self.bShouldPlayOpen then
    self:PlayAnimation(self.Open)
    self:CancelDelay("openTimeoutHandle")
    self.openTimeoutHandle = _G.DelayManager:DelaySeconds(TIMEOUT_DURATION, self.OnOpenAnimTimeout, self)
  end
end

function UMG_WeeklyChallengeBattle_Curtain_C:OnDeactive()
  self:CancelDelay("closeTimeoutHandle")
  self:CancelDelay("openTimeoutHandle")
end

function UMG_WeeklyChallengeBattle_Curtain_C:OnAddEventListener()
end

function UMG_WeeklyChallengeBattle_Curtain_C:TryClose()
  Log.Info("UMG_WeeklyChallengeBattle_Curtain_C:TryClose \229\176\157\232\175\149\229\133\179\233\151\173Curtain")
  if self:IsAnimationPlaying(self.Close) then
    self.bShouldPlayOpen = true
  else
    self:PlayAnimation(self.Open)
    self:CancelDelay("openTimeoutHandle")
    self.openTimeoutHandle = _G.DelayManager:DelaySeconds(TIMEOUT_DURATION, self.OnOpenAnimTimeout, self)
  end
end

function UMG_WeeklyChallengeBattle_Curtain_C:OnOpenAnimTimeout()
  Log.Warning("UMG_WeeklyChallengeBattle_Curtain_C: Open animation timeout! Force closing panel.")
  self.openTimeoutHandle = nil
  self:StopAllAnimations()
  if self.caller and self.caller.OnCurtainCloseComplete then
    self.caller:OnCurtainCloseComplete()
  end
  self:DoClose()
end

function UMG_WeeklyChallengeBattle_Curtain_C:OnAnimationFinished(Anim)
  if Anim == self.Close then
    self:CancelDelay("closeTimeoutHandle")
    if self.callback and self.caller then
      self.callback(self.caller)
    elseif self.callback then
      local callback = self.callback
      callback()
    end
    if self.bShouldPlayOpen then
      self:PlayAnimation(self.Open)
      self:CancelDelay("openTimeoutHandle")
      self.openTimeoutHandle = _G.DelayManager:DelaySeconds(TIMEOUT_DURATION, self.OnOpenAnimTimeout, self)
    end
  elseif Anim == self.Open then
    self:CancelDelay("openTimeoutHandle")
    Log.Info("UMG_WeeklyChallengeBattle_Curtain_C:TryClose \229\133\179\233\151\173Curtain")
    if self.caller and self.caller.OnCurtainCloseComplete then
      self.caller:OnCurtainCloseComplete()
    end
    self:DoClose()
  end
end

return UMG_WeeklyChallengeBattle_Curtain_C
