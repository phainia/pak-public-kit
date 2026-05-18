local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local UMG_Activity_QualificationFission_C = Base:Extend("UMG_Activity_QualificationFission_C")

function UMG_Activity_QualificationFission_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.BtnParticulars
  uiElements.timeRemaining = self.Text_TimeRemaining
  return uiElements
end

function UMG_Activity_QualificationFission_C:OnConstruct()
  Base.OnConstruct(self)
  self:InitActivity()
  self:AddButtonListener(self.Button_Open, self.GetCDKey)
  self:AddButtonListener(self.DuplicationBtn.btnLevelUp, self.DuplicationCDkey)
end

function UMG_Activity_QualificationFission_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveAllButtonListener()
end

function UMG_Activity_QualificationFission_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
end

function UMG_Activity_QualificationFission_C:OnDisable()
  Base.OnDisable(self)
end

function UMG_Activity_QualificationFission_C:InitActivity()
  if GlobalConfig.DebugOpenUI == true then
    self.CanvasPanel_155:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local activityInst = self.activityInst
  local activityConf = activityInst.activityConf
  self.Text_Title:SetText(activityConf.activity_name)
  self.Text_Describe:SetText(activityConf.prompt_text)
  local confs = _G.DataConfigManager:GetAllByName("ACTIVITY_CONDITION_REWARD_CONF")
  local datas = {}
  local ItemActivityData = {}
  ItemActivityData.config = confs[activityConf.base_id[1]]
  ItemActivityData.state = ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_NONE
  table.insert(datas, ItemActivityData)
  self.List:InitList(ActivityUtils.CreateActivityItemBaseDataForList(self, datas))
  local CDKeyActivityData = {}
  CDKeyActivityData.config = confs[activityConf.base_id[2]]
  CDKeyActivityData.state = ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_NONE
  table.insert(datas, CDKeyActivityData)
  self.Desc:SetText(CDKeyActivityData.config.part_name)
  self.RedDot:EnableAnimation()
  self.RedDot:SetupKey(ActivityEnum.RedPointKey.DetailReward, {
    self.activityInst:GetActivityId(),
    CDKeyActivityData.config.id
  })
  self.partDatas = datas
  if activityInst.svrActivityData then
    self:OnSvrUpdateActivityData(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP, activityInst.svrActivityData, true)
  end
end

function UMG_Activity_QualificationFission_C:OnSvrUpdateActivityData(_cmdId, _activityData, _initUpdate)
  if not _activityData.part_data then
    return
  end
  local bOverdue = true
  local cdKeyForOverdue
  for i, _data in ipairs(_activityData.part_data) do
    if _data.activity_part_id == self.partDatas[1].config.id then
      self.partDatas[1].state = _data.state
      self.partDatas[1].param = _data.param
      cdKeyForOverdue = _data.param and _data.param.param2
    elseif _data.activity_part_id == self.partDatas[2].config.id then
      self.partDatas[2].state = _data.state
      self.partDatas[2].param = _data.param
      bOverdue = false
    end
  end
  self:OnItemRefreshView(self.List:GetItemByIndex(0), 1, self.partDatas[1])
  self:RefreshCDKeyState(self.partDatas[2], bOverdue, cdKeyForOverdue)
end

function UMG_Activity_QualificationFission_C:RefreshCDKeyState(_data, bOverdue, cdKeyForOverdue)
  local AnimName = "In"
  self.bHasCDKey = false
  self.Button_Open:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.QualificationCode:SetText("")
  self.Endprompt:SetRenderOpacity(0)
  if string.IsNilOrEmpty(cdKeyForOverdue) then
    if not _data.param then
      Log.Error("UMG_Activity_QualificationFission_C:RefreshCDKeyState param is nil")
    end
    if not _data.param or _data.param.param1 <= 0 or bOverdue then
      self.NRCText_90:SetText("\233\130\128\232\175\183\229\144\141\233\162\157\229\183\178\229\143\145\230\148\190\229\174\140\230\175\149")
      self.Endprompt:SetRenderOpacity(1)
      AnimName = "In_end"
    else
      local state = _data.state
      if state == ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT then
        AnimName = "In_ready"
        self.Button_Open:SetVisibility(UE4.ESlateVisibility.Visible)
      elseif state == ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE then
        AnimName = "ready"
      end
    end
  else
    AnimName = "ready"
    self.QualificationCode:SetText(cdKeyForOverdue)
    self.bHasCDKey = true
  end
  self:PlayAnimationByName(AnimName)
end

function UMG_Activity_QualificationFission_C:OnItemUpdate(_itemInst, _index, _data)
  if _itemInst then
    if not _data.config then
      Log.Error("UMG_Activity_QualificationFission_C:OnItemUpdate No Config", _index)
      return
    end
    local rewardItem = _data.config.reward_group[1]
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(rewardItem.goods_id)
    _itemInst:SetDescribe(LuaText.Qualification_Splitting_Activity_Reward_Text)
    _itemInst.Icon:SetPath(BagItemConf.icon)
    _itemInst.Num:SetText("x" .. rewardItem.goods_count)
    ActivityUtils.SetRewardItemQuality(_itemInst.Quality, BagItemConf.item_quality)
    _itemInst:PlayRewardUnAvailableAnimation()
    _itemInst:SetupRedPoint(ActivityEnum.RedPointKey.DetailReward, {
      self.activityInst:GetActivityId(),
      _data.config.id
    })
  end
  self:OnItemRefreshView(_itemInst, _index, _data)
end

function UMG_Activity_QualificationFission_C:OnItemRefreshView(_itemInst, _index, _data)
  if _itemInst then
    local rewardState = _data.state
    if rewardState == ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_OPEN then
      _itemInst:SetBtnText(_G.DataConfigManager:GetLocalizationConf("task_in_progress").msg)
      _itemInst:SetRewardNumColor("929086ff")
      _itemInst:SetUnfinished(true)
      _itemInst:SetAlreadyReceived(false)
      _itemInst:SetParticleVisible(false)
      _itemInst:SetBtnVisible(true)
      _itemInst:SetBtnState(0)
      _itemInst:PlayRewardUnAvailableAnimation()
    elseif rewardState == ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT then
      _itemInst:SetBtnText(_G.DataConfigManager:GetLocalizationConf("TASK_TAKE").msg)
      _itemInst:SetRewardNumColor("f4eee1ff")
      _itemInst:SetUnfinished(false)
      _itemInst:SetAlreadyReceived(false)
      _itemInst:SetParticleVisible(true)
      _itemInst:SetBtnVisible(true)
      _itemInst:SetBtnState(2)
      _itemInst:PlayRewardAvailableAnimation()
    elseif rewardState == ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE then
      _itemInst:SetRewardNumColor("f4eee1ff")
      _itemInst:SetUnfinished(false)
      _itemInst:SetAlreadyReceived(true)
      _itemInst:SetParticleVisible(false)
      _itemInst:SetBtnVisible(false)
      _itemInst:SetBtnState(1)
      _itemInst:SetReminderSwitcher(_G.DataConfigManager:GetLocalizationConf("activity_checkin_tip3").msg)
      _itemInst:SetReminderVisible(true)
      _itemInst:PlayRewardReceivedAnimation()
    end
  end
end

function UMG_Activity_QualificationFission_C:OnItemSelected(_itemInst, _index, _data, _bSelected)
  if _bSelected then
    local rewardItem = _data.config.reward_group[1]
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, rewardItem.goods_id, rewardItem.goods_type)
  end
end

function UMG_Activity_QualificationFission_C:DoJoinActivityOrClaimReward(_itemInst, _index, _data)
  if _data.state == ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT then
    _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Activity_QualificationFission_C:JoinActivityOrClaimReward")
    self:OnZoneReceivePlayerActivityPartRewardReq(_data.config.id, _data.config)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1197, "UMG_Activity_QualificationFission_C:JoinActivityOrClaimReward")
  end
end

function UMG_Activity_QualificationFission_C:GetCDKey()
  _G.NRCAudioManager:PlaySound2DAuto(1333, "UMG_Activity_QualificationFission_C:GetCDKey")
  if self.partDatas[2].state == ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT then
    self:OnZoneReceivePlayerActivityPartRewardReq(self.partDatas[2].config.id)
  end
end

function UMG_Activity_QualificationFission_C:OnZoneReceivePlayerActivityPartRewardReq(activity_part_id, custom_data)
  local req = _G.ProtoMessage:newZoneReceivePlayerActivityPartRewardReq()
  req.activity_id = self.activityInst:GetActivityId()
  req.activity_part_id = activity_part_id
  if custom_data then
    ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_PART_REWARD_REQ, req, self, self.OnZoneReceivePlayerActivityPartRewardRsp, custom_data)
  else
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_PART_REWARD_REQ, req, self, self.OnZoneReceivePlayerActivityPartRewardRsp, true, true)
  end
end

function UMG_Activity_QualificationFission_C:OnZoneReceivePlayerActivityPartRewardRsp(rsp, reqMsg, custom_data)
  if 0 == rsp.ret_info.ret_code and custom_data then
    local rewardsList = {}
    local rewards = {}
    rewards.id = custom_data.reward_group[1].goods_id
    rewards.type = custom_data.reward_group[1].goods_type
    rewards.num = custom_data.reward_group[1].goods_count
    table.insert(rewardsList, rewards)
    _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, rewardsList, "")
  elseif rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_CREDIT_SCORE_NOT_ENOUGH then
    local Ctx = DialogContext()
    Ctx:SetTitle(LuaText.TIPS):SetMode(DialogContext.Mode.OK_CANCEL):SetCloseOnOK(true):SetCloseOnCancel(true):SetButtonText(LuaText.tips_dialog_butten_accept, LuaText.Credit_Score_Description4):SetContent(_G.DataConfigManager:GetLocalizationConf("Error_Code_2328").msg):SetCallback(self, function(this, result)
      if not result then
        _G.NRCSDKManager:OpenCreditScoreWebView()
      end
    end)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
  elseif rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_CDKEY_NOT_ENOUGH then
    local msg = _G.DataConfigManager:GetLocalizationConf("Error_Code_2358").msg
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg)
  end
  self.activityInst:ReqGetPlayerActivityData()
end

function UMG_Activity_QualificationFission_C:DuplicationCDkey()
  _G.NRCAudioManager:PlaySound2DAuto(41401019, "UMG_Activity_QualificationFission_C:DuplicationCDkey")
  if self.bHasCDKey then
    local CopyText = string.format("\232\181\132\230\160\188\231\160\129\227\128\144%s\227\128\145\239\188\140\231\153\187\229\189\149\233\161\181\233\157\162https://rocom.qq.com/act/a20241014cdk/web/index.html\239\188\140\229\156\168\233\161\181\233\157\162\228\184\138\232\190\147\229\133\165\232\181\132\230\160\188\231\160\129 \239\188\140\229\146\140\231\178\190\231\129\181\228\184\128\232\181\183\232\184\143\228\184\138\229\134\146\233\153\169\228\185\139\230\151\133\239\188\129", self.QualificationCode:GetText())
    if UE4.UNRCStatics.ClipboardCopy(CopyText) then
      local msg = _G.DataConfigManager:GetLocalizationConf("card_copy_UID_tips").msg
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg)
      ActivityUtils.SendTLogActivityAction(self.activityInst:GetActivityId(), self.partDatas[2].config.id, ActivityEnum.TLogActionType.Finish, "C0021")
    end
  end
end

return UMG_Activity_QualificationFission_C
