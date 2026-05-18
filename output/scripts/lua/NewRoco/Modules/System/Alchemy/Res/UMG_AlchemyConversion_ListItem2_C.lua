local AlchemyUtils = require("NewRoco.Modules.System.Alchemy.AlchemyUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AlchemyConversion_ListItem2_C = Base:Extend("UMG_AlchemyConversion_ListItem2_C")

function UMG_AlchemyConversion_ListItem2_C:OnConstruct()
  self.parent = nil
end

function UMG_AlchemyConversion_ListItem2_C:OnDestruct()
end

function UMG_AlchemyConversion_ListItem2_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.RecipeList = {}
  table.insert(self.RecipeList, self.RecipeItem1)
  table.insert(self.RecipeList, self.RecipeItem2)
  table.insert(self.RecipeList, self.RecipeItem3)
  table.insert(self.RecipeList, self.RecipeItem4)
  local cfg = _G.DataConfigManager:GetExchangeConf(self.data.exchangeId, true)
  if not cfg then
    return
  end
  for i, cost_item in ipairs(cfg.cost_item) do
    local bagItemData = AlchemyUtils.GetBagItemByID(cost_item.cost_goods_id)
    local new_cost_item = {}
    new_cost_item.cost_goods_id = cost_item.cost_goods_id
    new_cost_item.cost_goods_type = cost_item.cost_goods_type
    new_cost_item.cost_goods_num = cost_item.cost_goods_num
    if bagItemData then
      new_cost_item.num = bagItemData.num
    else
      new_cost_item.num = 0
    end
    self.RecipeList[i]:UpdateData(new_cost_item, self, i, #cfg.cost_item)
    self.RecipeList[i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  for i = #cfg.cost_item + 1, 4 do
    self.RecipeList[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_AlchemyConversion_ListItem2_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.select)
    self.parent:SetSelectExchangeId(self.data.exchangeId, self.index)
  else
    self:PlayAnimationReverse(self.select)
  end
end

function UMG_AlchemyConversion_ListItem2_C:OnDeactive()
end

function UMG_AlchemyConversion_ListItem2_C:SetParent(parent)
  self.parent = parent
end

return UMG_AlchemyConversion_ListItem2_C
