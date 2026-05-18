local UMG_Move_PC_C = _G.NRCPanelBase:Extend("UMG_Move_PC_C")
local Mode = {
  Move = 1,
  CameraMove = 2,
  Dash = 3,
  Jump = 4,
  End = 5
}

function UMG_Move_PC_C:OnActive(Mode)
  self:ChangeMode(Mode)
end

function UMG_Move_PC_C:ChangeMode(mode)
  self.mode = mode
  if mode == Mode.Move then
    self.isFirst = true
    self:PlayAnimation(self.FadeIn)
  elseif mode == Mode.CameraMove then
    self:PlayAnimation(self.FadeOut)
  elseif mode == Mode.Dash then
    self:PlayAnimation(self.FadeOut)
  elseif mode == Mode.Jump then
    self:PlayAnimation(self.FadeOut)
  elseif mode == Mode.End then
    self.isLast = true
    self:PlayAnimation(self.FadeOut)
  end
end

function UMG_Move_PC_C:ChangeToMove()
  self.W:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.A:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.S:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.D:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Text:SetText(_G.DataConfigManager:GetRoleGlobalConfig("ftue_joystick_PC").str)
end

function UMG_Move_PC_C:ChangeToCameraMove()
  self.Text:SetText(_G.DataConfigManager:GetRoleGlobalConfig("ftue_camera_adjust_PC").str)
  self.W:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.A:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.S:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.D:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Move_PC_C:ChangeToDash()
  self.Text:SetText(_G.DataConfigManager:GetRoleGlobalConfig("ftue_sprint_PC").str)
  self.W:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.A:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.S:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.D:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.LeftShift:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Move_PC_C:ChangeToJump()
  self.Text:SetText(_G.DataConfigManager:GetRoleGlobalConfig("ftue_jump_PC").str)
  self.LeftShift:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.W:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.A:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.S:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.D:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Space:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Move_PC_C:CheckIsPlayingAnim()
  if self:IsAnimationPlaying(self.FadeOut) or self:IsAnimationPlaying(self.FadeIn) then
    return true
  end
  return false
end

function UMG_Move_PC_C:OnDeactive()
end

function UMG_Move_PC_C:OnAddEventListener()
end

function UMG_Move_PC_C:OnAnimationStarted(anim)
  if anim == self.FadeIn then
    if self.mode == Mode.Move then
      self:ChangeToMove()
    elseif self.mode == Mode.CameraMove then
      self:ChangeToCameraMove()
    elseif self.mode == Mode.Dash then
      self:ChangeToDash()
    elseif self.mode == Mode.Jump then
      self:ChangeToJump()
    end
  end
end

function UMG_Move_PC_C:OnAnimationFinished(anim)
  if anim == self.FadeOut and not self.isLast then
    self:PlayAnimation(self.FadeIn)
  end
end

return UMG_Move_PC_C
