local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetRateTip_Item_C = Base:Extend("UMG_PetDetailedTemplate_C")

function UMG_PetRateTip_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:updateItemInfo(_data)
end

function UMG_PetRateTip_Item_C:updateItemInfo(_data)
  self:SetBaseInfo()
  self.NRCImageIcon:SetPath(_data.conf.attribute_icon)
  self.nameTxt:SetText(_data[1].name)
  local addNum_1 = _data[1].attrInfo.total_race
  local SumHistogram_1 = addNum_1 + _data[1].attrInfo.talent
  SumHistogram_1 = math.max(SumHistogram_1, 300)
  self.Title_2:SetText(addNum_1)
  self.progressPetExp:SetPercent(addNum_1 / SumHistogram_1)
  self.progressPetExp:SetIncreasePercent(_data[1].attrInfo.talent / SumHistogram_1)
  if _data[1].attrInfo.talent > 0 then
    self.Title_3:SetVisibility(UE4.ESlateVisibility.Visible)
    local Text_1 = string.format("%s%d", "+", _data[1].attrInfo.talent)
    self.Title_3:SetText(Text_1)
  else
    self.Title_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local natureConf_1 = _G.DataConfigManager:GetNatureConf(_data.nature)
  local positive_effect_1, negative_effect_1
  if 0 ~= _data.petdata.changed_nature_pos_attr_type then
    positive_effect_1 = self:GetChangeAttrReqEnum(_data.petdata.changed_nature_pos_attr_type)
  elseif natureConf_1 then
    positive_effect_1 = natureConf_1.positive_effect
  end
  if 0 ~= _data.petdata.changed_nature_neg_attr_type then
    negative_effect_1 = self:GetChangeAttrReqEnum(_data.petdata.changed_nature_neg_attr_type)
  elseif natureConf_1 then
    negative_effect_1 = natureConf_1.negative_effect
  end
  if _data.conf.attr_ui_type == Enum.AttrUIType.AUT_BASE then
    if positive_effect_1 == _data.attribute then
      self.imgUp:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.imgUp:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    if negative_effect_1 == _data.attribute then
      self.imgDown:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.imgDown:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

function UMG_PetRateTip_Item_C:GetChangeAttrReqEnum(attribute)
  if not attribute then
    return nil
  end
  if attribute == Enum.AttributeType.AT_HPMAX then
    return Enum.AttributeType.AT_HPMAX_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYATK then
    return Enum.AttributeType.AT_PHYATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEATK then
    return Enum.AttributeType.AT_SPEATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYDEF then
    return Enum.AttributeType.AT_PHYDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEDEF then
    return Enum.AttributeType.AT_SPEDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEED then
    return Enum.AttributeType.AT_SPEED_PERCENT
  end
end

function UMG_PetRateTip_Item_C:SetBaseInfo()
  self.imgDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.imgUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.index and 6 == self.index then
    self.Line1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_PetRateTip_Item_C
