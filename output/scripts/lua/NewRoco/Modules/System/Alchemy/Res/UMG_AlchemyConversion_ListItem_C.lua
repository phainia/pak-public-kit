local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AlchemyConversion_ListItem_C = Base:Extend("UMG_AlchemyConversion_ListItem_C")

function UMG_AlchemyConversion_ListItem_C:OnConstruct()
end

function UMG_AlchemyConversion_ListItem_C:OnDestruct()
end

function UMG_AlchemyConversion_ListItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.lineSelected = false
  self.index = index
  self.RecipeList = {}
  table.insert(self.RecipeList, self.RecipeItem1)
  table.insert(self.RecipeList, self.RecipeItem2)
  table.insert(self.RecipeList, self.RecipeItem3)
  table.insert(self.RecipeList, self.RecipeItem4)
  for i, cost_item in ipairs(self.data.cost_item) do
    self.RecipeList[i]:UpdateData(cost_item, self, i, #self.data.cost_item)
    self.RecipeList[i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  for i = #self.data.cost_item + 1, 4 do
    self.RecipeList[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_AlchemyConversion_ListItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Select_in)
  else
    self:PlayAnimation(self.Select_out)
  end
  self:SelectLine(_bSelected)
end

function UMG_AlchemyConversion_ListItem_C:OnDeactive()
end

function UMG_AlchemyConversion_ListItem_C:IsLineSelected()
  return self.lineSelected
end

function UMG_AlchemyConversion_ListItem_C:SelectLine(bSelect)
  self.lineSelected = bSelect
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.UpdateMaterialItems, self.data.exchangeId, 1)
  _G.NRCEventCenter:DispatchEvent(_G.AlchemyModuleEvent.AlchemyItemChanged, self.data.exchangeId, -1, self.index)
  self:SyncChildren()
end

function UMG_AlchemyConversion_ListItem_C:SyncChildren()
  for i, cost_item in ipairs(self.data.cost_item) do
    self.RecipeList[i]:SyncParentSelect(self.lineSelected)
  end
end

return UMG_AlchemyConversion_ListItem_C
