local UMG_Handbook_Habitat_C = _G.NRCViewBase:Extend("UMG_Handbook_Habitat_C")

function UMG_Handbook_Habitat_C:OnActive()
end

function UMG_Handbook_Habitat_C:OnDeactive()
end

function UMG_Handbook_Habitat_C:OnAddEventListener()
end

function UMG_Handbook_Habitat_C:SetCircleRadius(_r, mapScale)
  local cfg = _G.DataConfigManager:GetPetGlobalConfig("Handbook_habitat_radius_minimum")
  if cfg then
    local miniR = cfg.num
    if _r < miniR then
      _r = miniR
    end
    local scale = _r / 50 * mapScale
    self.CanvasPanel_0:SetRenderScale(UE4.FVector2D(scale, scale))
  end
end

return UMG_Handbook_Habitat_C
