local UMG_TakePhotos_Share_C = _G.NRCPanelBase:Extend("UMG_TakePhotos_Share_C")
local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")

function UMG_TakePhotos_Share_C:OnConstruct()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnBtnCloseClicked)
end

function UMG_TakePhotos_Share_C:OnBtnCloseClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_TakePhotos_Film_C:OnMouseButtonDown_ToggleSelectAll")
  self:DoClose()
end

function UMG_TakePhotos_Share_C:OnActive(PhotoData)
  self.PhotoData = PhotoData
  self:RegisterEvent(self, TakePhotosModuleEvent.OnReqSharePhoto, self.OnReqSharePhoto)
  local tableId = _G.DataConfigManager.ConfigTableId.SHARE_CONF
  local allData = _G.DataConfigManager:GetAllByTableID(tableId)
  local playerInfoData = _G.NRCModuleManager:DoCmd(_G.OnlineModuleCmd.GetUserAccountInfo)
  
  local function chooseLoginChannel(playerInfo, shareWayData, shareData)
    if playerInfo.loginChannelType == Enum.CliLoginChannel.CLC_WX then
      if shareWayData.login_required ~= Enum.ActivityLoginRequired.ALR_LOGIN_QQ then
        table.insert(shareData, shareWayData)
      end
    elseif playerInfo.loginChannelType == Enum.CliLoginChannel.CLC_QQ and shareWayData.login_required ~= Enum.ActivityLoginRequired.ALR_LOGIN_WECHAT then
      table.insert(shareData, shareWayData)
    end
  end
  
  local shareData = {}
  for _, shareWayData in ipairs(allData) do
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
  self.ShareList:InitGridView(shareData)
  self:SetCommonTitle()
  self:RefreshAvatar()
  self:RefreshPhotoData()
  self:PlayAnimation(self.In)
end

function UMG_TakePhotos_Share_C:Tick(MyGeometry, Dt)
  self:UpdateTransform()
end

function UMG_TakePhotos_Share_C:UpdateTransform()
  if self.FileTexture then
    local dpi = UE.UWidgetLayoutLibrary.GetViewportScale(UE4Helper.GetCurrentWorld())
    local Width = self.FileTexture:Blueprint_GetSizeX()
    local Height = self.FileTexture:Blueprint_GetSizeY()
    local DesiredViewportSize = self:GetModule().data:GetScreenSize()
    local DeltaWidth = DesiredViewportSize.X / Width
    local DeltaHeight = DesiredViewportSize.Y / Height
    local DesiredHeight = 0
    local DesiredWidth = 0
    local Scale = 1 / dpi
    if math.abs(DeltaWidth) >= math.abs(DeltaHeight) then
      DesiredHeight = DesiredViewportSize.Y * Scale
      DesiredWidth = DesiredHeight * Width / Height
    else
      DesiredWidth = DesiredViewportSize.X * Scale
      DesiredHeight = DesiredWidth * Height / Width
    end
    local CanvasSlot = self.CanvasPanel_153.Slot
    local Padding = CanvasSlot:GetOffsets()
    Padding.Left = -DesiredWidth / 2
    Padding.Top = -DesiredHeight / 2
    Padding.Right = DesiredWidth
    Padding.Bottom = DesiredHeight
    CanvasSlot:SetOffsets(Padding)
  end
end

function UMG_TakePhotos_Share_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_TakePhotos_Share_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    self.ShareBtnPlayIndex = 0
    self:DelaySeconds(0.1, FPartial(self.StartPlayShareBtnAnim, self))
  end
end

function UMG_TakePhotos_Share_C:StartPlayShareBtnAnim()
  if self.ShareBtnPlayIndex < self.ShareList:GetItemCount() then
    local index = self.ShareBtnPlayIndex
    self:PlayShareBtnAnim(index)
    self:PlayShareBtnAnim(index + 1)
    self.ShareBtnPlayIndex = self.ShareBtnPlayIndex + 2
    self:DelaySeconds(0.05, FPartial(self.StartPlayShareBtnAnim, self))
  end
end

function UMG_TakePhotos_Share_C:PlayShareBtnAnim(index)
  if index < self.ShareList:GetItemCount() then
    self.ShareList:GetItemByIndex(index):PlayInAnim()
  end
end

function UMG_TakePhotos_Share_C:GetPhotoTexture()
  return self.PhotoData:GetPhotoTexture2D()
end

function UMG_TakePhotos_Share_C:RefreshPhotoData()
  if not self.PhotoData then
    return
  end
  local FileTexture, Path = self:GetPhotoTexture()
  self.FileTexture = FileTexture
  if FileTexture then
    self.PhotoFile.Photo:SetBrush(UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(FileTexture))
    self.PhotoFile.Photo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.PhotoFile.Photo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self:UpdateTransform()
end

function UMG_TakePhotos_Share_C:RefreshAvatar()
  if not self.PhotoData then
    return
  end
  local bEnableWaterMask = self.PhotoData.bWaterMaskEnabled
  if bEnableWaterMask then
    self.PhotoFile.Text_WaterMark:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.PhotoFile.HeadPortrait:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.PhotoFile.Text_Name:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.PhotoFile.NRCImage_Logo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.PhotoFile.BG:SetVisibility(UE.ESlateVisibility.Collapsed)
    local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
    local CardInfo = PlayerInfo.additional_data.card_brief_info
    if CardInfo then
      local CardIconConf = _G.DataConfigManager:GetCardIconConf(CardInfo.card_icon_selected)
      if CardIconConf then
        local AvatarPath = CardIconConf.icon_resource_path
        AvatarPath = string.format("%s%s.%s'", "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/", AvatarPath, AvatarPath)
        self.PhotoFile.HeadPortrait:SetPath(AvatarPath)
      end
    else
      Log.Error("\230\178\161\230\156\137\233\187\152\232\174\164\229\144\141\231\137\135\229\164\180\229\131\143\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\144\142\229\143\176\230\149\176\230\141\174")
    end
    self.PhotoFile.Text_Name:SetText(PlayerInfo.name)
    self.PhotoFile.Text_WaterMark:SetText(string.format("UID:%s", PlayerInfo.uin))
  else
    self.PhotoFile.Text_WaterMark:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.PhotoFile.HeadPortrait:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.PhotoFile.Text_Name:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.PhotoFile.NRCImage_Logo:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.PhotoFile.BG:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_TakePhotos_Share_C:GetModule()
  return self.module
end

function UMG_TakePhotos_Share_C:OnDeactive()
  self.PhotoData = nil
  self:UnRegisterEvent(self, TakePhotosModuleEvent.OnReqSharePhoto)
end

function UMG_TakePhotos_Share_C:OnAddEventListener()
end

function UMG_TakePhotos_Share_C:OnReqSharePhoto(Way)
  if self.PhotoData then
    local PhotoPath = self.PhotoData:GetPhotoPath()
    local bWaterMaskEnabled = self.PhotoData.bWaterMaskEnabled
    local Names = string.split(PhotoPath, "/")
    local FileName = Names[#Names]
    if bWaterMaskEnabled then
      FileName = string.format("%s1.png", FileName)
    else
      FileName = string.format("%s0.png", FileName)
    end
    local TempPhotos = UE.UBlueprintPathsLibrary.Combine({
      UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
      "TempPhotos"
    })
    if not UE.UNRCStatics.DirectoryExists(TempPhotos) then
      UE.UNRCStatics.MakeDirectory(TempPhotos)
    end
    local WaterMaskPhotoPath = UE.UBlueprintPathsLibrary.Combine({TempPhotos, FileName})
    WaterMaskPhotoPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(WaterMaskPhotoPath)
    local Width = self.FileTexture:Blueprint_GetSizeX()
    local Height = self.FileTexture:Blueprint_GetSizeY()
    local DesiredSize = UE.FVector2D(Width, Height)
    local Result = UE.UPlatformImageLibrary.SaveUserWidgetToImageByCustomSize(UE4Helper.GetCurrentWorld(), self.PhotoFile, WaterMaskPhotoPath, DesiredSize)
    Log.Info("[TakePhoto] Share Photo:", WaterMaskPhotoPath, Way, Result)
    if Result then
      if "save" == Way then
        local function OnPermissionCallback()
          UE.UPlatformImageLibrary.SaveImageToAlbum(WaterMaskPhotoPath)
          
          if RocoEnv.PLATFORM_WINDOWS then
            _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.PC_Photo_Save_Tips)
          elseif RocoEnv.PLATFORM_OPENHARMONY then
            return
          else
            _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_save_succeed)
          end
        end
        
        if self.requestCode then
          UE.UNRCPermissionMgr.CancelRequestPermissionCallback(self.requestCode)
          self.requestCode = nil
        end
        local bGranted = UE.UNRCPermissionMgr.IfPermissionGranted(UE.ENRCPermissionType.AccessAlbum)
        if not bGranted and (RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_IOS or RocoEnv.PLATFORM_OPENHARMONY) then
          if not NRCModuleManager:DoCmd(ShareModuleCmd.CheckPermission, Way, UE.ENRCPermissionType.AccessAlbum) then
            return
          end
          self.requestCode = UE.UNRCPermissionMgr.RequestPermission(UE.ENRCPermissionType.AccessAlbum, {
            self,
            function(_, bGranted)
              self.requestCode = nil
              if bGranted then
                OnPermissionCallback()
              else
                self:LogError("[TakePhotos] !!!Permission!!!")
                _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_save_fail)
              end
            end
          })
        else
          OnPermissionCallback()
        end
      else
        local AbsolutePath = UE.UNRCStatics.ConvertToAbsolutePath(WaterMaskPhotoPath, true)
        NRCModuleManager:DoCmd(ShareModuleCmd.SharePic, AbsolutePath, Way)
      end
    end
  end
end

return UMG_TakePhotos_Share_C
