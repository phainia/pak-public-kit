local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_CommonPetIcon_C = Base:Extend("UMG_CommonPetIcon_C")

function UMG_CommonPetIcon_C:OnConstruct()
end

function UMG_CommonPetIcon_C:OnDestruct()
end

function UMG_CommonPetIcon_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetInfo()
end

function UMG_CommonPetIcon_C:SetInfo()
  self.pet:SetIconPathAndMaterial(self.uiData.PetData.base_conf_id, self.uiData.PetData.mutation_type, self.uiData.PetData.glass_info)
  self.Text_Quantity:SetText(string.format("%d", self.uiData.PetData.level))
  if self.uiData.bShowTag then
    self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Travel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, self.uiData.PetData.gid)
    local IsMainTeam = PetUtils.GetIsMainTeamByGid(self.uiData.PetData.gid)
    if IsMainTeam then
      self.Travel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif isTravel then
      self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Travel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Travel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CommonPetIcon_C:OnItemSelected(_bSelected)
  if _bSelected and self.uiData.PetData and self.uiData.bShowTip then
    _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_PetReportPetListItem_C:OnItemSelected")
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.uiData.PetData)
  end
end

function UMG_CommonPetIcon_C:OnDeactive()
end

return UMG_CommonPetIcon_C
