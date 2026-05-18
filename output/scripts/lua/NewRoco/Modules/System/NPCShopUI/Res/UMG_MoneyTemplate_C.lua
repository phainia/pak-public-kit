require("UnLuaEx")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MoneyTemplate_C = Base:Extend("UMG_MoneyTemplate_C")

function UMG_MoneyTemplate_C:OnConstruct()
  self.uiData = {}
end

function UMG_MoneyTemplate_C:Destruct()
end

function UMG_MoneyTemplate_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:updateItemInfo()
end

function UMG_MoneyTemplate_C:updateItemInfo()
  local itemType = self.uiData.currencyType
  local itemId = self.uiData.currencyId
  local itemNum = self.uiData.num
  local itemColor = self.uiData.showColor
  if itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemsConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    self.UMG_UIIcon:SetPath(vItemsConf.iconPath)
    self.UMG_UIIcon_big:SetPath(vItemsConf.bigIcon)
  elseif itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    self.UMG_UIIcon:SetPath(bagItemConf.icon)
    self.UMG_UIIcon_big:SetPath(bagItemConf.icon)
  end
  if self.uiData.showbg then
    self.NRCImage_bg:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NRCImage_bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.uiData.bigIcon then
    self.SizeBox_uicionbig:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SizeBox_uicion:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.SizeBox_uicionbig:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox_uicion:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if 0 == itemColor then
    self.SumNum:SetText(itemNum)
    self.SumNum:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CostNum:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.uiData.numTextColor then
      self.SumNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.uiData.numTextColor))
    end
  else
    self.CostNum:SetText(itemNum)
    self.SumNum:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CostNum:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.uiData.numTextColor then
      self.CostNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.uiData.numTextColor))
    end
  end
end

return UMG_MoneyTemplate_C
