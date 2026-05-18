local UMG_WarningPrompt_C = _G.NRCPanelBase:Extend("UMG_WarningPrompt_C")

function UMG_WarningPrompt_C:OnActive(RuleIds, Caller, CallBack, is_flower_task)
  is_flower_task = is_flower_task or false
  self:UpdateData(RuleIds, Caller, CallBack)
  if not is_flower_task then
    self:AddListen()
  end
  self:RefreshUI(is_flower_task)
  self:PlayAnimation(self.In)
end

function UMG_WarningPrompt_C:AddListen()
  self.TxtPower.OnRichTextClick:Add(self, self.OnDescTextClicked)
end

function UMG_WarningPrompt_C:UpdateData(RuleIds, Caller, CallBack)
  self.Caller = Caller
  self.CallBack = CallBack
  local Conf = _G.DataConfigManager:GetBattleGlobalConfig("battle_attention_tip_show_time")
  self.CountDown = Conf.num / 1000
  self.strText = ""
  self.descText = ""
  local first = true
  for _, ruleId in pairs(RuleIds) do
    local ruleConf = _G.DataConfigManager:GetBattleRuleConf(ruleId)
    if first then
      if ruleConf.title then
        self.strText = string.format("%s: %s", ruleConf.title, ruleConf.desc)
      else
        self.strText = ruleConf.desc
      end
    else
      self.strText = self.strText .. "\n" .. string.format("%s: %s", ruleConf.title, ruleConf.desc)
    end
  end
end

function UMG_WarningPrompt_C:RefreshUI(is_flower_task)
  if is_flower_task then
    self.Btn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Btn.OnClicked:Add(self, self.Onclick)
  end
  self.CanClose = false
  if self.CallBack then
    self:DelaySeconds(self.CountDown, self.CountDownOver, self)
  else
    self:CountDownOver()
  end
  self.descText = self.strText
  self.TxtPower:SetText(self.strText)
end

function UMG_WarningPrompt_C:OnDescTextClicked(id)
  local nounInterpretationTipsInfo = {}
  nounInterpretationTipsInfo.text = self.descText
  _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
end

function UMG_WarningPrompt_C:CountDownOver()
  self.CanClose = true
end

function UMG_WarningPrompt_C:Onclick()
  if self.CanClose then
    if self.Caller and self.CallBack then
      self.CallBack(self.Caller)
    end
    self:DoClose()
  end
end

function UMG_WarningPrompt_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  end
end

function UMG_WarningPrompt_C:PlayEndAnim()
  self:PlayAnimation(self.Out)
end

return UMG_WarningPrompt_C
