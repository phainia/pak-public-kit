local UMG_Scrapbook_MapMarker_C = _G.NRCPanelBase:Extend("UMG_Scrapbook_MapMarker_C")

function UMG_Scrapbook_MapMarker_C:OnConstruct()
end

function UMG_Scrapbook_MapMarker_C:OnDestruct()
end

function UMG_Scrapbook_MapMarker_C:OnActive()
end

function UMG_Scrapbook_MapMarker_C:OnDeactive()
end

function UMG_Scrapbook_MapMarker_C:OnAddEventListener()
end

function UMG_Scrapbook_MapMarker_C:PlayGetAnimation()
  if not self:IsAnimationPlaying(self.Get) then
    self:PlayAnimation(self.Get)
  end
end

function UMG_Scrapbook_MapMarker_C:OnAnimationFinished(Anim)
  if Anim == self.Get then
    _G.NRCModuleManager:DoCmd(TaskModuleCmd.ShowNameTagNewInAnim)
  end
end

return UMG_Scrapbook_MapMarker_C
