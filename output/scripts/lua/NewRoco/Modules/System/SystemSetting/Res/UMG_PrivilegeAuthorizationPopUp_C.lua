local UMG_PrivilegeAuthorizationPopUp_C = _G.NRCPanelBase:Extend("UMG_PrivilegeAuthorizationPopUp_C")
local NativePrivilegeType = {
  PhoneState = "PhoneState",
  Camera = "Camera",
  Location = "Location",
  Microphone = "Microphone",
  Photo = "Photo",
  LocalNetwork = "LocalNetwork",
  Calendar = "Calendar",
  SMS = "SMS",
  ExternalCard = "ExternalCard",
  Notifications = "Notifications"
}
local AuthorityItemDataDic = {
  [NativePrivilegeType.Camera] = {
    PrivilegeName = LuaText.privacy_setting_23,
    PrivilegeDesc = LuaText.privacy_setting_24,
    PrivilegeType = NativePrivilegeType.Camera,
    UEPrivilegeType = UE.ENRCPermissionType.Camera
  },
  [NativePrivilegeType.Location] = {
    PrivilegeName = LuaText.privacy_setting_25,
    PrivilegeDesc = LuaText.privacy_setting_26,
    PrivilegeType = NativePrivilegeType.Location,
    UEPrivilegeType = UE.ENRCPermissionType.Location
  },
  [NativePrivilegeType.Microphone] = {
    PrivilegeName = LuaText.privacy_setting_27,
    PrivilegeDesc = LuaText.privacy_setting_28,
    PrivilegeType = NativePrivilegeType.Microphone,
    UEPrivilegeType = UE.ENRCPermissionType.RecordAudio
  },
  [NativePrivilegeType.Photo] = {
    PrivilegeName = LuaText.privacy_setting_15,
    PrivilegeDesc = LuaText.privacy_setting_16,
    PrivilegeType = NativePrivilegeType.Photo,
    UEPrivilegeType = UE.ENRCPermissionType.AccessAlbum
  },
  [NativePrivilegeType.Calendar] = {
    PrivilegeName = LuaText.privacy_setting_21,
    PrivilegeDesc = LuaText.privacy_setting_22,
    PrivilegeType = NativePrivilegeType.Calendar,
    UEPrivilegeType = UE.ENRCPermissionType.Calendar
  },
  [NativePrivilegeType.LocalNetwork] = {
    PrivilegeName = LuaText.privacy_setting_29,
    PrivilegeDesc = LuaText.privacy_setting_30,
    PrivilegeType = NativePrivilegeType.LocalNetwork,
    UEPrivilegeType = UE.ENRCPermissionType.LocalNetwork
  },
  [NativePrivilegeType.PhoneState] = {
    PrivilegeName = LuaText.privacy_setting_31,
    PrivilegeDesc = LuaText.privacy_setting_32,
    PrivilegeType = NativePrivilegeType.PhoneState,
    UEPrivilegeType = UE.ENRCPermissionType.PhoneState
  },
  [NativePrivilegeType.SMS] = {
    PrivilegeName = LuaText.privacy_setting_33,
    PrivilegeDesc = LuaText.privacy_setting_34,
    PrivilegeType = NativePrivilegeType.SMS,
    UEPrivilegeType = UE.ENRCPermissionType.SMS
  },
  [NativePrivilegeType.ExternalCard] = {
    PrivilegeName = LuaText.privacy_setting_17,
    PrivilegeDesc = LuaText.privacy_setting_18,
    PrivilegeType = NativePrivilegeType.ExternalCard,
    UEPrivilegeType = UE.ENRCPermissionType.ExternalCard
  },
  [NativePrivilegeType.Notifications] = {
    PrivilegeName = LuaText.privacy_setting_41,
    PrivilegeDesc = LuaText.privacy_setting_42,
    PrivilegeType = NativePrivilegeType.Notifications,
    UEPrivilegeType = UE.ENRCPermissionType.Notifications
  }
}
local IOSAuthorityItemDatas = {
  NativePrivilegeType.Microphone,
  NativePrivilegeType.Photo,
  NativePrivilegeType.Notifications
}
local AndroidAuthorityItemDatas = {
  NativePrivilegeType.Microphone,
  NativePrivilegeType.Photo,
  NativePrivilegeType.Notifications
}
local OpenHarmonyAuthorityItemDatas = {
  NativePrivilegeType.Microphone,
  NativePrivilegeType.Photo,
  NativePrivilegeType.Notifications
}

function UMG_PrivilegeAuthorizationPopUp_C:OnActive(...)
  NRCPanelBase.OnActive(self, ...)
  self.permissionRequestID = nil
  self.requestID2PermissionTypeDic = {}
  local authorityItemDatas = {}
  local dataList = {}
  if RocoEnv.PLATFORM_ANDROID then
    authorityItemDatas = AndroidAuthorityItemDatas
  elseif RocoEnv.PLATFORM_IOS then
    authorityItemDatas = IOSAuthorityItemDatas
  elseif RocoEnv.PLATFORM_OPENHARMONY then
    authorityItemDatas = OpenHarmonyAuthorityItemDatas
  else
    for _, v in pairs(NativePrivilegeType) do
      table.insert(authorityItemDatas, v)
    end
  end
  for _, privilegeType in ipairs(authorityItemDatas) do
    local data = AuthorityItemDataDic[privilegeType]
    if data then
      local authorizationItemData = {
        PrivilegeName = data.PrivilegeName,
        PrivilegeDesc = data.PrivilegeDesc,
        PrivilegeType = data.PrivilegeType,
        OnBtnGoSetClickCallbackOwner = self,
        OnBtnGoSetClickCallback = self.OnBtnGoToSetClick
      }
      table.insert(dataList, authorizationItemData)
    end
  end
  self.List:InitGridView(dataList)
  self:SetCommonPopUpInfo(self.PopUp)
  self:LoadAnimation(0)
end

function UMG_PrivilegeAuthorizationPopUp_C:OnDeactive()
  NRCPanelBase.OnDeactive(self)
  if self.permissionRequestID then
    UE.UNRCPermissionMgr.CancelRequestPermissionCallback(self.permissionRequestID)
    self.permissionRequestID = nil
  end
  self.requestID2PermissionTypeDic = {}
end

function UMG_PrivilegeAuthorizationPopUp_C:OnConstruct()
  self:DynamicAddChildView(self.PopUp)
end

function UMG_PrivilegeAuthorizationPopUp_C:OnDestruct()
end

function UMG_PrivilegeAuthorizationPopUp_C:OnBtnGoToSetClick(privilegeType)
  Log.Info("UMG_PrivilegeAuthorizationPopUp_C:OnBtnGoSetClickCallback ", privilegeType)
  if AuthorityItemDataDic[privilegeType] then
    local uePermissionType = AuthorityItemDataDic[privilegeType].UEPrivilegeType
    if not UE.UNRCPermissionMgr.IfRequestPermissionSupport(uePermissionType) then
      Log.Error("unsupport privilege ", privilegeType)
      UE.UNRCPermissionMgr.JumpToSysSetting()
      Log.Info("UMG_PrivilegeAuthorizationPopUp_C:JumpToSysSetting")
    elseif RocoEnv.PLATFORM_IOS then
      if UE.UNRCPermissionMgr.IsFirstTimeRequest(uePermissionType) then
        Log.Info("UMG_PrivilegeAuthorizationPopUp_C firstTime ", privilegeType)
        if self.permissionRequestID then
          UE.UNRCPermissionMgr.CancelRequestPermissionCallback(self.permissionRequestID)
          self.requestID2PermissionTypeDic[self.permissionRequestID] = nil
          self.permissionRequestID = nil
        end
        self.permissionRequestID = UE.UNRCPermissionMgr.RequestPermission(uePermissionType, SimpleDelegateFactory:CreateCallback(self, self.OnRequestPermissionCallback))
        self.requestID2PermissionTypeDic[self.permissionRequestID] = privilegeType
      else
        Log.Info("UMG_PrivilegeAuthorizationPopUp_C:JumpToSysSetting")
        UE.UNRCPermissionMgr.JumpToSysSetting()
      end
    elseif RocoEnv.PLATFORM_ANDROID then
      if privilegeType == NativePrivilegeType.Notifications then
        UE.UNRCPermissionMgr.JumpToSysSetting()
        return
      end
      UE.UNativeExtensionUtils.NativeRequestPlatoformPrivilegeAuthority(privilegeType)
    elseif RocoEnv.PLATFORM_OPENHARMONY then
      UE.UNRCPermissionMgr.JumpToSysSetting()
      return
    end
  end
end

function UMG_PrivilegeAuthorizationPopUp_C:OnRequestPermissionCallback(bGranted)
  local requestID = self.permissionRequestID
  self.permissionRequestID = nil
  local privilegeType = self.requestID2PermissionTypeDic[requestID]
  Log.Info("UMG_PrivilegeAuthorizationPopUp_C:OnBtnGoSetClickCallback ", privilegeType, bGranted)
end

function UMG_PrivilegeAuthorizationPopUp_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnPcClose
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_PrivilegeAuthorizationPopUp_C:OnPcClose()
  self:Log("OnPcClose")
  self:LoadAnimation(2)
end

function UMG_PrivilegeAuthorizationPopUp_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_PrivilegeAuthorizationPopUp_C
