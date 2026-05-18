local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AlchemyIcon_Ani_1_C = Base:Extend("UMG_AlchemyIcon_Ani_1_C")

function UMG_AlchemyIcon_Ani_1_C:OnConstruct()
end

function UMG_AlchemyIcon_Ani_1_C:OnDestruct()
end

function UMG_AlchemyIcon_Ani_1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.icon:SetPath(self.data.normal_icon)
  self.icon_1:SetPath(self.data.select_icon)
  self.index = index
  self.selected = false
  self:StopAllAnimations()
  self:PlayAnimation(self.normal)
  _G.DelayManager:CancelDelay(self.PlayLoopAnimation)
end

function UMG_AlchemyIcon_Ani_1_C:OnItemSelected(_bSelected)
  self:SetSelected(_bSelected)
end

function UMG_AlchemyIcon_Ani_1_C:SetSelected(bSelected)
  _G.DelayManager:CancelDelay(self.PlayLoopAnimation)
  if self.selected == bSelected then
    if self.selected then
      if not self:IsAnimationPlaying(self.change1) then
        self:StopAllAnimations()
        self:PlayAnimation(self.select_loop)
      end
    else
      self:StopAllAnimations()
      self:PlayAnimation(self.normal)
    end
    return
  end
  self.selected = bSelected
  self:StopAllAnimations()
  if self.selected then
    _G.NRCEventCenter:DispatchEvent(_G.AlchemyModuleEvent.AlchemyPanelChanged, self.data.index, true)
    self:PlayAnimation(self.change1)
  else
    self:PlayAnimation(self.change2)
  end
end

function UMG_AlchemyIcon_Ani_1_C:PlayLoopAnimation()
  if self.PlayAnimation and self.select_loop then
    self:PlayAnimation(self.select_loop)
  end
end

function UMG_AlchemyIcon_Ani_1_C:OnAnimationFinished(Anim)
  if self.selected then
    _G.DelayManager:CancelDelay(self.PlayLoopAnimation)
    _G.DelayManager:DelaySeconds(3, self.PlayLoopAnimation, self)
  else
  end
end

function UMG_AlchemyIcon_Ani_1_C:OnDeactive()
end

return UMG_AlchemyIcon_Ani_1_C
