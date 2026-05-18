local Base = require("NewRoco/Modules/System/MainUI/Res/UMG_WandLockBase_C")
local UMG_FashionStaff_C = Base:Extend("UMG_FashionStaff_C")

function UMG_FashionStaff_C:OnActive()
end

function UMG_FashionStaff_C:OnDeactive()
end

function UMG_FashionStaff_C:OnAddEventListener()
end

function UMG_FashionStaff_C:OnConstruct()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.isWaitingAnimFinished = false
end

function UMG_FashionStaff_C:OnDestruct()
end

function UMG_FashionStaff_C:PlayAnimationHelper(anim)
  self.isWaitingAnimFinished = true
  self:PlayAnimation(anim)
end

function UMG_FashionStaff_C:OnShow()
  self:StopAllAnim()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.isLockingState == nil or self.isLockingState == false then
    self:PlayAnimationHelper(self.open)
  else
    self:OnEnterLockingState(true)
  end
end

function UMG_FashionStaff_C:OnEnterLockingState(bool)
  self:StopAllAnim()
  if bool then
    self:PlayAnimationHelper(self.change1)
  else
    self:PlayAnimationHelper(self.change2)
  end
end

function UMG_FashionStaff_C:OnCancel(cancelType)
  if self:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    return
  end
  self:StopAllAnim()
  self:PlayAnimationHelper(self.close)
end

function UMG_FashionStaff_C:StopAllAnim()
  self.isWaitingAnimFinished = false
  if self:IsAnyAnimationPlaying() then
    self:StopAllAnimations()
  end
end

function UMG_FashionStaff_C:ClearActorCache()
  self.lastActor = nil
  self.isLockingState = false
end

function UMG_FashionStaff_C:OnAnimationFinished(anim)
  if not self.isWaitingAnimFinished then
    return
  end
  if anim == self.close then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif anim == self.open or anim == self.change2 then
    self:PlayAnimationHelper(self.normal, 0.0, 0)
  elseif anim == self.change1 then
    self:PlayAnimationHelper(self.select, 0.0, 0)
  end
end

return UMG_FashionStaff_C
