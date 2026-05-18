local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ConsumptionItem_C = Base:Extend("UMG_ConsumptionItem_C")

function UMG_ConsumptionItem_C:OnConstruct()
end

function UMG_ConsumptionItem_C:OnDestruct()
end

function UMG_ConsumptionItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:UpdateUI()
end

function UMG_ConsumptionItem_C:OnItemSelected(_bSelected)
end

function UMG_ConsumptionItem_C:UpdateUI()
  local type = self.data.type or _G.Enum.GoodsType.GT_BAGITEM
  local iconPath
  if type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.id)
    self:SetQuality(bagItemConf.item_quality)
    iconPath = bagItemConf.icon
  elseif type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.data.id)
    if nil ~= vItemConf then
      self:SetQuality(vItemConf.item_quality)
      iconPath = vItemConf.bigIcon
    end
  end
  local itemCount = self.data.item.num or 0
  local needCount = self.data.needUseNum or 0
  self.txtLV:SetText(itemCount .. "/" .. needCount)
  self.icon:SetPath(iconPath)
end

function UMG_ConsumptionItem_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_ConsumptionItem_C:OnDeactive()
end

return UMG_ConsumptionItem_C
