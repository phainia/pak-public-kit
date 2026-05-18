local UMG_PVPRankStarBase_C = _G.NRCPanelBase:Extend("UMG_PVPRankStarBase_C")

function UMG_PVPRankStarBase_C:OnActive()
end

function UMG_PVPRankStarBase_C:OnDeactive()
end

function UMG_PVPRankStarBase_C:OnAddEventListener()
end

function UMG_PVPRankStarBase_C:OnLogin()
end

function UMG_PVPRankStarBase_C:OnConstruct()
end

function UMG_PVPRankStarBase_C:OnDestruct()
end

function UMG_PVPRankStarBase_C:OnAnimationFinished(anim)
end

function UMG_PVPRankStarBase_C:ShowStarIn()
  self:PlayAnimation(self.In)
end

return UMG_PVPRankStarBase_C
