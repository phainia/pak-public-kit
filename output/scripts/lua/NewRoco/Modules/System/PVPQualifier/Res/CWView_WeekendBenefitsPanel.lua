local Base = require("NewRoco.Modules.System.PVPQualifier.Res.CompositeWidgetViewBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local CWView_WeekendBenefitsPanel = Base:Extend("CWView_WeekendBenefitsPanel")

function CWView_WeekendBenefitsPanel:Ctor(panelObject, ...)
  local memberNames = {
    "WeekendBenefitsPanel",
    "MultipleText",
    "Btn_particulars",
    "NRCSwitcher_bg",
    "LOGO2"
  }
  Base.Ctor(self, panelObject, memberNames, ...)
end

function CWView_WeekendBenefitsPanel:OnActive(...)
  BattleUtils.SetPvpScoreIcon(self.LOGO2)
  self:AddButtonListener(self.Btn_particulars.btnLevelUp, self.OnClick_WeekendBenefitsTips)
end

function CWView_WeekendBenefitsPanel:OnDeactive(...)
  self:RemoveButtonListener(self.Btn_particulars.btnLevelUp)
end

function CWView_WeekendBenefitsPanel:RefreshUI()
  self.WeekendBenefitsPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local bWeekendBenefits = _G.NRCModeManager:DoCmd(PVPRankedMatchModuleCmd.OnCmdIsInWeekendBenefitsPeriod)
  if bWeekendBenefits then
    self.NRCSwitcher_bg:SetActiveWidgetIndex(0)
    self.MultipleText:SetText(LuaText.PVP_rank_rule_tips5)
    if self.ownerPanel.Award_on_In then
      self:PlayAnimationSequence({
        "Award_on_In",
        {animation = "Loop", loop = true}
      })
    else
      self:PlayAnimationSequence({
        "Fire_In",
        {animation = "Loop", loop = true}
      })
    end
  else
    if self.ownerPanel.Award_off_In then
      self:PlayAnimationSequence({
        "Award_off_In"
      })
    end
    self.NRCSwitcher_bg:SetActiveWidgetIndex(1)
    self.MultipleText:SetText(LuaText.PVP_rank_rule_tips4)
  end
end

function CWView_WeekendBenefitsPanel.OnClick_WeekendBenefitsTips()
  local titleText = LuaText.PVP_rank_rule_tips3
  local contentStr = LuaText.PVP_rank_rule_tips2
  local Context = DialogContext()
  Context:SetTitle(titleText):SetContent(contentStr):SetContentTextJustify(UE4.ETextJustify.Left):SetMode(DialogContext.Mode.NotBtn):SetCloseOnOK(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

return CWView_WeekendBenefitsPanel
