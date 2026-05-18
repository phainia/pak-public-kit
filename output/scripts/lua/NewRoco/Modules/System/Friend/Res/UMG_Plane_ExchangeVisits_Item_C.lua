local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_Plane_ExchangeVisits_Item_C = Base:Extend("UMG_Plane_ExchangeVisits_Item_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")

function UMG_Plane_ExchangeVisits_Item_C:Construct()
  Base.Construct(self)
  self.Module = NRCModuleManager:GetModule("FriendModule")
  self.ModuleData = self.Module:GetData("FriendModuleData")
  self.WorldLevelWidget = {
    self.NRCImage_10,
    self.NRCImage_11,
    self.NRCImage_12,
    self.NRCImage_13,
    self.NRCImage_14,
    self.NRCImage_15
  }
end

function UMG_Plane_ExchangeVisits_Item_C:DestroyItem()
  self.Module:UnRegisterEvent(self, FriendModuleEvent.NotifyInteractResult)
  if self.VisitTimer then
    _G.TimerManager:RemoveTimer(self.VisitTimer)
    self.VisitTimer = nil
  end
end

function UMG_Plane_ExchangeVisits_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:SetWorldLevelInfo()
  self.HeadItem:SetInfo(self.data)
  UIUtils.SetTextPlayerNameByCheckFriendNote(self.RemarkName, self.data.uin, self.data.name, "#625F5DFF")
  self:OnAddEventListener()
  self.Switcher:SetActiveWidgetIndex(0)
  local Default = 15
  local CountDown
  if self.data.Type == FriendEnum.ExchangeVisitsType.ApplyVisit then
    CountDown = "online_apply_message_handle_time"
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.InviteVisit then
    CountDown = "online_apply_message_handle_time"
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ResponseCompetition then
    CountDown = "invite_spar_show_time"
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ResponseSwapEggs then
    CountDown = "invite_spar_show_time"
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.DoubleRide then
    CountDown = "invite_spar_show_time"
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.EnterHome then
    Default = nil
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ReturnBigWorld then
    Default = nil
  end
  self.ApplyTime = Default
  local OnlineConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ONLINE_GLOBAL_CONFIG):GetAllDatas()
  for i = 1, #OnlineConf do
    if OnlineConf[i].key == CountDown then
      if _data.apply_time then
        Log.Trace(_G.ZoneServer:GetServerTime() / 1000, _data.apply_time, "Plane_ExchangeVisits_Item_ApplyTime")
        self.ApplyTime = OnlineConf[i].num - math.floor(_G.ZoneServer:GetServerTime() / 1000 - _data.apply_time + 0.5)
      end
      self.TotalTime = OnlineConf[i].num
      break
    end
  end
  if self.ApplyTime then
    self.Text_Class_1:SetText(self.ApplyTime .. LuaText.umg_plane_exchangevisits_item_1)
    self.VisitTimer = _G.TimerManager:CreateTimer(self, "UMG_Plane_ExchangeVisits_Item_C.VisitTimer" .. self.data.uin, self.ApplyTime, self.OnTimerUpdate, self.OnTimerComplete, 1)
    self.Time:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Plane_ExchangeVisits_Item_C:OnTimerUpdate()
  self.ApplyTime = self.ApplyTime - 1
  self.Text_Class_1:SetText(self.ApplyTime .. LuaText.umg_plane_exchangevisits_item_1)
end

function UMG_Plane_ExchangeVisits_Item_C:OnTimerComplete(NoTips)
  if self.VisitTimer then
    _G.TimerManager:RemoveTimer(self.VisitTimer)
    self.VisitTimer = nil
  end
  if not NoTips then
  end
  self.ApplyTime = nil
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ModuleData:RemoveApplyVisitNotifyToListByUin(self.data.uin)
  self.data.Parent:IsHasItem()
end

function UMG_Plane_ExchangeVisits_Item_C:SetWorldLevelInfo()
  local WorldLevel = self.data.world_level
  if WorldLevel then
    for i = 1, #self.WorldLevelWidget do
      if i <= WorldLevel then
        self.WorldLevelWidget[i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.WorldLevelWidget[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_Plane_ExchangeVisits_Item_C:OnAddEventListener()
  self.Btn_Consent2.OnClicked:Add(self, self.OnApply)
  self.Btn_TurnDown2.OnClicked:Add(self, self.OnCancel)
end

function UMG_Plane_ExchangeVisits_Item_C:OnApply()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Plane_ExchangeVisits_Item_C:OnApply")
  if self.data.Type == FriendEnum.ExchangeVisitsType.ApplyVisit then
    if _G.NRCModuleManager:DoCmd(FriendModuleCmd.GetWaitVisitReplyRsp) then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.online_visitor_apply_list_cd)
      return
    end
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.Visiting, true)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.InviteVisit then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.InviteVisiting, true)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ResponseCompetition then
    BattleProfiler:CheckPoint(BattleProfilerCheckPoint.PVPFriendResponseCompetition)
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.Fighting, true)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ResponseSwapEggs then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.ExchangeEgg, true)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.DoubleRide then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.DoubleRide, true)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.EnterHome then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdZoneSceneHomeTeamRespondInviteReq, self.data.uin, self.data.team_type, ProtoEnum.HomeTeamRespondType.HOME_TEAM_RESPOND_TYPE_ACCEPT)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ReturnBigWorld then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdZoneSceneHomeTeamRespondInviteReq, self.data.uin, self.data.team_type, ProtoEnum.HomeTeamRespondType.HOME_TEAM_RESPOND_TYPE_ACCEPT)
  end
  self:OnTimerComplete(true)
end

function UMG_Plane_ExchangeVisits_Item_C:OnCancel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Plane_ExchangeVisits_Item_C:OnCancel")
  if self.data.Type == FriendEnum.ExchangeVisitsType.ApplyVisit then
    if _G.NRCModuleManager:DoCmd(FriendModuleCmd.GetWaitVisitReplyRsp) then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.online_visitor_apply_list_cd)
      return
    end
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.Visiting, false)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.InviteVisit then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.InviteVisiting, false)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ResponseCompetition then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.Fighting, false)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ResponseSwapEggs then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.ExchangeEgg, false)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.DoubleRide then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZoneReplyPlayerInteract, self.data.uin, ProtoEnum.PlayerInteractType.DoubleRide, false)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.EnterHome then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdZoneSceneHomeTeamRespondInviteReq, self.data.uin, self.data.team_type, ProtoEnum.HomeTeamRespondType.HOME_TEAM_RESPOND_TYPE_REJECT)
  elseif self.data.Type == FriendEnum.ExchangeVisitsType.ReturnBigWorld then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdZoneSceneHomeTeamRespondInviteReq, self.data.uin, self.data.team_type, ProtoEnum.HomeTeamRespondType.HOME_TEAM_RESPOND_TYPE_REJECT)
  end
  self:OnTimerComplete(true)
end

function UMG_Plane_ExchangeVisits_Item_C:OnItemSelected(_bSelected)
end

function UMG_Plane_ExchangeVisits_Item_C:SetTimeText(TimeString)
  self.Text_Class_1:SetText(TimeString .. LuaText.umg_plane_exchangevisits_item_1)
end

return UMG_Plane_ExchangeVisits_Item_C
