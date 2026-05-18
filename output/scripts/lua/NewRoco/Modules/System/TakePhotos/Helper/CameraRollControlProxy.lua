local TakePhotosUtils = require("NewRoco.Modules.System.TakePhotos.TakePhotosUtils")
local CameraRollControlProxy = Class("CameraRollControlProxy")

function CameraRollControlProxy:Ctor(MainPanel)
  self.MainPanel = MainPanel
  MainPanel.OnModeChangedDelegate:Add(self, self.OnModeChanged)
  MainPanel.OnDestroyMultiDelegate:Add(self, self.OnDestroy)
  self.Settings = MainPanel:GetPhotoController().TakePhotoSettings
  self.Settings.CameraRollProgress.OnValueChanged:Add(self, self.OnRollSettingsChanged)
end

function CameraRollControlProxy:OnDestroy()
  TakePhotosUtils.ChangeRoll(0)
end

function CameraRollControlProxy:OnModeChanged(Mode)
  if not Mode then
    return
  end
  local DesiredRoll = self.Settings.CameraRollProgress:GetValue()
  if Mode.Mgr:Is1PMode() or Mode.Mgr:IsSelfieMode() then
    TakePhotosUtils.ChangeRoll(DesiredRoll)
  else
    TakePhotosUtils.ChangeRoll(0)
  end
end

function CameraRollControlProxy:OnRollSettingsChanged(Value)
  self:OnModeChanged(self.MainPanel.CurrMode)
end

return CameraRollControlProxy
