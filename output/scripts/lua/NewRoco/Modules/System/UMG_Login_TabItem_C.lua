local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local UMG_Login_TabItem_C = _G.NRCPanelBase:Extend("UMG_Login_TabItem_C")

function UMG_Login_TabItem_C:OnConstruct()
  self:PlayAnimation(self.normal)
  self.index = nil
  self.isSelect = false
  self:OnAddEventListener()
  self.RedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RedDotOriginalTranslation = UE4.FVector2D(self.RedDot.RenderTransform.Translation.X, self.RedDot.RenderTransform.Translation.Y)
end

function UMG_Login_TabItem_C:OnDestruct()
end

function UMG_Login_TabItem_C:OnActive(index)
  self.index = index
  self:SetPath()
end

function UMG_Login_TabItem_C:OnDeactive()
end

function UMG_Login_TabItem_C:OnAddEventListener()
  self:AddButtonListener(self.btnLevelUp, self.OnItemSelected)
end

function UMG_Login_TabItem_C:OnItemSelected()
  local CurSelectBtnIndex = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetSelectTabIndex)
  if CurSelectBtnIndex ~= self.index then
    _G.NRCModuleManager:DoCmd(LoginModuleCmd.SetSelectTabIndex, self.index)
    self:IsSelect(true)
  end
  if 1 == self.index then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.OnClickAnnouncement)
  elseif 2 == self.index then
    _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_Login_TabItem_C:OnItemSelected")
    _G.NRCModuleManager:DoCmd(UpdateUIModuleCmd.OpenRepairToolsPanel)
  elseif 3 == self.index then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.OnClickAccountSwitch)
  elseif 4 == self.index then
  elseif 5 == self.index then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.OnClickExitGame)
  elseif 6 == self.index then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.BtnAutoGameClick)
  elseif 7 == self.index then
  elseif 8 == self.index then
    _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_Login_TabItem_C:OnItemSelected")
    _G.NRCModuleManager:DoCmd(LoginModuleCmd.OnOpenScanLoginPanel)
  elseif 9 == self.index then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.OnClickCustomerService)
  elseif 10 == self.index then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.OnBtnDownloadClick)
  end
end

function UMG_Login_TabItem_C:RemoveSelected(selectIndex)
  if selectIndex == self.index then
    self:StopAllAnimations()
    self:IsSelect(false)
  end
end

function UMG_Login_TabItem_C:SetPath(btnType)
  if btnType then
  elseif 1 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_gonggao_png.img_gonggao_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_gonggao1_png.img_gonggao1_png'")
  elseif 2 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_xiufu_png.img_xiufu_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_xiufu1_png.img_xiufu1_png'")
  elseif 3 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_zhuxiao_png.img_zhuxiao_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_zhuxiao1_png.img_zhuxiao1_png'")
  elseif 4 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_Notification1_png.img_Notification1_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_Notification2_png.img_Notification2_png'")
  elseif 5 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_Off_png.img_Off_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_Off1_png.img_Off1_png'")
  elseif 6 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_Off_png.img_Off_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_Off1_png.img_Off1_png'")
  elseif 8 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_saoma_png.img_saoma_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_saoma1_png.img_saoma1_png'")
  elseif 9 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_kefu_png.img_kefu_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_kefu1_png.img_kefu1_png'")
  elseif 10 == self.index then
    self.Ordinary:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_xiazaiwancheng1_png.img_xiazaiwancheng1_png'")
    self.PitchOn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_xiazaiwancheng2_png.img_xiazaiwancheng2_png'")
  end
end

function UMG_Login_TabItem_C:IsSelect(_IsSelect)
  if _IsSelect then
    self:PlayAnimation(self.change1)
  else
    self:PlayAnimation(self.change2)
  end
end

function UMG_Login_TabItem_C:CancelSelect()
  self:StopAllAnimations()
  self:IsSelect(false)
end

function UMG_Login_TabItem_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    self:PlayAnimation(self.select_loop)
  end
end

function UMG_Login_TabItem_C:SetRedPointUIType(Type, bShow)
  self.RedDot:SetRedPointUIType(Type, bShow)
  if bShow then
    local originalPos = self.RedDotOriginalTranslation
    if originalPos then
      local offsetX = 15
      local offsetY = -15
      local newTranslation = UE4.FVector2D(originalPos.X + offsetX, originalPos.Y + offsetY)
      self.RedDot:SetRenderTranslation(newTranslation)
    end
    self.RedDot:SetRenderOpacity(1)
  else
    self.RedDot:SetRenderOpacity(0)
  end
end

return UMG_Login_TabItem_C
