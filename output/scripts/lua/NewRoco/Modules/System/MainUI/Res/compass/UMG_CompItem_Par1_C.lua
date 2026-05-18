local UMG_CompItem_Par1_C = _G.NRCPanelBase:Extend("UMG_CompItem_Par1_C")

function UMG_CompItem_Par1_C:OnActive()
end

function UMG_CompItem_Par1_C:OnDeactive()
end

function UMG_CompItem_Par1_C:OnAddEventListener()
end

function UMG_CompItem_Par1_C:PlayLoop1Animation()
  self:PlayAnimation(self.Loop_1, 0, 0)
end

function UMG_CompItem_Par1_C:PlayLoop2Animation()
  self:PlayAnimation(self.Loop_2, 0, 0)
end

function UMG_CompItem_Par1_C:PlayLoop3Animation()
  self:PlayAnimation(self.Loop_3, 0, 0)
end

function UMG_CompItem_Par1_C:PlayLoop4Animation()
  self:PlayAnimation(self.Loop_4, 0, 0)
end

function UMG_CompItem_Par1_C:StopLoopAnimations()
  self:StopAnimation(self.Loop_1)
  self:StopAnimation(self.Loop_2)
  self:StopAnimation(self.Loop_3)
  self:StopAnimation(self.Loop_4)
end

function UMG_CompItem_Par1_C:OnAnimationFinished(anim)
end

return UMG_CompItem_Par1_C
