local NRCCommonItemIconData = NRCClass:Extend("NRCCommonItemIconData")

function NRCCommonItemIconData:Ctor()
  NRCClass.Ctor(self)
  self.PetData = nil
  self.bShowTip = false
  self.bShowTag = false
  self.IsDoCmd = false
  self.DoCmd = nil
  self.Key = nil
  self.extraKey = nil
end
