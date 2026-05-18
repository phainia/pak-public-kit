local MiracleExchangeModuleData = _G.NRCData:Extend("MiracleExchangeModuleData")

function MiracleExchangeModuleData:Ctor()
  NRCData.Ctor(self)
  self.MiracleExchangeMainSelectPetGid = 0
  self.chooseTypeList = {}
  self.chooseTypeListTemporary = {}
end

return MiracleExchangeModuleData
