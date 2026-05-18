local UMG_Bag_Hatch_C = _G.NRCPanelBase:Extend("UMG_Bag_Hatch_C")

function UMG_Bag_Hatch_C:OnActive(curItemData)
  self.data = self.module:GetData("BagModuleData")
  _G.NRCAudioManager:PlaySound2DAuto(41400007, "UMG_Bag_PopUp_C:OnBtnOKClick")
  self.itemData = curItemData
  self.itemConf = _G.DataConfigManager:GetBagItemConf(curItemData.id)
  self.Template:OnItemUpdate(self.itemData)
  self.Template.TextBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Template.NumText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetCommonPopUpInfo(self.PopUp4)
  local allText = _G.DataConfigManager:GetLocalizationConf("UMG_Bag_Hatch").msg
  self.PopUp4:SetDescInfo(allText)
  self:OnAddEventListener()
  self:LoadAnimation(0)
  self:BindInputAction()
end

function UMG_Bag_Hatch_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_Bag_Hatch_C:OnDestruct()
end

function UMG_Bag_Hatch_C:OnDeactive()
end

function UMG_Bag_Hatch_C:OnAddEventListener()
  self:AddButtonListener(self.Template.ClickBtn, self.ShowTips)
end

function UMG_Bag_Hatch_C:OpenPetBag()
  if self:IsAnimationPlaying(self:GetAnimByIndex(2)) then
    return
  end
  local functionBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET, true)
  if functionBan then
    self:OnClose()
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_Bag_Hatch_C:OpenPetBag")
  
  function self.CallBlack()
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetHatchingPanel, self.itemData.gid)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.CloseHatchingRightPanel)
    local petModule = _G.NRCModuleManager:GetModule("PetUIModule")
    if petModule:HasPanel("PetHatchingPanel") then
      self.module:ClosePanel("BagMain")
    end
  end
  
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1220002036, "UMG_Bag_Hatch_C:OpenPetBag")
  self:OnClose()
end

function UMG_Bag_Hatch_C:OnUpdateHatching()
  if self.bPendingClose then
    return
  end
  if self:IsAnimationPlaying(self:GetAnimByIndex(2)) then
    return
  end
  self.bPendingClose = true
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetHatchingPanel, self.itemData.gid, true)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.CloseHatchingRightPanel)
  self:OnClose()
end

function UMG_Bag_Hatch_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OpenPetBag
  CommonPopUpData.Btn_RightHandler = self.OnUpdateHatching
  CommonPopUpData.ClosePanelHandler = self.OnUpdateHatching
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Bag_Hatch_C:OnClose()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_Bag_Hatch_C:OpenPetBag")
  self:LoadAnimation(2)
end

function UMG_Bag_Hatch_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    if self.CallBlack then
      self.CallBlack()
    end
    if self.data and self.data.CacheHatchEggItem then
      self.data.CacheHatchEggItem = nil
    end
    self.CallBlack = nil
    self:DoClose()
  end
end

function UMG_Bag_Hatch_C:ShowTips()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_CampingTemplate_C:OnItemSelected")
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.itemData.id, _G.Enum.GoodsType.GT_BAGITEM, false, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, self.itemData.gid)
end

function UMG_Bag_Hatch_C:OnDestruct()
  self.CallBlack = nil
end

function UMG_Bag_Hatch_C:BindInputAction()
end

function UMG_Bag_Hatch_C:OnPcClose2()
end

return UMG_Bag_Hatch_C
