local UMG_LevelBreakThrough_C = _G.NRCPanelBase:Extend("UMG_LevelBreakThrough_C")

function UMG_LevelBreakThrough_C:OnConstruct()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_LevelBreakThrough_C:OnActive(param)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.conf = param.conf
  self.expInfo = param.expTip
  self.Panel_StartShow:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Panel_EndSow:SetVisibility(UE4.ESlateVisibility.Hidden)
  _G.NRCAudioManager:PlaySound2DAuto(1220002125, "UMG_LevelBreakThrough_C:OnActive")
  self:PlayAnimation(self.LevelUpTips)
end

function UMG_LevelBreakThrough_C:OnAnimationFinished(Animation)
  if Animation == self.LevelUpTips then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ParentPanel:ConsumeNext()
  end
end

function UMG_LevelBreakThrough_C:OnDeactive()
end

function UMG_LevelBreakThrough_C:OnAddEventListener()
end

function UMG_LevelBreakThrough_C:SetParent(parent)
  self.ParentPanel = parent
end

return UMG_LevelBreakThrough_C
