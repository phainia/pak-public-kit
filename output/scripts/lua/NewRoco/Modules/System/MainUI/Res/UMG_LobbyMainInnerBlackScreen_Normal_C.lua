local UMG_LobbyMainInnerBlackScreen_Normal_C = _G.NRCPanelBase:Extend("UMG_LobbyMainInnerBlackScreen_Normal_C")

function UMG_LobbyMainInnerBlackScreen_Normal_C:OnActive(data)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  _G.NRCAudioManager:PlaySound2DAuto(40008045, "UMG_MagicManual_Task_Tads_C:SelectTaskType")
  self:PlayAnimation(self.Transition_In)
end

function UMG_LobbyMainInnerBlackScreen_Normal_C:DelaySetMask()
end

function UMG_LobbyMainInnerBlackScreen_Normal_C:OnDeactive()
end

function UMG_LobbyMainInnerBlackScreen_Normal_C:OnAddEventListener()
end

function UMG_LobbyMainInnerBlackScreen_Normal_C:OnAnimationFinished(Anim)
  if self.Transition_In == Anim then
    _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainInnerBlackTransitionFinish)
  elseif self.Transition_Out == Anim then
    self:DoClose()
  end
end

function UMG_LobbyMainInnerBlackScreen_Normal_C:PlayTransitionsOut()
  self:PlayAnimation(self.Transition_Out, 0, 1, 0, 1)
end

return UMG_LobbyMainInnerBlackScreen_Normal_C
