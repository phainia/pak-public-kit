local LegendaryBattleModuleHead = NRCModuleHeadBase:Extend("LegendaryBattleModuleHead")

function LegendaryBattleModuleHead:OnConstruct()
  _G.LegendaryBattleModuleCmd = reload("NewRoco.Modules.Activity.LegendaryBattle.LegendaryBattleModuleCmd")
  self:BindCmd(_G.LegendaryBattleModuleCmd.OpenMatchMainPanel, "OnOpenMatchMainPanel")
  self:BindCmd(_G.LegendaryBattleModuleCmd.SetStarNum, "OnSetStarNum")
  self:BindCmd(_G.LegendaryBattleModuleCmd.GetCurMatchInfo, "GetCurMatchInfo")
  self:BindCmd(_G.LegendaryBattleModuleCmd.CancelMatchNotify, "OnCancelMatchNotify")
  self:BindCmd(_G.LegendaryBattleModuleCmd.GetLegendaryBattleAwards, "OnCmdGetLegendaryBattleAwards")
  self:BindCmd(_G.LegendaryBattleModuleCmd.OnCheckChallenge, "OnCmdChallengeCheck")
  self:BindCmd(_G.LegendaryBattleModuleCmd.ChangeCurMatchState, "OnChangeCurMatchState")
  self:BindCmd(_G.LegendaryBattleModuleCmd.OnBattleEnd, "OnBattleEnd")
  self:BindCmd(_G.LegendaryBattleModuleCmd.OnEnterBattleLoading, "OnEnterBattleLoading")
  self:BindCmd(_G.LegendaryBattleModuleCmd.GetActivityTimeByContentId, "OnCmdGetActivityTimeByContentId")
  self:BindCmd(_G.LegendaryBattleModuleCmd.OnReceiveTeamBattleInviteNotify, "OnReceiveTeamBattleInviteNotify")
  self:BindCmd(_G.LegendaryBattleModuleCmd.GetChallengeTimes, "OnCmdGetChallengeTimes")
  self:BindCmd(_G.LegendaryBattleModuleCmd.CheckLegendaryBattleMatchState, "OnCmdCheckLegendaryBattleMatchState")
  self:BindCmd(_G.LegendaryBattleModuleCmd.CheckCanStartLegendaryBattle, "CheckCanStartLegendaryBattle")
  self:BindCmd(_G.LegendaryBattleModuleCmd.OnSendZoneBeastStartMatchReq, "OnSendZoneBeastStartMatchReq")
  self:BindCmd(_G.LegendaryBattleModuleCmd.OnOnlyZoneQueryBeastChallengeReq, "OnOnlyZoneQueryBeastChallengeReq")
  self:BindCmd(_G.LegendaryBattleModuleCmd.OnUpdatePetCollectTagRsp, "OnUpdatePetCollectTagRsp")
end

return LegendaryBattleModuleHead
