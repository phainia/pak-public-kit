local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FoodItem_C = Base:Extend("UMG_FoodItem_C")

function UMG_FoodItem_C:OnConstruct()
end

function UMG_FoodItem_C:OnAddEventListener()
  self.TipsBtn.OnClicked:Add(self, self.OnTipsBtnClick)
end

function UMG_FoodItem_C:OnDestruct()
  self.TipsBtn.OnClicked:Remove(self, self.OnTipsBtnClick)
end

function UMG_FoodItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:OnAddEventListener()
  self:RefreshView()
end

function UMG_FoodItem_C:OnTouchEnded(MyGeometry, InTouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(40001002, "UMG_FoodItem_C:OnTouchEnded")
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_FoodItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.data.isUnLock then
      self:OnSelectIn()
      _G.HomeIndoorSandbox:DispatchEvent(_G.HomeIndoorSandbox.Event.OnFoodProcessingSelectFood, self.index)
    else
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.lock_proccessing_products_tips, self.data.unlockParam))
    end
  elseif self.data.isUnLock then
    self:OnSelectOut()
  end
end

function UMG_FoodItem_C:OnTipsBtnClick()
  if not (self.data and self.data.foodItemId) or self.data.foodItemType then
  end
end

function UMG_FoodItem_C:OnSelectIn()
  self.TipsBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self:StopAllAnimations()
  self:PlayAnimation(self.select)
end

function UMG_FoodItem_C:OnSelectOut()
  self.TipsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:StopAllAnimations()
  self:PlayAnimation(self.Unselect)
end

function UMG_FoodItem_C:RefreshView()
  self.TipsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.isUnLock then
    self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemIcon:SetPath(self:GetIconPath())
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UnlockLevels:SetText(string.format(LuaText.lock_proccessing_products_tips, self.data.unlockParam))
    self.Lock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_FoodItem_C:GetIconPath()
  local iconPath
  if self.data.foodItemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.data.foodItemId)
    if vItemConf then
      iconPath = vItemConf.bigIcon
    end
  elseif self.data.foodItemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.foodItemId)
    if bagItemConf then
      iconPath = bagItemConf.icon
    end
  end
  return iconPath
end

function UMG_FoodItem_C:OnDeactive()
end

return UMG_FoodItem_C
