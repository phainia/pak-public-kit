local ResTrackerModuleHead = NRCModuleHeadBase:Extend("ResTrackerModuleHead")

function ResTrackerModuleHead:OnConstruct()
  _G.ResTrackerModuleCmd = reload("NewRoco.Modules.System.ResTracker.ResTrackerModuleCmd")
end

return ResTrackerModuleHead
