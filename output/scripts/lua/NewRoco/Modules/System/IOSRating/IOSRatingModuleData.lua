local IOSRatingModuleData = _G.NRCData:Extend("IOSRatingModuleData")

function IOSRatingModuleData:Ctor()
  NRCData.Ctor(self)
  self.cacheRatingTopupId = nil
  self.forbidRatingPopupUsingGM = nil
end

return IOSRatingModuleData
