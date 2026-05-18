local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Map_RecoveryTime_Item_C = Base:Extend("UMG_Map_RecoveryTime_Item_C")

function UMG_Map_RecoveryTime_Item_C:OnConstruct()
end

function UMG_Map_RecoveryTime_Item_C:OnDestruct()
end

function UMG_Map_RecoveryTime_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.IsSelect = false
  self:UpdateItemInfo()
end

function UMG_Map_RecoveryTime_Item_C:UpdateItemInfo()
  self.Icon:SetPath(NRCUtils:FormatConfIconPath(self.data.Icon, _G.UIIconPath.BagItemPath))
  self.NumText:SetText(string.format("x%d", self.data.ItemNum))
  self.Select:SetVisibility(UE4.ESlateVisibility.Hidden)
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

function UMG_Map_RecoveryTime_Item_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Select_Quality:SetPath(UEPath.PROP_QUALITY_1)
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Select_Quality:SetPath(UEPath.PROP_QUALITY_2)
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Select_Quality:SetPath(UEPath.PROP_QUALITY_3)
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Select_Quality:SetPath(UEPath.PROP_QUALITY_4)
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Select_Quality:SetPath(UEPath.PROP_QUALITY_5)
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Map_RecoveryTime_Item_C:SetSelectInfo(IsSelect)
  if IsSelect then
    self.Select:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Select_Quality:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Select_Quality:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Map_RecoveryTime_Item_C:OnItemSelected(_bSelected)
  self:SetSelectInfo(_bSelected)
  if _bSelected then
    if self.IsSelect then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.ItemId, self.data.type)
      self.IsSelect = false
    else
      _G.NRCModuleManager:DoCmd(StarChainModuleCmd.SelectItemChange, self._index)
      self.IsSelect = true
    end
  else
    self.IsSelect = false
  end
end

function UMG_Map_RecoveryTime_Item_C:OnDeactive()
end

return UMG_Map_RecoveryTime_Item_C
