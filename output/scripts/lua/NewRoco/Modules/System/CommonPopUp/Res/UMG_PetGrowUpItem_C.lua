local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetGrowUpItem_C = Base:Extend("UMG_PetGrowUpItem_C")

function UMG_PetGrowUpItem_C:OnConstruct()
end

function UMG_PetGrowUpItem_C:OnDestruct()
end

function UMG_PetGrowUpItem_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  self:UpdateView()
end

function UMG_PetGrowUpItem_C:UpdateView()
  if self.Data then
    local Data = self.Data
    if Data.ItemName ~= nil then
      self.AttrName:SetText(Data.ItemName)
    end
    if nil ~= Data.IsShowIcon then
      self.AttrIcon:SetVisibility(Data.IsShowIcon and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
    if nil ~= Data.ItemType then
      local AttributeConf = _G.DataConfigManager:GetAttributeConf(Data.ItemType)
      if AttributeConf and AttributeConf.attribute_icon then
        self.AttrIcon:SetPath(AttributeConf.attribute_icon)
      end
    end
    if nil ~= Data.BeforeValue then
      self.CurValueText:SetText(Data.BeforeValue)
    end
    if nil ~= Data.AfterValue then
      self.NextValueText:SetText(Data.AfterValue)
    end
  end
end

function UMG_PetGrowUpItem_C:OnItemSelected(_bSelected)
end

function UMG_PetGrowUpItem_C:OnDeactive()
end

return UMG_PetGrowUpItem_C
