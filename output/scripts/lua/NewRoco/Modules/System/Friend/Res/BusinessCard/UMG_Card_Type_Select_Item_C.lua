local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_Card_Type_Select_Item_C = Base:Extend("UMG_Card_Type_Select_Item_C")

function UMG_Card_Type_Select_Item_C:OnConstruct()
  self.module = _G.NRCModuleManager:GetModule("FriendModule")
  self.moduleData = self.module:GetData("FriendModuleData")
  self.Click.OnClicked:Add(self, self.OnBtnClick)
end

function UMG_Card_Type_Select_Item_C:OnDestruct()
end

function UMG_Card_Type_Select_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:UpdateInfo()
end

function UMG_Card_Type_Select_Item_C:UpdateInfo()
  local curEditPetTypeList = self.moduleData:GetCurEditPetTypeIdList()
  if curEditPetTypeList and table.contains(curEditPetTypeList, self.data) then
    self.Switcher:SetActiveWidgetIndex(0)
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.Switcher:SetActiveWidgetIndex(1)
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605eFF"))
  end
  local petTypeData = _G.DataConfigManager:GetTypeDictionary(self.data)
  if petTypeData then
    self.SortText:SetText(petTypeData.short_name)
    self.DepartmentIcon:SetPath(petTypeData.type_icon)
    self.DepartmentIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.SortText:SetText("")
    self.DepartmentIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Card_Type_Select_Item_C:OnBtnClick()
  local curEditPetTypeList = self.moduleData:GetCurEditPetTypeIdList()
  if curEditPetTypeList and table.contains(curEditPetTypeList, self.data) then
    table.removeValue(curEditPetTypeList, self.data)
  else
    table.insert(curEditPetTypeList, self.data)
  end
  self:UpdateInfo()
  self.module:DispatchEvent(FriendModuleEvent.UpdatePetTypeSelect)
end

function UMG_Card_Type_Select_Item_C:OnDeactive()
end

return UMG_Card_Type_Select_Item_C
