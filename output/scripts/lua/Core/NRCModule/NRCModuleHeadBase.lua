local NRCModuleHeadBase = NRCClass:Extend("NRCModuleHeadBase")

function NRCModuleHeadBase:Ctor(moduleHeadName)
  NRCClass.Ctor(self)
  self.moduleHeadName = moduleHeadName
  self.cmdDict = {}
  self:OnConstruct()
end

function NRCModuleHeadBase:OnConstruct()
end

function NRCModuleHeadBase:BindCmd(cmd, funcName)
  self.cmdDict[cmd] = funcName
end

function NRCModuleHeadBase:BindInitArgs()
end

return NRCModuleHeadBase
