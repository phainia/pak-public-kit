local IOSRatingModuleHead = NRCModuleHeadBase:Extend("IOSRatingModuleHead")

function IOSRatingModuleHead:OnConstruct()
  _G.IOSRatingModuleCmd = reload("NewRoco.Modules.System.IOSRating.IOSRatingModuleCmd")
  self:BindCmd(_G.IOSRatingModuleCmd.GMIOSRating, "GMIOSRating")
  self:BindCmd(_G.IOSRatingModuleCmd.GMCloseIOSRating, "GMCloseIOSRating")
  self:BindCmd(_G.IOSRatingModuleCmd.GMOpenIOSRating, "GMOpenIOSRating")
end

return IOSRatingModuleHead
