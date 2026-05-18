local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FriendTeamAvatarp_C = Base:Extend("UMG_FriendTeamAvatarp_C")

function UMG_FriendTeamAvatarp_C:OnConstruct()
end

function UMG_FriendTeamAvatarp_C:OnDestruct()
end

function UMG_FriendTeamAvatarp_C:OnItemUpdate(_data, datalist, index)
  local switcherActiveIndex = 0
  local skillDamTypeList = {}
  local reportVisibility = UE.ESlateVisibility.Collapsed
  local attrVisibility = UE.ESlateVisibility.Collapsed
  if "nil" == _data then
    switcherActiveIndex = 1
  elseif _data then
    self.petData = _data.PetData
    if self.petData then
      local isTrailPet = self.petData.isTrailPet
      if isTrailPet then
        self.NRCImage_1:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        self.NRCImage_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self.NRCSwitcher_0:SetActiveWidgetIndex(0)
      self.SelectedGrade:SetText(self.petData.level)
      self.HeadIcon:SetIconPathAndMaterial(self.petData.base_conf_id, self.petData.mutation_type, self.petData.glass_info)
      local typeInfo = self.petData and self.petData.type
      local typeInfoType = typeInfo and typeInfo.type
      if typeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
        switcherActiveIndex = 2
        local skillDamType = typeInfo and typeInfo.param
        table.insert(skillDamTypeList, skillDamType)
        if skillDamType == ProtoEnum.SkillDamType.SDT_INVALID then
          reportVisibility = UE.ESlateVisibility.SelfHitTestInvisible
        else
          attrVisibility = UE.ESlateVisibility.SelfHitTestInvisible
        end
      end
    end
  end
  self.NRCSwitcher_0:SetActiveWidgetIndex(switcherActiveIndex)
  self.Report:SetVisibility(reportVisibility)
  self.Attr:SetVisibility(attrVisibility)
  self.Attr:InitGridView(skillDamTypeList)
end

function UMG_FriendTeamAvatarp_C:OnItemSelected(_bSelected)
end

function UMG_FriendTeamAvatarp_C:OnDeactive()
end

return UMG_FriendTeamAvatarp_C
