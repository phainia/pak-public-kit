local UMG_CompItem_VariegatedFlowerSpecies_C = _G.NRCPanelBase:Extend("UMG_CompItem_VariegatedFlowerSpecies_C")

function UMG_CompItem_VariegatedFlowerSpecies_C:OnEnable(typeWrap)
  if typeWrap.IsShinyFlower then
    self:PlayAnimation(self.Yisehuazhong_Loop, 0, 0)
  elseif typeWrap.IsLimitedFlower then
    self:PlayAnimation(self.Xishouhuazhong_Loop, 0, 0)
  end
end

return UMG_CompItem_VariegatedFlowerSpecies_C
