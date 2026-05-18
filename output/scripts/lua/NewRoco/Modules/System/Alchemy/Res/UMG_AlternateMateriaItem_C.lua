local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AlternateMateriaItem_C = Base:Extend("UMG_AlternateMateriaItem_C")

function UMG_AlternateMateriaItem_C:OnConstruct()
  self.OnLongPressedEvent:Add(self, self.OnLongPressed)
end

function UMG_AlternateMateriaItem_C:OnDestruct()
  self.OnLongPressedEvent:Remove(self, self.OnLongPressed)
end

function UMG_AlternateMateriaItem_C:OnItemUpdate(_data, datalist, index)
  self.isFocusing = false
  self.data = _data
  self.index = index
  self.isSelect = false
  self.bagItemNum = 0
  self.getBagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.itemId)
  if self.getBagItemConf then
    local bagItem, _ = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, self.getBagItemConf.id)
    if bagItem then
      self.bagItemNum = bagItem.num
    end
    self:SetQuality(self.getBagItemConf.item_quality)
    self.BgSwitcher:SetActiveWidgetIndex(0)
    self.SkillStone:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ICON_2:SetPath(self.getBagItemConf.icon)
    self.NeedNum:SetText(string.format("/%d", self.data.needNum))
    local itemType = self.getBagItemConf.type
    local typeConf = _G.DataConfigManager:GetBagItemTypeConf(itemType)
    local maxCount = typeConf.single_item_limit_max
    if maxCount < self.bagItemNum then
      self.CurrentNum:SetText(string.format("%d", maxCount))
    else
      self.CurrentNum:SetText(string.format("%d", self.bagItemNum))
    end
    self:UpdateTextColor()
  end
end

function UMG_AlternateMateriaItem_C:OnItemSelected(_bSelected)
  if _bSelected and self.bagItemNum <= 0 then
    self.ParentView:DeselectItemByIndex(self.index)
    return
  end
  if self.ParentView:GetMultipleChoice() then
    if self.bagItemNum > 0 then
      self:OnItemFocused()
    end
    local selectedItems = self.ParentView:GetSelectedItem()
    local selectedNum = 0
    for k, v in pairs(selectedItems) do
      selectedNum = selectedNum + 1
    end
    if not _bSelected and selectedNum < 1 then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.exchange_min_raw_text)
      self.ParentView:SelectItemByIndex(self.index - 1)
      return
    end
    if _bSelected and self.ParentView then
      local exchangeId, _ = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialItems)
      local exchangeConf = _G.DataConfigManager:GetExchangeConf(exchangeId)
      if exchangeConf then
        local maxBubbleNum = _G.DataConfigManager:GetGlobalConfigNumByKey("exchange_bubble_max_num", 4)
        if maxBubbleNum < #exchangeConf.cost_item - 1 + selectedNum then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.exchange_max_bubble_text)
          self.ParentView:DeselectItemByIndex(self.index)
          return
        end
      end
    end
  elseif _bSelected then
    self:OnItemFocused()
  end
  if _bSelected then
    self.Check:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.Check:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.isSelect = _bSelected
end

function UMG_AlternateMateriaItem_C:SetIconText(SlateColor)
  self.Quality:SetColorAndOpacity(SlateColor)
end

function UMG_AlternateMateriaItem_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#afac9fff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#5ca011ff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#42a7ccff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#7f4dffff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#efa012ff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_AlternateMateriaItem_C:SetParent(parent)
  self.parent = parent
end

function UMG_AlternateMateriaItem_C:OnDeactive()
end

function UMG_AlternateMateriaItem_C:UpdateTextColor()
  local color
  if self.isFocusing then
    color = "#f4eee2ff"
  else
    color = "#908f85ff"
  end
  self.NeedNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(color))
  if self.bagItemNum > 0 and self.bagItemNum >= self.data.needNum then
    self.Obturation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CurrentNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(color))
  else
    self.Obturation:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.CurrentNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ff4a4aff"))
  end
end

function UMG_AlternateMateriaItem_C:OnItemFocused()
  if self.parent then
    self.parent:SetFocusIndex(self.index)
  end
  self:StopAllAnimations()
  if self.isFocusing then
    self:PlayAnimation(self.select)
  else
    self:PlayAnimation(self.change1)
  end
  self.isFocusing = true
  self:UpdateTextColor()
end

function UMG_AlternateMateriaItem_C:OnItemLostFocus()
  self:StopAllAnimations()
  if self.isFocusing then
    self:PlayAnimation(self.change2)
  else
    self:PlayAnimation(self.normal)
  end
  self.isFocusing = false
  self:UpdateTextColor()
end

function UMG_AlternateMateriaItem_C:OnLongPressed()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.data.itemId, self.data.itemType)
end

return UMG_AlternateMateriaItem_C
