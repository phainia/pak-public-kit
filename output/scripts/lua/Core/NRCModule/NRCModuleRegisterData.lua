local NRCModuleRegisterData = NRCClass()

function NRCModuleRegisterData:Ctor()
  NRCClass.Ctor(self)
  Log.Debug("NRCModuleRegisterData ctor")
  self.moduleName = nil
  self.modulePath = nil
  self.moduleClass = nil
  self.moduleActiveArgs = nil
  self.module = nil
end

return NRCModuleRegisterData
