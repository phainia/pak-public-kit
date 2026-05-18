local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local UMG_Activity_InvitationRegister_Item_C = Base:Extend("UMG_Activity_InvitationRegister_Item_C")

function UMG_Activity_InvitationRegister_Item_C:OnConstruct()
  self:AddButtonListener(self.ButtonClick, self.OnShareBtnClick)
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_SHARE_INFO_RSP, self.SetWaitToReward)
end

function UMG_Activity_InvitationRegister_Item_C:OnDestruct()
  self:RemoveButtonListener(self.ButtonClick)
  _G.ZoneServer:RemoveProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_SHARE_INFO_RSP, self.SetWaitToReward)
end

function UMG_Activity_InvitationRegister_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.Icon:SetPath(_data.reward_icon)
  self.Icon_2:SetPath(_data.reward_icon)
  self.QuantityText:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("report_ratio").msg, _data.reward_num))
  self.Desc:SetText(_data.task_name)
  local textStr
  if 1 == index then
    self.QuantityText_1:SetText(_data.get_num)
    self.Switcher:SetActiveWidgetIndex(0)
    textStr = _G.DataConfigManager:GetLocalizationConf("activity_invite_freind_getreward_num").msg
  elseif 2 == index then
    self.QuantityText_1:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_task").msg, _data.get_num, _data.max_reward_num))
    if _data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_OPEN then
      self.Switcher:SetActiveWidgetIndex(4)
    elseif _data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT then
      self.Switcher:SetActiveWidgetIndex(1)
    elseif _data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE then
      self.Switcher:SetActiveWidgetIndex(3)
    else
      Log.Error("reward_state is none!")
    end
    textStr = _G.DataConfigManager:GetLocalizationConf("activity_invite_freind_getreward_limit").msg
    self.redPointNew:SetupKey(215, _data.activity_id)
  elseif 3 == index then
    self.QuantityText_1:SetText(_data.get_num)
    self.Switcher:SetActiveWidgetIndex(2)
    textStr = _G.DataConfigManager:GetLocalizationConf("activity_invite_freind_getreward_num").msg
  end
  self.NRCText_31:SetText(textStr)
end

function UMG_Activity_InvitationRegister_Item_C:OnShareBtnClick()
  if 2 == self.index then
    if self.data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_OPEN then
      self:ShareH5()
    elseif self.data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT then
      local req = _G.ProtoMessage:newZoneReceivePlayerActivityPartRewardReq()
      req.activity_id = self.data.activity_id
      req.activity_part_id = self.data.base_id
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_PART_REWARD_REQ, req, self, self.GetDailyReward)
    elseif self.data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE then
      if self.data.get_num == self.data.max_reward_num then
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("Activity_Invite_friend_reward_limit_tips").msg)
      else
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("Activity_Invite_friend_reward_alreadyget_tips").msg)
      end
    end
  else
    self:ShareH5()
  end
  self:PlayAnimation(self.Click)
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_InvitationRegister_Item_C:OnShareBtnClick")
end

function UMG_Activity_InvitationRegister_Item_C:ShareH5()
  local playerInfoData = _G.NRCModuleManager:DoCmd(_G.OnlineModuleCmd.GetUserAccountInfo)
  if playerInfoData.loginChannel == nil then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("Activity_Invite_friend_Pcfail_tips").msg)
    return
  end
  if RocoEnv.PLATFORM_WINDOWS then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("Activity_Invite_friend_Pcfail_tips").msg)
  elseif RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_IOS or RocoEnv.PLATFORM_OPENHARMONY then
    local share_part_conf = _G.DataConfigManager:GetSharePartConf(self.data.share_part_conf_id)
    local uin = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info.uin
    local userName = LoginUtils.GetLoginData():GetUserName()
    if playerInfoData.loginChannelType == Enum.CliLoginChannel.CLC_WX then
      _G.NRCModuleManager:DoCmd(_G.ShareModuleCmd.ShareH5WechatAndQQ, share_part_conf.wechat_applet_title, share_part_conf.wechat_applet_des, tostring(uin), share_part_conf.wechat_applet_img, share_part_conf.wechat_applet_first_page, true)
      if 2 == self.index then
        self:OnShareComplete()
      end
    elseif playerInfoData.loginChannelType == Enum.CliLoginChannel.CLC_QQ then
      _G.NRCModuleManager:DoCmd(_G.ShareModuleCmd.ShareH5WechatAndQQ, share_part_conf.wechat_applet_title, share_part_conf.wechat_applet_des, tostring(uin), share_part_conf.wechat_applet_img, share_part_conf.wechat_applet_first_page, false)
      if 2 == self.index then
        self:OnShareComplete()
      end
    end
  end
end

function UMG_Activity_InvitationRegister_Item_C:OnShareComplete()
  local req = _G.ProtoMessage:newZonePlayerShareInfoReq()
  local share_part_id = self.data.share_part_conf_id
  local share_base_id = _G.DataConfigManager:GetSharePartConf(share_part_id).share_button_type
  req.share_base_id = share_base_id
  req.share_part_id = share_part_id
  req.opt = 1
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_SHARE_INFO_REQ, req)
end

function UMG_Activity_InvitationRegister_Item_C:SetWaitToReward(rsp)
  if 0 == rsp.ret_info.ret_code and self.data.get_num < self.data.max_reward_num then
    self.Switcher:SetActiveWidgetIndex(1)
    self.data.reward_state = _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT
  end
end

function UMG_Activity_InvitationRegister_Item_C:GetDailyReward(rsp)
  if 0 == rsp.ret_info.ret_code then
    local popupInitData = {}
    local rewardData = _G.DataConfigManager:GetActivityInviteRegisterConf(self.data.base_id).reward_group
    for _, v in ipairs(rewardData) do
      local popupData = {}
      popupData.id = v.goods_id
      popupData.num = v.goods_count
      popupData.type = v.goods_type
      table.insert(popupInitData, popupData)
    end
    _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNPCShopItemRewardsPanel, popupInitData)
    self.Switcher:SetActiveWidgetIndex(3)
    self:PlayAnimation(self.Get)
    self.data.get_num = self.data.get_num + self.data.reward_num
    self.data.reward_state = _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE
    self.QuantityText_1:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_task").msg, self.data.get_num, self.data.max_reward_num))
  end
end

function UMG_Activity_InvitationRegister_Item_C:OnItemSelected(_bSelected)
end

function UMG_Activity_InvitationRegister_Item_C:OnDeactive()
end

return UMG_Activity_InvitationRegister_Item_C
