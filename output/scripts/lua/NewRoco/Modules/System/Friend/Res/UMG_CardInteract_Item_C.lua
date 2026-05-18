local BP_NRCItemBase_C = require("NewRoco.TUI.BP_NRCItemBase_C")
local Base = BP_NRCItemBase_C
local UMG_CardInteract_Item_C = Base:Extend("UMG_CardInteract_Item_C")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local FriendEnum = reload("NewRoco.Modules.System.Friend.FriendEnum")

function UMG_CardInteract_Item_C:Construct()
  Base.Construct(self)
  self.TimerText = ""
  self.Module = NRCModuleManager:GetModule("FriendModule")
  self.ModuleData = self.Module:GetData("FriendModuleData")
  self:OnAddEventListener()
  self.Countdown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Details.Ordinary:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Details.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Details.ps:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_CardInteract_Item_C:DestroyItem()
  self.Module:UnRegisterEvent(self, FriendModuleEvent.NotifyInteractResult)
  self.Module:UnRegisterEvent(self, FriendModuleEvent.ResZonePlayerInteract)
  if self.ApplyVisitTimer then
    _G.TimerManager:RemoveTimer(self.ApplyVisitTimer)
    self.ApplyVisitTimer = nil
  end
end

function UMG_CardInteract_Item_C:OnAddEventListener()
  self.Module:RegisterEvent(self, FriendModuleEvent.NotifyInteractResult, self.OnNotifyInteractResult)
  self.Module:RegisterEvent(self, FriendModuleEvent.ResZonePlayerInteract, self.OnResZonePlayerInteract)
  self.Details.btnLevelUp.OnClicked:Add(self, self.OnDetailsClicked)
end

function UMG_CardInteract_Item_C:OnItemUpdate(_data, datalist, index)
  self.CardInfo = self.ModuleData:GetCardFriendInfo()
  self.data = _data
  self.datalist = datalist
  self.index = index
  self.unlocked = true
  self:SetInfo()
end

function UMG_CardInteract_Item_C:SetInfo()
  local data = self.data
  self.Title:SetText(data.name)
  self.Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if data.IsActive then
    self.Details:SetPath(data.Icon, data.Icon, data.Icon)
  else
    self.Details:SetPath(data.DisabledIcon, data.DisabledIcon, data.DisabledIcon)
  end
  self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.Icon then
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetIsCanClick(data.IsActive)
  if data.TabType == FriendEnum.CardInteractionEntrance.RequestAccess or data.TabType == FriendEnum.CardInteractionEntrance.Invitation then
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
      self.unlocked = false
    end
    local Level = self.CardInfo.level or self.CardInfo.base and self.CardInfo.base.lv or 0
    if UnlockLevel > Level then
      self.ClickMsg = _G.DataConfigManager:GetLocalizationConf("cant_online_apply_other").msg
      self.unlocked = false
    end
  end
  if not self.unlocked then
    self.Lock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.Icon then
      self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self:UpdateTimerInfo()
end

function UMG_CardInteract_Item_C:SetIsCanClick(IsCanClick)
  if IsCanClick then
    self.Details.btnLevelUp:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Details.btnLevelUp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_CardInteract_Item_C:OnDetailsClicked()
  if self.CountDown:IsVisible() then
    return
  end
  if self.Icon then
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local Uin = self.data.PlayerInfo.uin
  if self.data.TabType == FriendEnum.CardInteractionEntrance.AddFriend then
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_CardInteract_Item_C:SelectInfo")
    self.Module:ReportTLog(4, 7, self.data.PlayerInfo)
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddFriendApplicationOrRemoveFriend, self.data.PlayerInfo.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveFriendReq.TYPE.ADD_FRIEND)
  elseif self.data.TabType == FriendEnum.CardInteractionEntrance.Chitchat then
    self.Module:ReportTLog(4, 5, self.data.PlayerInfo)
    NRCProfilerLog:NRCClickBtn(true, "Chat_Main")
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenChatMainPanelByCardPanel, self.data.PlayerInfo.uin, self.index)
  elseif self.data.TabType == FriendEnum.CardInteractionEntrance.HomeInfo then
    self.Module:ReportTLog(4, 3, self.data.PlayerInfo)
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_CardInteract_Item_C:SelectInfo")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdSendZoneHomeQueryFriendHomeInfoReq, Uin)
  elseif self.data.TabType == FriendEnum.CardInteractionEntrance.WorldInfo then
    self.Module:ReportTLog(4, 4, self.data.PlayerInfo)
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_CardInteract_Item_C:SelectInfo")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendWold, self.data.PlayerInfo, self.index)
  elseif self.data.TabType == FriendEnum.CardInteractionEntrance.RequestAccess then
    self.Module:ReportTLog(4, 8, self.data.PlayerInfo)
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_CardInteract_Item_C:SelectInfo")
    if self.ClickMsg then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.ClickMsg)
      return
    end
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.Visiting)
  elseif self.data.TabType == FriendEnum.CardInteractionEntrance.Invitation then
    self.Module:ReportTLog(4, 9, self.data.PlayerInfo)
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_CardInteract_Item_C:SelectInfo")
    if self.ClickMsg then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.ClickMsg)
      return
    end
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.InviteVisiting)
  elseif self.data.TabType == FriendEnum.CardInteractionEntrance.Teleport then
    self.Module:ReportTLog(4, 10, self.data.PlayerInfo)
    _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_CardInteract_Item_C:SelectInfo")
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.OnCmdTeleportToPlayerReq, Uin)
  end
end

function UMG_CardInteract_Item_C:SetTimerInfo(CountDown, TimerText, TimerKey, TimeCost)
  local LeftTime = 0
  local OnlineConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ONLINE_GLOBAL_CONFIG):GetAllDatas()
  for i = 1, #OnlineConf do
    if OnlineConf[i].key == CountDown then
      LeftTime = OnlineConf[i].num - TimeCost
      break
    end
  end
  if LeftTime <= 0 then
    self:OnTimerComplete(true)
    return
  end
  self.ApplyTime = LeftTime
  self.Countdown:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.Icon then
    self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:SetClickable(false)
  self.TimerText = string.format(_G.DataConfigManager:GetLocalizationConf(TimerText).msg, self.ApplyTime)
  self.Countdown:SetText(self.ApplyTime .. "s")
  self.ApplyVisitTimer = _G.TimerManager:CreateTimer(self, TimerKey, self.ApplyTime, self.OnTimerUpdate, self.OnTimerComplete, 1)
end

function UMG_CardInteract_Item_C:OnTimerUpdate()
  self.ApplyTime = self.ApplyTime - 1
  self.Countdown:SetText(self.ApplyTime .. "s")
end

function UMG_CardInteract_Item_C:OnTimerComplete(NoTips)
  if not NoTips then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("online_over_time").msg)
  end
  if self.ApplyVisitTimer then
    _G.TimerManager:RemoveTimer(self.ApplyVisitTimer)
    self.ApplyVisitTimer = nil
  end
  self.Countdown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.Icon then
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetClickable(true)
end

function UMG_CardInteract_Item_C:OnNotifyInteractResult(Notify)
  if not self.data then
    return
  end
  if self.data.TabType ~= FriendEnum.CardInteractionEntrance.RequestAccess and self.data.TabType ~= FriendEnum.CardInteractionEntrance.Invitation then
    return
  end
  if self.data.TabType == FriendEnum.CardInteractionEntrance.RequestAccess then
    if Notify.type ~= ProtoEnum.PlayerInteractType.Visiting then
      return
    end
  elseif self.data.TabType == FriendEnum.CardInteractionEntrance.Invitation and Notify.type ~= ProtoEnum.PlayerInteractType.InviteVisiting then
    return
  end
  self:OnTimerComplete(true)
end

function UMG_CardInteract_Item_C:OnResZonePlayerInteract(Res)
  self:UpdateTimerInfo()
end

function UMG_CardInteract_Item_C:UpdateTimerInfo()
  if not self.data then
    return
  end
  if self.data.TabType ~= FriendEnum.CardInteractionEntrance.RequestAccess and self.data.TabType ~= FriendEnum.CardInteractionEntrance.Invitation then
    return
  end
  local applyTime = self.ModuleData:GetApplyTimeForPlayerInteractType(self.data.PlayerInfo.uin, self.data.TabType)
  local TimeCost = math.floor(_G.ZoneServer:GetServerTime() / 1000 - applyTime)
  if self.data.TabType == FriendEnum.CardInteractionEntrance.RequestAccess then
    self:SetTimerInfo("online_apply_message_handle_time", "players_interact_apply_online_succeed_btn", "UMG_CardInteract_Item_C.ApplyVisitTimer", TimeCost)
  elseif self.data.TabType == FriendEnum.CardInteractionEntrance.Invitation then
    self:SetTimerInfo("invite_online_show_time", "online_invite_succeed_btn", "UMG_CardInteract_Item_C.InviteVisit", TimeCost)
  end
end

function UMG_CardInteract_Item_C:OnAnimationFinished(Animation)
  Log.Error("UMG_CardInteract_Item_C:OnAnimationFinished")
  if Animation == self.Press then
    self:PlayAnimation(self.Up)
    self:SelectInfo()
    self.parent:SetOnlyClick(self.index, true)
  elseif Animation == self.Up then
  end
end

function UMG_CardInteract_Item_C:OnDeactive()
end

return UMG_CardInteract_Item_C
