local Base = _G.NRCPanelBase
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local UMG_GlobalBlack_C = _G.NRCPanelBase:Extend("UMG_GlobalBlack_C")

function UMG_GlobalBlack_C:OnConstruct()
  self.bIsBlack = true
end

function UMG_GlobalBlack_C:OnDestruct()
  self:CancelDelay()
end

function UMG_GlobalBlack_C:OnActive(caller, callback)
  if caller and callback then
    callback(caller)
  end
end

function UMG_GlobalBlack_C:SetInputEnable(enabled)
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    if self.bIsBlack then
      localPlayer.inputComponent:SetInputEnable(self, enabled, "GlobalBlack")
    else
      localPlayer.inputComponent:SetInputEnable(self, enabled, "GlobalWhite")
    end
    if not enabled then
      localPlayer:Stop()
    end
  end
end

function UMG_GlobalBlack_C:OnAnimationFinished(Animation)
  Log.Debug("UMG_GlobalBlack_C:OnAnimationFinished, ", self.panelName, Animation:GetName())
  if Animation == self.FadeIn then
    if self.PendingStartAnimCallback and self.PendingStartAnimCaller then
      self.PendingStartAnimCallback(self.PendingStartAnimCaller)
      self.PendingStartAnimCallback = nil
      self.PendingStartAnimCaller = nil
    end
    self:DoPlayPendingEndAnimation()
  end
  if Animation == self.FadeOut then
    if self.PendingEndAnimCallback and self.PendingEndAnimCaller then
      self.PendingEndAnimCallback(self.PendingEndAnimCaller)
      self.PendingEndAnimCallback = nil
      self.PendingEndAnimCaller = nil
    end
    self:Disable()
    self:DoPlayPendingStartAnimation()
  end
end

function UMG_GlobalBlack_C:PlayStartAnimation(caller, callback, bFade)
  Log.Debug("UMG_GlobalBlack_C:PlayStartAnimation, ", self.panelName)
  if self.PendingEndAnim then
    self.PendingEndAnim = false
  end
  if self:IsAnimationPlaying(self.FadeIn) then
    Log.DebugFormat("UMG_GlobalBlack_C:PlayStartAnimation, request start animation for %s when start animation is playing, ignore", self.panelName)
    if caller and callback then
      callback(caller)
    end
    return
  end
  self.PendingStartAnim = true
  self.PendingStartAnimCaller = caller
  self.PendingStartAnimCallback = callback
  self.bPendingStartAnimFade = bFade
  if self:IsAnimationPlaying(self.FadeOut) then
    Log.DebugFormat("UMG_GlobalBlack_C:PlayStartAnimation, request start animation for %s when end animation is playing, pending", self.panelName)
    return
  end
  self:DoPlayPendingStartAnimation()
end

function UMG_GlobalBlack_C:DoPlayPendingStartAnimation()
  if not self.PendingStartAnim then
    return
  end
  self.PendingStartAnim = false
  self:Enable()
  self:PlayAnimation(self.FadeIn, self.bPendingStartAnimFade and 0.0 or self.FadeIn:GetEndTime())
  Log.Debug("UMG_GlobalBlack_C:DoPlayPendingStartAnimation, ", self.panelName)
end

function UMG_GlobalBlack_C:PlayEndAnimation(caller, callback, bFade)
  Log.Debug("UMG_GlobalBlack_C:PlayEndAnimation, ", self.panelName)
  if self.PendingStartAnim then
    self.PendingStartAnim = false
  end
  if not self.module:IsPanelEnabled(self.panelName) then
    Log.DebugFormat("UMG_GlobalBlack_C:PlayEndAnimation, request end animation for %s when ui is disabled, ignore", self.panelName)
    if caller and callback then
      callback(caller)
    end
    return
  end
  if self:IsAnimationPlaying(self.FadeOut) then
    Log.DebugFormat("UMG_GlobalBlack_C:PlayEndAnimation, request end animation for %s when end animation is playing, ignore", self.panelName)
    if caller and callback then
      callback(caller)
    end
    return
  end
  self.PendingEndAnim = true
  self.PendingEndAnimCaller = caller
  self.PendingEndAnimCallback = callback
  self.bPendingEndAnimFade = bFade
  if self:IsAnimationPlaying(self.FadeIn) then
    Log.DebugFormat("UMG_GlobalBlack_C:PlayEndAnimation, request end animation for %s when start animation is playing, pending", self.panelName)
    return
  end
  self:DoPlayPendingEndAnimation()
end

function UMG_GlobalBlack_C:DoPlayPendingEndAnimation()
  if not self.PendingEndAnim then
    return
  end
  self.PendingEndAnim = false
  self:PlayAnimation(self.FadeOut, self.bPendingEndAnimFade and 0.0 or self.FadeOut:GetEndTime())
  Log.Debug("UMG_GlobalBlack_C:DoPlayPendingEndAnimation, ", self.panelName)
end

function UMG_GlobalBlack_C:OnDisable()
  Log.Debug("UMG_GlobalBlack_C:OnDisable, ", self.panelName)
  if self.bIsBlack then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ResumeTip, TipEnum.TipsPauseReason.GlobalBlack)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ResumeTip, TipEnum.TipsPauseReason.GlobalWhite)
  end
  self:SetInputEnable(true)
  Base.OnDisable(self)
end

function UMG_GlobalBlack_C:OnEnable()
  Log.Debug("UMG_GlobalBlack_C:OnEnable, ", self.panelName)
  Base.OnEnable(self)
  self:SetInputEnable(false)
  if self.bIsBlack then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.PauseTip, TipEnum.TipsPauseReason.GlobalBlack)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.PauseTip, TipEnum.TipsPauseReason.GlobalWhite)
  end
end

return UMG_GlobalBlack_C
