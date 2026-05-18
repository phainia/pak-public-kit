local UMG_Tips_CollectionAtlases_C = _G.NRCPanelBase:Extend("UMG_Tips_CollectionAtlases_C")

function UMG_Tips_CollectionAtlases_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Tips_CollectionAtlases_C:OnDestruct()
  self:RemoveAllButtonListener()
end

function UMG_Tips_CollectionAtlases_C:OnActive(tipsParam)
  self:PlayAnimation(self.Appear)
  if tipsParam then
    self.NRCText_76:SetText(tipsParam.title)
    self.ChangeText:SetText(tipsParam.desc)
  end
end

function UMG_Tips_CollectionAtlases_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnBtnCloseTipsClick)
end

function UMG_Tips_CollectionAtlases_C:OnBtnCloseTipsClick()
  self:PlayAnimation(self.Disappear)
end

function UMG_Tips_CollectionAtlases_C:OnAnimationFinished(Anim)
  if Anim == self.Disappear then
    self:DoClose()
  end
end

return UMG_Tips_CollectionAtlases_C
