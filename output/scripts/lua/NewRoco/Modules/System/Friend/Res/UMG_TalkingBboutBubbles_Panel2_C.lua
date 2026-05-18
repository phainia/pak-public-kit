local UMG_TalkingBboutBubbles_Panel2_C = _G.NRCPanelBase:Extend("UMG_TalkingBboutBubbles_Panel2_C")

function UMG_TalkingBboutBubbles_Panel2_C:OnActive()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Panel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  Log.Debug("UMG_TalkingBboutBubbles_Panel2_C:OnActive")
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OnCmdChangeChatBubblesParent, self.Panel)
end

function UMG_TalkingBboutBubbles_Panel2_C:OnDeactive()
  if not self._bDeactiving then
    Log.Debug("UMG_TalkingBboutBubbles_Panel2_C:OnDeactive")
    self._bDeactiving = true
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OnCmdHideChatBubbles, self.Panel)
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.UseMainUIChatBubbleParent)
    self._bDeactiving = false
  end
end

function UMG_TalkingBboutBubbles_Panel2_C:OnTick(DeltaTime)
  local FriendModule = _G.NRCModuleManager:GetModule("FriendModule")
  if FriendModule then
    FriendModule:UpdateChatBubbles(DeltaTime)
  end
end

return UMG_TalkingBboutBubbles_Panel2_C
