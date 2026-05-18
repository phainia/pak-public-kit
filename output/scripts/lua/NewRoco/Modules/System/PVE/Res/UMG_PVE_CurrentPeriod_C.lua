local UMG_PVE_CurrentPeriod_C = _G.NRCPanelBase:Extend("UMG_PVE_CurrentPeriod_C")
local PVEModuleEvent = require("NewRoco.Modules.System.PVE.PVEModuleEvent")

function UMG_PVE_CurrentPeriod_C:OnConstruct()
  self:SetChildViews(self.PopUp)
  self:RegisterEvent(self, PVEModuleEvent.SwitchCurrentPeriodSelectedItem, self.OnSwitchCurrentPeriodSelectedItem)
end

function UMG_PVE_CurrentPeriod_C:OnDestruct()
  self:UnRegisterEvent(self, PVEModuleEvent.SwitchCurrentPeriodSelectedItem)
end

function UMG_PVE_CurrentPeriod_C:OnActive(pveBaseConf)
  self.pveBaseConf = pveBaseConf
  self:SetCommonPopUpInfo(self.PopUp)
  if pveBaseConf then
    self.ListTab1:InitGridView(pveBaseConf.rule_show)
    self.ListTab1:SelectItemByIndex(0)
  else
    self.ListTab1:InitGridView({})
  end
  self:LoadAnimation(0)
end

function UMG_PVE_CurrentPeriod_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.PopUpType = 2
  CommonPopUpData.ClosePanelHandler = self.OnClickCloseButton
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_PVE_CurrentPeriod_C:OnClickCloseButton()
  self:LoadAnimation(2)
end

function UMG_PVE_CurrentPeriod_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_PVE_CurrentPeriod_C:OnSwitchCurrentPeriodSelectedItem(data)
  local ruleItems = {}
  if data and data.season_battle_rule then
    local battleRuleConf = _G.DataConfigManager:GetSeasonBattleRuleConf(data.season_battle_rule)
    if battleRuleConf then
      ruleItems = battleRuleConf.rule_weight
    end
  end
  self.List:InitList(ruleItems)
end

return UMG_PVE_CurrentPeriod_C
