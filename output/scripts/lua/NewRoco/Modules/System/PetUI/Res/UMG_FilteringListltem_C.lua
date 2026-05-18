local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FilteringListltem_C = Base:Extend("UMG_FilteringListltem_C")

function UMG_FilteringListltem_C:OnConstruct()
end

function UMG_FilteringListltem_C:OnDestruct()
end

function UMG_FilteringListltem_C:OnItemUpdate(_data, datalist, index)
  self.conf = _data
  self.clickToggle = false
  self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  if self.conf == nil then
    return
  end
  if self.clickToggle == true then
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("F8C969FF"))
    self.NRCImage_54:SetRenderOpacity(1)
  else
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("E9E1CFFF"))
    self.NRCImage_54:SetRenderOpacity(0)
  end
  self.TText:SetText(self.conf.filter_desc)
  self.TText_1:SetText(self.conf.filter_desc)
end

function UMG_FilteringListltem_C:OnNotPlaySound()
  self.IsNotPlaySound = true
end

function UMG_FilteringListltem_C:SetSkillNum(num)
  self.ScreeningQuantity:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NumberText:SetText(num)
end

function UMG_FilteringListltem_C:OnItemSelected(_bSelected)
  if _bSelected then
    if not self.IsNotPlaySound then
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_FilteringListltem_C:OnItemSelected")
    else
      self.IsNotPlaySound = false
    end
    self.clickToggle = not self.clickToggle
    if self.clickToggle then
      self:PlayAnimation(self.Press)
    else
      self:PlayAnimation(self.Cancel)
    end
    if self.clickToggle then
      self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
    else
      self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
    end
    local filterEnumValues = {}
    for i, v in ipairs(self.conf.filter_enum_value) do
      table.insert(filterEnumValues, _G.Enum[self.conf.filter_enum_name][v])
    end
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnPetFilterTypeSelect, self.conf.filter_type, filterEnumValues, self.clickToggle)
  end
end

function UMG_FilteringListltem_C:OnDeactive()
end

return UMG_FilteringListltem_C
