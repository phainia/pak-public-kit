local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ClothingItem_C = Base:Extend("UMG_ClothingItem_C")

function UMG_ClothingItem_C:OnConstruct()
end

function UMG_ClothingItem_C:OnDestruct()
end

function UMG_ClothingItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:UpdateUI()
end

function UMG_ClothingItem_C:UpdateUI()
  if not self.uiData or not self.uiData.ItemId then
    return
  end
  local fashionItemId = self.uiData.ItemId
  local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(fashionItemId, true)
  if not fashionItemConf then
    return
  end
  local bHasOwned = self.uiData.bHasOwned
  if self.uiData.bPendingPurchase then
    self.CurrentPurchaseBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self.uiData.bHasOwned then
      self.AlreadyOwnedBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.GreyColor))
      self.FashionDifferentColorsBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.GreyColor))
    else
      self.AlreadyOwnedBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.Color))
      self.FashionDifferentColorsBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.Color))
    end
  else
    self.CurrentPurchaseBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.AlreadyOwnedBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.Color))
    if not self.uiData.bHasOwned then
      self.FashionDifferentColorsBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.GreyColor))
    else
      self.FashionDifferentColorsBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.Color))
    end
  end
  self.CurrentPurchaseBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.Color))
  self.Icon:SwitchToSetBrushFromMaterialInstanceMode(false)
  self.Icon:SetPath(fashionItemConf.icon)
  self.bHadPlayAnimationIn = false
  self:StopAllAnimations()
  if self.uiData.bPendingPurchase and self.uiData.bHasOwned then
    self:PlayAnimation(self.DangQian_Loop, 0, 0)
  end
end

function UMG_ClothingItem_C:OnItemSelected(_bSelected)
end

function UMG_ClothingItem_C:OnDeactive()
end

function UMG_ClothingItem_C:StartPerform()
  if self.uiData.bPendingPurchase and not self.uiData.bHasOwned then
    self.bHadPlayAnimationIn = true
    self:PlayAnimation(self.DangQian_In)
  end
end

function UMG_ClothingItem_C:OnAnimationFinished(Anim)
  if Anim == self.DangQian_In and self.bHadPlayAnimationIn then
    self:PlayAnimation(self.DangQian_Loop, 0, 0)
  end
end

return UMG_ClothingItem_C
