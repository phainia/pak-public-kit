local UMG_Common_BIconParItem_C = _G.NRCPanelBase:Extend("UMG_Common_BIconParItem_C")

function UMG_Common_BIconParItem_C:OnConstruct()
  self.isloop = false
end

function UMG_Common_BIconParItem_C:OnDestruct()
  self.isloop = false
end

function UMG_Common_BIconParItem_C:OnActive()
end

function UMG_Common_BIconParItem_C:OnDeactive()
end

function UMG_Common_BIconParItem_C:PlayLoop()
  if self.isloop == false then
    self:PlayAnimation(self.loop, 0, 0)
  end
end

function UMG_Common_BIconParItem_C:PlayLoopAnimation()
  if self.loop ~= nil then
    self:PlayAnimation(self.loop, 0, 0)
  end
end

function UMG_Common_BIconParItem_C:StopLoop()
  self:StopAnimation(self.loop)
end

function UMG_Common_BIconParItem_C:OnAnimationStarted(Animation)
  self.isloop = true
end

function UMG_Common_BIconParItem_C:OnAnimationFinished(anim)
  self.isloop = false
end

return UMG_Common_BIconParItem_C
