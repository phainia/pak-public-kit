local UMG_Envelope1_light_C = _G.NRCViewBase:Extend("UMG_Envelope1_light_C")

function UMG_Envelope1_light_C:OnConstruct()
  self:PlayAnimation(self.Loop, 0, 9999)
end

function UMG_Envelope1_light_C:OnDestruct()
end

function UMG_Envelope1_light_C:OnActive()
end

function UMG_Envelope1_light_C:OnDeactive()
end

function UMG_Envelope1_light_C:OnAddEventListener()
end

return UMG_Envelope1_light_C
