local UMG_Activity_AbuReward_C = _G.NRCPanelBase:Extend("UMG_Activity_AbuReward_C")
local LotteryResultID = {LotterySuccessed = 10001, LotteryFailed = 10002}

function UMG_Activity_AbuReward_C:OnActive(LotteryData)
  self.LotteryData = LotteryData
  self:RefreshUI()
  self:PlayAnimation(self.AwardWinning_In)
end

function UMG_Activity_AbuReward_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Activity_AbuReward_C:OnDestruct()
  self:RemoveAllButtonListener()
end

function UMG_Activity_AbuReward_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose.btnClose, self.OnClickCloseBtn)
  self:AddButtonListener(self.Btn_Notarize.btnLevelUp, self.OnClickCloseBtn)
end

function UMG_Activity_AbuReward_C:RefreshUI()
  local data = self.LotteryData
  if data then
    local lotteryCfg = _G.DataConfigManager:GetLotteryResultPageConf(data.lottery_result)
    if lotteryCfg then
      local bSuccessed = data.lottery_result == LotteryResultID.LotterySuccessed
      local soundID = 1043
      if bSuccessed then
        self.NRCSwitcher_12:SetActiveWidgetIndex(1)
        self.TitleText_1:SetText(lotteryCfg.part_name)
        self.Text_Describe_1:SetText(lotteryCfg.part_desc)
        self.NRCImage_173:SetPath(lotteryCfg.umg_path)
        self.ParticleSystemWidget2_138:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
        soundID = 1231
      else
        self.NRCSwitcher_12:SetActiveWidgetIndex(0)
        self.TitleText:SetText(lotteryCfg.part_name)
        self.Text_Describe:SetText(lotteryCfg.part_desc)
        self.ParticleSystemWidget2_138:SetVisibility(UE4.ESlateVisibility.Collapsed)
        soundID = 1043
      end
      _G.NRCAudioManager:PlaySound2DAuto(soundID, "UMG_Activity_AbuBadge_C:OnTraceBtnClick")
    else
      Log.Error("LotteryResultPageConf is nil:", data.lottery_result)
    end
  end
end

function UMG_Activity_AbuReward_C:OnClickCloseBtn()
  local req = _G.ProtoMessage:newZoneConfirmLotteryRewardReq()
  req.lottery_item = self.LotteryData.lottery_item
  req.trans_id = self.LotteryData.trans_id
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CONFIRM_LOTTERY_REWARD_REQ, req)
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_Activity_AbuBadge_C:OnClickCloseBtn")
  self:LoadAnimation(2)
end

function UMG_Activity_AbuReward_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:OnClose()
    _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OnCmdOpenLotteryResultPanel)
  end
end

return UMG_Activity_AbuReward_C
