local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetDropDownListItem_C = Base:Extend("UMG_PetDropDownListItem_C")

function UMG_PetDropDownListItem_C:OnConstruct()
end

function UMG_PetDropDownListItem_C:OnDestruct()
end

function UMG_PetDropDownListItem_C:OnActive()
end

function UMG_PetDropDownListItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self:SetData(_data)
end

function UMG_PetDropDownListItem_C:SetData(data)
  self.uiData = data
  self.ParenPanel = data.panel
  if self.uiData.InitSelect == true then
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("F8C969FF"))
    self.NRCImage_54:SetRenderOpacity(1)
  else
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("E9E1CFFF"))
    self.NRCImage_54:SetRenderOpacity(0)
  end
  self.TText:SetText(self.uiData.data.sequence_desc)
  self.TText_1:SetText(self.uiData.data.sequence_desc)
end

function UMG_PetDropDownListItem_C:OnItemSelected(selected)
  if selected then
    if self.ParenPanel then
      self.ParenPanel:OnSortItemSelect(self.uiData.data.sequence_default)
    else
      NRCModuleManager:DoCmd(PetUIModuleCmd.PetSort, self.index)
    end
    if not self.uiData.InitSelect then
      self:PlayAnimation(self.Press)
    else
      self.uiData.InitSelect = false
    end
    self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_PetDropDownListItem_C:OnDeactive()
end

return UMG_PetDropDownListItem_C
