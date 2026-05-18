local UMG_SeasonBeginsTips_C = _G.NRCPanelBase:Extend("UMG_SeasonBeginsTips_C")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")

function UMG_SeasonBeginsTips_C:OnActive(tipObject)
  self.tipObject = tipObject
  self.seasonInfo = _G.NRCModuleManager:DoCmd(_G.SeasonIntegrationModuleCmd.GetSeasonInfo)
  if self.seasonInfo == nil then
    Log.Error("UMG_SeasonBeginsTips_C:OnActive seasonInfo is nil")
    return
  end
  local seasonConf = _G.DataConfigManager:GetSeasonConf(self.seasonInfo.season_id)
  if seasonConf then
    self.Title_Describe:SetText(seasonConf.popup_text)
  end
  self:PlayAnimation(self.In)
  local MainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  if MainUIModule and MainUIModule:HasPanel("LobbyMain") then
    local panel = MainUIModule:GetPanel("LobbyMain")
    if panel and panel.UMG_CompassIcon then
      panel.UMG_CompassIcon:PlayAnimation(panel.UMG_CompassIcon.Flash)
      self.Fx_SeasonEntry = panel.UMG_CompassIcon.Fx_SeasonEntry
    end
  end
  _G.NRCAudioManager:PlaySound2DAuto(1000, "UMG_SeasonBeginsTips_C:OnActive")
  _G.NRCEventCenter:RegisterEvent(self.name, self, TipsModuleEvent.Tips_DisplayCoordinatorPaused, self.OnTipsPaused)
  _G.NRCEventCenter:RegisterEvent(self.name, self, TipsModuleEvent.Tips_DisplayCoordinatorResumed, self.OnTipsResumed)
end

function UMG_SeasonBeginsTips_C:OnTipsPaused()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.Fx_SeasonEntry and UE4.UObject.IsValid(self.Fx_SeasonEntry) then
    self.Fx_SeasonEntry:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_SeasonBeginsTips_C:OnTipsResumed()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.Fx_SeasonEntry and UE4.UObject.IsValid(self.Fx_SeasonEntry) then
    self.Fx_SeasonEntry:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_SeasonBeginsTips_C:OnAnimationFinished(anim)
  if anim == self.In then
    self.tipObject:MarkFinished()
    self:DoClose()
  end
end

function UMG_SeasonBeginsTips_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, TipsModuleEvent.Tips_DisplayCoordinatorPaused, self.OnTipsPaused)
  _G.NRCEventCenter:UnRegisterEvent(self, TipsModuleEvent.Tips_DisplayCoordinatorResumed, self.OnTipsResumed)
end

return UMG_SeasonBeginsTips_C
