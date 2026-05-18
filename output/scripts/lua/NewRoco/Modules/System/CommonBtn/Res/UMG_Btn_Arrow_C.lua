local UMG_Btn_Arrow_C = _G.NRCPanelBase:Extend("UMG_Btn_Arrow_C")

function UMG_Btn_Arrow_C:OnConstruct()
  self.CommonBtnArrowData = nil
  self:OnAddEventListener()
end

function UMG_Btn_Arrow_C:OnDestruct()
end

function UMG_Btn_Arrow_C:OnActive()
end

function UMG_Btn_Arrow_C:OnDeactive()
end

function UMG_Btn_Arrow_C:OnAddEventListener()
  if self.btnLevelUp then
    self:AddButtonListener(self.btnLevelUp, self.btnLevelUpOnClicked)
  end
end

function UMG_Btn_Arrow_C:SetBtnInfo(CommonBtnArrowData)
  self.CommonBtnArrowData = CommonBtnArrowData
  if CommonBtnArrowData.modeIndex then
    self:SetArrowMode(CommonBtnArrowData.modeIndex)
  end
end

function UMG_Btn_Arrow_C:SetBtnIcon(iconType, iconPath)
  local switcherIndex = self.NRCSwitcher_0:GetActiveWidgetIndex()
  if iconType and 1 == iconType then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if 0 == switcherIndex then
      self.PetIcon_L:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NPCIcon_L:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.ItemIcon_L:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.PetIcon_L:SetPath(iconPath)
    elseif 1 == switcherIndex then
      self.PetIcon_R:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NPCIcon_R:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.ItemIcon_R:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.PetIcon_R:SetPath(iconPath)
    end
  elseif iconType and 2 == iconType then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if 0 == switcherIndex then
      self.PetIcon_L:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NPCIcon_L:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ItemIcon_L:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NPCIcon_L:SetPath(iconPath)
    elseif 1 == switcherIndex then
      self.PetIcon_R:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NPCIcon_R:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ItemIcon_R:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NPCIcon_R:SetPath(iconPath)
    end
  elseif iconType and 3 == iconType then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if 0 == switcherIndex then
      self.PetIcon_L:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NPCIcon_L:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.ItemIcon_L:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ItemIcon_L:SetPath(iconPath)
    elseif 1 == switcherIndex then
      self.PetIcon_R:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NPCIcon_R:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.ItemIcon_R:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ItemIcon_R:SetPath(iconPath)
    end
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Btn_Arrow_C:ShowOrHideBtnArrow(_IsShow)
  if _IsShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Btn_Arrow_C:SetArrowMode(modeIndex)
  if modeIndex and modeIndex > 0 and modeIndex <= 4 then
    self.NRCSwitcher_0:SetActiveWidgetIndex(modeIndex - 1)
  end
end

function UMG_Btn_Arrow_C:btnLevelUpOnClicked()
  if self.CommonBtnArrowData and self.CommonBtnArrowData.Call and self.CommonBtnArrowData.btnHandler then
    self.CommonBtnArrowData.btnHandler(self.CommonBtnArrowData.Call)
  end
end

return UMG_Btn_Arrow_C
