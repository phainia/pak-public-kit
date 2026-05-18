local UMG_ShowMagicMessage_Fake_C = _G.NRCPanelBase:Extend("UMG_ShowMagicMessage_Fake_C")

function UMG_ShowMagicMessage_Fake_C:OnActive(fakeMessageId, action)
  if not fakeMessageId or not action then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_UI, "ShowMagicMessage_Fake")
  self.fakeMessageId = fakeMessageId
  self.action = action
  local fakeMessageConf = _G.DataConfigManager:GetMarkFakeMagicMessageConf(fakeMessageId, true)
  if fakeMessageConf then
    if fakeMessageConf.player_icon then
      local cardIconConf = _G.DataConfigManager:GetCardIconConf(fakeMessageConf.player_icon)
      if cardIconConf then
        local path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/"
        local avatarPath = cardIconConf.icon_resource_path
        avatarPath = string.format("%s%s.%s'", path, avatarPath, avatarPath)
        self.Image_Head:SetPath(avatarPath)
      end
    end
    if fakeMessageConf.player_name then
      self.Text_RoleName:SetText(fakeMessageConf.player_name)
    end
    if fakeMessageConf.message_content then
      self.Text_Message:SetText(fakeMessageConf.message_content)
    end
    if fakeMessageConf.like_count then
      self.Text_LikeCnt:SetText(fakeMessageConf.like_count)
    end
    if fakeMessageConf.hug_count then
      self.Text_HugCnt:SetText(fakeMessageConf.hug_count)
    end
    if fakeMessageConf.light_count then
      self.Text_InspireCnt:SetText(fakeMessageConf.light_count)
    end
  end
end

function UMG_ShowMagicMessage_Fake_C:OnConstruct()
  self:AddButtonListener(self.Btn_Close.btnClose, self.OnClickCloseBtn)
  self.Btn_Like.OnClicked:Add(self, self.OnClickAttitudeBtn)
  self.Btn_Hug.OnClicked:Add(self, self.OnClickAttitudeBtn)
  self.Btn_Inspire.OnClicked:Add(self, self.OnClickAttitudeBtn)
  self.Btn_Incomprehension.OnClicked:Add(self, self.OnClickAttitudeBtn)
end

function UMG_ShowMagicMessage_Fake_C:OnClickAttitudeBtn()
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.magic_message_attitude_fobbiden)
end

function UMG_ShowMagicMessage_Fake_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self.fakeMessageId = nil
    self.action:Finish(true, nil)
    self:DoClose()
  end
end

function UMG_ShowMagicMessage_Fake_C:OnClickCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_ShowMagicMessage_C:OnClickCloseBtn")
  self:PlayAnimation(self.Out)
end

function UMG_ShowMagicMessage_Fake_C:OnDestruct()
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_UI, "ShowMagicMessage_Fake")
end

return UMG_ShowMagicMessage_Fake_C
