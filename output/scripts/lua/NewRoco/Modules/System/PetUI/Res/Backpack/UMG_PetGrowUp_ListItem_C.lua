local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetGrowUp_ListItem_C = Base:Extend("UMG_PetGrowUp_ListItem_C")

function UMG_PetGrowUp_ListItem_C:OnConstruct()
  if self.BtnDetails then
    self:AddButtonListener(self.BtnDetails.btnLevelUp, self.OnClickBtnDetails)
  end
end

function UMG_PetGrowUp_ListItem_C:OnDestruct()
  if self.BtnDetails then
    self:RemoveButtonListener(self.BtnDetails.btnLevelUp, self.OnClickBtnDetails)
  end
end

function UMG_PetGrowUp_ListItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self.datalist = datalist
  self:SetPetproperty()
end

function UMG_PetGrowUp_ListItem_C:SetPetproperty()
  local uiData = self.uiData
  if uiData.IsShow and uiData.StyleIndex and 2 == uiData.StyleIndex then
    self.NRC_NoChange_3:SetText(uiData.name)
    self.BtnDetails:SetVisibility(self.uiData.IsShowWenhao and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
    self.Switcher:SetActiveWidgetIndex(2)
  elseif uiData.IsShow == true then
    local pos = self.NRCIcon.Slot:GetPosition()
    self.NRCIcon.Slot:SetPosition(pos)
    self.NRC_NoChange_2:SetText(uiData.name)
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.NRC_NoChange_1:SetText(uiData.name)
    self.Switcher:SetActiveWidgetIndex(0)
  end
  self:SetItemIcon()
  if self.UpIcon then
    self.UpIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if uiData.IsShowUp == false then
      self.UpIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local PetBeforeProperty
  if math.type(uiData.PetBeforeProperty) == "integer" then
    if uiData.PetAddAttribute and 1 == uiData.PetAddAttribute.is_percent_attr then
      PetBeforeProperty = string.format("%d%s", uiData.PetBeforeProperty, "%")
      if uiData.IsShowAddIcon then
        PetBeforeProperty = string.format("+%d%s", uiData.PetBeforeProperty, "%")
      end
    elseif uiData.IsShowAddIcon then
      PetBeforeProperty = string.format("+%d", uiData.PetBeforeProperty)
    else
      PetBeforeProperty = string.format("%d", uiData.PetBeforeProperty)
    end
  end
  self.NRC_NoChange:SetText(PetBeforeProperty)
  if uiData.PetLaterProperty then
    self.NRC_Change:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCArrows:SetVisibility(UE4.ESlateVisibility.Visible)
    local PetLaterProperty
    if "integer" == math.type(uiData.PetLaterProperty) then
      if uiData.PetAddAttribute and 1 == uiData.PetAddAttribute.is_percent_attr then
        PetLaterProperty = string.format("%d%s", uiData.PetLaterProperty, "%")
        if uiData.IsShowAddIcon then
          PetLaterProperty = string.format("+%d%s", uiData.PetLaterProperty, "%")
        end
      elseif uiData.IsShowAddIcon then
        PetLaterProperty = string.format("+%d", uiData.PetLaterProperty)
      else
        PetLaterProperty = string.format("%d", uiData.PetLaterProperty)
      end
    end
    self.NRC_Change:SetText(PetLaterProperty)
  else
    self.NRC_Change:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCArrows:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Line1 then
    self.Line1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Line2 then
    self.Line2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.index ~= nil and nil ~= self.datalist and self.index == #self.datalist then
    if self.Line1 then
      self.Line1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.Line2 then
      self.Line2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetGrowUp_ListItem_C:SetItemIcon()
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

function UMG_PetGrowUp_ListItem_C:OnClickBtnDetails()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401011, "UMG_PetDetailedTemplate_C:ShowTalentTips")
  if self.uiData == nil then
    Log.Error("UMG_PetGrowUp_ListItem_C:OnClickBtnDetails uiData is nil")
    return
  end
  if self.uiData.PetAddAttribute then
    local attributeType = self.uiData.PetAddAttribute.attribute
    if attributeType then
      local AttributeTitle = ""
      local AttributeDesc = ""
      local AttributeCurEffect = ""
      if attributeType == Enum.AttributeType.AT_TYPE_BLUNT then
        AttributeTitle = LuaText.type_blunt_text_1
        AttributeDesc = LuaText.type_blunt_text_2
        AttributeCurEffect = string.format(LuaText.type_blunt_text_3, self.uiData.PetBeforeProperty, self.uiData.PetBeforeProperty)
      elseif attributeType == Enum.AttributeType.AT_TYPE_SHARPEN then
        AttributeTitle = LuaText.type_sharpen_text_1
        AttributeDesc = LuaText.type_sharpen_text_2
        AttributeCurEffect = string.format(LuaText.type_sharpen_text_3, self.uiData.PetBeforeProperty, self.uiData.PetBeforeProperty)
      end
      local nounInterpretationTipsInfo = {}
      nounInterpretationTipsInfo.bIsUseOriginalText = true
      nounInterpretationTipsInfo.originalTextList = {}
      nounInterpretationTipsInfo.originalTextList[1] = AttributeTitle .. "\n" .. AttributeDesc
      nounInterpretationTipsInfo.originalTextList[2] = AttributeCurEffect
      _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
    end
  elseif self.uiData.IsEffortLevel then
    local nounInterpretationTipsInfo = {}
    nounInterpretationTipsInfo.bIsUseOriginalText = true
    nounInterpretationTipsInfo.originalTextList = {}
    nounInterpretationTipsInfo.originalTextList[1] = LuaText.grow_explain_text_1
    nounInterpretationTipsInfo.OverviewChangeInfoList = {}
    local OverviewChangeInfo = {}
    OverviewChangeInfo[1] = {
      ItemName = LuaText.grow_explain_text_2,
      IsShowIcon = false,
      BeforeValue = self.uiData.PetBeforeProperty,
      AfterValue = self.uiData.PetLaterProperty
    }
    nounInterpretationTipsInfo.OverviewChangeInfoList[1] = OverviewChangeInfo
    local CurGrowLevelConf = _G.DataConfigManager:GetGrowLevelConf(self.uiData.PetBeforeProperty)
    local NextGrowLevelConf = _G.DataConfigManager:GetGrowLevelConf(self.uiData.PetLaterProperty)
    if nil ~= CurGrowLevelConf and nil ~= NextGrowLevelConf then
      nounInterpretationTipsInfo.DetailsChangeInfoList = {}
      local DetailsChangeInfo = {}
      for i, AttrItem in pairs(CurGrowLevelConf.attr or {}) do
        table.insert(DetailsChangeInfo, {
          ItemName = CurGrowLevelConf.attr[i].attr_name .. LuaText.grow_explain_text_3,
          IsShowIcon = true,
          ItemType = CurGrowLevelConf.attr[i].attr_type,
          BeforeValue = CurGrowLevelConf.attr[i].attr_data,
          AfterValue = NextGrowLevelConf.attr[i].attr_data
        })
      end
      nounInterpretationTipsInfo.DetailsChangeInfoList[1] = DetailsChangeInfo
    end
    nounInterpretationTipsInfo.LineShowFlagList = {
      [1] = true
    }
    _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
  end
end

function UMG_PetGrowUp_ListItem_C:OnDeactive()
end

return UMG_PetGrowUp_ListItem_C
