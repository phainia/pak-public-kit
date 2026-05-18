local UMG_TalkingBboutBubbles_Emoji_C = _G.NRCPanelBase:Extend("UMG_TalkingBboutBubbles_Emoji_C")

function UMG_TalkingBboutBubbles_Emoji_C:OnConstruct()
  if 0 == self:GetSerialNumber() then
    self:PlayAnimation(self.Dialogbox_in)
  end
  self:OnAddEventListener()
end

function UMG_TalkingBboutBubbles_Emoji_C:OnAddEventListener()
  self:AddButtonListener(self.ClickButton, self.OnClickClickButton)
end

function UMG_TalkingBboutBubbles_Emoji_C:OnClickClickButton()
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OnCmdSetIsPanelMoveCamera, true)
  NRCModuleManager:DoCmd(MainUIModuleCmd.TryOpenChatPanel, true)
end

return UMG_TalkingBboutBubbles_Emoji_C
