local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Bag_CommonPetHeadPicture_C = Base:Extend("UMG_Bag_CommonPetHeadPicture_C")

function UMG_Bag_CommonPetHeadPicture_C:OnConstruct()
end

function UMG_Bag_CommonPetHeadPicture_C:OnDestruct()
end

function UMG_Bag_CommonPetHeadPicture_C:OnItemUpdate(_data, datalist, index)
  self.PetData = _data
  self:InitializeInfo()
  self:SetData()
end

function UMG_Bag_CommonPetHeadPicture_C:InitializeInfo()
  self.NumText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Bag_CommonPetHeadPicture_C:SetData()
  self.HeadIcon:SetIconPathAndMaterial(self.PetData.base_conf_id, self.PetData.mutation_type, self.PetData.glass_info)
  self.HeadIcon_1:SetIconPathAndMaterial(self.PetData.base_conf_id, self.PetData.mutation_type, self.PetData.glass_info)
end

function UMG_Bag_CommonPetHeadPicture_C:SetEvolutionChainPetInfo(Num)
  self.NumText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NumText:SetText(Num)
end

function UMG_Bag_CommonPetHeadPicture_C:SetMedalType(medal_type)
  if medal_type == _G.Enum.MedalType.MT_IND then
    self.MedalTypeSwitch:SetActiveWidgetIndex(0)
  elseif medal_type == _G.Enum.MedalType.MT_SPECIES or medal_type == _G.Enum.MedalType.MT_BOND then
    self.MedalTypeSwitch:SetActiveWidgetIndex(1)
  end
end

function UMG_Bag_CommonPetHeadPicture_C:SelectInfo(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.Select_In)
  else
    self:PlayAnimation(self.Select_Out)
  end
end

function UMG_Bag_CommonPetHeadPicture_C:OnItemSelected(_bSelected)
  self:SelectInfo(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(BagModuleCmd.SelectCommonPetHeadPicture, self.PetData)
  end
end

function UMG_Bag_CommonPetHeadPicture_C:OnDeactive()
end

return UMG_Bag_CommonPetHeadPicture_C
