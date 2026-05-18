require("UnLuaEx")
local ResTrackerModuleEvent = require("NewRoco.Modules.System.ResTracker.ResTrackerModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ResTrackResultClassItem_C = Base:Extend("UMG_ResTrackResultClassItem_C")

function UMG_ResTrackResultClassItem_C:OnConstruct()
end

function UMG_ResTrackResultClassItem_C:OnDestruct()
  if self.selected ~= nil and self.selected then
    self:Deselect()
  end
end

function UMG_ResTrackResultClassItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self.Text:SetText("  " .. _data .. "  ")
end

function UMG_ResTrackResultClassItem_C:Select()
  if self.BgImage == nil then
    return
  end
  self.BgImage:SetOpacity(0)
end

function UMG_ResTrackResultClassItem_C:Deselect()
  if self.BgImage == nil then
    return
  end
  self.BgImage:SetOpacity(0.4)
end

function UMG_ResTrackResultClassItem_C:OnItemSelected(selected)
  Log.Debug("OnItemSelected: " .. self.data .. " " .. tostring(selected))
  self.selected = selected
  if selected then
    self:Select()
  else
    self:Deselect()
    return
  end
  if self.data == nil then
    return
  end
  local TrackerModule = _G.NRCModuleManager:GetModule("ResTrackerModule")
  TrackerModule:DispatchEvent(ResTrackerModuleEvent.ClassItemClicked, self)
end

return UMG_ResTrackResultClassItem_C
