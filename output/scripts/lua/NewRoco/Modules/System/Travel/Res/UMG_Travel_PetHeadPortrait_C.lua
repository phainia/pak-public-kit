local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")
local UMG_Travel_PetHeadPortrait_C = Base:Extend("UMG_Travel_PetHeadPortrait_C")

function UMG_Travel_PetHeadPortrait_C:OnConstruct()
end

function UMG_Travel_PetHeadPortrait_C:OnDestruct()
end

function UMG_Travel_PetHeadPortrait_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Select:SetVisibility(self.data.isSelect and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self.NRCSwitcher_17:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Add:SetVisibility(UE4.ESlateVisibility.Visible)
  if -1 ~= self.data.baseId and -1 ~= self.data.gid then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.data.gid)
    self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    if petData then
      self.HeadIcon:SetIconPathAndMaterial(petData.base_conf_id, petData.mutation_type, petData.glass_info)
    end
    self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Gender:SetActiveWidgetIndex(petData.gender - 1)
    self.Gender:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Gender:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Travel_PetHeadPortrait_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1281, "UMG_Travel_PetHeadPortrait_C:OnItemSelected")
    _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnOpenTravelPetListPanel, self.data.gid)
    if -1 ~= self.data.baseId and -1 ~= self.data.gid then
      _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.UnSelectPetListItem, self.data.gid, self.index)
    end
    if self.data.isShowTips then
      local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.data.gid)
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, PetData)
    end
  end
end

function UMG_Travel_PetHeadPortrait_C:OnDeactive()
end

return UMG_Travel_PetHeadPortrait_C
