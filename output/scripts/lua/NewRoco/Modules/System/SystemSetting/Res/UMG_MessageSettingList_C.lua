local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local UMG_MessageSettingList_C = _G.NRCViewBase:Extend("UMG_MessageSettingList_C")

function UMG_MessageSettingList_C:OnConstruct()
  self.ManagementBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self:AddButtonListener(self.ManagementBtn.btnLevelUp, self.OnManagementBtnClicked)
  _G.NRCEventCenter:RegisterEvent("UMG_MessageSettingList_C", self, SystemSettingModuleEvent.PlayerSettingUpdate, self.HandlePlayerSettingUpdate)
  self.module:RegisterEvent(self, SystemSettingModuleEvent.CloudMessageManagementBtnOKClicked, self.OnCloudMessageManagementBtnOKClicked)
  self.module:RegisterEvent(self, SystemSettingModuleEvent.CloseDetailTips, self.OnCloseDetailTips)
  self.module:RegisterEvent(self, SystemSettingModuleEvent.GetUserSubscribeTplInfo, self.OnGetUserSubscribeTplInfo)
  self:InitGridView()
  self._permissionNotificationCheckID = nil
  self._permissionNotificationRequestID = nil
  self._permissionNotificationStatus = nil
end

function UMG_MessageSettingList_C:InitGridView()
  local dataList = {
    {
      Name = LuaText.push_setting_3,
      IsToggled = self:CheckUserSubscribe(Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_HATCH_EGG),
      OnItemClickCheckedOwner = self,
      OnItemClickChecked = self.OnUserSubscribeChanged,
      UniqueType = Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_HATCH_EGG,
      OnBtnDetailClickedOwner = self,
      OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
    },
    {
      Name = LuaText.push_setting_4,
      IsToggled = self:CheckUserSubscribe(Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_TRAVEL),
      OnItemClickCheckedOwner = self,
      OnItemClickChecked = self.OnUserSubscribeChanged,
      UniqueType = Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_TRAVEL,
      OnBtnDetailClickedOwner = self,
      OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
    },
    {
      Name = LuaText.push_setting_5,
      IsToggled = self:CheckUserSubscribe(Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_DEBRIS_FULL),
      OnItemClickCheckedOwner = self,
      OnItemClickChecked = self.OnUserSubscribeChanged,
      UniqueType = Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_DEBRIS_FULL,
      OnBtnDetailClickedOwner = self,
      OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
    },
    {
      Name = LuaText.push_setting_6,
      IsToggled = self:CheckUserSubscribe(Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_FRIEND_BATTLE),
      OnItemClickCheckedOwner = self,
      OnItemClickChecked = self.OnUserSubscribeChanged,
      UniqueType = Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_FRIEND_BATTLE,
      OnBtnDetailClickedOwner = self,
      OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
    },
    {
      Name = LuaText.push_setting_7,
      IsToggled = self:CheckUserSubscribe(Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_NEW_ACTIVITY),
      OnItemClickCheckedOwner = self,
      OnItemClickChecked = self.OnUserSubscribeChanged,
      UniqueType = Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_NEW_ACTIVITY,
      OnBtnDetailClickedOwner = self,
      OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
    },
    {
      Name = LuaText.push_setting_8,
      IsToggled = self:CheckUserSubscribe(Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_EXCHANGE_EGG),
      OnItemClickCheckedOwner = self,
      OnItemClickChecked = self.OnUserSubscribeChanged,
      UniqueType = Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_EXCHANGE_EGG,
      OnBtnDetailClickedOwner = self,
      OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
    },
    {
      Name = LuaText.push_setting_9,
      IsToggled = self:CheckUserSubscribe(Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_FRIEND_VISIT),
      OnItemClickCheckedOwner = self,
      OnItemClickChecked = self.OnUserSubscribeChanged,
      UniqueType = Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_FRIEND_VISIT,
      OnBtnDetailClickedOwner = self,
      OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
    }
  }
  self.dataList = dataList
  self.List:InitGridView(dataList)
end

function UMG_MessageSettingList_C:OnUserSubscribeChanged(data, bChecked)
  Log.Info("UMG_MessageSettingList_C.OnUserSubscribeChanged", data.Name, bChecked)
  local playerSettings = _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.GetPlayerSettings)
  local newPlayerSettings = {}
  if playerSettings then
    table.copy(playerSettings, newPlayerSettings)
  end
  if newPlayerSettings.userSubscribe then
    if data.UniqueType == Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_HATCH_EGG then
      newPlayerSettings.userSubscribe.hatch_egg = bChecked
    elseif data.UniqueType == Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_TRAVEL then
      newPlayerSettings.userSubscribe.travel = bChecked
    elseif data.UniqueType == Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_DEBRIS_FULL then
      newPlayerSettings.userSubscribe.debris_full = bChecked
    elseif data.UniqueType == Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_FRIEND_BATTLE then
      newPlayerSettings.userSubscribe.friend_battle = bChecked
    elseif data.UniqueType == Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_NEW_ACTIVITY then
      newPlayerSettings.userSubscribe.new_activity = bChecked
    elseif data.UniqueType == Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_EXCHANGE_EGG then
      newPlayerSettings.userSubscribe.exchange_egg = bChecked
    elseif data.UniqueType == Enum.UserSubscribeType.USER_SUBSCRIBE_TYPE_FRIEND_VISIT then
      newPlayerSettings.userSubscribe.friend_visit = bChecked
    end
  end
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqModifyPlayerSettings, newPlayerSettings)
  if not RocoEnv.PLATFORM_WINDOWS and bChecked then
    if UE.UNRCPermissionMgr.IfRequestPermissionSupport(UE.ENRCPermissionType.Notifications) then
      if self._permissionNotificationCheckID then
        UE.UNRCPermissionMgr.CancelIfRequestPermissionGrantedAsync(self._permissionNotificationCheckID)
        self._permissionNotificationCheckID = nil
      end
      self._permissionNotificationCheckID = UE.UNRCPermissionMgr.IfPermissionGrantedAsync(UE.ENRCPermissionType.Notifications, SimpleDelegateFactory:CreateCallback(self, self.OnIfNotificationsPermissionGrantedAsyncCallback))
    else
      UE.UNRCPermissionMgr.JumpToSysSetting()
    end
  end
end

function UMG_MessageSettingList_C:OnIfNotificationsPermissionGrantedAsyncCallback(PermissionStatus)
  Log.Info("UMG_MessageSettingList_C:OnIfNotificationsPermissionGrantedAsyncCallback ", PermissionStatus)
  self._permissionNotificationCheckID = nil
  self._permissionNotificationStatus = PermissionStatus
  if 0 == PermissionStatus then
    Log.Info("UMG_MessageSettingList_C:Notification Permission Already Granted")
  else
    _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.OpenCloudMessageManagementPopUp)
  end
end

function UMG_MessageSettingList_C:OnCloseDetailTips()
  if self.List then
    local itemCount = self.List:GetItemCount()
    for i = 1, itemCount do
      local itemData = self.List:GetItemByIndex(i - 1)
      if itemData then
        itemData:CloseDetailTips()
      end
    end
  end
end

function UMG_MessageSettingList_C:OnCloudMessageManagementBtnOKClicked()
  Log.Info("UMG_MessageSettingList_C:OnCloudMessageManagementBtnOKClicked ", self._permissionNotificationStatus)
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.CloseCloudMessageManagementPopUp)
  if 0 ~= self._permissionNotificationStatus then
    if -1 == self._permissionNotificationStatus then
      if self._permissionNotificationRequestID then
        UE.UNRCPermissionMgr.CancelRequestPermissionCallback(self._permissionNotificationRequestID)
        self._permissionNotificationRequestID = nil
      end
      UE.UNRCPermissionMgr.RequestPermission(UE.ENRCPermissionType.Notifications, SimpleDelegateFactory:CreateCallback(self, self.OnRequestNotificationsPermissionCallback))
    else
      UE.UNRCPermissionMgr.JumpToSysSetting()
    end
  end
  self._permissionNotificationRequestID = nil
  self._permissionNotificationStatus = nil
end

function UMG_MessageSettingList_C:OnRequestNotificationsPermissionCallback(bGranted)
  Log.Info("UMG_MessageSettingList_C:OnRequestNotificationsPermissionCallback ", bGranted)
  self._permissionNotificationRequestID = nil
end

function UMG_MessageSettingList_C:HandlePlayerSettingUpdate()
  self:RefreshGridViewToggleState()
end

function UMG_MessageSettingList_C:CheckUserSubscribe(userSubscribeType)
  return _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.CheckUserSubscribeInfo, userSubscribeType)
end

function UMG_MessageSettingList_C:RefreshGridViewToggleState()
  if self.dataList then
    for _, data in pairs(self.dataList) do
      data.IsToggled = self:CheckUserSubscribe(data.UniqueType)
    end
    self.List:InitGridView(self.dataList)
  end
end

function UMG_MessageSettingList_C:OnManagementBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MessageSettingList_C:OnManagementBtnClicked")
  local tpl = {
    Enum.UserSubscribeTplType.USER_SUBSCRIBE_TPL_TYPE_ACT,
    Enum.UserSubscribeTplType.USER_SUBSCRIBE_TPL_TYPE_FRIEND,
    Enum.UserSubscribeTplType.USER_SUBSCRIBE_TPL_TYPE_FUNC
  }
  local need_open_link = 1
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqGetUserSubscribeTplInfo, tpl, need_open_link)
end

function UMG_MessageSettingList_C:OnGridViewItemBtnDetailClicked()
  Log.Info("UMG_MessageSettingList_C:OnGridViewItemBtnDetailClicked")
  self.module:DispatchEvent(SystemSettingModuleEvent.DetailTipsShowNotify)
end

function UMG_MessageSettingList_C:OnCloseDetailTips()
  Log.Info("UMG_MessageSettingList_C:OnCloseDetailTips")
  if self.List then
    local itemCount = self.List:GetItemCount()
    for i = 1, itemCount do
      local itemData = self.List:GetItemByIndex(i - 1)
      if itemData then
        itemData:CloseDetailTips()
      end
    end
  end
end

function UMG_MessageSettingList_C:OnGetUserSubscribeTplInfo(rsp)
  if rsp.openlink and string.len(rsp.openlink) > 0 then
    Log.Info("openlink", rsp.openlink)
    local screenType = 2
    if RocoEnv.PLATFORM == "PLATFORM_WINDOWS" then
      screenType = 1
    end
    local isFullScreen = false
    local isUseURLEncode = true
    local entraJson = ""
    local bIsBrowser = false
    UE4.UWebViewStatics.OpenURL(rsp.openlink, screenType, isFullScreen, isUseURLEncode, entraJson, bIsBrowser)
  end
end

function UMG_MessageSettingList_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, SystemSettingModuleEvent.PlayerSettingUpdate, self.HandlePlayerSettingUpdate)
  if self.module then
    self.module:UnRegisterEvent(self, SystemSettingModuleEvent.CloseDetailTips)
    self.module:UnRegisterEvent(self, SystemSettingModuleEvent.GetUserSubscribeTplInfo)
    self.module:UnRegisterEvent(self, SystemSettingModuleEvent.CloudMessageManagementBtnOKClicked)
  end
  if self._permissionNotificationCheckID then
    UE.UNRCPermissionMgr.CancelIfRequestPermissionGrantedAsync(self._permissionNotificationCheckID)
    self._permissionNotificationCheckID = nil
  end
  if self._permissionNotificationRequestID then
    UE.UNRCPermissionMgr.CancelRequestPermissionCallback(self._permissionNotificationRequestID)
    self._permissionNotificationRequestID = nil
  end
end

return UMG_MessageSettingList_C
