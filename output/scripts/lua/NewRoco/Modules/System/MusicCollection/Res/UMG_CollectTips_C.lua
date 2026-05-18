local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local UMG_CollectTips_C = _G.NRCPanelBase:Extend("UMG_CollectTips_C")

function UMG_CollectTips_C:OnConstruct(tip)
  self:OnAddEventListener()
  local curModule = self.module
  self.tipsDisplayController = curModule and curModule.getMusicCollectUnlockTipsController
  if self.tipsDisplayController then
    self.tipsDisplayController:BindView(self)
    self.tipsDisplayController:GetExecutor():StartTipDispatchStateListener()
  end
  self:PCKeySetting()
end

function UMG_CollectTips_C:OnDestruct()
  if self.tipsDisplayController then
    self.tipsDisplayController:UnBindView()
  end
end

function UMG_CollectTips_C:OnActive()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_CollectTips_C:OnPlayTips(tip)
  local tipData = tip.customData
  self.customData = tip.customData
  self.text:SetText(tipData.TypeName)
  self.RichText:SetText(tipData.Name)
  if tip.timeLeft then
    self.text_1:SetText(string.format(tipData.countdownStr, tip.timeLeft))
  end
  _G.NRCAudioManager:PlaySound2DAuto(40008001, "UMG_CollectTips_C:OnPlayTips")
  self:StopAllAnimations()
  self:PlayAnimation(self.Appear)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_CollectTips_C:PCKeySetting()
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

function UMG_CollectTips_C:OnAllTipsFinished()
  self:ClosePanel()
end

function UMG_CollectTips_C:OnPlayTipStatusChange(pause)
  if pause then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    if self:IsAnimationPlaying(self.Disappear) then
      self:DoClose()
      return
    end
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_CollectTips_C:OnUpdateTips(tip, interval)
  if tip and tip.timeLeft then
    local tipData = tip.customData
    self.text_1:SetText(string.format(tipData.countdownStr, tip.timeLeft))
  end
end

function UMG_CollectTips_C:OnClickTips()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_CollectTips_C:OnPlayTips")
  if self.tipsDisplayController then
    local tip = self.tipsDisplayController:GetExecutor():GetDisplayingTip()
    if tip and self.customData then
      _G.NRCModuleManager:DoCmd(MusicCollectionModuleCmd.OnOpenMainPanel, self.customData.UnlockId)
    end
    self.tipsDisplayController:GetExecutor():ConsumeNextTip()
  else
    self:DoClose()
  end
end

function UMG_CollectTips_C:ClosePanel()
  self:PlayAnimation(self.Disappear)
end

function UMG_CollectTips_C:OnAnimationFinished(anim)
  if anim == self.Disappear then
    self:DoClose()
  end
end

function UMG_CollectTips_C:OnAddEventListener()
  self:AddButtonListener(self.TipsBtn, self.OnClickTips)
  _G.NRCEventCenter:RegisterEvent("UMG_CollectTips_C", self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_CollectTips_C:HasValidData()
  if self.tipsDisplayController then
    local tip = self.tipsDisplayController:GetExecutor():GetDisplayingTip()
    return nil ~= tip
  end
  return false
end

return UMG_CollectTips_C
