local UMG_PetEvoLevelUP_fx_C = _G.NRCViewBase:Extend("UMG_PetEvoLevelUP_fx_C")

function UMG_PetEvoLevelUP_fx_C:OnConstruct()
end

function UMG_PetEvoLevelUP_fx_C:OnDestruct()
end

function UMG_PetEvoLevelUP_fx_C:OnActive()
end

function UMG_PetEvoLevelUP_fx_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_PetEvoLevelUP_fx_C:PlayLevelUpEffect()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.LevelUp)
end

function UMG_PetEvoLevelUP_fx_C:OnAnimationFinished(Animation)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

return UMG_PetEvoLevelUP_fx_C
