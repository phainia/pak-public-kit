local UMG_RelationTree_More_C = _G.NRCPanelBase:Extend("UMG_RelationTree_More_C")

function UMG_RelationTree_More_C:OnActive()
end

function UMG_RelationTree_More_C:OnDeactive()
end

function UMG_RelationTree_More_C:OnAddEventListener()
end

function UMG_RelationTree_More_C:PlayAnimationIn()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.In)
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_RelationTree_C:ShowMoreClick")
end

function UMG_RelationTree_More_C:UpdateMoreItemList(MoreItemTable)
  if MoreItemTable then
    self.MoreList:InitGridView(MoreItemTable)
  end
end

function UMG_RelationTree_More_C:OnFocusLost(InFocusEvent)
  _G.NRCModeManager:DoCmd(_G.RelationTreeCmd.UpdateShowMoreClick)
end

function UMG_RelationTree_More_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    _G.NRCModeManager:DoCmd(_G.RelationTreeCmd.DynamicAddEventListener)
  end
end

return UMG_RelationTree_More_C
