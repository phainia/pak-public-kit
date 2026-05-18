local UMG_PetRadarInfoTemple_C = _G.NRCViewBase:Extend("UMG_PetRadarInfoTemple_C")

function UMG_PetRadarInfoTemple_C:Initialize(Initializer)
  Log.Debug("UMG_PetRadarInfoTemple_C:Initialize")
end

function UMG_PetRadarInfoTemple_C:OnConstruct()
  Log.Debug("UMG_PetRadarInfoTemple_C:OnConstruct")
end

function UMG_PetRadarInfoTemple_C:OnDestruct()
end

function UMG_PetRadarInfoTemple_C:OnEnable()
  Log.Debug("UMG_PetRadarInfoTemple_C:OnEnable")
end

function UMG_PetRadarInfoTemple_C:OnDisable()
end

function UMG_PetRadarInfoTemple_C:SetData(data)
  self.numTxt:SetText(data)
end

return UMG_PetRadarInfoTemple_C
