local Base = _G.NRCUmgClass
local UMG_Task_UIIcon_C = Base:Extend("UMG_Task_UIIcon_C")

function UMG_Task_UIIcon_C:SetPath(path)
  self.Icon:SetPath(path)
  self.IconSub:SetPath(path)
end

function UMG_Task_UIIcon_C:StartAnimation()
  self:PlayAnimation(self.select)
end

function UMG_Task_UIIcon_C:OnAnimationStarted(Animation)
end

function UMG_Task_UIIcon_C:OnAnimationFinished(Animation)
  if Animation == self.select then
    self:PlayAnimation(self.loop)
  elseif Animation == self.loop then
    self:PlayAnimation(self.loop)
  end
end

return UMG_Task_UIIcon_C
