local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_StarChain_ItemTemplate_C = Base:Extend("UMG_StarChain_ItemTemplate_C")

function UMG_StarChain_ItemTemplate_C:OnConstruct()
end

function UMG_StarChain_ItemTemplate_C:OnDestruct()
end

function UMG_StarChain_ItemTemplate_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:UpdateItemInfo()
end

function UMG_StarChain_ItemTemplate_C:UpdateItemInfo()
  self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(self.data.Icon, _G.UIIconPath.BagItemPath))
  self.NumText:SetText(self.data.ItemNum)
  self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  if self.data.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_ITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.ItemId)
    if bagItemConf then
      self:SetQuality(bagItemConf.item_quality)
    end
  elseif self.data.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_DIAMOND then
    local VItemConf = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_DIAMOND)
    if VItemConf then
      self:SetQuality(VItemConf.item_quality)
    end
  end
end

function UMG_StarChain_ItemTemplate_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_StarChain_ItemTemplate_C:SetSelectInfo(IsSelect)
  if IsSelect then
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_StarChain_ItemTemplate_C:OnItemSelected(_bSelected)
  self:SetSelectInfo(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_StarChain_ItemTemplate_C:OnItemSelected")
    _G.NRCModuleManager:DoCmd(StarChainModuleCmd.SelectItemChange, self._index)
  end
end

function UMG_StarChain_ItemTemplate_C:OnDeactive()
end

return UMG_StarChain_ItemTemplate_C
