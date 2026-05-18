local UMG_RelationTree_Perception_C = _G.NRCViewBase:Extend("UMG_RelationTree_Perception_C")

function UMG_RelationTree_Perception_C:OnActive()
end

function UMG_RelationTree_Perception_C:SetRelationTreeType(RelationTreeType, ActionID, IsNotLoopAnim)
  self.RelationTreeType = RelationTreeType
  self.ActionID = ActionID
  self:UpdateUI(IsNotLoopAnim)
end

function UMG_RelationTree_Perception_C:UpdateUI(IsNotLoopAnim)
  self.Interaction:UpdateHeadHUD(true, self.RelationTreeType, self.ActionID, IsNotLoopAnim)
end

function UMG_RelationTree_Perception_C:SetPosition(position)
  self.Slot:SetPosition(position)
end

function UMG_RelationTree_Perception_C:UpdateArrow(theta)
  self:ToggleArrow(true)
  self.CanvasPanel_71:SetRenderTransformAngle(math.deg(theta) - 90)
end

local VisibleEnum = UE.ESlateVisibility.Visible
local CollapseEnum = UE.ESlateVisibility.Collapsed

function UMG_RelationTree_Perception_C:ToggleArrow(show, dist)
  if show then
    if not self:IsVisible() then
      self:SetVisibility(VisibleEnum)
      self:StopAnimation(self.loop_arrows)
      self:PlayAnimation(self.In_arrows)
      if self.Interaction then
        self.Interaction:PlayerPerceptionAnimIn()
      end
    end
  else
    self:SetVisibility(CollapseEnum)
  end
end

function UMG_RelationTree_Perception_C:OnAnimationFinished(anim)
  if anim == self.In_arrows then
    self:PlayAnimation(self.loop_arrows, 0, 0)
  end
end

function UMG_RelationTree_Perception_C:OnDeactive()
end

function UMG_RelationTree_Perception_C:OnAddEventListener()
end

return UMG_RelationTree_Perception_C
