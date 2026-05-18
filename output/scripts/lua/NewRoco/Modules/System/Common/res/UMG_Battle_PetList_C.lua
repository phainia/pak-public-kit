local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Battle_PetList_C = Base:Extend("UMG_Battle_PetList_C")

function UMG_Battle_PetList_C:OnConstruct()
end

function UMG_Battle_PetList_C:OnDestruct()
end

function UMG_Battle_PetList_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:UpdateItemInfo()
end

function UMG_Battle_PetList_C:UpdateItemInfo()
  local attrConf = _G.DataConfigManager:GetAttributeConf(self.uiData.attrType)
  if attrConf then
    self.imageAttriIcon:SetPath(attrConf.attribute_icon)
    self.attriNameTxt:SetText(attrConf.attribute_name)
  end
  self.numTxt:SetText(self.uiData.addiAttrInfo)
  local addTxt = "+" .. self.uiData.attrInfo.talent
  self.addNumTxt:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.uiData.attrInfo.talent > 0 then
    self.addNumTxt:SetVisibility(UE4.ESlateVisibility.Visible)
    self.addNumTxt:SetText(addTxt)
  end
  local addNum = self.uiData.attrInfo.total_race
  self.curNumTxt:SetText(addNum)
  if self.uiData.positive_effect == self.uiData.arrowType then
    self.State:SetActiveWidgetIndex(0)
  elseif self.uiData.negative_effect == self.uiData.arrowType then
    self.State:SetActiveWidgetIndex(1)
  else
    self.State:SetActiveWidgetIndex(2)
  end
  if self.uiData.NoShowLine then
    self.Divider:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Divider:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Race:SetText(self.uiData.name)
end

function UMG_Battle_PetList_C:OnItemSelected(_bSelected)
end

function UMG_Battle_PetList_C:OnDeactive()
end

return UMG_Battle_PetList_C
