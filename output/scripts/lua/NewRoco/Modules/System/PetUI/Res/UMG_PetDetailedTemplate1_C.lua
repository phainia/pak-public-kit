local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetDetailedTemplate1_C = Base:Extend("UMG_PetDetailedTemplate1_C")

function UMG_PetDetailedTemplate1_C:OnConstruct()
end

function UMG_PetDetailedTemplate1_C:OnDestruct()
end

function UMG_PetDetailedTemplate1_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  if self.BtnDetails then
    self:AddButtonListener(self.BtnDetails.btnLevelUp, self.OnClickDetailBtn)
  end
  self:updateItemInfo(_data)
end

function UMG_PetDetailedTemplate1_C:updateItemInfo(_data)
  if self.BtnDetails then
    self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if _data.conf.attribute == Enum.AttributeType.AT_TYPE_BLUNT or _data.conf.attribute == Enum.AttributeType.AT_TYPE_SHARPEN then
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
  if _data.conf and 1 == _data.conf.is_percent_attr then
    if _data.conf.attribute == Enum.AttributeType.AT_TYPE_BLUNT or _data.conf.attribute == Enum.AttributeType.AT_TYPE_SHARPEN then
      self.numTxt:SetText(_data.num .. "%")
    else
      self.numTxt:SetText(_data.num // 100 .. "%")
    end
  else
    self.numTxt:SetText(_data.num)
  end
  self.nameTxt:SetText(_data.conf.attribute_name)
  self.NRCImageIcon:SetPath(_data.conf.attribute_icon)
end

function UMG_PetDetailedTemplate1_C:OnClickDetailBtn()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401011, "UMG_PetDetailedTemplate_C:ShowTalentTips")
  local attributeType = self.Data.conf.attribute
  if attributeType then
    local AttributeTitle = ""
    local AttributeDesc = ""
    local AttributeCurEffect = ""
    if attributeType == Enum.AttributeType.AT_TYPE_BLUNT then
      AttributeTitle = LuaText.type_blunt_text_1
      AttributeDesc = LuaText.type_blunt_text_2
      AttributeCurEffect = string.format(LuaText.type_blunt_text_3, tostring(self.Data.num), tostring(self.Data.num))
    elseif attributeType == Enum.AttributeType.AT_TYPE_SHARPEN then
      AttributeTitle = LuaText.type_sharpen_text_1
      AttributeDesc = LuaText.type_sharpen_text_2
      AttributeCurEffect = string.format(LuaText.type_sharpen_text_3, tostring(self.Data.num), tostring(self.Data.num))
    end
    local nounInterpretationTipsInfo = {}
    nounInterpretationTipsInfo.bIsUseOriginalText = true
    nounInterpretationTipsInfo.originalTextList = {}
    nounInterpretationTipsInfo.originalTextList[1] = AttributeTitle .. "\n" .. AttributeDesc
    nounInterpretationTipsInfo.originalTextList[2] = AttributeCurEffect
    _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
  end
end

function UMG_PetDetailedTemplate1_C:OnItemSelected(_bSelected)
end

function UMG_PetDetailedTemplate1_C:OnDeactive()
end

return UMG_PetDetailedTemplate1_C
