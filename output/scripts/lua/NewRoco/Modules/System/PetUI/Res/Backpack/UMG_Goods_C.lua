local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Goods_C = Base:Extend("UMG_Goods_C")

function UMG_Goods_C:OnConstruct()
end

function UMG_Goods_C:OnDestruct()
end

function UMG_Goods_C:OnActive()
end

function UMG_Goods_C:OnItemUpdate(_itemData)
  self.uiData = _itemData
  self:SetData()
end

function UMG_Goods_C:SetData()
  local itemCfg = self.uiData.itemCfg
  if itemCfg then
    self.itemIcon:SetPath(itemCfg.icon)
    self:SetQuality(itemCfg.item_quality)
    self.panelItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetQuality(1)
    self.panelItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self.itemMaxCount:SetText(self.uiData.itemCount)
end

function UMG_Goods_C:OnItemSelected(_bselect)
  if _bselect then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.itemCfg.id, _G.Enum.GoodsType.GT_BAGITEM, false)
  end
end

function UMG_Goods_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Goods_C:OnDeactive()
end

return UMG_Goods_C
