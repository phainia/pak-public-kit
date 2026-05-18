local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Customdot_C = Base:Extend("UMG_Customdot_C")

function UMG_Customdot_C:OnConstruct()
end

function UMG_Customdot_C:OnDestruct()
end

function UMG_Customdot_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetInfo()
end

function UMG_Customdot_C:SetInfo()
  local Data = self.uiData
  self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if Data.IsMarker == true then
    self.BlackMask:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BlackMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.NRCText_28:SetText(Data.Index)
end

function UMG_Customdot_C:SetMarkerIndex(_Index)
  self.NRCText_28:SetText(_Index)
end

function UMG_Customdot_C:SetSelectedVisible(_bSelected)
  if _bSelected then
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Customdot_C:OnItemSelected(_bSelected)
  self:SetSelectedVisible(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.SelectMarker, self.uiData)
  end
end

function UMG_Customdot_C:OnDeactive()
end

return UMG_Customdot_C
