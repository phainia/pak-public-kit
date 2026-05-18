local UMG_PetTriedHeadTemple_C = NRCClass()

function UMG_PetTriedHeadTemple_C:Construct()
end

function UMG_PetTriedHeadTemple_C:Destruct()
  self.uiData = nil
end

function UMG_PetTriedHeadTemple_C:SetData(_data)
  self.uiData = _data
  self:UpdateHeadInfo()
end

function UMG_PetTriedHeadTemple_C:UpdateHeadInfo()
  if not (self.uiData and self.uiData.petBaseConfId) or self.uiData.petBaseConfId <= 0 then
    return
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.petBaseConfId)
  if not petBaseConf then
    return
  end
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  if not modelConf then
    return
  end
  if modelConf.tired_small_icon then
    self.headIcon:SetPath(modelConf.tired_small_icon)
  end
end

return UMG_PetTriedHeadTemple_C
