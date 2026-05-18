local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_StarLightPetDetails_C = Base:Extend("UMG_StarLightPetDetails_C")

function UMG_StarLightPetDetails_C:OnConstruct()
end

function UMG_StarLightPetDetails_C:OnDestruct()
end

function UMG_StarLightPetDetails_C:OnItemUpdate(_data, datalist, index)
  self.petID = _data.petID
  self.petGID = _data.petGID
  self.realIDIndex = _data.realIDIndex
  self.petData = _data
  if 0 == self.petGID then
    self.EmptyState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.EmptyState:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.petGID and _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGID) then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGID)
    self.HeadIcon:SetIconPathAndMaterial(self.petID, petData.mutation_type, petData.glass_info)
  else
    self.HeadIcon:SetIconPathAndMaterial(self.petID)
  end
  self.index = index
end

function UMG_StarLightPetDetails_C:OnItemSelected(_bSelected)
end

function UMG_StarLightPetDetails_C:OnDeactive()
end

return UMG_StarLightPetDetails_C
