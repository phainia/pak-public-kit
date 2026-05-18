local UMG_CompItem_Par_C = _G.NRCPanelBase:Extend("UMG_CompItem_Par_C")

function UMG_CompItem_Par_C:OnActive()
end

function UMG_CompItem_Par_C:OnDeactive()
end

function UMG_CompItem_Par_C:OnAddEventListener()
end

function UMG_CompItem_Par_C:PlayInAnimation()
  self:PlayAnimation(self.In)
end

function UMG_CompItem_Par_C:PlayInAnimation2()
  self:PlayAnimation(self.In2)
end

function UMG_CompItem_Par_C:PlayLoopAnimation()
  self:PlayAnimation(self.Loop, 0, 0)
end

function UMG_CompItem_Par_C:PlayOutAnimation()
  self.UMG_CompItem_Par1:StopLoopAnimations()
  self:StopAnimation(self.Loop)
  self:PlayAnimation(self.Out)
end

function UMG_CompItem_Par_C:OnAnimationFinished(anim)
end

return UMG_CompItem_Par_C
