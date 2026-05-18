local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local UMG_LegendaryTaskUnlockTips_C = _G.NRCPanelBase:Extend("UMG_LegendaryTaskUnlockTips_C")

function UMG_LegendaryTaskUnlockTips_C:OnActive()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:OnAddEventListener()
  local curModule = self.module
  self.tipsDisplayController = curModule and curModule.getLegendaryTaskTipsController
  if self.tipsDisplayController then
    self.tipsDisplayController:BindView(self)
    self.tipsDisplayController:GetExecutor():StartTipDispatchStateListener()
  end
  self:PCKeySetting()
end

function UMG_LegendaryTaskUnlockTips_C:OnDeactive()
  if self.tipsDisplayController then
    self.tipsDisplayController:UnBindView()
  end
end

function UMG_LegendaryTaskUnlockTips_C:OnPlayTips(tip)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local tipData = tip.customData
  self.customData = tip.customData
  self.text:SetText(tipData.title)
  self.RichText:SetText(tipData.content)
  self.Icon:SetPath(tipData.iconPath)
  if tip.timeLeft then
    self.text_1:SetText(string.format(tipData.countdownStr, tip.timeLeft))
  end
  self:PlayAnimation(self.Appear)
end

function UMG_LegendaryTaskUnlockTips_C:OnAllTipsFinished()
  self:ClosePanel()
end

function UMG_LegendaryTaskUnlockTips_C:OnPlayTipStatusChange(pause)
  if pause then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_LegendaryTaskUnlockTips_C:OnUpdateTips(tip, interval)
  if tip and tip.timeLeft then
    local tipData = tip.customData
    self.text_1:SetText(string.format(tipData.countdownStr, tip.timeLeft))
  end
end

function UMG_LegendaryTaskUnlockTips_C:OnClickTips()
  if self.tipsDisplayController then
    local tip = self.tipsDisplayController:GetExecutor():GetDisplayingTip()
    if tip then
      _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenLegendaryPanel, self.customData.UnlockTipsType)
    end
    self.tipsDisplayController:GetExecutor():ConsumeNextTip()
  else
    self:DoClose()
  end
end

function UMG_LegendaryTaskUnlockTips_C:PCKeySetting()
  if SystemSettingModuleCmd then
    local InputAction = string.format("IA_MessageDetails")
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, InputAction)
    if "" ~= image then
      self.PCKey:SetImageMode(image)
    else
      self.PCKey:SetText(text)
    end
    self.PCKey:SetKeyVisibility(true)
  end
end

function UMG_LegendaryTaskUnlockTips_C:ClosePanel()
  self:PlayAnimation(self.Disappear)
end

function UMG_LegendaryTaskUnlockTips_C:OnAnimationFinished(Anim)
  if Anim == self.Disappear then
    self:DoClose()
  end
end

function UMG_LegendaryTaskUnlockTips_C:OnAddEventListener()
  self:AddButtonListener(self.TipsBtn, self.OnClickTips)
  _G.NRCEventCenter:RegisterEvent("UMG_LegendaryTaskUnlockTips_C", self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_LegendaryTaskUnlockTips_C:HasValidData()
  if self.tipsDisplayController then
    local tip = self.tipsDisplayController:GetExecutor():GetDisplayingTip()
    return nil ~= tip
  end
  return false
end

return UMG_LegendaryTaskUnlockTips_C
