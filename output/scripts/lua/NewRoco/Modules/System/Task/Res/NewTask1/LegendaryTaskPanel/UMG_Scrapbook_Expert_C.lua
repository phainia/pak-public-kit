local UMG_Scrapbook_Expert_C = _G.NRCPanelBase:Extend("UMG_Scrapbook_Expert_C")

function UMG_Scrapbook_Expert_C:OnConstruct()
  self.index = 0
  self.limit = 0
  self.matchIndex = 0
  self:OnAddEventListener()
end

function UMG_Scrapbook_Expert_C:OnDestruct()
end

function UMG_Scrapbook_Expert_C:OnActive()
end

function UMG_Scrapbook_Expert_C:OnDeactive()
end

function UMG_Scrapbook_Expert_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton_29, self.OnExpertClicked)
end

function UMG_Scrapbook_Expert_C:PlayInAnimation()
  self:PlayAnimation(self.In)
end

function UMG_Scrapbook_Expert_C:OnExpertClicked()
  local cluePage = 3
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.PlayNameTagAnimOnClicked, self.matchIndex, cluePage)
end

function UMG_Scrapbook_Expert_C:OnAnimationFinished(Anim)
  if Anim == self.In and self.index == self.limit then
    _G.NRCModuleManager:DoCmd(TaskModuleCmd.ShowNameTagInAnim)
  end
end

return UMG_Scrapbook_Expert_C
