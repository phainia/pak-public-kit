local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagDropDownListltem_C = Base:Extend("UMG_BagDropDownListltem_C")

function UMG_BagDropDownListltem_C:OnConstruct()
end

function UMG_BagDropDownListltem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self:SetData(_data)
end

function UMG_BagDropDownListltem_C:SetData(data)
  self.TImage:SetVisibility(UE4.ESlateVisibility.Hidden)
  local sortId = data + 1
  local sortInfo = _G.DataConfigManager:GetBagItemSequence(sortId)
  self.TText:SetText(sortInfo.sequence_desc)
end

function UMG_BagDropDownListltem_C:OnClick()
end

function UMG_BagDropDownListltem_C:UnClick()
end

function UMG_BagDropDownListltem_C:OnItemSelected(selected)
  if selected then
    _G.NRCAudioManager:PlaySound2DAuto(1090, "UMG_BagDropDownListltem_C:OnItemSelected")
    self.TImage:SetVisibility(UE4.ESlateVisibility.Visible)
    NRCModuleManager:DoCmd(BagModuleCmd.OnSequenceSelected, self.index)
  else
    self.TImage:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

return UMG_BagDropDownListltem_C
