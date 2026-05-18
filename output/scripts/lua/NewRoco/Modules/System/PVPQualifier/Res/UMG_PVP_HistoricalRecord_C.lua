local UMG_PVP_HistoricalRecord_C = _G.NRCPanelBase:Extend("UMG_PVP_HistoricalRecord_C")

function UMG_PVP_HistoricalRecord_C:OnActive()
  self:OnAddEventListener()
  self:InitData()
  self:RefreshUI()
  self:SetCommonPopUpInfo()
end

function UMG_PVP_HistoricalRecord_C:SetCommonPopUpInfo()
  local winCount, loseCount = self.data:GetPvpHistoryWinLoseCount()
  local Conf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character6")
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Desc = string.format(Conf.str, winCount or 0, loseCount or 0)
  CommonPopUpData.Call = self
  CommonPopUpData.PopUpType = 2
  CommonPopUpData.ClosePanelHandler = self.OnClickCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp1:SetPanelInfo(CommonPopUpData)
  self.Desc:SetText(CommonPopUpData.Desc)
end

function UMG_PVP_HistoricalRecord_C:OnDeactive()
end

function UMG_PVP_HistoricalRecord_C:OnAddEventListener()
end

function UMG_PVP_HistoricalRecord_C:OnLogin()
end

function UMG_PVP_HistoricalRecord_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
end

function UMG_PVP_HistoricalRecord_C:OnDestruct()
end

function UMG_PVP_HistoricalRecord_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self.GridView:InitGridView(self.historyData)
  end
end

function UMG_PVP_HistoricalRecord_C:OnClickCloseBtn()
  self:StopAllAnimations()
  self:LoadAnimation(2)
end

function UMG_PVP_HistoricalRecord_C:InitData()
  self.data = self.module:GetData("PVPRankedMatchModuleData")
  self.historyData = self.data:GetPvpHisQueryData() or {}
end

function UMG_PVP_HistoricalRecord_C:RefreshUI()
  if #self.historyData > 0 then
    self.NRCSwitcher_1:SetActiveWidgetIndex(0)
    self.GridView:InitGridView({})
  else
    self.NRCSwitcher_1:SetActiveWidgetIndex(1)
  end
  local str = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_trial_pet_character5").str
  self.NRCText_0:SetText(str)
  self:StopAllAnimations()
  self:LoadAnimation(0)
end

return UMG_PVP_HistoricalRecord_C
