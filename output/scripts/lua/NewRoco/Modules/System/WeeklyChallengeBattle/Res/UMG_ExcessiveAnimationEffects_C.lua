local UMG_ExcessiveAnimationEffects_C = _G.NRCPanelBase:Extend("UMG_ExcessiveAnimationEffects_C")

function UMG_ExcessiveAnimationEffects_C:OnActive(caller, callback)
  Log.Info("UMG_ExcessiveAnimationEffects_C:OnActive \230\137\147\229\188\128ExcessiveAnimationEffects")
  self:StopAllAnimations()
  self:PlayAnimation(self.Cut_In)
  self.caller = caller
  self.callback = callback
  self.bCutOutScheduled = false
end

function UMG_ExcessiveAnimationEffects_C:OnDeactive()
  if self.delayHandle then
    _G.DelayManager:CancelDelayById(self.delayHandle)
    self.delayHandle = nil
  end
end

function UMG_ExcessiveAnimationEffects_C:OnAddEventListener()
end

function UMG_ExcessiveAnimationEffects_C:TryClose()
  Log.Info("UMG_ExcessiveAnimationEffects_C:TryClose \229\176\157\232\175\149\229\133\179\233\151\173ExcessiveAnimationEffects")
  if self:IsAnimationPlaying(self.Cut_In) then
    self.bShouldPlayCutOut = true
  elseif self:IsAnimationPlaying(self.Cut_Out) then
    Log.Info("UMG_ExcessiveAnimationEffects_C:Cut_Out\230\173\163\229\156\168\230\146\173\230\148\190\239\188\140\229\191\189\231\149\165TryClose")
  elseif self:IsAnimationPlaying(self.Camera_Out) then
    Log.Info("UMG_ExcessiveAnimationEffects_C:Camera_Out\230\173\163\229\156\168\230\146\173\230\148\190\239\188\140\229\191\189\231\149\165TryClose")
  elseif not self.bCutOutScheduled then
    self:PlayAnimation(self.Cut_Out)
  end
end

function UMG_ExcessiveAnimationEffects_C:OnAnimationFinished(Anim)
  if Anim == self.Cut_In then
    if self.callback and self.caller then
      self.callback(self.caller)
    elseif self.callback then
      local callback = self.callback
      callback()
    end
    Log.Info("UMG_ExcessiveAnimationEffects_C:Cut_In \229\174\140\230\136\144\239\188\140\229\187\182\232\191\1590.8\231\167\146\230\146\173\230\148\190Cut_Out")
    self.bCutOutScheduled = true
    self.delayHandle = _G.DelayManager:DelaySeconds(0.8, function()
      Log.Info("UMG_ExcessiveAnimationEffects_C:\229\187\182\232\191\159\231\187\147\230\157\159\239\188\140\230\146\173\230\148\190Cut_Out")
      self:PlayAnimation(self.Cut_Out)
    end)
  elseif Anim == self.Cut_Out then
    Log.Info("UMG_ExcessiveAnimationEffects_C:Cut_Out \229\174\140\230\136\144\239\188\140\228\187\1650.33\229\128\141\233\128\159\229\186\166\230\146\173\230\148\190Camera_Out")
    self:PlayAnimation(self.Camera_Out, 0, 1, UE4.EUMGSequencePlayMode.Forward, 0.33)
  elseif Anim == self.Camera_Out then
    Log.Info("UMG_ExcessiveAnimationEffects_C:Camera_Out \229\174\140\230\136\144\239\188\140\229\133\179\233\151\173ExcessiveAnimationEffects")
    if self.caller and self.caller.OnEffectCloseComplete then
      self.caller:OnEffectCloseComplete()
    end
    self:DoClose()
  end
end

return UMG_ExcessiveAnimationEffects_C
