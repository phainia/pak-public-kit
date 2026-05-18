local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ArdourUpPanelList_C = Base:Extend("UMG_ArdourUpPanelList_C")

function UMG_ArdourUpPanelList_C:OnConstruct()
end

function UMG_ArdourUpPanelList_C:OnDestruct()
end

function UMG_ArdourUpPanelList_C:OnItemUpdate(_data, datalist, index)
  self.isNormal = _data.isNormal
  if _data.isNormal then
    self:StopAllAnimations()
    self:PlayAnimation(self.Level_normal)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Level_loop)
  end
end

function UMG_ArdourUpPanelList_C:OnItemSelected(_bSelected)
end

function UMG_ArdourUpPanelList_C:OnDeactive()
end

function UMG_ArdourUpPanelList_C:OnAnimationFinished(Anim)
  if Anim == self.Level_loop then
    self:PlayAnimation(self.Level_loop)
  end
end

return UMG_ArdourUpPanelList_C
