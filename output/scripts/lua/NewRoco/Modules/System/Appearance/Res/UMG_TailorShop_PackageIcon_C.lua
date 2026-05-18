local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TailorShop_PackageIcon_C = Base:Extend("UMG_TailorShop_PackageIcon_C")

function UMG_TailorShop_PackageIcon_C:OnConstruct()
  self.icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.activeBgColor = "#F6A85DFF"
  self.inactiveBgColor = "#1C1C1CFF"
  self.inactiveTicketBgColor = "#E1DCD0FF"
end

function UMG_TailorShop_PackageIcon_C:OnDestruct()
end

function UMG_TailorShop_PackageIcon_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.FashionItemId = _data.itemId
  local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(self.FashionItemId)
  if fashionItemConf.icon then
    self.icon_1:SetPath(fashionItemConf.icon)
  else
    self.icon_1:SetPath("")
  end
  if self.uiData.bIsInTailorShop then
    self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.inactiveBgColor))
  else
    self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.inactiveTicketBgColor))
  end
  self.Switcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.uiData.bOwned then
    if self.uiData.bIsInTailorShop then
      self.Switcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Switcher_0:SetActiveWidgetIndex(1)
    end
    if not self.uiData.bIsInTailorShop then
      self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.activeBgColor))
    end
  elseif self.uiData.bIsGift then
    self.Switcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_0:SetActiveWidgetIndex(0)
  end
end

function UMG_TailorShop_PackageIcon_C:UpdateUI()
end

return UMG_TailorShop_PackageIcon_C
