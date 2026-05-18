local UMG_ShareUIMore_C = _G.NRCPanelBase:Extend("UMG_ShareUIMore_C")

function UMG_ShareUIMore_C:Init(data)
  self.IsPlayOut = false
  if data.moreDataList and #data.moreDataList > 0 then
    self.HasContent = true
    self.List:InitGridView(data.moreDataList)
  end
end

function UMG_ShareUIMore_C:PlayInAnim()
  self:SetShowState(true)
  self:PlayAnimation(self.In)
end

function UMG_ShareUIMore_C:PlayOutAnim()
  self.IsPlayOut = true
  self:PlayAnimation(self.Out)
end

function UMG_ShareUIMore_C:SetShowState(isShow)
  if isShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ShareUIMore_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    self:SetShowState(false)
    self.IsPlayOut = false
  end
end

return UMG_ShareUIMore_C
