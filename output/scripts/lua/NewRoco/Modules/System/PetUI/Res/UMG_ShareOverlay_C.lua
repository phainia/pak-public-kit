local UMG_ShareOverlay_C = _G.NRCPanelBase:Extend("UMG_ShareOverlay_C")

function UMG_ShareOverlay_C:OnActive(data)
  self.data = data
  self:PlayAnimation(self.NewAnimation)
end

function UMG_ShareOverlay_C:OnDeactive()
end

function UMG_ShareOverlay_C:OnAddEventListener()
end

function UMG_ShareOverlay_C:OnAnimationFinished(Animation)
  if Animation == self.NewAnimation then
    local data = self.data
    
    local function OpenCb()
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PlayShareVideoG6)
    end
    
    local function CloseCb()
      _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.OpenShareUIPanel, data)
    end
    
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenShareCameraPanel, data.petData, OpenCb, CloseCb)
  end
end

return UMG_ShareOverlay_C
