local UMG_VariegatedFlowerSpecies_C = _G.NRCPanelBase:Extend("UMG_VariegatedFlowerSpecies_C")

function UMG_VariegatedFlowerSpecies_C:OnActive()
end

function UMG_VariegatedFlowerSpecies_C:OnDeactive()
end

function UMG_VariegatedFlowerSpecies_C:OnAddEventListener()
end

function UMG_VariegatedFlowerSpecies_C:OnEnable(typeWrap)
  if typeWrap.IsShinyFlower then
    self:PlayAnimation(self.Yisehuazhong_Loop)
  elseif typeWrap.IsLimitedFlower then
    self:PlayAnimation(self.Xishouhuazhong_Loop)
  end
end

return UMG_VariegatedFlowerSpecies_C
