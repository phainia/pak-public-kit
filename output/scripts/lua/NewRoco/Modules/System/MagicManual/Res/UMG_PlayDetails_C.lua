local UMG_PlayDetails_C = _G.NRCPanelBase:Extend("UMG_PlayDetails_C")

function UMG_PlayDetails_C:OnActive(BattleRuleId)
  self.BattleRuleId = BattleRuleId
  self:SetPanelInfo()
  self:PlayAnimation(self.open)
  self:OnAddEventListener()
end

function UMG_PlayDetails_C:OnDeactive()
end

function UMG_PlayDetails_C:SetPanelInfo()
  if self.BattleRuleId and #self.BattleRuleId > 0 then
    self.List:InitList(self.BattleRuleId)
  end
end

function UMG_PlayDetails_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnClickCloseBtn)
end

function UMG_PlayDetails_C:OnClickCloseBtn()
  self:PlayAnimation(self.close)
end

function UMG_PlayDetails_C:ShowDescPanel(descText)
end

function UMG_PlayDetails_C:OnAnimationFinished(Anim)
  if Anim == self.close then
    self:DoClose()
  end
end

return UMG_PlayDetails_C
