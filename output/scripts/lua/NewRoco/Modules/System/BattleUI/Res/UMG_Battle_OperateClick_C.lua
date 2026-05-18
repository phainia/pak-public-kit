local UMG_Battle_OperateClick_C = NRCUmgClass:Extend("")

function UMG_Battle_OperateClick_C:PlayUnselectAnimation()
  self:StopAllAnimations()
  self:PlayAnimation(self.unselect)
end

function UMG_Battle_OperateClick_C:PlaySelectAnimation()
  self:StopAllAnimations()
  self:PlayAnimation(self.click)
end

return UMG_Battle_OperateClick_C
