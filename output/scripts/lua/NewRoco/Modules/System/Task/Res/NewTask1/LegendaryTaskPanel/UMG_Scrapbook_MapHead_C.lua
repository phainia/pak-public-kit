local UMG_Scrapbook_MapHead_C = _G.NRCPanelBase:Extend("UMG_Scrapbook_MapHead_C")

function UMG_Scrapbook_MapHead_C:OnConstruct()
  self.index = 0
  self.limit = 0
  self.matchIndex = 0
  self:OnAddEventListener()
end

function UMG_Scrapbook_MapHead_C:OnDestruct()
end

function UMG_Scrapbook_MapHead_C:OnActive()
end

function UMG_Scrapbook_MapHead_C:OnDeactive()
end

function UMG_Scrapbook_MapHead_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton_29, self.OnHeadClicked)
end

function UMG_Scrapbook_MapHead_C:PlayInAnimation()
  self:PlayAnimation(self.In)
end

function UMG_Scrapbook_MapHead_C:PlayNewInAnimation()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.New_in)
end

function UMG_Scrapbook_MapHead_C:SetBgColor(index)
  if 1 == index then
    self.HeadBgColour:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("8b9ca4"))
  elseif 2 == index then
    self.HeadBgColour:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("a8b88b"))
  elseif 3 == index then
    self.HeadBgColour:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("dfb44c"))
  elseif 4 == index then
    self.HeadBgColour:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("e3deaf"))
  elseif 5 == index then
    self.HeadBgColour:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("c6cec1"))
  end
end

function UMG_Scrapbook_MapHead_C:OnHeadClicked()
  self:PlayAnimation(self.Press)
  local cluePage = 1
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.PlayNameTagAnimOnClicked, self.matchIndex, cluePage)
end

function UMG_Scrapbook_MapHead_C:OnAnimationFinished(Anim)
  if Anim == self.In and self.index == self.limit then
    _G.NRCModuleManager:DoCmd(TaskModuleCmd.ShowNewLineLinkAnim)
  elseif Anim == self.New_in then
    _G.NRCModuleManager:DoCmd(TaskModuleCmd.ShowNewLineLinkAnim)
  end
end

return UMG_Scrapbook_MapHead_C
