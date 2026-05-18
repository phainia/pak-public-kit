local NRCPanelResLoadData = NRCClass:Extend("NRCPanelResLoadData")

function NRCPanelResLoadData:Ctor()
  NRCClass.Ctor(self)
  self.PreLoadResList = nil
  self.LoadingResList = nil
  self.LoadingText = nil
  self.TabResList = nil
end

return NRCPanelResLoadData
