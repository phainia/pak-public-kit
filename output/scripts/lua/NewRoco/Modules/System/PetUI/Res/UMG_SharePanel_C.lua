local ShareModuleEnum = require("NewRoco.Modules.System.Share.ShareModuleEnum")
local UMG_SharePanel_C = _G.NRCPanelBase:Extend("UMG_SharePanel_C")
local NRCSDKManagerEvent = require("Core.Service.SDKManager.NRCSDKManagerEvent")

function UMG_SharePanel_C:OnConstruct()
  self:SetChildViews(self.PhotoSharing, self.VideoSharing, self.CardSharing)
  self:SetCommonTitle()
  self.bExp = true
  self.cardIndex = 1
  self.cardIds = {}
  self.unlockData = nil
  self.bCardDebugFirstOpen = true
end

function UMG_SharePanel_C:OnActive(index, petData)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    return
  end
  self.petData = self:GetNewPetData(petData)
  self.ShareBtnPlayIndex = 0
  self.IsLock = false
  self.Index = index
  self.IsAnimAllFinish = false
  self:InitShareWay()
  if 1 == index then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
    end
    self:ShowPhoto()
  elseif 2 == index then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[2].subtitle)
    end
    self:ShowVideo()
  elseif 3 == index then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[3].subtitle)
    end
    self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local req = ProtoMessage:newZoneGetShareFormInfoReq()
    req.pet_id = self.petData.base_conf_id
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_SHARE_FORM_INFO_REQ, req, self, self.ShowCard, false, true)
  end
  self:OnAddEventListener()
  self:BindInputAction()
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPetMainPanelVisibility, false)
end

function UMG_SharePanel_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_SharePanel_C:OnDeactive()
  if self.requestCode then
    UE.UNRCPermissionMgr.CancelRequestPermissionCallback(self.requestCode)
    self.requestCode = nil
  end
  self:RemoveButtonListener(self.CloseBtn.btnClose)
  self:RemoveButtonListener(self.Button)
  self:RemoveButtonListener(self.Btn1.btnLevelUp)
  self:RemoveButtonListener(self.Btn2.btnLevelUp)
  _G.NRCSDKManager:RemoveEventListener(self, NRCSDKManagerEvent.OnDeliverMessageNotify, self.SharePetSuccess)
end

function UMG_SharePanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickCloseBtn)
  self:AddButtonListener(self.Button, self.OnClickExpButton)
  self:AddButtonListener(self.Btn1.btnLevelUp, self.TurnLeft)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.TurnRight)
  _G.NRCSDKManager:AddEventListener(self, NRCSDKManagerEvent.OnDeliverMessageNotify, self.SharePetSuccess)
end

function UMG_SharePanel_C:ShowPhoto()
  self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PhotoSharing:Show(self.petData)
  self:PlayAnimation(self.In_one)
end

function UMG_SharePanel_C:ShowVideo()
  self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.VideoSharing:SetParent(self)
  self.VideoSharing:Show(self.petData)
  self.VideoSharing.PlayBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:PlayAnimation(self.In_video, 0)
  self:PauseAnimation(self.In_video)
  local globalConf = _G.DataConfigManager:GetGlobalConfig("share_video_endingframe_duration")
  local time = globalConf.num / 1000
  self:OnCancelDelayHandle()
  self.DelayHandle = _G.DelayManager:DelaySeconds(time, self.OpenShareVideo, self)
  self.VideoSharing:PlayStampInAnim()
end

function UMG_SharePanel_C:ShowCard(rsp)
  if rsp.ret_info and 0 == rsp.ret_info.ret_code then
    local shareConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_SHARE_ITEM_CONF):GetAllDatas()
    local cardBaseData = {}
    for _, v in pairs(shareConf) do
      if v.allowed_petbase == self.petData.base_conf_id then
        table.insert(cardBaseData, {
          v.id,
          v.share_pattern
        })
      end
    end
    local share_pattern = _G.DataConfigManager:GetSharePartConf(103).share_pattern
    local card_ids = {}
    for _, pattern in ipairs(share_pattern) do
      for _, v in ipairs(cardBaseData) do
        if v[2] == pattern then
          table.insert(card_ids, v[1])
          break
        end
      end
    end
    local unlockData = table.new(#card_ids, 0)
    if rsp.share_form_item then
      for i = 1, #card_ids do
        unlockData[i] = false
        for _, v in ipairs(rsp.share_form_item) do
          if v.id == card_ids[i] then
            unlockData[i] = true
            break
          end
        end
      end
    end
    local index = 1
    while index <= #card_ids do
      if not unlockData[index] and not _G.DataConfigManager:GetPetShareItemConf(card_ids[index]).is_show_unlock then
        table.remove(unlockData, index)
        table.remove(card_ids, index)
      else
        index = index + 1
      end
    end
    local openIndex
    for i = #unlockData, 1, -1 do
      if unlockData[i] then
        openIndex = i
        break
      end
    end
    self.CardPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.cardIds = card_ids
    self.unlockData = unlockData
    self.CardSharing:Init(self.petData, card_ids, unlockData)
    self:ChangeCard(openIndex)
    self:PlayAnimation(self.In)
  end
end

function UMG_SharePanel_C:ChangeCard(cardIndex)
  self.cardIndex = cardIndex
  local visible = self.unlockData[cardIndex] and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible
  self.Locked:SetVisibility(visible)
  self.CardSharing:SetMaskVisibility(visible)
  self.CardSharing:ChangeCard(cardIndex)
  if 1 == cardIndex then
    self.Btn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if #self.cardIds > 1 then
      self.Btn2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if cardIndex == #self.cardIds then
    self.Btn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if #self.cardIds > 1 then
      self.Btn1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if cardIndex > 1 and cardIndex < #self.cardIds then
    self.Btn1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if _G.DataConfigManager:GetPetShareItemConf(self.cardIds[cardIndex]).share_pattern == Enum.SharePattern.ASP_CARD_RARE then
    self.CardSharing.Slot:SetSize(UE4.FVector2D(1560, 580))
  else
    self.CardSharing.Slot:SetSize(UE4.FVector2D(1150, 800))
  end
end

function UMG_SharePanel_C:OpenCardDebugPanel()
  if self.bCardDebugFirstOpen then
    self.UMG_CardDebugPanel:SetCardPanel(self.CardSharing, self.petData.base_conf_id)
    self.bCardDebugFirstOpen = false
  end
  self.UMG_CardDebugPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_SharePanel_C:OpenShareVideo()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:PlayAnimation(self.In_video)
end

function UMG_SharePanel_C:OnAnimationFinished(Animation)
  if Animation == self.In_video then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.CloseShareCameraPanel)
    self.VideoSharing.PlayBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self:StartPlayShareBtnAnim()
  end
  if Animation == self.In_one or Animation == self.In then
    self:StartPlayShareBtnAnim()
  end
  if Animation == self.Out then
    if _G.GlobalConfig.DebugOpenUI then
      NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PlayShareVideoEnablePetMain, true)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPetMainPanelVisibility, true)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.VideoShareResetPetMainPet3D)
    self:DoClose()
  end
end

function UMG_SharePanel_C:OnClickCloseBtn()
  if not self.IsAnimAllFinish then
    return
  end
  self:PlayAnimation(self.Out)
end

function UMG_SharePanel_C:InitShareWay()
  local playerInfoData = _G.NRCModuleManager:DoCmd(_G.OnlineModuleCmd.GetUserAccountInfo)
  local tableId = _G.DataConfigManager.ConfigTableId.SHARE_CONF
  local allData = _G.DataConfigManager:GetAllByTableID(tableId)
  if playerInfoData.loginChannel == nil then
    self.NRCGridView_38:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  
  local function chooseLoginChannel(playerInfo, shareWayData, shareData)
    if playerInfo.loginChannelType == Enum.CliLoginChannel.CLC_WX then
      if shareWayData.login_required ~= Enum.ActivityLoginRequired.ALR_LOGIN_QQ then
        table.insert(shareData, shareWayData)
      end
    elseif playerInfo.loginChannelType == Enum.CliLoginChannel.CLC_QQ and shareWayData.login_required ~= Enum.ActivityLoginRequired.ALR_LOGIN_WECHAT then
      table.insert(shareData, shareWayData)
    end
  end
  
  local shareType = Enum.ShareType.STP_IMAGE
  if 2 == self.Index then
    shareType = Enum.ShareType.STP_VIDEO
  end
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
      elseif RocoEnv.PLATFORM_OPENHARMONY then
        if table.contains(shareWayData.login_plat, Enum.PlatType.PT_HARMONY_OS) then
          chooseLoginChannel(playerInfoData, shareWayData, shareData)
        end
      elseif RocoEnv.PLATFORM_IOS and table.contains(shareWayData.login_plat, Enum.PlatType.PT_IOS) then
        chooseLoginChannel(playerInfoData, shareWayData, shareData)
      end
    end
  end
  self.NRCGridView_38:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRCGridView_38:InitGridView(shareData)
end

function UMG_SharePanel_C:StartPlayShareBtnAnim()
  if not self.NRCGridView_38 or self.NRCGridView_38:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    self.IsAnimAllFinish = true
    return
  end
  if self.ShareBtnPlayIndex then
    if self.ShareBtnPlayIndex < self.NRCGridView_38:GetItemCount() then
      local index = self.ShareBtnPlayIndex
      self:PlayShareBtnAnim(index)
      self:PlayShareBtnAnim(index + 1)
      self.ShareBtnPlayIndex = self.ShareBtnPlayIndex + 2
      self:OnCancelDelayHandle()
      self.DelayHandle = _G.DelayManager:DelaySeconds(0.05, self.StartPlayShareBtnAnim, self)
    else
      self.IsAnimAllFinish = true
    end
  end
end

function UMG_SharePanel_C:PlayShareBtnAnim(index)
  if index < self.NRCGridView_38:GetItemCount() then
    self.NRCGridView_38:GetItemByIndex(index):PlayInAnim()
  end
end

function UMG_SharePanel_C:DownloadSharePet(way, gid)
  if self.IsLock then
    return
  end
  if 1 == self.Index then
    self:SharePetPhoto(way, gid)
  elseif 2 == self.Index then
    self:SharePetVideo(way, gid)
  elseif 3 == self.Index then
    if self.unlockData[self.cardIndex] then
      self:SharePetCard(way, gid)
    else
      self.CardSharing:ShowTips()
    end
  end
end

function UMG_SharePanel_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_SharePanel")
  if mappingContext then
    mappingContext:BindAction("IA_CloseSharePanel", self, "OnPcClose2")
  end
end

function UMG_SharePanel_C:OnPcClose2()
  if self:GetVisibility() ~= UE4.ESlateVisibility.Visible and self:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
    return
  end
  self:OnClickCloseBtn()
end

function UMG_SharePanel_C:SharePetCard(way, gid)
  self.IsLock = true
  local TempPhotos = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "TempPhotos"
  })
  local SavePath = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectSavedDir(),
    "PhotoScreenshots"
  })
  if not UE.UNRCStatics.DirectoryExists(TempPhotos) then
    UE.UNRCStatics.MakeDirectory(TempPhotos)
  end
  if not UE.UNRCStatics.DirectoryExists(SavePath) then
    UE.UNRCStatics.MakeDirectory(SavePath)
  end
  local GUID = UE.UKismetGuidLibrary.NewGuid()
  local FileNameTmp = UE.UKismetGuidLibrary.Conv_GuidToString(GUID)
  local FileName = tostring(gid) ~= nil and tostring(gid) or FileNameTmp
  local pathIndex = 1
  local PhotoPath
  while true do
    local NewFileName = FileName .. "_" .. tostring(pathIndex) .. ".png"
    PhotoPath = UE.UBlueprintPathsLibrary.Combine({SavePath, NewFileName})
    PhotoPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
    if UE4.UBlueprintPathsLibrary.FileExists(PhotoPath) then
      pathIndex = pathIndex + 1
    else
      PhotoPath = NewFileName
      break
    end
  end
  PhotoPath = UE.UBlueprintPathsLibrary.Combine({TempPhotos, PhotoPath})
  PhotoPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
  
  local function OnPermissionCallback(moveToAlbum)
    self.IsLock = false
    if UE.UPlatformImageLibrary.SaveUserWidgetToImage(UE4Helper.GetCurrentWorld(), self.CardSharing, PhotoPath, false, 2) then
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
    self.IsLock = false
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
    self.IsLock = false
    local absolutePath = UE.UNRCStatics.ConvertToAbsolutePath(PhotoPath, true)
    if UE.UNRCStatics.FileExists(PhotoPath) then
      NRCModuleManager:DoCmd(ShareModuleCmd.SharePic, absolutePath, way)
    elseif UE.UPlatformImageLibrary.SaveUserWidgetToImage(UE4Helper.GetCurrentWorld(), self.CardSharing, PhotoPath, false, 2) then
      NRCModuleManager:DoCmd(ShareModuleCmd.SharePic, absolutePath, way)
    else
      Log.Error("save widget error")
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.share_fail_tips, nil, nil, 2)
    end
  end
end

function UMG_SharePanel_C:SharePetPhoto(way, gid)
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
  local FileName = FileNameTmp .. ".png"
  local PhotoPath = UE.UBlueprintPathsLibrary.Combine({TempPhotos, FileName})
  PhotoPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
  
  local function OnPermissionCallback(moveToAlbum)
    self:SetSharePhotoLock(false)
    if UE.UPlatformImageLibrary.SaveUserWidgetToImage(UE4Helper.GetCurrentWorld(), self.PhotoSharing, PhotoPath) then
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
  if not bGranted and (RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_IOS or RocoEnv.PLATFORM_OPENHARMONY) then
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

function UMG_SharePanel_C:SharePetVideo(way, gid)
  self:SendTLog(way, 1)
  if "save" == way then
    NRCModuleManager:DoCmd(ShareModuleCmd.SaveVideoToAlbum, gid)
  else
    NRCModuleManager:DoCmd(ShareModuleCmd.ShareLocalVideo, way, gid)
  end
end

function UMG_SharePanel_C:SharePetSuccess(baseRet)
  if 0 ~= baseRet.retCode then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.share_fail_tips, nil, nil, 2)
  end
end

function UMG_SharePanel_C:SetSharePhotoLock(enable)
  if self.IsLock == enable then
    return
  end
  self.IsLock = enable
  self.PhotoSharing.UMG_PetImage3D:SetSharePhotoPetAnim(enable)
end

function UMG_SharePanel_C:GetNewPetData(petData)
  if not petData then
    Log.Error("UMG_SharePanel_C:GetNewPetData petdata is nil")
    return petData
  end
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if battlePetList then
    for i, data in ipairs(battlePetList) do
      if petData.gid == data.gid then
        return data
      end
    end
  end
  local backpackPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  if backpackPetList then
    for i, data in ipairs(backpackPetList) do
      if petData.gid == data.gid then
        return data
      end
    end
  end
  local housePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerHousePetInfo()
  if housePetList then
    for i, data in ipairs(housePetList) do
      if petData.gid == data.gid then
        return data
      end
    end
  end
  return petData
end

function UMG_SharePanel_C:SendTLog(shareWay, shareType)
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
  local petBaseConfId = self.petData.base_conf_id
  local gid = self.petData.gid
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
  local shareSource = 0
  local value = string.format(tempString, gameServerId, gameTime, gameAppId, platId, zoneId, openId, uin, roleName, level, petBaseConfId, gid, shareType, shareWay, miniShare, shareSource)
  _G.GEMPostManager:SendNRCTLog(key, value)
end

function UMG_SharePanel_C:OnClickExpButton()
  if not self.IsAnimAllFinish or not self.CardSharing:GetCanChange() then
    return
  end
  self.bExp = not self.bExp
  self.CardSharing:SetExp(self.bExp)
  if self.bExp then
    self:PlayAnimation(self.Check1)
  else
    self:PlayAnimation(self.Off)
  end
end

function UMG_SharePanel_C:TurnLeft()
  if not self.IsAnimAllFinish or not self.CardSharing:GetCanChange() then
    return
  end
  self:ChangeCard(self.cardIndex - 1)
end

function UMG_SharePanel_C:TurnRight()
  if not self.IsAnimAllFinish or not self.CardSharing:GetCanChange() then
    return
  end
  self:ChangeCard(self.cardIndex + 1)
end

function UMG_SharePanel_C:OnCardExpire(expireId)
  local expireIndex
  for i = 1, #self.cardIds do
    if self.cardIds[i] == expireId then
      expireIndex = i
      break
    end
  end
  if expireIndex then
    self.unlockData[expireIndex] = false
    if self.cardIndex == expireIndex then
      self.Locked:SetVisibility(UE4.ESlateVisibility.Visible)
      self.CardSharing:SetMask(UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_SharePanel_C:DoClose()
  if _G.NRCModuleManager:DoCmd(PetUIModuleCmd.IsShareRecordVideo) then
    _G.NRCModuleManager:DoCmd(ShareModuleCmd.EndRecordVideo, self.petData.gid)
  end
  self:OnCancelDelayHandle()
  _G.NRCPanelBase.DoClose(self)
end

function UMG_SharePanel_C:OnCancelDelayHandle()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
end

return UMG_SharePanel_C
