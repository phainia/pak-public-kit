local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TabIcon_Ani_C = Base:Extend("UMG_TabIcon_Ani_C")

function UMG_TabIcon_Ani_C:OnConstruct()
end

function UMG_TabIcon_Ani_C:OnDestruct()
  self:CancelDelay()
end

function UMG_TabIcon_Ani_C:OnItemUpdate(_data, datalist, index)
  self:PlayAnimation(self.normal)
  self.data = _data
  self.index = index
  self:SetIcon()
  self.RedDot:SetupKey(50, {
    index - 1
  })
end

function UMG_TabIcon_Ani_C:SetIcon()
  self.icon:SetPath(self.data.icon)
  self.icon_1:SetPath(self.data.select_icon)
end

function UMG_TabIcon_Ani_C:OnItemSelected(bSelected, bScrollChoose)
  if bSelected then
    self:StopAllAnimations()
    self:PlayAnimation(self.change1)
    self:CancelDelay()
    self.DelayHandle = _G.DelayManager:DelaySeconds(3, function()
      self:PlayLoopAnim()
    end)
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_TabIcon_Ani_C:OnTouchEnded")
    _G.NRCModuleManager:GetModule("CommonModule"):DispatchEvent(CommonModuleEvent.SelectTab, self.index)
  else
    self:CancelDelay()
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
end

function UMG_TabIcon_Ani_C:PlayLoopAnim()
  if self.isDestruct then
    self:CancelDelay()
    return
  end
  self:PlayAnimation(self.select_loop)
end

function UMG_TabIcon_Ani_C:CancelDelay()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
end

function UMG_TabIcon_Ani_C:RemoveSelected(_CurItemType)
  self:CancelDelay()
  if 0 == _CurItemType then
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
    self:CancelDelay()
  end
end

function UMG_TabIcon_Ani_C:PlayDefauleSelecteAnim()
  self:PlayAnimation(self.normal)
  self:StopAllAnimations()
  self:PlayAnimation(self.change1)
end

function UMG_TabIcon_Ani_C:OnAnimationFinished(Anim)
  if Anim == self.change1 then
  end
end

return UMG_TabIcon_Ani_C
