local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_Friend_Function_Item_C = Base:Extend("UMG_Friend_Function_Itme_C")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")

function UMG_Friend_Function_Item_C:Construct()
  Base.Construct(self)
  self.TimerText = ""
  self.Module = NRCModuleManager:GetModule("FriendModule")
  self.ModuleData = self.Module:GetData("FriendModuleData")
  self:OnAddEventListener()
end

function UMG_Friend_Function_Item_C:DestroyItem()
  self.Module:UnRegisterEvent(self, FriendModuleEvent.NotifyInteractResult)
  self.Module:UnRegisterEvent(self, FriendModuleEvent.ResZonePlayerInteract)
  if self.ApplyVisitTimer then
    _G.TimerManager:RemoveTimer(self.ApplyVisitTimer)
    self.ApplyVisitTimer = nil
  end
end

function UMG_Friend_Function_Item_C:OnAddEventListener()
  self.Module:RegisterEvent(self, FriendModuleEvent.NotifyInteractResult, self.OnNotifyInteractResult)
  self.Module:RegisterEvent(self, FriendModuleEvent.ResZonePlayerInteract, self.OnResZonePlayerInteract)
end

function UMG_Friend_Function_Item_C:OnItemUpdate(_data, datalist, index)
  self.CardInfo = self.ModuleData:GetCardFriendInfo()
  self.data = _data
  self.datalist = datalist
  self.index = index
  self:SetInfo()
end

function UMG_Friend_Function_Item_C:SetParent(_parent)
  self.parent = _parent
end

function UMG_Friend_Function_Item_C:SetInfo()
  local data = self.data
  self.Title:SetText(data.name)
  self.Icon:SetPath(data.Icon)
  self:SetIsCanClick(data.IsActive)
  if data.TabType == FriendEnum.TAB_TYPE.RequestAccess or data.TabType == FriendEnum.TAB_TYPE.Invitation then
    local OnlineConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ONLINE_GLOBAL_CONFIG):GetAllDatas()
    local UnlockLevel = 15
    for i = 1, #OnlineConf do
      if OnlineConf[i].key == "online_unlock_role_level" then
        UnlockLevel = OnlineConf[i].num
        break
      end
    end
    local PlayerLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
    if UnlockLevel > PlayerLevel then
      self.ClickMsg = string.format(_G.DataConfigManager:GetLocalizationConf("cant_online_apply_mine").msg, UnlockLevel)
    end
    local Level = self.CardInfo.level or self.CardInfo.base and self.CardInfo.base.lv or 0
    if UnlockLevel > Level then
      self.ClickMsg = _G.DataConfigManager:GetLocalizationConf("cant_online_apply_other").msg
    end
  end
end

function UMG_Friend_Function_Item_C:SetIsCanClick(IsCanClick)
  self:SetIsEnabled(IsCanClick)
end

function UMG_Friend_Function_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:SelectInfo()
  end
end

function UMG_Friend_Function_Item_C:SelectInfo()
  self.Title_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local Uin = self.CardInfo.uin or self.CardInfo.base.logic_id
  if self.data.TabType == FriendEnum.TAB_TYPE.Material then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
  elseif self.data.TabType == FriendEnum.TAB_TYPE.AddFriend then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddFriendApplicationOrRemoveFriend, self.data.PlayerInfo.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveFriendReq.TYPE.ADD_FRIEND)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.AddBlackList then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
    self:OnDeleteFriendOrAddBlack("blacklist_affirm_content", self.OnOnAddBlackListCallback)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Remark then
    if self.data.PlayerInfo.note then
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
    else
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
    end
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendRemark, self.data.PlayerInfo)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.RemoveFriend then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
    self:OnDeleteFriendOrAddBlack("delete_friend_affirm_content", self.DeleteCallback)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Report then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendReport, self.data.PlayerInfo)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.RemoveBlackList then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddOrRemoveBlackList, self.data.PlayerInfo.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveBlackListReq.TYPE.REMOVE)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.ChangeHeadIcon then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Function_Item_C:SelectInfo")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenChangeAvatarPanel)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.ChangeCardBG then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Function_Item_C:SelectInfo")
    local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
    local AvatarSkinId = PlayerInfo.additional_data.card_brief_info.card_skin_selected
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenChangeCardBG, AvatarSkinId)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.ChangeLabel then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Function_Item_C:SelectInfo")
    local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
    local LabelFirstId = PlayerInfo.additional_data.card_brief_info.card_label_first_selected
    local LabelLastId = PlayerInfo.additional_data.card_brief_info.card_label_last_selected
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenChangeCardLabel, LabelFirstId, LabelLastId)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.ChangeSign then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Function_Item_C:SelectInfo")
    local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
    local Data = PlayerInfo
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenChangeSign, Data)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Chitchat then
    NRCProfilerLog:NRCClickBtn(true, "Chat_Main")
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenChatMainPanel, self.data.PlayerInfo.uin, self.index)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.WorldInfo then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendWold, self.data.PlayerInfo, self.index)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.RequestAccess then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
    if self.ClickMsg then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.ClickMsg)
      return
    end
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.Visiting)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Invitation then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
    if self.ClickMsg then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.ClickMsg)
      return
    end
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.InviteVisiting)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Fight then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.Fighting)
  elseif self.data.TabType == FriendEnum.TAB_TYPE.InteractiveEggs then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.ExchangeEgg)
  end
end

function UMG_Friend_Function_Item_C:SetTimerInfo(CountDown, TimerText, TimerKey, TimeCost)
  self.Title:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Title_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetClickable(false)
  local OnlineConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ONLINE_GLOBAL_CONFIG):GetAllDatas()
  for i = 1, #OnlineConf do
    if OnlineConf[i].key == CountDown then
      self.ApplyTime = OnlineConf[i].num - TimeCost
      break
    end
  end
  self.TimerText = string.format(_G.DataConfigManager:GetLocalizationConf(TimerText).msg, self.ApplyTime)
  self.Title_1:SetText(self.TimerText .. self.ApplyTime .. LuaText.umg_plane_exchangevisits_item_1)
  self.ApplyVisitTimer = _G.TimerManager:CreateTimer(self, TimerKey, self.ApplyTime, self.OnTimerUpdate, self.OnTimerComplete, 1)
end

function UMG_Friend_Function_Item_C:OnTimerUpdate()
  self.ApplyTime = self.ApplyTime - 1
  self.Title_1:SetText(self.TimerText .. self.ApplyTime .. LuaText.umg_plane_exchangevisits_item_1)
end

function UMG_Friend_Function_Item_C:OnTimerComplete(NoTips)
  if not NoTips then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("online_over_time").msg)
  end
  if self.ApplyVisitTimer then
    _G.TimerManager:RemoveTimer(self.ApplyVisitTimer)
    self.ApplyVisitTimer = nil
  end
  self.Title_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetClickable(true)
end

function UMG_Friend_Function_Item_C:OnNotifyInteractResult(Notify)
  if not self.data then
    return
  end
  if self.data.TabType == FriendEnum.TAB_TYPE.RequestAccess then
    if Notify.type ~= ProtoEnum.PlayerInteractType.Visiting then
      return
    end
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Invitation then
    if Notify.type ~= ProtoEnum.PlayerInteractType.InviteVisiting then
      return
    end
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Fight then
    if Notify.type ~= ProtoEnum.PlayerInteractType.Fighting then
      return
    end
  elseif self.data.TabType == FriendEnum.TAB_TYPE.InteractiveEggs and Notify.type ~= ProtoEnum.PlayerInteractType.ExchangeEgg then
    return
  end
  self:OnTimerComplete(true)
end

function UMG_Friend_Function_Item_C:OnResZonePlayerInteract(Res)
  if not self.data then
    return
  end
  local TimeCost = math.floor(_G.ZoneServer:GetServerTime() / 1000 - Res.player_info.apply_time)
  if self.data.TabType == FriendEnum.TAB_TYPE.RequestAccess then
    if Res.type == ProtoEnum.PlayerInteractType.Visiting then
      self:SetTimerInfo("online_apply_message_handle_time", "players_interact_apply_online_succeed_btn", "UMG_Friend_Function_Item_C.ApplyVisitTimer", TimeCost)
    end
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Invitation then
    if Res.type == ProtoEnum.PlayerInteractType.InviteVisiting then
      self:SetTimerInfo("invite_online_show_time", "online_invite_succeed_btn", "UMG_Friend_Function_Item_C.InviteVisit", TimeCost)
    end
  elseif self.data.TabType == FriendEnum.TAB_TYPE.Fight then
    if Res.type == ProtoEnum.PlayerInteractType.Fighting then
      BattleProfiler:CheckPoint(BattleProfilerCheckPoint.PVPFriendRequireCompetition)
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenApplyVisitInfoHit, FriendEnum.ExchangeVisitsType.RequireCompetition, Res.player_info)
      self:SetTimerInfo("invite_spar_show_time", "spar_invite_succeed_btn", "UMG_Friend_Function_Item_C.Competition", TimeCost)
    end
  elseif self.data.TabType == FriendEnum.TAB_TYPE.InteractiveEggs and Res.type == ProtoEnum.PlayerInteractType.ExchangeEgg then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenApplyVisitInfoHit, FriendEnum.ExchangeVisitsType.RequireSwapEggs, Res.player_info)
    self:SetTimerInfo("invite_spar_show_time", "petegg_trade_invite_succeed_btn", "UMG_Friend_Function_Item_C.SwapEggs", TimeCost)
  end
end

function UMG_Friend_Function_Item_C:OnDeleteFriendOrAddBlack(_Id, Callback)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local dialogContext = DialogContext()
  local Text = _G.DataConfigManager:GetLocalizationConf(_Id).msg
  local TipsContent = string.format(Text, self.data.PlayerInfo.name)
  dialogContext:SetContent(TipsContent):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetCallback(self, Callback)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
end

function UMG_Friend_Function_Item_C:DeleteCallback(_ok)
  if _ok then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddFriendApplicationOrRemoveFriend, self.data.PlayerInfo.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveFriendReq.TYPE.REMOVE_FRIEND)
  end
end

function UMG_Friend_Function_Item_C:OnOnAddBlackListCallback(_ok)
  if _ok then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddOrRemoveBlackList, self.data.PlayerInfo.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveBlackListReq.TYPE.ADD, self.data)
  end
end

function UMG_Friend_Function_Item_C:OnAnimationFinished(Animation)
  Log.Error("UMG_Friend_Function_Item_C:OnAnimationFinished")
  if Animation == self.Press then
    self:PlayAnimation(self.Up)
    self:SelectInfo()
    self.parent:SetOnlyClick(self.index, true)
  elseif Animation == self.Up then
  end
end

function UMG_Friend_Function_Item_C:OnDeactive()
end

return UMG_Friend_Function_Item_C
