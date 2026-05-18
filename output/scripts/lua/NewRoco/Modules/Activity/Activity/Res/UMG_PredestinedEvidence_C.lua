local UMG_PredestinedEvidence_C = _G.NRCPanelBase:Extend("UMG_PredestinedEvidence_C")

function UMG_PredestinedEvidence_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
end

function UMG_PredestinedEvidence_C:OnActive(medalData)
  self.GridView:InitGridView(medalData)
  local data = _G.NRCCommonPopUpData()
  data.Call = self
  data.ClosePanelHandler = self.ClosePanel
  self.PopUp1:SetPanelInfo(data)
  self:LoadAnimation(0)
end

function UMG_PredestinedEvidence_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_PredestinedEvidence_C:ClosePanel")
  self:LoadAnimation(2)
end

function UMG_PredestinedEvidence_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_PredestinedEvidence_C:OnPcClose()
  self:ClosePanel()
end

return UMG_PredestinedEvidence_C
