local ResTrackerModuleEvent = require("NewRoco.Modules.System.ResTracker.ResTrackerModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ResTrackUMGListItem_C = Base:Extend("UMG_ResTrackUMGListItem_C")

function UMG_ResTrackUMGListItem_C:OnConstruct()
end

function UMG_ResTrackUMGListItem_C:OnDestruct()
end

function UMG_ResTrackUMGListItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Text:SetText("  " .. _data .. "  ")
end

function UMG_ResTrackUMGListItem_C:OnItemSelected(selected)
  if selected then
    local TrackerModule = _G.NRCModuleManager:GetModule("ResTrackerModule")
    TrackerModule:DispatchEvent(ResTrackerModuleEvent.UMGItemClicked, self.data)
  end
end

function UMG_ResTrackUMGListItem_C:OnDeactive()
end

return UMG_ResTrackUMGListItem_C
