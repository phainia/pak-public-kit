local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leve_RivalCamp_C = Base:Extend("UMG_Leve_RivalCamp_C")

function UMG_Leve_RivalCamp_C:OnConstruct()
end

function UMG_Leve_RivalCamp_C:OnDestruct()
end

function UMG_Leve_RivalCamp_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.data and self.data.pet_gid and 0 ~= self.data.pet_gid then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.data.pet_gid)
    if petData then
      self.SelectedGrade:SetVisibility(UE4.ESlateVisibility.Visible)
      self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SelectedGrade:SetText(petData.level)
      self.HeadIcon:SetIconPathAndMaterial(petData.base_conf_id, petData.mutation_type, petData.glass_info)
    end
  else
    self.SelectedGrade:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.data.isLevelTeam then
    self.SelectedGrade:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SelectedGrade:SetText(self.data.level)
    self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.HeadIcon:SetIconPathAndMaterial(self.data.base_conf_id)
  end
end

function UMG_Leve_RivalCamp_C:OnItemSelected(_bSelected)
end

function UMG_Leve_RivalCamp_C:OnDeactive()
end

return UMG_Leve_RivalCamp_C
