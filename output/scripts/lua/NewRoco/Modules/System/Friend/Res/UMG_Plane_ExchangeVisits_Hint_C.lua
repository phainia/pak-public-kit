local UMG_Plane_ExchangeVisits_Hint_C = _G.NRCPanelBase:Extend("UMG_Plane_ExchangeVisits_Hint_C")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local TeamBattleModuleEnum = require("NewRoco.Modules.System.TeamBattle.TeamBattleModuleEnum")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local UIUtils = require("NewRoco.Utils.UIUtils")
local EnmBlacklistByControlVisibility = {
  UMG_LeftBottomFunctionEntry = true,
  UMG_PhotoFrame = true,
  UMG_PhotoFrame_Open = true,
  TakePhotosMainUI = true,
  PopupPhotoMomentUI = true,
  SeasonBeginsTips = true
}

function UMG_Plane_ExchangeVisits_Hint_C:OnConstruct()
  self.bHadActive = false
end

function UMG_Plane_ExchangeVisits_Hint_C:OnActive(reason, data, number)
  self.reason = reason
  self.bHadActive = true
  self.PCKey:SetKeyVisibility(true)
  if reason ~= FriendEnum.ExchangeVisitsType.RequireCompetition and reason ~= FriendEnum.ExchangeVisitsType.RequireSwapEggs and SystemSettingModuleCmd then
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_MessageDetails")
    if "" ~= image then
      self.PCKey:SetImageMode(image)
    else
      self.PCKey:SetText(text)
    end
  end
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.VISIT_HINT_PANEL_OPEN)
  self:OnAddEventListener()
  self:PlayInAnim()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.PauseTip, TipEnum.TipsPauseReason.ExchangeVisitsHint)
  self.ModuleData = self.module:GetData("FriendModuleData")
  if reason == FriendEnum.ExchangeVisitsType.ApplyVisit then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_Hint_C:OnActive1")
    local NotifyList = _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdOperatorApplyVisitNotifyList, "Get")
    data = NotifyList[1]
    self.OpenVisit = false
  elseif reason == FriendEnum.ExchangeVisitsType.TeamBattle then
    _G.NRCAudioManager:PlaySound2DAuto(1075, "UMG_Plane_ExchangeVisits_Hint_C:OnActive2")
  end
  if reason == FriendEnum.ExchangeVisitsType.InviteVisit then
    _G.NRCAudioManager:PlaySound2DAuto(40008042, "UMG_Plane_ExchangeVisits_Hint_C:OnActive1")
  end
  if reason == FriendEnum.ExchangeVisitsType.EnterHome or reason == FriendEnum.ExchangeVisitsType.ReturnBigWorld then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_Hint_C:OnActive1")
  end
  self:SetPanelInfo(reason, data, number)
  self:BindInputAction()
end

function UMG_Plane_ExchangeVisits_Hint_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_MessageDetails")
  if mappingContext then
    mappingContext:BindAction("IA_MessageDetails")
  end
end

function UMG_Plane_ExchangeVisits_Hint_C:UnBindInputAction()
  self:RemoveInputMappingContext("IMC_MessageDetails")
end

function UMG_Plane_ExchangeVisits_Hint_C:OnDeactive()
  self:UnBindInputAction()
  self.bHadActive = false
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.VISIT_HINT_PANEL_CLOSE)
  if self.VisitTimer then
    _G.TimerManager:RemoveTimer(self.VisitTimer)
    self.VisitTimer = nil
  end
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnected)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_CONNECTED, self.OnConnected)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.OpenPanel, self.OnOpenPanel)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ResumeTip, TipEnum.TipsPauseReason.ExchangeVisitsHint)
end

function UMG_Plane_ExchangeVisits_Hint_C:OnAddEventListener()
  self:AddButtonListener(self.OpenVisitPanelBtn, self.OpenVisitPanel)
  self:RegisterEvent(self, FriendModuleEvent.NotifyInteractResult, self.OnNotifyInteractResult)
  _G.NRCEventCenter:RegisterEvent("UMG_Plane_ExchangeVisits_Hint_C", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnected)
  _G.NRCEventCenter:RegisterEvent("UMG_Plane_ExchangeVisits_Hint_C", self, _G.NRCGlobalEvent.ON_CONNECTED, self.OnConnected)
  _G.NRCEventCenter:RegisterEvent("UMG_Plane_ExchangeVisits_Hint_C", self, _G.NRCPanelEvent.OpenPanel, self.OnOpenPanel)
  _G.NRCEventCenter:RegisterEvent("UMG_Plane_ExchangeVisits_Hint_C", self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
end

function UMG_Plane_ExchangeVisits_Hint_C:SetPanelInfo(reason, data, number)
  if not data then
    return
  end
  if self.VisitTimer then
    if self.DelayHandle then
      _G.DelayManager:CancelDelayById(self.DelayHandle)
      self.DelayHandle = nil
    end
    self.DelayHandle = _G.DelayManager:DelaySeconds(math.max(0, self.ApplyTime - 1), function(self, Uin)
      self.DelayHandle = nil
      if not self.ModuleData then
        return
      end
      if self.Reason == FriendEnum.ExchangeVisitsType.ApplyVisit then
        self.ModuleData:RemoveApplyVisitNotifyToListByUin(Uin)
      end
    end, self, self.uiData.uin)
    _G.TimerManager:RemoveTimer(self.VisitTimer)
    self.VisitTimer = nil
  end
  self.Reason = reason
  self.uiData = data
  self.HeadItem2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Hint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local TimeCost = 0
  if data.apply_time then
    TimeCost = math.floor(_G.ZoneServer:GetServerTime() / 1000 - data.apply_time)
  end
  if reason == FriendEnum.ExchangeVisitsType.ApplyVisit then
    self.NRCSwitcher_73:SetActiveWidgetIndex(1)
    self.HeadItem2:SetInfo(self.uiData)
    local showName = UIUtils.GetShowNameByCheckFriendNote(self.uiData.uin, self.uiData.name, true)
    if number > 1 then
      self.RemarkName:SetText(string.format("%s%s", showName, _G.DataConfigManager:GetLocalizationConf("online_apply_multiplayer").msg))
      self.Number:SetText(tostring(number))
    else
      self.RemarkName:SetText(showName)
      self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    self.Hint:SetText(_G.DataConfigManager:GetLocalizationConf("online_apply_succeed_owner_tips").msg)
    self.RemarkName_2:SetText(_G.DataConfigManager:GetLocalizationConf("online_apply_abbr").msg)
    self:SetTimerInfo("online_apply_message_handle_time", "umg_plane_exchangevisits_hint_2", "UMG_Plane_ExchangeVisits_Hint_C.ApplyVisit" .. self.uiData.uin, TimeCost)
  elseif reason == FriendEnum.ExchangeVisitsType.TeamBattle then
    self.NRCSwitcher_73:SetActiveWidgetIndex(0)
    self.StartTimer = true
    self.HandleTime = 0
    self.HandleTimer = 0
    local visitorList = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
    visitorList = visitorList or {}
    if #visitorList < 1 then
      visitorList = _G.DataModelMgr.PlayerDataModel.visitList
    end
    self.Hint:SetText(LuaText.umg_plane_exchangevisits_hint_1)
    if visitorList and #visitorList > 0 then
      local ownerName = visitorList[1].name
      local ownerUin = visitorList[1].uin
      local showName = UIUtils.GetShowNameByCheckFriendNote(ownerUin, ownerName, true)
      self.RemarkName:SetText(showName)
      local ownerHeadInfo = {
        uin = visitorList[1].uin,
        level = visitorList[1].level,
        card_info = visitorList[1].card_info
      }
      self.HeadItem2:SetInfo(ownerHeadInfo)
    else
      Log.Error("\228\186\146\232\174\191\230\149\176\230\141\174\230\156\137\232\175\175\239\188\140\232\175\183\230\163\128\230\159\165visitorList\230\149\176\230\141\174")
    end
    local countDownTime = _G.DataConfigManager:GetGlobalConfigByKeyType("team_battle_teammate_wait_time", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).num
    self.HandleTime = countDownTime - (math.floor(_G.ZoneServer:GetServerTime() / 1000) - data.server_time)
    self.HandleTimer = countDownTime - (math.floor(_G.ZoneServer:GetServerTime() / 1000) - data.server_time)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif reason == FriendEnum.ExchangeVisitsType.InviteVisit then
    local showName = UIUtils.GetShowNameByCheckFriendNote(self.uiData.uin, self.uiData.name, true)
    self.NRCSwitcher_73:SetActiveWidgetIndex(0)
    self.RemarkName:SetText(showName)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.HeadItem2:SetInfo(self.uiData)
    self.Hint:SetText(_G.DataConfigManager:GetLocalizationConf("online_invite_owner_tips").msg)
    self:SetTimerInfo("online_apply_message_handle_time", "umg_plane_exchangevisits_hint_2", "UMG_Plane_ExchangeVisits_Hint_C.InviteVisit", TimeCost)
  elseif reason == FriendEnum.ExchangeVisitsType.RequireCompetition then
    self.NRCSwitcher_73:SetActiveWidgetIndex(2)
    self.Hint:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadItem2:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Competition_Guest:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.RemarkName:SetText(_G.DataConfigManager:GetLocalizationConf("spar_invite_owner_tips").msg)
    self:SetTimerInfo("invite_spar_show_time", "interact_invite_owner_show_time", "UMG_Plane_ExchangeVisits_Hint_C.RequireCompetition", TimeCost)
  elseif reason == FriendEnum.ExchangeVisitsType.ResponseCompetition then
    local showName = UIUtils.GetShowNameByCheckFriendNote(self.uiData.uin, self.uiData.name, true)
    self.NRCSwitcher_73:SetActiveWidgetIndex(2)
    self.RemarkName:SetText(showName)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Competition_Guest:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HeadItem2:SetInfo(self.uiData)
    self.Hint:SetText(_G.DataConfigManager:GetLocalizationConf("spar_invite_visitor_tips").msg)
    self.RemarkName_3:SetText(_G.DataConfigManager:GetLocalizationConf("spar_invite_abbr").msg)
    self:SetTimerInfo("invite_spar_show_time", "interact_invite_owner_show_time", "UMG_Plane_ExchangeVisits_Hint_C.ResponseCompetition", TimeCost)
  elseif reason == FriendEnum.ExchangeVisitsType.RequireSwapEggs then
    self.NRCSwitcher_73:SetActiveWidgetIndex(3)
    self.Hint:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadItem2:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.SwapEggs_Guest:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.HeadItem2:SetInfo(self.uiData)
    self.RemarkName:SetText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_invite_owner_tips").msg)
    self:SetTimerInfo("invite_spar_show_time", "interact_invite_owner_show_time", "UMG_Plane_ExchangeVisits_Hint_C.RequireSwapEggs", TimeCost)
  elseif reason == FriendEnum.ExchangeVisitsType.ResponseSwapEggs then
    local showName = UIUtils.GetShowNameByCheckFriendNote(self.uiData.uin, self.uiData.name, true)
    self.NRCSwitcher_73:SetActiveWidgetIndex(3)
    self.RemarkName:SetText(showName)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.SwapEggs_Guest:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HeadItem2:SetInfo(self.uiData)
    self.Hint:SetText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_invite_visitor_tips").msg)
    self.RemarkName_4:SetText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_invite_abbr").msg)
    self:SetTimerInfo("invite_spar_show_time", "interact_invite_owner_show_time", "UMG_Plane_ExchangeVisits_Hint_C.ResponseSwapEggs", TimeCost)
  elseif reason == FriendEnum.ExchangeVisitsType.DoubleRide then
    local showName = UIUtils.GetShowNameByCheckFriendNote(self.uiData.uin, self.uiData.name, true)
    self.NRCSwitcher_73:SetActiveWidgetIndex(4)
    self.RemarkName:SetText(showName)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.SwapEggs_Guest:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HeadItem2:SetInfo(self.uiData)
    self.Hint:SetText(_G.DataConfigManager:GetLocalizationConf("ride_invitation_popup_text").msg)
    self.RemarkName_4:SetText(_G.DataConfigManager:GetLocalizationConf("ride_tandem_popup_text").msg)
    self:SetTimerInfo("invite_spar_show_time", "interact_invite_owner_show_time", "UMG_Plane_ExchangeVisits_Hint_C.DoubleRide", TimeCost)
  elseif reason == FriendEnum.ExchangeVisitsType.EnterHome then
    self.NRCSwitcher_73:SetActiveWidgetIndex(5)
    self.HeadItem2:SetInfo({
      uin = self.uiData.uin,
      level = self.uiData.level,
      card_info = self.uiData.card_info
    })
    self.RemarkName_6:SetText(LuaText.invite_visit_home_visitor)
    self.RemarkName:SetText(self.uiData.name)
    self.Hint:SetText(LuaText.invite_visit_home_visitor_text)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Text_Class_1:SetText(LuaText.group_home_bottom_tips)
    self.Text_Class_1:SetVisibility(UE.UGameplayStatics.GetGameInstance(self):IsPCMode() and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.ProgressBar_53:SetPercent(100)
  elseif reason == FriendEnum.ExchangeVisitsType.ReturnBigWorld then
    self.NRCSwitcher_73:SetActiveWidgetIndex(5)
    self.HeadItem2:SetInfo({
      uin = self.uiData.uin,
      level = self.uiData.level,
      card_info = self.uiData.card_info
    })
    self.RemarkName_6:SetText(LuaText.invite_leave_home_visitor)
    self.RemarkName:SetText(self.uiData.name)
    self.Hint:SetText(LuaText.invite_invite_leave_home_visitor_text)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Text_Class_1:SetText(LuaText.group_home_bottom_tips)
    self.Text_Class_1:SetVisibility(UE.UGameplayStatics.GetGameInstance(self):IsPCMode() and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.ProgressBar_53:SetPercent(100)
  end
end

function UMG_Plane_ExchangeVisits_Hint_C:SetTimerInfo(CountDown, TimerText, TimerKey, TimeCost)
  local OnlineConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ONLINE_GLOBAL_CONFIG):GetAllDatas()
  for i = 1, #OnlineConf do
    if OnlineConf[i].key == CountDown then
      self.ApplyTime = OnlineConf[i].num - TimeCost
      self.TotalTime = OnlineConf[i].num
      break
    end
  end
  self.TimerText = _G.DataConfigManager:GetLocalizationConf(TimerText).msg
  self.Text_Class_1:SetText(string.format(self.TimerText, self.ApplyTime))
  self.VisitTimer = _G.TimerManager:CreateTimer(self, TimerKey, self.ApplyTime, self.OnTimerUpdate, self.OnTimerComplete, 1)
  self.ProgressBar_53:SetPercent(self.ApplyTime / self.TotalTime)
end

function UMG_Plane_ExchangeVisits_Hint_C:OnTimerUpdate()
  self.ApplyTime = self.ApplyTime - 1
  self.Text_Class_1:SetText(string.format(self.TimerText, self.ApplyTime))
  self.ProgressBar_53:SetPercent(self.ApplyTime / self.TotalTime)
  if self.Reason == FriendEnum.ExchangeVisitsType.ApplyVisit then
    local ApplyList = self.ModuleData:GetApplyVisitNotifyList()
    if #ApplyList > 1 then
      self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Number:SetText(tostring(#ApplyList))
    else
      self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

function UMG_Plane_ExchangeVisits_Hint_C:OnTimerComplete()
  if self.VisitTimer then
    _G.TimerManager:RemoveTimer(self.VisitTimer)
    self.VisitTimer = nil
  end
  if self.Reason == FriendEnum.ExchangeVisitsType.ApplyVisit then
    self.ModuleData:RemoveApplyVisitNotifyToListByUin(self.uiData.uin)
  end
  if self:IsVisible() then
    self:PlayAnimation(self.Out)
  else
    self:OnAnimationFinished(self.Out)
  end
end

function UMG_Plane_ExchangeVisits_Hint_C:OnTick(delaTime)
  if self.StartTimer then
    self.HandleTime = self.HandleTime - delaTime
    self.ProgressBar_53:SetPercent(self.HandleTime / self.HandleTimer)
    if self.HandleTime <= 0 then
      if self.Reason == FriendEnum.ExchangeVisitsType.TeamBattle then
      end
      self.StartTimer = false
      self:PlayAnimation(self.Out)
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdOperatorApplyVisitNotifyList, "Remove")
      self.HandleTime = self.HandleTimer
      return
    end
    self.Text_Class_1:SetText(string.format(LuaText.umg_plane_exchangevisits_hint_2, math.floor(self.HandleTime)))
  else
    self.HandleTime = self.HandleTimer
  end
end

function UMG_Plane_ExchangeVisits_Hint_C:OpenVisitPanel()
  if self.Reason == FriendEnum.ExchangeVisitsType.RequireCompetition or self.Reason == FriendEnum.ExchangeVisitsType.RequireSwapEggs then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_Plane_ExchangeVisits_Hint_C:OpenVisitPanel")
  self.OpenVisit = true
  self:PlayAnimation(self.Out)
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ReleaseAimState)
end

function UMG_Plane_ExchangeVisits_Hint_C:PlayInAnim()
  if self.reason == FriendEnum.ExchangeVisitsType.EnterHome or self.reason == FriendEnum.ExchangeVisitsType.ReturnBigWorld then
    self:PlayAnimation(self.In_home)
  else
    self:PlayAnimation(self.In)
  end
end

function UMG_Plane_ExchangeVisits_Hint_C:OnAnimationFinished(anim)
  if anim == self.Out then
    local NotifyList = _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdOperatorApplyVisitNotifyList, "Get")
    if self.OpenVisit then
      if self.Reason == FriendEnum.ExchangeVisitsType.ApplyVisit then
        _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenApplyVisitListInfo, NotifyList, FriendEnum.ExchangeVisitsType.ApplyVisit)
      elseif self.Reason == FriendEnum.ExchangeVisitsType.TeamBattle then
        _G.NRCModuleManager:DoCmd(_G.TeamBattleModuleCmd.QueryCurTeamState)
        _G.NRCModuleManager:DoCmd(TeamBattleModuleCmd.SetHintLeftTime, self.HandleTime)
      else
        _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenApplyVisitListInfo, {
          self.uiData
        }, self.Reason)
      end
      self:DoClose()
      return
    end
    if #NotifyList > 0 then
      self:SetPanelInfo(self.Reason, NotifyList[1], #NotifyList)
      _G.NRCAudioManager:PlaySound2DAuto(1335, "UMG_Plane_ExchangeVisits_Hint_C:OnActive")
      self:PlayInAnim()
    end
    if 0 == #NotifyList then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ResumeTip, TipEnum.TipsPauseReason.ExchangeVisitsHint)
      self:DoClose()
    end
  end
end

function UMG_Plane_ExchangeVisits_Hint_C:OnNotifyInteractResult(Notify)
  self:PlayAnimation(self.Out)
end

function UMG_Plane_ExchangeVisits_Hint_C:SetVisibleManual(bVisible)
  if bVisible then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Plane_ExchangeVisits_Hint_C:OnOpenPanel(PanelData)
  self._ctrlByPanel = false
  local Name = PanelData.panelName
  if EnmBlacklistByControlVisibility[Name] then
    return
  end
  self._ctrlByPanel = true
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Plane_ExchangeVisits_Hint_C:OnClosePanel(PanelData)
  self._ctrlByPanel = false
  local Name = PanelData.panelName
  if EnmBlacklistByControlVisibility[Name] then
    return
  end
  self._ctrlByPanel = true
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Plane_ExchangeVisits_Hint_C:OnConnected()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Plane_ExchangeVisits_Hint_C:OnDisconnected()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Plane_ExchangeVisits_Hint_C:IsInteractableNow()
  return self.bHadActive and self:IsVisible() and self.Reason and self.uiData
end

return UMG_Plane_ExchangeVisits_Hint_C
