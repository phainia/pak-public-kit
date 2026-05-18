local UMG_PetOutlinear_C = _G.NRCClass:Extend("UMG_PetOutlinear_C")

function UMG_PetOutlinear_C:Construct()
end

function UMG_PetOutlinear_C:BindOwner(Owner)
  self._Owner = Owner
end

function UMG_PetOutlinear_C:StartAnim(Owner)
  self:BindOwner(Owner)
  self.OnFinishDelegate = self.OnFadeIn
  self.FinishAnim = self.In
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
end

function UMG_PetOutlinear_C:StopAnim(Owner)
  self:BindOwner(Owner)
  self.OnFinishDelegate = self.OnFadeOut
  self.FinishAnim = self.Out
  self:StopAllAnimations()
  self:PlayAnimation(self.Out)
end

function UMG_PetOutlinear_C:OnFadeIn()
  if self._Owner then
    self._Owner:OnFadeIn()
  end
end

function UMG_PetOutlinear_C:OnFadeOut()
  if self._Owner then
    self._Owner:OnFadeOut()
  end
end

function UMG_PetOutlinear_C:OnAnimationFinished(Animation)
  if Animation == self.FinishAnim and self.OnFinishDelegate then
    self.OnFinishDelegate(self)
  end
end

return UMG_PetOutlinear_C
