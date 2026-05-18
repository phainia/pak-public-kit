local NRCModuleResData = NRCClass()

function NRCModuleResData:Ctor()
  NRCClass.Ctor(self)
  Log.Debug("NRCModuleResData ctor")
  self.resName = nil
  self.resPath = nil
end

return NRCModuleResData
