local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Pet_CatchSucc_Item_C = Base:Extend("UMG_Pet_CatchSucc_Item_C")

function UMG_Pet_CatchSucc_Item_C:OnConstruct()
end

function UMG_Pet_CatchSucc_Item_C:OnDestruct()
end

function UMG_Pet_CatchSucc_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_Pet_CatchSucc_Item_C:SetInfo()
  local data = self.data
  if data.natureConf and data.natureConf.positive_effect == data.attributeType then
    self.imgUp:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.imgUp:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if data.natureConf.negative_effect == data.attributeType then
    self.imgDown:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.imgDown:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self.numTxt:SetText(data.data)
  self.imageAttriIcon:SetPath(data.Icon)
end

function UMG_Pet_CatchSucc_Item_C:OnItemSelected(_bSelected)
end

function UMG_Pet_CatchSucc_Item_C:OnDeactive()
end

return UMG_Pet_CatchSucc_Item_C
