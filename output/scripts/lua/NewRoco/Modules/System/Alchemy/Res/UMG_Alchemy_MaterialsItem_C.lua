local UMG_Alchemy_MaterialsItem_C = _G.NRCPanelBase:Extend("UMG_Alchemy_MaterialsItem_C")

function UMG_Alchemy_MaterialsItem_C:OnActive()
end

function UMG_Alchemy_MaterialsItem_C:OnDeactive()
end

function UMG_Alchemy_MaterialsItem_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton_74, self.OnClick)
  self.NRCButton_74.OnPressed:Add(self, self.OnClickBtnPressed)
  self.NRCButton_74.OnReleased:Add(self, self.OnClickBtnReleased)
end

function UMG_Alchemy_MaterialsItem_C:SetData(item, index)
  self.item = item
  self.index = index
  if self.item == nil then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    return
  end
  self.BtnChange:SetVisibility(self.item.bAlternate and UE.ESlateVisibility.Visible or UE.ESlateVisibility.Collapsed)
  self:SetMaterialInfo()
end

function UMG_Alchemy_MaterialsItem_C:OnClick()
  if self.BtnChange:GetVisibility() == UE4.ESlateVisibility.Visible then
    _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenAlternateMaterial)
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.itemId, self.item.goods_type, false)
  end
end

function UMG_Alchemy_MaterialsItem_C:OnClickBtnPressed()
  self:PlayAnimation(self.Press)
end

function UMG_Alchemy_MaterialsItem_C:OnClickBtnReleased()
  self:PlayAnimation(self.Up)
end

function UMG_Alchemy_MaterialsItem_C:Disappear()
  self:StopAllAnimations()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:PlayAnimation(self.Out)
end

function UMG_Alchemy_MaterialsItem_C:Show()
  _G.NRCAudioManager:PlaySound2DAuto(1369, "UMG_Alchemy_MaterialsItem_C:Show")
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
end

function UMG_Alchemy_MaterialsItem_C:QuickHide()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.Hide)
end

function UMG_Alchemy_MaterialsItem_C:DoShow(index)
  if 1 == index then
    self:PlayAnimation(self.Out_1)
  elseif 2 == index then
    self:PlayAnimation(self.Out_2)
  elseif 3 == index then
    self:PlayAnimation(self.Out_3)
  elseif 4 == index then
    self:PlayAnimation(self.Out_4)
  end
end

function UMG_Alchemy_MaterialsItem_C:OnAnimationFinished(Animation)
end

function UMG_Alchemy_MaterialsItem_C:SetMaterialInfo()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self.itemId = self.item.goods_id
  local itemType = self.item.goods_type
  local needNum = self.item.goods_num
  if itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.itemId)
    if nil ~= vItemConf then
      self.UMG_UIIcon:SetPath(vItemConf.bigIcon)
    end
  elseif itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.itemId)
    if nil ~= bagItemConf then
      self.UMG_UIIcon:SetPath(bagItemConf.icon)
    end
  end
  local hasNum = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, self.itemId, itemType)
  if hasNum and needNum then
    self.CurrentNum:SetText(string.format("%d", hasNum))
    self.NeedNum:SetText(string.format("/%d", needNum))
    if hasNum > 0 and needNum <= hasNum then
      self.CurrentNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#f4eee1ff"))
    else
      self.CurrentNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ff4a4aff"))
    end
  else
    Log.Error("hasNum or needNum is nil")
  end
end

return UMG_Alchemy_MaterialsItem_C
