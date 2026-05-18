local UMG_LobbyMainInnerBlackScreen_C = _G.NRCPanelBase:Extend("UMG_LobbyMainInnerBlackScreen_C")

function UMG_LobbyMainInnerBlackScreen_C:OnActive(data)
  self.type = data.type
  self.position = data.position
  if self.position then
    self:SetPosition(self.position)
  end
  self:PlayTransitions(self.type)
  self.ResourceReady = true
end

function UMG_LobbyMainInnerBlackScreen_C:DelaySetMask()
  self:SetMask(self.loaded_class)
  self.loaded_class = nil
end

function UMG_LobbyMainInnerBlackScreen_C:OnDeactive()
end

function UMG_LobbyMainInnerBlackScreen_C:OnAddEventListener()
end

function UMG_LobbyMainInnerBlackScreen_C:PlayTransitions(type)
  Log.Debug("UMG_LobbyMainInnerBlackScreen_C:PlayTransitions", type)
  if type then
    self.type = type
  end
  _G.NRCAudioManager:PlaySound2DAuto(40008037, "UMG_LobbyMainInnerBlackScreen_C:PlayTransitions")
  _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainInnerBlackTransitionInBegin)
  local loopTime = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetIconLoopTime)
  self:PlayAnimation(self.Transition_In, 0, 1, 0, 1)
  self.UMG_LobbyMainInner_Icon:PlayAnimation(self.UMG_LobbyMainInner_Icon.IconTransition_In, 0, 1, 0, 1)
  self.UMG_LobbyMainInner_Icon:PlayAnimation(self.UMG_LobbyMainInner_Icon.Loop, loopTime, 1, 0, 1)
  self.UMG_LobbyMainInner_Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_LobbyMainInnerBlackScreen_C:OnAnimationFinished(Anim)
  if Anim == self.Transition_In then
    self.PanelReady = true
    Log.Debug("UMG_LobbyMainInnerBlackScreen_C:OnAnimationFinished Transition In")
    _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainInnerBlackTransitionFinish)
  elseif Anim == self.Transition_Out then
    Log.Debug("UMG_LobbyMainInnerBlackScreen_C:OnAnimationFinished Transition Out")
    self:DoClose()
  end
end

function UMG_LobbyMainInnerBlackScreen_C:PlayTransitionsOut()
  self:PlayAnimation(self.Transition_Out, 0, 1, 0, 1)
  self.UMG_LobbyMainInner_Icon:PlayAnimation(self.UMG_LobbyMainInner_Icon.IconTransition_Out, 0, 1, 0, 1)
end

return UMG_LobbyMainInnerBlackScreen_C
