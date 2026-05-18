local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local UMG_Battle_Replay_C = _G.NRCPanelBase:Extend("UMG_Battle_Replay_C")

function UMG_Battle_Replay_C:Construct()
  self.BottomSkillTextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PauseDisplayBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SlowSpeedBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.FastSpeedBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:AddListener()
end

function UMG_Battle_Replay_C:Destruct()
  self:RemoveListener()
end

function UMG_Battle_Replay_C:AddListener()
  self.BtnRoundUndo.OnClicked:Add(self, self.OnBtnUndoClicked)
  self.BtnRoundRedo.OnClicked:Add(self, self.OnBtnRedoClicked)
  self.BtnRoundResume.OnClicked:Add(self, self.OnBtnResumeClicked)
  self.BtnRoundPause.OnClicked:Add(self, self.OnBtnPauseClicked)
  self.BtnPlayFast.OnClicked:Add(self, self.OnBtnPlayFastClicked)
  self.BtnPlaySlow.OnClicked:Add(self, self.OnBtnPlaySlowClicked)
  self.BtnExit.OnClicked:Add(self, self.OnBtnExitClicked)
  _G.BattleEventCenter:Bind(self, BattleEvent.Replay_RefreshRoundIdxUI, BattleEvent.Replay_RefreshBottomSkillText, BattleEvent.Replay_RefreshPauseUi, BattleEvent.Replay_RefreshPlaySpeedUi)
end

function UMG_Battle_Replay_C:RemoveListener()
  self.BtnRoundUndo.OnClicked:Remove(self, self.OnBtnUndoClicked)
  self.BtnRoundRedo.OnClicked:Remove(self, self.OnBtnRedoClicked)
  self.BtnRoundResume.OnClicked:Remove(self, self.OnBtnResumeClicked)
  self.BtnRoundPause.OnClicked:Remove(self, self.OnBtnPauseClicked)
  self.BtnPlayFast.OnClicked:Remove(self, self.OnBtnPlayFastClicked)
  self.BtnPlaySlow.OnClicked:Remove(self, self.OnBtnPlaySlowClicked)
  self.BtnExit.OnClicked:Remove(self, self.OnBtnExitClicked)
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Battle_Replay_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.Replay_RefreshRoundIdxUI then
    self:OnRefreshRoundIdx(...)
    return true
  elseif eventName == BattleEvent.Replay_RefreshBottomSkillText then
    self:OnRefreshBottomSkillText(...)
    return true
  elseif eventName == BattleEvent.Replay_RefreshPauseUi then
    self:OnRefreshPauseUi(...)
    return true
  elseif eventName == BattleEvent.Replay_RefreshPlaySpeedUi then
    self:OnRefreshSpeedUi(...)
    return true
  end
end

function UMG_Battle_Replay_C:OnBtnUndoClicked()
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_Undo)
end

function UMG_Battle_Replay_C:OnBtnRedoClicked()
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_Redo)
end

function UMG_Battle_Replay_C:OnRefreshRoundIdx(roundIdx)
  self.TargetRound:SetText(tostring(roundIdx))
end

function UMG_Battle_Replay_C:OnRefreshBottomSkillText(text)
  if "" == text then
    self.BottomSkillText:SetText(text)
    self.BottomSkillTextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BottomSkillText:SetText(text)
    self.BottomSkillTextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_Battle_Replay_C:OnRefreshPauseUi(isPause)
  if isPause then
    self.PauseDisplayBackground:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.PauseDisplayBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Replay_C:OnRefreshSpeedUi(playSpeed)
  if playSpeed == BattleConst.Replay.ReplaySpeedSlow then
    self.FastSpeedBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SlowSpeedBackground:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  elseif playSpeed == BattleConst.Replay.ReplaySpeedFast then
    self.SlowSpeedBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FastSpeedBackground:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.SlowSpeedBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FastSpeedBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Replay_C:OnBtnResumeClicked()
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_Resume)
end

function UMG_Battle_Replay_C:OnBtnPauseClicked()
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_Pause)
end

function UMG_Battle_Replay_C:OnBtnPlayFastClicked()
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_Fast)
end

function UMG_Battle_Replay_C:OnBtnPlaySlowClicked()
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_Slow)
end

function UMG_Battle_Replay_C:OnBtnExitClicked()
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_Exit)
  self:DoClose()
end

return UMG_Battle_Replay_C
