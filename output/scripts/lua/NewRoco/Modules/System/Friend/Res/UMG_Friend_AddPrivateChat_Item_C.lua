local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local ProtoEnum = require("Data.PB.ProtoEnum")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UIUtils = require("NewRoco.Utils.UIUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_Friend_AddPrivateChat_Item_C = Base:Extend("UMG_Friend_AddPrivateChat_Item_C")

function UMG_Friend_AddPrivateChat_Item_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent("UMG_Friend_AddPrivateChat_Item_C", self, FriendModuleEvent.ModifyFriendRemarkUpdate, self.OnModifyFriendRemarkUpdate)
  self.module = _G.NRCModuleManager:GetModule("FriendModule")
  self.moduleData = self.module:GetData("FriendModuleData")
  self.VisitNumMax = self.module:GetVisitNumMax()
end

function UMG_Friend_AddPrivateChat_Item_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.ModifyFriendRemarkUpdate, self.OnModifyFriendRemarkUpdate)
end

function UMG_Friend_AddPrivateChat_Item_C:OnModifyFriendRemarkUpdate(uin, newRemark)
  if not self.data then
    return
  end
  if self.data.uin == uin then
    self:UpdatePlayerNameInfo()
  end
end

function UMG_Friend_AddPrivateChat_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.RedDot:SetupKey(82, {
    self.data.uin
  })
  self.index = index
  self.Offset = 0
  self.vector2DZero = UE4.FVector2D(0, 0)
  if self.isShowSelectAnim then
    self:ResetUnselectedState()
  end
  self.isShowSelectAnim = false
  self.isLogicSelected = false
  self:UpdateInfo()
  self:OnAddEventListener()
  if nil == _data then
    Log.Error("UMG_Friend_AddPrivateChat_Item_C:OnItemUpdate _data is nil", table.isArray(datalist), #datalist, index)
  end
end

function UMG_Friend_AddPrivateChat_Item_C:OnClickedQQ()
  if self.Privilege then
    self.Privilege:OnClickedQQ()
  end
end

function UMG_Friend_AddPrivateChat_Item_C:OnClickedWX()
  if self.Privilege then
    self.Privilege:OnClickedWX()
  end
end

function UMG_Friend_AddPrivateChat_Item_C:PlayInAnimation()
  if self.index <= 50 then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.DelayId = _G.DelayManager:DelaySeconds(0.1 * self.index, function()
      self:SetVisibility(UE4.ESlateVisibility.Visible)
      self:PlayAnimation(self.Appear)
    end)
  end
end

function UMG_Friend_AddPrivateChat_Item_C:SetParentInfo(_Parent, _ParentSwitcherOffset)
  if self.HeadItem then
    self.HeadItem:SetParentInfo(_Parent, _ParentSwitcherOffset)
    self.HeadItem:SetItemSize(self.ItemSize.Slot:GetSize())
  end
end

function UMG_Friend_AddPrivateChat_Item_C:OnAddEventListener()
  self.NewsBtn.OnClicked:Add(self, self.OnSendMessage)
  self.Privilege.QQBtn.OnClicked:Add(self, self.OnClickedQQ)
  self.Privilege.WeiXinBtn.OnClicked:Add(self, self.OnClickedWX)
end

function UMG_Friend_AddPrivateChat_Item_C:OnSendMessage()
  self.module:ReportTLog(3, 5, self.data)
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_CHAT, true)
  if isBan then
    return
  end
  if self:CheckIsSelectBtn() then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "Friend").MESSAGE
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401003, "UMG_Friend_AddPrivateChat_Item_C:OnSendMessage")
  NRCProfilerLog:NRCClickBtn(true, "Chat_Main")
  local myUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local myPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, myUin)
  local bInFighting = false
  if myPlayer then
    bInFighting = myPlayer:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_FIGHTING)
  end
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenChatMainPanelByFriendPanel, self.data.uin, self.index, bInFighting)
end

function UMG_Friend_AddPrivateChat_Item_C:UpdateInfo()
  local Data = self.data
  if not Data then
    Log.Error("UMG_Friend_AddPrivateChat_Item_C:SetData")
    return
  end
  self:UpdatePlayerNameInfo()
  if Data.online then
    self.State:SetActiveWidgetIndex(0)
    if self.OnlineOrNot_Title then
      self.OnlineOrNot_Title:SetText(self.onlineTitle)
    end
  else
    local CurSelectTabIndex = self:GetSelectFriendTab()
    self.State:SetActiveWidgetIndex(1)
    local LastLogoutTime = Data.last_logout_time or 0
    local nowTime = math.floor(_G.ZoneServer:GetServerTime() / 1000)
    local TimeDiff = nowTime - LastLogoutTime
    local min = math.floor(TimeDiff / 60)
    local hour = math.floor(min / 60)
    local day = math.floor(hour / 24)
    Log.Debug(LastLogoutTime, nowTime, TimeDiff, min, hour, day, Data.name, "UMG_Friend_AddPrivateChat_Item_C:SetData")
    if self.Offline then
      if day >= 7 then
        self.Offline:SetText(LuaText.umg_friend_item_2)
      else
        local Text
        if day < 7 and hour >= 24 then
          Text = string.format(LuaText.umg_friend_item_3, day)
        elseif hour < 24 and hour > 0 then
          Text = string.format(LuaText.umg_friend_item_4, hour)
        elseif min < 60 and min >= 1 then
          Text = string.format(LuaText.umg_friend_applyfor_item_6, min)
        elseif min < 1 and min >= 0 then
          Text = LuaText.umg_friend_applyfor_item_5
        end
        self.Offline:SetText(Text)
      end
    end
  end
  self:SetHeadInfo()
  self:SetBtnByTab()
  self:SetLabel()
  self:UpdatePrivilegeUI()
  self.NRCImage_13:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.pinned_time and self.data.pinned_time > 0 then
    self.TopPositionIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.TopPositionIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if Data.is_chat_node_unlock ~= nil then
    if Data.is_chat_node_unlock then
      self.NewsBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.NewsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:UpdateVisitInfo()
  self:UpdateBehaviorInfo()
  self:SetSignature()
end

function UMG_Friend_AddPrivateChat_Item_C:UpdatePlayerNameInfo()
  if not self.data then
    return
  end
  local name = self.data.name or ""
  local note = self.data.note or ""
  local platformName = self.data.plat_nick_name or ""
  self.RemarkName:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local gameNameShow, gameColorShow
  if note and "" ~= note then
    gameNameShow = note
    gameColorShow = UE4.UNRCStatics.HexToSlateColor("d56c1fff")
  else
    gameNameShow = name
    if self.isLogicSelected then
      gameColorShow = UE4.UNRCStatics.HexToSlateColor("272727ff")
    else
      gameColorShow = UE4.UNRCStatics.HexToSlateColor("f4eee1ff")
    end
  end
  self.RemarkName:SetText(gameNameShow)
  self.RemarkName:SetColorAndOpacity(gameColorShow)
  if platformName and "" ~= platformName then
    self.Name_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local platformShowName = string.format("(%s)", platformName)
    local platformColorShow
    if self.isLogicSelected then
      platformColorShow = UE4.UNRCStatics.HexToSlateColor("272727ff")
    else
      platformColorShow = UE4.UNRCStatics.HexToSlateColor("f4eee1ff")
    end
    self.Name_1:SetText(platformShowName)
    self.Name_1:SetColorAndOpacity(platformColorShow)
  else
    self.Name_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Friend_AddPrivateChat_Item_C:SetSignature()
  UIUtils.SafeSetVisibility(self.Signature0, UE4.ESlateVisibility.SelfHitTestInvisible)
  local signatureText = ""
  if self.data.signature == nil or "" == self.data.signature then
    signatureText = _G.DataConfigManager:GetLocalizationConf("card_signature_input_empty_text").msg
  else
    signatureText = self.data.signature
  end
  local battleText = self.OnlineOrNot_Title:GetText()
  local battleTextNum = utf8.len(battleText)
  local totalNum = _G.DataConfigManager:GetGlobalConfigNumByKey("status_signature_num_sum", 20)
  local signatureTextNum = utf8.len(signatureText)
  if totalNum < battleTextNum + signatureTextNum then
    local maxSignatureNum = totalNum - battleTextNum
    if maxSignatureNum > 3 then
      signatureText = self:SubUTF8String(signatureText, maxSignatureNum) .. "..."
    elseif maxSignatureNum > 0 then
      signatureText = self:SubUTF8String(signatureText, maxSignatureNum)
    else
      signatureText = ""
    end
  end
  UIUtils.SafeSetText(self.Signature, signatureText)
end

function UMG_Friend_AddPrivateChat_Item_C:SubUTF8String(str, maxChars)
  return UIUtils.SubUTF8String(str, maxChars)
end

function UMG_Friend_AddPrivateChat_Item_C:UpdatePrivilegeUI()
  local data = self.data
  if not data then
    self.Privilege:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if not data.start_up_privilege_info then
    self.Privilege:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if data.cli_login_channel ~= Enum.CliLoginChannel.CLC_WX and data.cli_login_channel ~= Enum.CliLoginChannel.CLC_QQ then
    self.Privilege:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self.Privilege:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local startUpPrivilegeInfo = data.start_up_privilege_info
  self.Privilege:SetData(data.cli_login_channel, startUpPrivilegeInfo)
end

function UMG_Friend_AddPrivateChat_Item_C:GetSelectFriendTab()
  local TabIndex = self.module:GetPrivateChatTabIndex()
  return TabIndex
end

function UMG_Friend_AddPrivateChat_Item_C:SetBtnByTab()
  self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanel_197:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.source and self.data.source == ProtoEnum.FriendSource.FS_VISIT then
    self.hufang:SetText(LuaText.friend_recommend_tips1)
    self.CanvasPanel_197:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.data.source and self.data.source == ProtoEnum.FriendSource.FS_PVP then
    self.hufang:SetText(LuaText.friend_recommend_tips2)
    self.CanvasPanel_197:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.data.source and self.data.source == ProtoEnum.FriendSource.FS_PET_EGG_EXCHANGE then
    self.hufang:SetText(LuaText.friend_recommend_tips3)
    self.CanvasPanel_197:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Friend_AddPrivateChat_Item_C:SetLabel()
  local Path = UEPath.CARD_COMMON_PATH
  local Id = not self.data.card_skin_selected and self.data.card_info and self.data.card_info.card_appearance_info and self.data.card_info.card_appearance_info.card_skin_selected
  if Id and 0 ~= Id and _G.DataConfigManager:GetCardSkinConf(Id) then
    local CardSkinConf = _G.DataConfigManager:GetCardSkinConf(Id)
    local SkinPath = string.format(Path, CardSkinConf.skin_resource_path, "Skin", CardSkinConf.skin_resource_path, "Skin")
    self.skin_1:SetPath(SkinPath)
    self.Grade:Init(Id)
    if CardSkinConf.level_icon and CardSkinConf.level_icon ~= "" then
      self:PlayAnimation(self.shine_loop)
    else
      self:PlayAnimation(self.shine_no)
    end
  else
  end
  local CardInfo = self.data and self.data.card_info
  if self.data.card_label_first_selected and self.data.card_label_first_selected and 0 ~= self.data.card_label_first_selected or CardInfo and CardInfo.card_label_first_selected and 0 ~= CardInfo.card_label_first_selected and CardInfo.card_label_last_selected and 0 ~= CardInfo.card_label_last_selected then
    self.BriefIntroduction:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local CardLabelFirstConf = _G.DataConfigManager:GetCardLabelConf(self.data and self.data.card_label_first_selected or CardInfo and CardInfo.card_label_first_selected)
    local CardLabelLastConf = _G.DataConfigManager:GetCardLabelConf(self.data and self.data.card_label_last_selected or CardInfo and CardInfo.card_label_last_selected)
    if CardLabelLastConf and CardLabelFirstConf then
      self.BriefIntroduction:SetText(string.format("%s%s", CardLabelFirstConf.label_text, CardLabelLastConf.label_text))
    end
  else
    self.BriefIntroduction:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Label:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Friend_AddPrivateChat_Item_C:SetHeadInfo()
  if self.HeadItem then
    local data = self.data
    local CurSelectTabIndex = self:GetSelectFriendTab()
    local studentCardForbidAddFriend = CurSelectTabIndex == FriendEnum.FriendTab.SearchFriend and not self.data.isSearch
    self.HeadItem:SetInfo(data, self.index, studentCardForbidAddFriend)
  end
end

function UMG_Friend_AddPrivateChat_Item_C:ResetUnselectedState()
  if not self.isShowSelectAnim then
    return
  end
  Log.Debug("UMG_Friend_AddPrivateChat_Item_C:ResetUnselectedState", self.index)
  if self.HeadItem then
    self.HeadItem:PlayAni(false)
  end
  self:PlayAnimation(self.Select_out, 0, 1, UE4.EUMGSequencePlayMode.Forward, 10)
end

function UMG_Friend_AddPrivateChat_Item_C:OnItemSelected(_bSelected, bScrolled)
  if not self then
    Log.Error("UMG_Friend_AddPrivateChat_Item_C:OnItemSelected self is nil")
    return
  end
  if self.HeadItem then
    self.HeadItem:PlayAni(_bSelected)
  end
  self.isLogicSelected = _bSelected
  if _bSelected then
    if not self.isShowSelectAnim then
      self:PlayAnimation(self.Select_in)
    end
  else
    self:PlayAnimation(self.Select_out)
  end
  self:UpdatePlayerNameInfo()
end

function UMG_Friend_AddPrivateChat_Item_C:AddOrRemove(bAdd, bAnim)
  if bAnim then
    if bAdd then
      self:PlayAnimationReverse(self.Add)
    else
      self:PlayAnimation(self.Add)
    end
  end
end

function UMG_Friend_AddPrivateChat_Item_C:OnAnimationFinished(Animation)
  if Animation == self.Add then
    self.ParentView:AddOrRemoveItem(false, self.index, nil, false)
  elseif Animation == self.Select_out then
    self.isShowSelectAnim = false
    Log.Debug("1111UMG_Friend_AddPrivateChat_Item_C:OnAnimationFinished", self.index, "finish Select_out, set bIsSelect is false")
  elseif Animation == self.Select_in then
    self.isShowSelectAnim = true
    Log.Debug("1111UMG_Friend_AddPrivateChat_Item_C:OnAnimationFinished", self.index, "finish Select_in, set bIsSelect is true")
  end
end

function UMG_Friend_AddPrivateChat_Item_C:OnDeactive()
end

function UMG_Friend_AddPrivateChat_Item_C:CheckIsSelectBtn()
  return _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, "FriendModule", "Friend")
end

function UMG_Friend_AddPrivateChat_Item_C:UpdateVisitInfo()
  local data = self.data
  if self.MutualVisits then
    self.MutualVisits:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if not data then
    Log.Error("UMG_Friend_AddPrivateChat_Item_C:UpdateVisitInfo data is nil")
    return
  end
  local visitInfo = data.visit_info
  if not visitInfo then
    return
  end
  local visitNum = visitInfo.visitor_num
  if not visitNum then
    return
  end
  if visitNum > 0 then
    local visitNumText = string.format("%d/%d", visitNum, self.VisitNumMax)
    self.MutualVisitsText:SetText(visitNumText)
    self.MutualVisits:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Friend_AddPrivateChat_Item_C:UpdateBehaviorInfo()
  local data = self.data
  if not data then
    Log.Error("UMG_Friend_AddPrivateChat_Item_C:UpdateBehaviorInfo data is nil")
    return
  end
  if not self.OnlineOrNot_Title then
    Log.Error("UMG_Friend_AddPrivateChat_Item_C:UpdateBehaviorInfo OnlineOrNot_Title is nil")
    return
  end
  local onlineTitle = self.module:GetFriendBehaviorText(data)
  self.OnlineOrNot_Title:SetText(onlineTitle)
end

return UMG_Friend_AddPrivateChat_Item_C
