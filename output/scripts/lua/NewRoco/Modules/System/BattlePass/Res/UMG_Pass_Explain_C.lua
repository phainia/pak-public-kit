local UMG_Pass_Explain_C = _G.NRCPanelBase:Extend("UMG_Pass_Explain_C")

function UMG_Pass_Explain_C:OnActive()
  local BattlePassInfo = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.GetCurrentBattlePassInfo)
  local rule_tips_id = _G.DataConfigManager:GetBattlePassConf(BattlePassInfo.battle_pass_id).rule_tips_id
  local text = _G.DataConfigManager:GetLocalizationConf(rule_tips_id).msg
  self.Text_Describe_1:SetText(text)
  _G.NRCAudioManager:PlaySound2DAuto(1236, "UMG_Pass_Explain_C:OnActive")
  self:LoadAnimation(0)
  self:OnAddEventListener()
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BattlePassModule", "BattlePassAwardMain", _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BattlePassAwardMain").INFO)
  self:AddPcInputBlock()
  self:BindInputAction()
end

function UMG_Pass_Explain_C:OnDeactive()
  self:RemovePcInputBlock()
end

function UMG_Pass_Explain_C:AddPcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.AddBlockIMC, self, self.depth)
end

function UMG_Pass_Explain_C:RemovePcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, self)
end

function UMG_Pass_Explain_C:OnCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(1061, "UMG_Pass_Explain_C:OnCloseBtn")
  self:LoadAnimation(2)
end

function UMG_Pass_Explain_C:OnAddEventListener()
  self:AddButtonListener(self.Button_116, self.OnCloseBtn)
end

function UMG_Pass_Explain_C:OnConstruct()
end

function UMG_Pass_Explain_C:OnDestruct()
end

function UMG_Pass_Explain_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

function UMG_Pass_Explain_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_PassExplain")
  if mappingContext then
    mappingContext:BindAction("IA_ClosePassExplain", self, "OnPcClose2")
  end
end

function UMG_Pass_Explain_C:OnPcClose2()
  self:OnCloseBtn()
end

return UMG_Pass_Explain_C
