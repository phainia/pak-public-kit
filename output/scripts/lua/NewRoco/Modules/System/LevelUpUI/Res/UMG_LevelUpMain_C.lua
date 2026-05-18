local UMG_LevelUpMain_C = _G.NRCPanelBase:Extend("UMG_LevelUpMain_C")

function UMG_LevelUpMain_C:OnConstruct()
  self.uiData = {}
end

function UMG_LevelUpMain_C:OnDestruct()
end

function UMG_LevelUpMain_C:OnActive()
end

function UMG_LevelUpMain_C:OnDeactive()
end

function UMG_LevelUpMain_C:OnShowLevelUp(_param)
  Log.Warning("\228\184\187\231\149\140\233\157\162\229\138\159\232\131\189\229\183\178\231\187\143\231\167\187\233\153\164")
end

function UMG_LevelUpMain_C:OnLevelUpShowEnd()
  self:PlayAnimation(self.LevelUpEnd)
end

function UMG_LevelUpMain_C:OnAnimationFinished(anim)
  if anim == self.LevelUpShow then
  end
end

return UMG_LevelUpMain_C
