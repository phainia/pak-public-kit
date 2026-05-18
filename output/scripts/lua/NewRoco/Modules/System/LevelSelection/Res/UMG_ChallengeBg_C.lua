local UMG_ChallengeBg_C = _G.NRCPanelBase:Extend("UMG_ChallengeBg_C")

function UMG_ChallengeBg_C:OnConstruct()
end

function UMG_ChallengeBg_C:OnDestruct()
end

function UMG_ChallengeBg_C:OnActive()
end

function UMG_ChallengeBg_C:OnEnable()
  if _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnGetPanelState, "Leve_BattleArray") then
    self:PlayLoop()
  else
    _G.NRCModeManager:DoCmd(LevelSelectionModuleCmd.ChallengeBgLoadSucceed)
  end
end

function UMG_ChallengeBg_C:OnDisable()
  self:PlayAnimation(self.Close)
end

function UMG_ChallengeBg_C:PlayOpen()
  self:PlayAnimation(self.Open)
end

function UMG_ChallengeBg_C:PlayLoop()
  self:PlayAnimation(self.Loop, 0, 99999)
end

function UMG_ChallengeBg_C:OnDeactive()
end

function UMG_ChallengeBg_C:OnAddEventListener()
end

function UMG_ChallengeBg_C:OnAnimationFinished(Anim)
  if Anim == self.Open then
    self:PlayAnimation(self.Loop, 0, 99999)
  end
end

return UMG_ChallengeBg_C
