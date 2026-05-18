local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ConsumptionItem_C = Base:Extend("UMG_ConsumptionItem_C")

function UMG_ConsumptionItem_C:OnConstruct()
end

function UMG_ConsumptionItem_C:OnDestruct()
  self.data = nil
end

function UMG_ConsumptionItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.item = _data
  self.index = index
  self:SetMaterialInfo()
end

function UMG_ConsumptionItem_C:OnItemSelected(_bSelected)
end

function UMG_ConsumptionItem_C:OnDeactive()
  self.Reselect.btnLevelUp.OnClicked:Remove(self, self.OnReselect)
  self.DetailsBtn.btnLevelUp.OnClicked:Remove(self, self.OnClick)
end

function UMG_ConsumptionItem_C:OnTick()
end

function UMG_ConsumptionItem_C:OnLogin()
end

function UMG_ConsumptionItem_C:OnAnimationFinished(anim)
end

function UMG_ConsumptionItem_C:OnClick()
  if self.Reselect:GetVisibility() == UE4.ESlateVisibility.Visible then
    _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenAlternateMaterial)
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.itemId, self.item.goods_type, false)
  end
end

function UMG_ConsumptionItem_C:OnReselect()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenAlternateMaterial)
end

function UMG_ConsumptionItem_C:SetMaterialInfo()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self.itemId = self.item.goods_id
  local itemType = self.item.goods_type
  local needNum = self.item.goods_num
  self.Reselect:SetVisibility(self.item.bAlternate and UE.ESlateVisibility.Visible or UE.ESlateVisibility.Collapsed)
  self.Reselect.btnLevelUp.OnClicked:Add(self, self.OnReselect)
  self.DetailsBtn.OnClicked:Add(self, self.OnClick)
  if itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.itemId)
    if nil ~= vItemConf then
      self.Icon:SetPath(vItemConf.bigIcon)
      self:SetQuality(vItemConf.item_quality)
    end
  elseif itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.itemId)
    if nil ~= bagItemConf then
      self.Icon:SetPath(bagItemConf.icon)
      self:SetQuality(bagItemConf.item_quality)
    end
  end
  local hasNum = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, self.itemId, itemType)
  if hasNum and needNum then
    self.IconText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if hasNum > 0 and needNum <= hasNum then
      self.IconText:SetText(string.format("%d/%d", hasNum, needNum))
    else
      self.IconText:SetText(string.format("<span color=\"#c7494a\">%d</>/%d", hasNum, needNum))
    end
  else
    Log.Error("hasNum or needNum is nil")
  end
end

function UMG_ConsumptionItem_C:SetQuality(quality)
  self.Quality:SetVisibility(0 == quality and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
  if 0 == quality then
    self.Quality:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif 1 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_5)
  end
end

return UMG_ConsumptionItem_C
