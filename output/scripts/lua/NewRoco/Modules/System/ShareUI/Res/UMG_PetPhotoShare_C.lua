local UMG_PetPhotoShare_C = _G.NRCViewBase:Extend("UMG_PetPhotoShare_C")

function UMG_PetPhotoShare_C:OnConstruct()
  self:SetChildViews(self.PetRadarInfo, self.UMG_PetRate, self.UMG_PetImage3D)
end

return UMG_PetPhotoShare_C
