local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local CommonBtnEnum = require("NewRoco.Modules.System.CommonBtn.CommonBtnEnum")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_Friend_AddPrivateChat_C = _G.NRCPanelBase:Extend("UMG_Friend_AddPrivateChat_C")

function UMG_Friend_AddPrivateChat_C:OnConstruct()
  self.TabIndex = 0
  _G.DataModelMgr.PlayerDataModel:AddPanelMusic(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_FRIEND)
  local StateGroup = _G.DataModelMgr.PlayerDataModel:GetStateGroupByApplyEnum(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_FRIEND)
  if StateGroup then
    _G.NRCAudioManager:BatchSetState(StateGroup)
  end
  self.data = self.module:GetData("FriendModuleData")
  self:SetChildViews(self.Tab_1, self.Tab_2)
  self.FriendTabList = {
    self.Tab_1,
    self.Tab_2
  }
end

function UMG_Friend_AddPrivateChat_C:BindInputAction()
  local mappingContext
  mappingContext = self:AddInputMappingContext("IMC_FriendUI_1")
  if mappingContext then
    mappingContext:BindAction("IA_CloseFriendUI_1", self, "OnPcClose_1")
    mappingContext:BindAction("IA_CloseFriendQuick_1", self, "OnPcClose_1")
  end
end

function UMG_Friend_AddPrivateChat_C:OnPcClose()
  if self:GetVisibility() ~= UE4.ESlateVisibility.Visible and self:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
    return
  end
  self:OnCloseBtn()
end

function UMG_Friend_AddPrivateChat_C:OnPcClose_1()
  if self:GetVisibility() ~= UE4.ESlateVisibility.Visible and self:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
    return
  end
  self:OnCloseBtn()
end

function UMG_Friend_AddPrivateChat_C:OnActive()
  self:OnAddEventListener()
  self:SetTabInfo()
  self.Tab_1:OnSelect()
  if self.FriendChat then
    self.FriendChat:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetCommonTitle()
  self:PlayPlatformFriendItemInAnimation()
end

function UMG_Friend_AddPrivateChat_C:SetCommonTitle()
  local Panel = "Friend"
  self.titleConf = _G.DataConfigManager:GetTitleConf(Panel)
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Friend_AddPrivateChat_C:GetFriendTabSelectIndex()
  return self.module:GetPrivateChatTabIndex()
end

function UMG_Friend_AddPrivateChat_C:OnChangeFriendTab(FriendTab)
  if self.TabSelect then
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_Friend_C:OnClickTab_1")
  else
    self.TabSelect = true
  end
  self.ItemList_Friend_2:Clear()
  if FriendTab == FriendEnum.FriendTab.GameFriend then
    self:DoRequestFriendListStatusForChangeTab(ProtoEnum.FriendType.FRIEND_TYPE_IN_GAME)
  elseif FriendTab == FriendEnum.FriendTab.PlatformFriend then
    self:DoRequestFriendListStatusForChangeTab(ProtoEnum.FriendType.FRIEND_TYPE_PLAT)
  end
  self.module:SetPrivateChatTabIndex(FriendTab)
  self:PlayAnimation(self.change)
end

function UMG_Friend_AddPrivateChat_C:DoRequestFriendListStatusForChangeTab(friendType)
  local curTime = os.msTime() / 1000.0
  local lastRequestTime = self.data:GetLastChangeTabRefreshTimeSec(friendType)
  if curTime - lastRequestTime < 1 then
    Log.DebugFormat("UMG_Friend_C:DoRequestFriendListStatusForChangeTab friendType:%s request too frequently, lastRequestTime:%s, curTime:%s", tostring(friendType), tostring(lastRequestTime), tostring(curTime))
    return
  end
  self.data:SetLastChangeTabRefreshTimeSec(friendType, curTime)
  self.data:SetLastFriendListAutoRefreshTimeSec(friendType, curTime)
  if friendType == ProtoEnum.FriendType.FRIEND_TYPE_WEGAME then
    _G.NRCSDKManager:GetWeGameFriendsInfo()
    return
  end
  local isMergeData = false
  self.data:RequestFriendRoleInfo(self, self.OnFriendListRefreshRsp, FriendEnum.ClientFriendRoleInfoScene.FriendPanelDefault, nil, friendType, _G.ProtoEnum.ZoneFriendGetFriendListScene.ZONE_FRIEND_GET_FRIEND_LIST_SCENE_DEFAULT, isMergeData)
end

function UMG_Friend_AddPrivateChat_C:OnFriendListRefreshRsp(friendList, clientFriendScene)
  Log.DebugFormat("UMG_Friend_C:OnFriendListRefreshRsp friendList count:%s, clientFriendScene:%s", tostring(#friendList), tostring(clientFriendScene))
  self.module:DispatchEvent(FriendModuleEvent.OnFriendDataUpdate)
end

function UMG_Friend_AddPrivateChat_C:OnUpdateFriendTabInfo()
  local CurItemType = self:GetFriendTabSelectIndex()
  Log.Debug(CurItemType, "UMG_Friend_AddPrivateChat_C:SelectTaskTabInfo")
  if CurItemType == FriendEnum.FriendTab.GameFriend then
    self:OnClickTabGameFriend()
  elseif CurItemType == FriendEnum.FriendTab.PlatformFriend then
    self:OnClickTabPlatformFriend()
  end
end

function UMG_Friend_AddPrivateChat_C:OnClickTabGameFriend()
  self.ItemList_Friend_2:ClearSelection()
  if self.titleConf and self.titleConf.subtitle then
    self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
  end
  self.Switcher:SetActiveWidgetIndex(0)
  if self.Empty_1 then
    self.Empty_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:UpdateGameFriendListInfo()
end

function UMG_Friend_AddPrivateChat_C:OnClickTabPlatformFriend()
  self.ItemList_Friend_2:ClearSelection()
  if self.Empty_1 then
    self.Empty_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  Log.Debug("UMG_Friend_AddPrivateChat_C:OnClickTabPlatformFriend Switcher:SetActiveWidgetIndex(0)")
  self.Switcher:SetActiveWidgetIndex(0)
  local loginChannelType = self.data:GetLoginChannelType()
  if loginChannelType == Enum.CliLoginChannel.CLC_QQ then
    self.Title1:SetSubtitle(LuaText.friend_tab_tips2)
  elseif loginChannelType == Enum.CliLoginChannel.CLC_WX then
    self.Title1:SetSubtitle(LuaText.friend_tab_tips3)
  end
  self:UpdatePlatformFriendList()
end

function UMG_Friend_AddPrivateChat_C:UpdatePlatformFriendList(resetOffset)
  local platformFriendList = self.data:GetFriendListForSpecifiedType(ProtoEnum.FriendType.FRIEND_TYPE_PLAT)
  local oriScrollOffset = self.ItemList_Friend_2:GetScrollOffset()
  if not resetOffset then
    self.ItemList_Friend_2:NRCSetScrollOffset(oriScrollOffset)
  end
  local UnlockFriendList = {}
  for i, Friend in ipairs(platformFriendList) do
    if Friend.is_chat_node_unlock ~= nil and Friend.is_chat_node_unlock then
      table.insert(UnlockFriendList, Friend)
    end
  end
  if UnlockFriendList and #UnlockFriendList > 0 then
    self.ItemList_Friend_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ItemList_Friend_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:UpdateEmptyText()
    return
  end
  self.ItemList_Friend_2:InitList(UnlockFriendList)
end

function UMG_Friend_AddPrivateChat_C:PlayPlatformFriendItemInAnimation()
  local platformFriendList = self.data:GetFriendListForSpecifiedType(ProtoEnum.FriendType.FRIEND_TYPE_PLAT)
  for i, List in ipairs(platformFriendList) do
    local Item = self.ItemList_Friend_2:GetItemByIndex(i - 1)
    if Item then
      Item:PlayInAnimation()
    end
  end
end

function UMG_Friend_AddPrivateChat_C:PlayGameFriendItemInAnimation()
  local FriendList = self.data:GetFriendListForSpecifiedType(ProtoEnum.FriendType.FRIEND_TYPE_IN_GAME)
  for i, List in ipairs(FriendList) do
    local Item = self.ItemList_Friend_2:GetItemByIndex(i - 1)
    if Item then
      Item:PlayInAnimation()
    end
  end
end

function UMG_Friend_AddPrivateChat_C:UpdateGameFriendListInfo(resetOffset)
  self.Switcher:SetActiveWidgetIndex(0)
  local FriendList = self.data:GetFriendListForSpecifiedType(ProtoEnum.FriendType.FRIEND_TYPE_IN_GAME)
  local VisitList = self.data:GetOnlineVisitorList()
  if #FriendList > 0 then
    UIUtils.SafeSetVisibility(self.ItemList_Friend_2, UE4.ESlateVisibility.SelfHitTestInvisible)
    if #VisitList > 0 then
      for i = 1, #VisitList do
        for j = 1, #FriendList do
          if VisitList[i].uin == FriendList[j].uin then
            FriendList[j].is_Visit = true
          end
        end
      end
    end
    self.ItemList_Friend_2:SetCustomData(self:GetPanelName())
    local oriScrollOffset = self.ItemList_Friend_2:GetScrollOffset()
    local UnlockFriendList = {}
    for i, Friend in ipairs(FriendList) do
      if Friend.is_chat_node_unlock ~= nil and Friend.is_chat_node_unlock then
        table.insert(UnlockFriendList, Friend)
      end
    end
    if 0 == #UnlockFriendList then
      UIUtils.SafeSetVisibility(self.ItemList_Friend_2, UE4.ESlateVisibility.Collapsed)
      if 0 == self.Switcher:GetActiveWidgetIndex() then
        self:PlayAnimation(self.Page_In)
      end
      self:UpdateEmptyText()
      return
    end
    self.ItemList_Friend_2:InitList(UnlockFriendList)
    if not resetOffset then
      self.ItemList_Friend_2:NRCSetScrollOffset(oriScrollOffset)
    end
  else
    if 0 == self.Switcher:GetActiveWidgetIndex() then
      UIUtils.SafeSetVisibility(self.ItemList_Friend_2, UE4.ESlateVisibility.Collapsed)
      self:PlayAnimation(self.Page_In)
    end
    self:UpdateEmptyText()
  end
end

function UMG_Friend_AddPrivateChat_C:UpdateEmptyText()
  if self.Empty_1 then
    self.Empty_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.NRCText_1 then
    local CurSelectTabIndex = self.module:GetPrivateChatTabIndex()
    if CurSelectTabIndex == FriendEnum.FriendTab.PlatformFriend then
      self.NRCText_1:SetText(LuaText.no_privatechat_platform_friends)
    else
      self.NRCText_1:SetText(LuaText.no_privatechat_friends)
    end
  end
end

function UMG_Friend_AddPrivateChat_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_Friend_AddPrivateChat_C:OnDeactive()
end

function UMG_Friend_AddPrivateChat_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtn)
  self:RegisterEvent(self, FriendModuleEvent.OnFriendDataUpdate, self.OnFriendDataUpdate)
end

function UMG_Friend_AddPrivateChat_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, FriendModuleEvent.OnFriendDataUpdate)
end

function UMG_Friend_AddPrivateChat_C:SetTabInfo()
  local loginChannelType = self.data:GetLoginChannelType()
  self.Tab_1:SetPath(FriendEnum.FriendTab.GameFriend, loginChannelType)
  self.Tab_2:SetPath(FriendEnum.FriendTab.PlatformFriend, loginChannelType)
  if loginChannelType ~= Enum.CliLoginChannel.CLC_QQ and loginChannelType ~= Enum.CliLoginChannel.CLC_WX then
    self.Tab_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Tab_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Tab_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Tab_1:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  for _, tab in ipairs(self.FriendTabList) do
    tab:SetCallbacks(self.GetCurrentSelectedTabCallback, self.SetCurrentSelectedTabCallback, self)
  end
end

function UMG_Friend_AddPrivateChat_C:GetCurrentSelectedTabCallback()
  return self.module:GetPrivateChatTabIndex()
end

function UMG_Friend_AddPrivateChat_C:SetCurrentSelectedTabCallback(tabIndex)
  local CurItemType = self:GetFriendTabSelectIndex()
  for i, Friend in ipairs(self.FriendTabList) do
    Friend:RemoveSelected(CurItemType)
  end
  self.module:SetPrivateChatTabIndex(tabIndex)
  self:OnChangeFriendTab(tabIndex)
end

function UMG_Friend_AddPrivateChat_C:OnFriendDataUpdate()
  local CurItemType = self:GetFriendTabSelectIndex()
  Log.Debug("UMG_Friend_AddPrivateChat_C:OnFriendDataUpdate ", CurItemType)
  if CurItemType == FriendEnum.FriendTab.GameFriend then
    Log.Debug("UMG_Friend_AddPrivateChat_C:OnFriendDataUpdate FriendTab.Friend")
    self:OnClickTabGameFriend()
  elseif CurItemType == FriendEnum.FriendTab.PlatformFriend then
    Log.Debug("UMG_Friend_AddPrivateChat_C:OnFriendDataUpdate FriendTab.PlatformFriend")
    self:OnClickTabPlatformFriend()
  end
end

function UMG_Friend_AddPrivateChat_C:OnCloseBtn()
  if self:CheckIsSelectBtn() then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "Friend").CLOSE
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
  local mappingContext
  if "Friend" == self:GetPanelName() then
    mappingContext = self:GetInputMappingContext("IMC_FriendUI")
    if mappingContext then
      mappingContext:UnBindAction("IA_CloseFriendUI")
      mappingContext:UnBindAction("IA_CloseFriendQuick")
    end
  else
    mappingContext = self:GetInputMappingContext("IMC_FriendUI_1")
    if mappingContext then
      mappingContext:UnBindAction("IA_CloseFriendUI_1")
      mappingContext:UnBindAction("IA_CloseFriendQuick_1")
    end
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_Friend_AddPrivateChat_C:OnCloseBtn")
  self:PlayAnimation(self.Out)
  UE4Helper.SetEnableWorldRendering(true, false)
end

function UMG_Friend_AddPrivateChat_C:CheckIsSelectBtn()
  return _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, "FriendModule", "Friend")
end

return UMG_Friend_AddPrivateChat_C
