local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BookDropDownListltem_C = Base:Extend("UMG_BookDropDownListltem_C")

function UMG_BookDropDownListltem_C:OnConstruct()
end

function UMG_BookDropDownListltem_C:OnDestruct()
end

function UMG_BookDropDownListltem_C:OnItemUpdate(_data, datalist, index)
  self.TImage:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.sortId = _data
  local sortInfo = _G.DataConfigManager:GetPetHandbookSequence(self.sortId)
  self.TText:SetText(sortInfo.sequence_desc)
  _G.DelayManager:DelaySeconds(0.175 * index, function()
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  end)
end

function UMG_BookDropDownListltem_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1090, "UMG_BookDropDownListltem_C:OnItemSelected")
  end
  if _bSelected then
    self.TImage:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.TImage:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_BookDropDownListltem_C:OnDeactive()
end

return UMG_BookDropDownListltem_C
