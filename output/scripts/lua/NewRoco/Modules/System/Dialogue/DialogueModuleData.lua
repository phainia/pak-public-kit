local DialogueModuleData = _G.NRCData:Extend("DialogueModuleData")

function DialogueModuleData:Ctor()
  _G.NRCData.Ctor(self)
  self.CameraUI = nil
  self.SavedTargetView = {}
  self.IsCameraUIAlive = false
end

return DialogueModuleData
