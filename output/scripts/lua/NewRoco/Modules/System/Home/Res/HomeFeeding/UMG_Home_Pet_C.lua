local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UMG_Home_Pet_C = _G.NRCPanelBase:Extend("UMG_Home_Pet_C")

function UMG_Home_Pet_C:OnConstruct()
  Log.Debug("UMG_Home_Pet_C:OnConstruct")
end

function UMG_Home_Pet_C:UpdateIcon(petData)
  if not petData then
    self.Empty:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Gender:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:CheckManuallyRedraw()
    return
  else
    self.Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      local path = modelConf.icon
      if petData.mutation_type and PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
        path = modelConf.shiny_icon
      end
      self.NRCpetIcon:SetNestIconPathAndMaterial(path, petData.mutation_type, petData.glass_info, self)
    end
  end
  self.Gender:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if petData.gender ~= nil and petData.gender > 0 then
    self.Gender:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Gender:SetActiveWidgetIndex(petData.gender - 1)
  end
end

function UMG_Home_Pet_C:OnImageLoadFinished()
  if self.attachActor and self.attachActor.OnIconPrepared then
    self.attachActor:OnIconPrepared()
    self.attachActor = nil
  elseif UE.UObject.IsValid(self.petWidget) then
    self.petWidget:SetVisibility(true, true)
  end
  self:CheckManuallyRedraw()
end

function UMG_Home_Pet_C:OnActive()
end

function UMG_Home_Pet_C:SetParentHUD(parentHUD)
  self.petWidget = parentHUD
  self:CheckManuallyRedraw()
end

function UMG_Home_Pet_C:SetAttachActor(actor)
  self.attachActor = actor
end

function UMG_Home_Pet_C:CheckManuallyRedraw()
  if UE.UObject.IsValid(self.petWidget) then
    local result = true
    self.petWidget:SetManuallyRedraw(result)
    return result
  end
  return false
end

return UMG_Home_Pet_C
