local BP_Home_Pet_3D_Widget_C = Class()

function BP_Home_Pet_3D_Widget_C:UpdateData(petData)
  if not petData then
    return
  end
  if not petData.base_conf_id then
    if self.petWidget:IsVisible() then
      self.petWidget:SetVisible(false)
    else
      return
    end
  end
  if self.petWidget then
    if not self.petWidget:IsVisible() then
      self.petWidget:SetVisible(true)
    end
    local UMGHomePet = self.petWidget:GetWidget()
    if UMGHomePet and UMGHomePet.UpdateIcon then
      UMGHomePet:UpdateIcon(petData.base_conf_id)
    end
  end
end

return BP_Home_Pet_3D_Widget_C
