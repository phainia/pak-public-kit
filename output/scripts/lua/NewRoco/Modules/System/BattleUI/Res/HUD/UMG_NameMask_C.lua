local UMG_NameMask_C = _G.NRCPanelBase:Extend("UMG_NameMask_C")

function UMG_NameMask_C:OnActive(name, withAnim, fillText)
  name = LuaText.A1_finalbattle_unknown_pet_name
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.describe_1 then
    self.describe_1:SetText(name)
  end
  if withAnim then
    self:PlayAnimation(self.Cover_in)
  else
    self:PlayAnimation(self.Cover_loop, 0, 9999)
  end
  if fillText and self.FillText then
    fillText = string.gsub(fillText, "!", "")
    self.FillText:SetText(fillText)
  else
    self.FillText:SetText("")
  end
end

function UMG_NameMask_C:OnEnable(name, withAnim, fillText)
  self:OnActive(name, withAnim, fillText)
end

function UMG_NameMask_C:OnDeactive()
end

function UMG_NameMask_C:NameVisible()
  self:StopAllAnimations()
  self:PlayAnimation(self.Cover_out)
  _G.NRCAudioManager:PlaySound2DAuto(1076, "UMG_NameMask_C:NameVisible")
end

function UMG_NameMask_C:OnAddEventListener()
end

function UMG_NameMask_C:OnAnimationFinished(anim)
  if anim == self.Cover_in then
    self:PlayAnimation(self.Cover_loop, 0, 9999)
  elseif anim == self.Cover_out then
    self:OnClose()
  end
end

return UMG_NameMask_C
