local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetGrowUppanel_listItem = Base:Extend("UMG_PetGrowUppanel_listItem")

function UMG_PetGrowUppanel_listItem:OnConstruct()
  self.DefaultTextColor1 = self.NRC_NoChange_1.ColorAndOpacity
  self.DefaultTextColor2 = self.NRC_NoChange_2.ColorAndOpacity
  self.DefaultBgColor = self.Bg_Detail.ColorAndOpacity
end

function UMG_PetGrowUppanel_listItem:OnDestruct()
  if self.DelayId then
    DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function UMG_PetGrowUppanel_listItem:OnItemUpdate(_data, dataList, index)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.index = index
  self.uiData = _data
  self.dataList = dataList
  self:SetPetpropertyView()
  self.DelayId = _G.DelayManager:DelaySeconds(0.0625 * index, function()
    self:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.Parent and self.index == #self.dataList then
      self.Parent:SetLock()
    end
  end)
end

function UMG_PetGrowUppanel_listItem:SetParent(_Parent)
  self.Parent = _Parent
end

function UMG_PetGrowUppanel_listItem:SetPetpropertyView()
  local uiData = self.uiData
  if not uiData then
    Log.Error("UMG_PetGrowUppanel_listItem:SetPetproperty ui data is nil, destroy para is ", self.isDestruct)
    return
  end
  Log.Dump(uiData, 6, "UMG_PetGrowUppanel_listItem:SetPetpropertyView")
  self.NRC_NoChange_2:SetText(uiData.name)
  self.NRC_NoChange_1:SetText(uiData.name)
  self.NRCSwitcher_1:SetActiveWidgetIndex(0)
  self.NRC_NoChange_2:SetColorAndOpacity(self.DefaultTextColor2)
  self.NRC_NoChange_1:SetColorAndOpacity(self.DefaultTextColor1)
  self.Bg_Detail:SetColorAndOpacity(self.DefaultBgColor)
  self:SetItemIcon()
  if uiData.IsShowNew then
    self.NRC_NoChange:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCArrows:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_New:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NRC_NoChange:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCArrows:SetVisibility(UE4.ESlateVisibility.Visible)
    local PetBeforeProperty
    if uiData.PetBeforeProperty and uiData.PetAddAttribute and 1 == uiData.PetAddAttribute.is_percent_attr then
      PetBeforeProperty = string.format("%d%s", uiData.PetBeforeProperty, "%")
      if uiData.IsShowAddIcon then
        PetBeforeProperty = string.format("+%d%s", uiData.PetBeforeProperty, "%")
      end
    elseif uiData.PetBeforeProperty then
      if uiData.IsShowAddIcon then
        PetBeforeProperty = string.format("+%d", uiData.PetBeforeProperty)
      else
        PetBeforeProperty = string.format("%d", uiData.PetBeforeProperty)
      end
    end
    self.NRC_NoChange:SetText(PetBeforeProperty)
    self.Icon_New:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local PetLaterProperty
  if uiData.PetLaterProperty and uiData.PetAddAttribute and 1 == uiData.PetAddAttribute.is_percent_attr then
    PetLaterProperty = string.format("%d%s", uiData.PetLaterProperty, "%")
    if uiData.IsShowAddIcon then
      PetLaterProperty = string.format("+%d%s", uiData.PetLaterProperty, "%")
    end
  elseif uiData.PetLaterProperty then
    if uiData.IsShowAddIcon then
      PetLaterProperty = string.format("+%d", uiData.PetLaterProperty)
    else
      PetLaterProperty = string.format("%d", uiData.PetLaterProperty)
    end
  end
  self.TitleSwitcher:SetActiveWidgetIndex(0)
  if self.TitleSwitcher and self.uiData.bTextBold then
    self.TitleSwitcher:SetActiveWidgetIndex(1)
  end
  if self.uiData.TextColor then
    self.NRC_NoChange_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.uiData.TextColor))
    self.NRC_NoChange_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.uiData.TextColor))
    self.Bg_Detail:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(self.uiData.TextColor))
  end
  if self.Bg_Line then
    self.Bg_Line:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.index ~= nil and nil ~= self.dataList and self.index == #self.dataList then
      self.Bg_Line:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.NRC_Change:SetText(PetLaterProperty)
end

function UMG_PetGrowUppanel_listItem:SetItemIcon()
  if self.uiData.PetAddAttribute and self.uiData.PetAddAttribute.attribute_icon then
    self.NRCIcon:SetPath(self.uiData.PetAddAttribute.attribute_icon)
  end
  if self.uiData.IsEffortLevel then
    local IconPath = _G.DataConfigManager:GetPetGlobalConfig("pet_grow_icon").str
    if IconPath then
      self.NRCIcon:SetPath(IconPath)
    end
  end
end

function UMG_PetGrowUppanel_listItem:SetSwitcher()
  local PetPropertyInfo = self.uiData
  if 1 == PetPropertyInfo.showSort then
  else
    self.NRCSwitcher_1:SetActiveWidgetIndex(0)
  end
end

function UMG_PetGrowUppanel_listItem:OnDeactive()
end

return UMG_PetGrowUppanel_listItem
