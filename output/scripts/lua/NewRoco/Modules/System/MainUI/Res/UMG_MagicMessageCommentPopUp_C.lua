local UMG_MagicMessageCommentPopUp_C = _G.NRCPanelBase:Extend("UMG_MagicMessageCommentPopUp_C")

function UMG_MagicMessageCommentPopUp_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self:OnAddEventListener()
end

function UMG_MagicMessageCommentPopUp_C:OnDestruct()
end

function UMG_MagicMessageCommentPopUp_C:OnActive(feedInfo)
  self.feedInfo = feedInfo
  self:PlayAnimation(self.appeat)
  self:SetCommonPopUpInfo(self.PopUp3)
  local Conf = _G.DataConfigManager:GetGlobalConfig("magic_message_word_count")
  self.maxWordCount = Conf.num
end

function UMG_MagicMessageCommentPopUp_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_MagicMessageCommentPopUp_C:OnAddEventListener()
  self.InputBox_Content.OnTextChanged:Add(self, self.OnTextChanged)
end

function UMG_MagicMessageCommentPopUp_C:OnRemoveEventListener()
  self.InputBox_Content.OnTextChanged:Remove(self, self.OnTextChanged)
end

function UMG_MagicMessageCommentPopUp_C:OnPcClose()
  self:PlayAnimation(self.vanish)
end

function UMG_MagicMessageCommentPopUp_C:OnTextChanged()
  local content = self.InputBox_Content:GetText()
  local transCount = self.maxWordCount / 3 * 2
  local count = string.StringGetTotalNum(content)
  Log.Info("UMG_MagicMessageCommentPopUp_C:OnTextChanged GetText count", content, count)
  if RocoEnv.PLATFORM ~= "PLATFORM_WINDOWS" then
    if count > 40 then
      Log.Info("OnTextChanged SetAutoSize true")
      self.InputBox_Content.Slot:SetAutoSize(true)
    else
      Log.Info("OnTextChanged SetAutoSize false", content)
      self.InputBox_Content.Slot:SetAutoSize(false)
    end
  end
  if transCount < count then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_18303)
    local subStr = string.GetSubStr(content, transCount)
    Log.Info("OnTextChanged \232\182\133\232\191\13530\228\184\170\229\173\151\239\188\140\232\163\129\229\137\170\228\184\186", subStr)
    self.InputBox_Content:SetText(subStr)
  end
end

function UMG_MagicMessageCommentPopUp_C:SetCommonPopUpInfo(PopUp)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnBtnCancelClick
  CommonPopUpData.Btn_RightHandler = self.OnBtnOkClick
  CommonPopUpData.ClosePanelHandler = self.OnBtnCloseClick
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_MagicMessageCommentPopUp_C:OnBtnOkClick()
  if self.bReq then
    return
  end
  local content = self.InputBox_Content:GetText()
  if "" == content then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_18300)
    return
  end
  self.bReq = true
  local reqMsg = _G.ProtoMessage:newZoneFeedMagicFeedbackReq()
  reqMsg.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  reqMsg.feed_id = self.feedInfo.feed_id
  reqMsg.comment_content = content
  reqMsg.category = self.feedInfo.category
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_FEED_MAGIC_FEEDBACK_REQ, reqMsg, self, self.OnFeedBackProcess, nil, false)
  self:DelaySeconds(2, function()
    self.bReq = false
  end)
end

function UMG_MagicMessageCommentPopUp_C:OnFeedBackProcess(rsp)
  if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_COMMON_BANNED and rsp.ban_info then
    local ban_time = os.date("%Y-%m-%d %H:%M:%S", rsp.ban_info.ban_time)
    local banConfig = _G.DataConfigManager:GetGlobalConfig("banned_notice")
    local uin = rsp.ban_info.uin
    local contenText = string.format(banConfig.str, uin, ban_time, rsp.ban_info.ban_reason)
    local dialogContext = DialogContext()
    dialogContext:SetTitle(LuaText.TIPS):SetContent(contenText):SetMode(DialogContext.Mode.OK):SetCloseOnOK(true)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, dialogContext)
    return
  end
  if rsp.ret_info.ret_code == 18306 then
    if self.feedInfo.category == ProtoEnum.MarkGameplay.MK_MAGIC_VIDEO then
      _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.StopMagicReplay)
    end
    _G.NRCModuleManager:DoCmd(_G.MagicMessageModuleCmd.DeleteNpcByGridAndFeedId, self.feedInfo.grid_id, self.feedInfo.feed_id, self.feedInfo.category)
    local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
    local showMessagePanel = mainUIModule:GetPanel("ShowMagicMessage")
    if showMessagePanel then
      if 0 ~= self.feedInfo.music_id and -1 ~= showMessagePanel.SoundSession then
        showMessagePanel:DoStopMusic()
      end
      showMessagePanel:CloseUI()
    end
    return
  end
  if 0 == rsp.ret_info.ret_code then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.mark_magic_message_comment_success)
    _G.NRCModuleManager:DoCmd(_G.MagicMessageModuleCmd.UpdateNpcByGridAndFeedId, self.feedInfo.grid_id, self.feedInfo.feed_id, rsp.feed)
    local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
    local showMessagePanel = mainUIModule:GetPanel("ShowMagicMessage")
    if showMessagePanel then
      showMessagePanel:OnFeedBackSuccess(rsp)
    end
    self:PlayAnimation(self.vanish)
  end
end

function UMG_MagicMessageCommentPopUp_C:OnBtnCancelClick()
  self:PlayAnimation(self.vanish)
end

function UMG_MagicMessageCommentPopUp_C:OnBtnCloseClick()
  self:PlayAnimation(self.vanish)
end

function UMG_MagicMessageCommentPopUp_C:OnAnimationFinished(Anim)
  if self.vanish == Anim then
    self:DoClose()
  end
end

return UMG_MagicMessageCommentPopUp_C
