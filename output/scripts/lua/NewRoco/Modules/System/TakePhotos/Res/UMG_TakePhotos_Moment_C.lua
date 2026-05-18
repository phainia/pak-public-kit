local UMG_TakePhotos_Moment_C = _G.NRCPanelBase:Extend("UMG_TakePhotos_Moment_C")
local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")

function UMG_TakePhotos_Moment_C:OnActive(Callback)
  self.Callback = Callback
  self:PlayAnimation(self.take)
end

function UMG_TakePhotos_Moment_C:OnAnimationFinished(Anim)
  if Anim == self.take then
    local Callback = self.Callback
    if self.panelData and self.enableView then
      self:DoClose()
    end
    if Callback then
      Callback()
    end
  end
end

return UMG_TakePhotos_Moment_C
