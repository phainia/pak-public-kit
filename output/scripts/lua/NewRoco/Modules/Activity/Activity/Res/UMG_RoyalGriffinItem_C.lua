local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_RoyalGriffinItem_C = Base:Extend("UMG_RoyalGriffinItem_C")

function UMG_RoyalGriffinItem_C:OnItemSelected(_bSelected)
  Base.OnItemSelected(self, _bSelected)
  self:PlaySelectAnimation(_bSelected)
end

function UMG_RoyalGriffinItem_C:SetImagePreview(imagPath)
  if not string.IsNilOrEmpty(imagPath) then
    self.PetIllustration:SetPath(imagPath)
  end
end

function UMG_RoyalGriffinItem_C:SetRewardState(bGetMedal, bReward)
  if bGetMedal then
    self.CanvasMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if bReward then
    self.Selected2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Selected2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_RoyalGriffinItem_C:SetRewardMark()
  self.Selected2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_RoyalGriffinItem_C:PlaySelectAnimation(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimationImmediately(self.Select, false, 0)
  else
    self:PlayAnimationImmediately(self.Select, true, 0)
  end
end

return UMG_RoyalGriffinItem_C
