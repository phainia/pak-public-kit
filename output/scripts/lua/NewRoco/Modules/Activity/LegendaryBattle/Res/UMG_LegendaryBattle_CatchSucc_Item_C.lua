local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LegendaryBattle_CatchSucc_Item_C = Base:Extend("UMG_LegendaryBattle_CatchSucc_Item_C")

function UMG_LegendaryBattle_CatchSucc_Item_C:OnConstruct()
end

function UMG_LegendaryBattle_CatchSucc_Item_C:OnDestruct()
end

function UMG_LegendaryBattle_CatchSucc_Item_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self:SetInfoItemAttriValue(_data.data, _data.data1, _data.natureConf, _data.attributeType, _data.icon)
end

function UMG_LegendaryBattle_CatchSucc_Item_C:SetData()
end

function UMG_LegendaryBattle_CatchSucc_Item_C:SetInfoItemAttriValue(data, data1, natureConf, attributeType, icon)
  self.numTxt:SetText(data)
  self.imageAttriIcon:SetPath(icon)
  if natureConf.positive_effect == attributeType then
    self.imgUp:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.imgUp:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if natureConf.negative_effect == attributeType then
    self.imgDown:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.imgDown:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_LegendaryBattle_CatchSucc_Item_C:OnItemSelected(_bSelected)
end

function UMG_LegendaryBattle_CatchSucc_Item_C:OnDeactive()
end

return UMG_LegendaryBattle_CatchSucc_Item_C
