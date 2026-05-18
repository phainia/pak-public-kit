local UMG_Activity_CollegeCamp_Item_C = _G.NRCViewBase:Extend("UMG_Activity_CollegeCamp_Item_C")

function UMG_Activity_CollegeCamp_Item_C:OnConstruct()
  self:AddButtonListener(self.GlobalClickBtn, self.OnClickChoose)
end

function UMG_Activity_CollegeCamp_Item_C:SetImage(path)
  self.Image:SetPath(path)
end

function UMG_Activity_CollegeCamp_Item_C:SetRewards(rewards)
  self.List:InitGridView(rewards or {})
end

function UMG_Activity_CollegeCamp_Item_C:SetLocked(isLocked, lockDesc)
  self.NRCSwitcher_168:SetActiveWidgetIndex(isLocked and 1 or 0)
  self.StartTimeText:SetText(lockDesc or "")
end

function UMG_Activity_CollegeCamp_Item_C:SetSelected(isSelected)
  self.Switcher:SetActiveWidgetIndex(isSelected and 1 or 0)
  self:StopAllAnimations()
  if isSelected then
    self:PlayAnimation(self.Press_in)
    self:PlayAnimation(self.Press_loop, 0, 0)
  else
    self:PlayAnimation(self.Press_out)
  end
end

function UMG_Activity_CollegeCamp_Item_C:SetCollected(isCollected)
  self.Collected:SetVisibility(isCollected and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if isCollected then
    self:PlayAnimation(self.Selected)
  end
end

function UMG_Activity_CollegeCamp_Item_C:SetExtraInfo(visible, icon, name)
  self.CanvasCollege:SetVisibility(visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if visible then
    self.Badge:SetPath(icon)
    self.CollegeName:SetText(name)
    self.Pattern:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Pattern:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Activity_CollegeCamp_Item_C:SetDisableChoose(isDisableChoose)
  self.isDisableChoose = isDisableChoose
end

function UMG_Activity_CollegeCamp_Item_C:SetClickCallback(callback)
  self.clickCallback = callback
end

function UMG_Activity_CollegeCamp_Item_C:OnClickChoose()
  if self.isDisableChoose then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401003, "UMG_Activity_CollegeCamp_Item_C:OnClickChoose")
  local callback = self.clickCallback
  if callback then
    callback()
  end
end

return UMG_Activity_CollegeCamp_Item_C
