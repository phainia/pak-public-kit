local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetUpgradepanel_ListItem_C = Base:Extend("UMG_PetUpgradepanel_ListItem_C")

function UMG_PetUpgradepanel_ListItem_C:OnConstruct()
end

function UMG_PetUpgradepanel_ListItem_C:OnDestruct()
  if self.DelayId then
    DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function UMG_PetUpgradepanel_ListItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:SetPetproperty()
end

function UMG_PetUpgradepanel_ListItem_C:SetPetproperty()
  self.NRCIcon:SetPath(self.uiData.icon)
  if self.uiData.LearnSkillNum and self.uiData.LearnSkillNum > 0 then
  else
    self.NRCSwitcher_30:SetActiveWidgetIndex(0)
    self.NRC_NoChange_1:SetText(self.uiData.attributevalue)
    self.NRC_NoChange:SetText(self.uiData.petbeforeproperty)
    self.NRC_Change:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRC_Change:SetText(self.uiData.petlaterproperty)
  end
end

function UMG_PetUpgradepanel_ListItem_C:OnDeactive()
end

return UMG_PetUpgradepanel_ListItem_C
