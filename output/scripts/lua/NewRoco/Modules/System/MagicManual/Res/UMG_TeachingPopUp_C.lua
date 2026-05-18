local UMG_TeachingPopUp_C = _G.NRCPanelBase:Extend("UMG_TeachingPopUp_C")

function UMG_TeachingPopUp_C:OnActive(conf)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400007, "UMG_TeachingPopUp_C:OnActive")
  self:LoadAnimation(0)
  self.conf = conf
  self.Image_35:SetPath(conf.type_advantage_resource)
  self.ImageText:SetText(conf.type_advantage_depict)
  self.Describe1:SetText(conf.type_display)
  local tipsText = _G.DataConfigManager:GetGlobalConfigStrByKey("type_advantage_pic_save", "")
  self.ContentText:SetText(tipsText)
  self:AddButtonListener(self.FullScreen_Close, self.onCloseClick)
  self:AddButtonListener(self.DownloadBtn.btnLevelUp, self.DownloadBtnClick)
  self:AddButtonListener(self.CloseBtn.btnClose, self.onCloseClick)
end

function UMG_TeachingPopUp_C:OnDeactive()
end

function UMG_TeachingPopUp_C:GetPhotoPath()
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
  return PhotoPath
end

function UMG_TeachingPopUp_C:DownloadBtnClick()
  if not self or not UE.UObject.IsValid(self) then
    return
  end
  if RocoEnv.IS_EDITOR then
    local TempPhotos = RocoEnv.IS_EDITOR and UE.UBlueprintPathsLibrary.Combine({
      UE4.UBlueprintPathsLibrary.ProjectSavedDir(),
      "PhotoScreenshots"
    }) or UE.UBlueprintPathsLibrary.Combine({
      UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
      "TempPhotos"
    })
    if not UE.UNRCStatics.DirectoryExists(TempPhotos) then
      UE.UNRCStatics.MakeDirectory(TempPhotos)
    end
    local PhotoPath
    PhotoPath = UE.UBlueprintPathsLibrary.Combine({
      TempPhotos,
      string.format("%s.png", self.conf.type_display_name)
    })
    PhotoPath = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
    if UE.UPlatformImageLibrary.SaveWidgetToImage(UE4Helper.GetCurrentWorld(), self.PopUps, PhotoPath) then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.save_success_location, PhotoPath), nil, nil, 2)
    else
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.save_fail_tips, nil, nil, 2)
    end
  else
    local PhotoPath = self:GetPhotoPath()
    if UE.UPlatformImageLibrary.SaveWidgetToImage(UE4Helper.GetCurrentWorld(), self.PopUps, PhotoPath) then
      local destPath = UE.UPlatformImageLibrary.SaveImageToAlbum(PhotoPath)
      if RocoEnv.PLATFORM_WINDOWS then
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.save_success_location, destPath), nil, nil, 2)
      elseif RocoEnv.PLATFORM_OPENHARMONY then
        return
      else
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.save_success_tips, nil, nil, 2)
      end
    else
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.save_fail_tips, nil, nil, 2)
    end
  end
end

function UMG_TeachingPopUp_C:onCloseClick()
  if self:IsAnyAnimationPlaying() then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400008, "UMG_TeachingPopUp_C:onCloseClick")
  self:LoadAnimation(2)
end

function UMG_TeachingPopUp_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_TeachingPopUp_C
