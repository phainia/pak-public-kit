local UMG_LayerMapTemplate_C = _G.NRCPanelBase:Extend("UMG_LayerMapTemplate_C")

function UMG_LayerMapTemplate_C:OnActive()
end

function UMG_LayerMapTemplate_C:OnDeactive()
end

function UMG_LayerMapTemplate_C:OnAddEventListener()
end

function UMG_LayerMapTemplate_C:OnConstruct()
end

function UMG_LayerMapTemplate_C:OnDestruct()
end

function UMG_LayerMapTemplate_C:SetLayerMapImage(path)
  self.MapImage:SetPath(path)
end

function UMG_LayerMapTemplate_C:SetMapOpacity(opacity)
  self.MapImage:SetOpacity(opacity)
end

return UMG_LayerMapTemplate_C
