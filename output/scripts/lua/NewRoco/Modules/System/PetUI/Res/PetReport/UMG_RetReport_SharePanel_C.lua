local NRCSDKManagerEvent = require("Core.Service.SDKManager.NRCSDKManagerEvent")
local UMG_RetReport_SharePanel_C = _G.NRCPanelBase:Extend("UMG_RetReport_SharePanel_C")

function UMG_RetReport_SharePanel_C:OnActive(data)
  self.uiData = data
  self.IsLock = false
  self:OnAddEventListener()
  self:InitUI()
  _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_RetReport_SharePanel_C:OnActive")
  self:PlayAnimation(self.In)
end

function UMG_RetReport_SharePanel_C:OnDeactive()
  if self.requestCode then
    UE.UNRCPermissionMgr.CancelRequestPermissionCallback(self.requestCode)
    self.requestCode = nil
  end
  _G.NRCSDKManager:RemoveEventListener(self, NRCSDKManagerEvent.OnDeliverMessageNotify, self.SharePetSuccess)
end

function UMG_RetReport_SharePanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickedClose)
  _G.NRCSDKManager:AddEventListener(self, NRCSDKManagerEvent.OnDeliverMessageNotify, self.SharePetSuccess)
end

function UMG_RetReport_SharePanel_C:InitUI()
  self:InitParticularsUI()
  self:InitCommonTitle()
  self:InitShareWay()
end

function UMG_RetReport_SharePanel_C:InitParticularsUI()
  self.Particulars_Share:InitUI(self.uiData)
  self.Particulars_Share:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_RetReport_SharePanel_C:InitCommonTitle()
  local titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  if titleConf then
    self.Title1:Set_MainTitle(titleConf.title)
    self.Title1:SetBg(titleConf.head_icon)
    self.Title1:SetSubtitle(titleConf.subtitle[1].subtitle)
  end
end

function UMG_RetReport_SharePanel_C:InitShareWay()
  local playerInfoData = _G.NRCModuleManager:DoCmd(_G.OnlineModuleCmd.GetUserAccountInfo)
  local tableId = _G.DataConfigManager.ConfigTableId.SHARE_CONF
  local allData = _G.DataConfigManager:GetAllByTableID(tableId)
  if playerInfoData.loginChannel == nil then
    self.NRCGridView_38:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  
  local function chooseLoginChannel(playerInfo, shareWayData, shareData)
    local data = {}
    data.name = shareWayData.name
    data.share_icon = shareWayData.share_icon
    data.bPetReport = true
    if self.uiData and self.uiData.pet_brief and self.uiData.pet_brief.gid then
      data.gid = self.uiData.pet_brief.gid
    end
    if playerInfo.loginChannelType == Enum.CliLoginChannel.CLC_WX then
      if shareWayData.login_required ~= Enum.ActivityLoginRequired.ALR_LOGIN_QQ then
        table.insert(shareData, data)
      end
    elseif playerInfo.loginChannelType == Enum.CliLoginChannel.CLC_QQ and shareWayData.login_required ~= Enum.ActivityLoginRequired.ALR_LOGIN_WECHAT then
      table.insert(shareData, data)
    end
  end
  
  local shareType = Enum.ShareType.STP_IMAGE
  local shareData = {}
  for _, shareWayData in ipairs(allData) do
    if table.contains(shareWayData.share_type, shareType) then
      if RocoEnv.PLATFORM_WINDOWS then
        if table.contains(shareWayData.login_plat, Enum.PlatType.PT_PC) then
          chooseLoginChannel(playerInfoData, shareWayData, shareData)
        end
      elseif RocoEnv.PLATFORM_ANDROID then
        if table.contains(shareWayData.login_plat, Enum.PlatType.PT_ANDROID) then
          chooseLoginChannel(playerInfoData, shareWayData, shareData)
        end
      elseif RocoEnv.PLATFORM_IOS then
        if table.contains(shareWayData.login_plat, Enum.PlatType.PT_IOS) then
          chooseLoginChannel(playerInfoData, shareWayData, shareData)
        end
      elseif RocoEnv.PLATFORM_OPENHARMONY and table.contains(shareWayData.login_plat, Enum.PlatType.PT_HARMONY_OS) then
        chooseLoginChannel(playerInfoData, shareWayData, shareData)
      end
    end
  end
  self.NRCGridView_38:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRCGridView_38:InitGridView(shareData)
end

function UMG_RetReport_SharePanel_C:SharePetPhoto(way, gid)
  if self.IsLock then
    return
  end
  self:SendTLog(way, 0)
  self:SetSharePhotoLock(true)
  local TempPhotos = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "TempPhotos"
  })
  if not UE.UNRCStatics.DirectoryExists(TempPhotos) then
    UE.UNRCStatics.MakeDirectory(TempPhotos)
  end
  local GUID = UE.UKismetGuidLibrary.NewGuid()
  local FileNameTmp = UE.UKismetGuidLibrary.Conv_GuidToString(GUID)
  local FileName = tostring(gid) ~= nil and tostring(gid) or FileNameTmp
  FileName = "PetReport" .. FileName .. ".png"
  local PhotoPath = UE.UBlueprintPathsLibrary.Combine({TempPhotos, FileName})
  PhotoPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
  
  local function OnPermissionCallback(moveToAlbum)
    self:SetSharePhotoLock(false)
    if UE.UPlatformImageLibrary.SaveUserWidgetToImage(UE4Helper.GetCurrentWorld(), self.Particulars_Share, PhotoPath) then
      if moveToAlbum then
        local destPath = UE.UPlatformImageLibrary.SaveImageToAlbum(PhotoPath)
        if RocoEnv.PLATFORM_WINDOWS then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.save_success_location, destPath), nil, nil, 2)
        elseif RocoEnv.PLATFORM_OPENHARMONY then
          return
        else
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.save_success_tips, nil, nil, 2)
        end
      end
    else
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.save_fail_tips, nil, nil, 2)
    end
  end
  
  if self.requestCode then
    UE.UNRCPermissionMgr.CancelRequestPermissionCallback(self.requestCode)
    self.requestCode = nil
  end
  local bGranted = UE.UNRCPermissionMgr.IfPermissionGranted(UE.ENRCPermissionType.AccessAlbum)
  if not bGranted and (RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_IOS) then
    self:SetSharePhotoLock(false)
    if not NRCModuleManager:DoCmd(ShareModuleCmd.CheckPermission, way, UE.ENRCPermissionType.AccessAlbum) then
      return
    end
    self.requestCode = UE.UNRCPermissionMgr.RequestPermission(UE.ENRCPermissionType.AccessAlbum, {
      self,
      function(_, bGranted)
        self.requestCode = nil
        if bGranted then
          OnPermissionCallback("save" == way)
        else
          self:LogError("!!!Permission!!!")
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.save_fail_tips, nil, nil, 2)
        end
      end
    })
  else
    OnPermissionCallback("save" == way)
  end
  if "save" ~= way then
    self:SetSharePhotoLock(false)
    local absolutePath = UE.UNRCStatics.ConvertToAbsolutePath(PhotoPath, true)
    if UE.UNRCStatics.FileExists(PhotoPath) then
      NRCModuleManager:DoCmd(ShareModuleCmd.SharePic, absolutePath, way)
    elseif UE.UPlatformImageLibrary.SaveUserWidgetToImage(UE4Helper.GetCurrentWorld(), self.PhotoSharing, PhotoPath) then
      NRCModuleManager:DoCmd(ShareModuleCmd.SharePic, absolutePath, way)
    else
      Log.Error("save widget error")
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.share_fail_tips, nil, nil, 2)
    end
  end
end

function UMG_RetReport_SharePanel_C:SharePetSuccess(baseRet)
  if 0 ~= baseRet.retCode then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.share_fail_tips, nil, nil, 2)
  end
end

function UMG_RetReport_SharePanel_C:SetSharePhotoLock(enable)
  if self.IsLock == enable then
    return
  end
  self.IsLock = enable
end

function UMG_RetReport_SharePanel_C:OnClickedClose()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_RetReport_SharePanel_C:OnActive")
  self:PlayAnimation(self.Out)
end

function UMG_RetReport_SharePanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  end
end

function UMG_RetReport_SharePanel_C:SendTLog(shareWay, shareType)
  if self.uiData.pet_brief and self.uiData.pet_brief.base_conf_id and self.uiData.pet_brief.gid then
    local key = "PetShareLog"
    local tempString = "PetShareLog|%s|%s|%s|%d|%d|%s|%d|%s|%d|%d|%d|%d|%s|%d|%d"
    local gameServerId = "nil"
    local gameTime = os.date("%Y-%m-%d %H:%M:%S")
    local gameAppId = "1110613799"
    local platId = -1
    local zoneId = 0
    local openId = "nil"
    local uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin() or 0
    local roleName = _G.DataModelMgr.PlayerDataModel:GetPlayerName() or "nil"
    local level = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
    local petBaseConfId = self.uiData.pet_brief.base_conf_id
    local gid = self.uiData.pet_brief.gid
    local miniShare = 1
    if _G.OnlineModuleCmd then
      local needData = _G.NRCModuleManager:DoCmd(_G.OnlineModuleCmd.GetUserAccountInfo)
      if needData and type(needData) == "table" then
        gameServerId = needData.serverName or "nil"
        platId = needData.plat_info.plat_id or -1
        zoneId = needData.zoneId or 0
        openId = needData.openid or "nil"
      end
    end
    if "WeChatFriend" == shareWay or "WeChatMoments" == shareWay or "QQFriend" == shareWay or "Qzone" == shareWay then
      miniShare = 0
    end
    local shareSource = 1
    local value = string.format(tempString, gameServerId, gameTime, gameAppId, platId, zoneId, openId, uin, roleName, level, petBaseConfId, gid, shareType, shareWay, miniShare, shareSource)
    _G.GEMPostManager:SendNRCTLog(key, value)
  end
end

return UMG_RetReport_SharePanel_C
