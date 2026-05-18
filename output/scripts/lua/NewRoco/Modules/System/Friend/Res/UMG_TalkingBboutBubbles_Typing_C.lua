local UMG_TalkingBboutBubbles_Typing_C = _G.NRCPanelBase:Extend("UMG_TalkingBboutBubbles_Typing_C")

function UMG_TalkingBboutBubbles_Typing_C:OnConstruct()
  if 0 == self:GetSerialNumber() then
    self:PlayAnimation(self.Dialogbox_in)
  end
  self:OnAddEventListener()
end

function UMG_TalkingBboutBubbles_Typing_C:OnAddEventListener()
  self.ClickButton.OnClicked:Add(self, self.OnClickClickButton)
end

function UMG_TalkingBboutBubbles_Typing_C:OnClickClickButton()
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OnCmdSetIsPanelMoveCamera, true)
  NRCModuleManager:DoCmd(MainUIModuleCmd.TryOpenChatPanel, true)
end

function UMG_TalkingBboutBubbles_Typing_C:OnAnimationFinished(anim)
  if anim == self.Dialogbox_in then
    self:PlayAnimation(self.Inputting_loop, 0, 9999)
  end
end

return UMG_TalkingBboutBubbles_Typing_C
