local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MarkPointBnt_C = Base:Extend("UMG_MarkPointBnt_C")

function UMG_MarkPointBnt_C:OnConstruct()
end

function UMG_MarkPointBnt_C:OnDestruct()
end

function UMG_MarkPointBnt_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Image_Icon:SetPath(_data.Icon)
end

function UMG_MarkPointBnt_C:OnItemSelected(_bSelected)
  if _bSelected then
    local SelectMarkerType = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetSelectMarkerType)
    if SelectMarkerType and SelectMarkerType.Type == self.data.Type then
      return
    end
    self:PlayAnimation(self.Press)
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.MarkerTypeSelect, self.data)
  else
    self:PlayAnimation(self.Up)
  end
end

function UMG_MarkPointBnt_C:OnDeactive()
end

return UMG_MarkPointBnt_C
