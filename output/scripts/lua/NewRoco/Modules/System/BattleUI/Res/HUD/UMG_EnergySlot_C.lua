require("UnLuaEx")
local UMG_EnergySlot_C = NRCUmgClass:Extend("")

function UMG_EnergySlot_C:Construct()
  self.On:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_EnergySlot_C:Toggle(Visible, Anim, Force)
  if Force or self:IsOn() ~= Visible then
    if Visible then
      self.On:SetVisibility(UE4.ESlateVisibility.Visible)
      if Anim then
        self:StopAnimation(self.Out)
        self:PlayAnimation(self.In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, true)
      end
    elseif Anim then
      self:StopAnimation(self.In)
      self:PlayAnimation(self.Out, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, true)
    else
      self.On:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_EnergySlot_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    self.On:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_EnergySlot_C:IsOn()
  return self.On:GetVisibility() == UE4.ESlateVisibility.Visible
end

function UMG_EnergySlot_C:PlayBlink()
  self:PlayAnimation(self.Blink)
end

return UMG_EnergySlot_C
