local UMG_SeasonRank_C = _G.NRCPanelBase:Extend("UMG_SeasonRank_C")
local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")
local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local Timer = require("NewRoco.Modules.System.PVPQualifier.Res.Timer")
local UMG_PVP_DanGrading_C = require("NewRoco.Modules.System.BattleUI.Res.UMG_PVP_DanGrading_C")
local kCloseDelayTime = 2

function UMG_SeasonRank_C:OnConstruct()
  self.bEventDispatched = false
  self.CloseDelayTimer = Timer()
end

function UMG_SeasonRank_C:OnActive(oldRank, resetToRank)
  Log.Debug("SeasonOpen Progress: UMG_SeasonRank_C:OnActive")
  self:BindToAnimationFinished(self.In, {
    self,
    self.OnAnimationFinished_In
  })
  self:PlayAnimation(self.In)
  local umgAnimLength = 0
  umgAnimLength = umgAnimLength + self.In:GetEndTime() - self.In:GetStartTime()
  umgAnimLength = umgAnimLength + self.DissolveFlag:GetEndTime() - self.DissolveFlag:GetStartTime()
  self.CloseDelayTimer:Reset(kCloseDelayTime + umgAnimLength)
  self:AddButtonListener(self.BtnClose, self.OnClick_BtnClose)
  local oldRankConf = PVPRankedMatchModuleUtils.GetPvpRankConf(oldRank)
  local rankConf = PVPRankedMatchModuleUtils.GetPvpRankConf(resetToRank)
  if oldRankConf then
    self.later:SetPath(oldRankConf.rank_effect)
    self.RankName:SetText(oldRankConf.name)
  end
  if rankConf then
    self.before_1:SetPath(rankConf.rank_effect)
    self.RankName_later:SetText(rankConf.name)
  end
  self.TextHint:SetText(_G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character24").str)
end

function UMG_SeasonRank_C:OnDeactive()
  self:TryDispatchEvent()
end

function UMG_SeasonRank_C:OnClick_BtnClose()
  if self.CloseDelayTimer:IsExceed() then
    self:TryCloseAnimated()
  end
end

function UMG_SeasonRank_C:TryDispatchEvent()
  if self.bEventDispatched then
    return
  end
  self.bEventDispatched = true
  _G.NRCEventCenter:DispatchEvent(PVPRankedMatchModuleEvent.UI_SeasonResetRankAnimationFinished)
end

function UMG_SeasonRank_C:TryCloseAnimated()
  if not self.PlayingCloseAnim then
    self.PlayingCloseAnim = true
    self:DoCloseAnimated()
  end
end

function UMG_SeasonRank_C:DoCloseAnimated()
  self:BindToAnimationFinished(self.Out, {
    self,
    self.OnAnimationFinished_Out
  })
  self:PlayAnimation(self.Out)
end

function UMG_SeasonRank_C:OnAnimationFinished_In()
  Log.Debug("SeasonOpen Progress: UMG_SeasonRank_C:OnAnimationFinished_In")
  self:PlayAnimation(self.DissolveFlag)
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdTrySwitch_UMG_SeasonOpen, false)
end

function UMG_SeasonRank_C:OnAnimationFinished_Out()
  Log.Debug("SeasonOpen Progress: UMG_SeasonRank_C:OnAnimationFinished_Out")
  self.PlayingCloseAnim = false
  self:TryDispatchEvent()
end

function UMG_SeasonRank_C:OnTick(deltaTime)
  self.CloseDelayTimer:Tick(deltaTime)
end

return UMG_SeasonRank_C
