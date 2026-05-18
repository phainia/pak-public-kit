local NRCPanelOpenReqData = NRCClass:Extend("NRCPanelOpenReqData")

function NRCPanelOpenReqData:Ctor()
  NRCClass.Ctor(self)
  self.cmdId = nil
  self.reqClass = nil
  self.paramList = nil
  self.needModal = nil
  self.needModal = false
  self.ignoreErrorTip = false
  self.NPCAction = nil
  self.Caller = nil
  self.Callback = nil
end

return NRCPanelOpenReqData
