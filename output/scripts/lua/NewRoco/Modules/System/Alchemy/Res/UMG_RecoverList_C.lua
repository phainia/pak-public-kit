local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RecoverList_C = Base:Extend("UMG_RecoverList_C")

function UMG_RecoverList_C:OnConstruct()
end

function UMG_RecoverList_C:OnDestruct()
end

function UMG_RecoverList_C:OnItemUpdate(_data, datalist, index)
  self.filled = _data.filled
  self:StopAllAnimations()
  if self.filled then
    self:PlayAnimation(self.Level_normal)
  else
    self:PlayAnimation(self.Level_loop)
  end
end

function UMG_RecoverList_C:OnItemSelected(_bSelected)
end

function UMG_RecoverList_C:OnDeactive()
end

function UMG_RecoverList_C:OnAnimationFinished(Anim)
  if Anim == self.Level_loop then
    self:PlayAnimation(self.Level_loop)
  end
end

return UMG_RecoverList_C
