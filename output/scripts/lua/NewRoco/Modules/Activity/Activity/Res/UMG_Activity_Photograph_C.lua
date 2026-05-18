local UMG_Activity_Photograph_C = _G.NRCPanelBase:Extend("UMG_Activity_Photograph_C")

function UMG_Activity_Photograph_C:OnActive(path)
  _G.NRCAudioManager:PlaySound2DAuto(40008019, "UMG_Activity_Photograph_C:OnActive")
  self:LoadAnimation(0)
  self.Photograph:SetPath(path)
end

function UMG_Activity_Photograph_C:OnDeactive()
end

function UMG_Activity_Photograph_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Close, self.OnCloseBtnClicked)
end

function UMG_Activity_Photograph_C:OnPcClose()
  self:OnCloseBtnClicked()
end

function UMG_Activity_Photograph_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Activity_Photograph_C:OnDestruct()
end

function UMG_Activity_Photograph_C:OnCloseBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_Activity_Photograph_C:OnActive")
  self:LoadAnimation(2)
end

function UMG_Activity_Photograph_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Activity_Photograph_C
