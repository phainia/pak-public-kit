local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local UMG_LobbyDownTips_C = _G.NRCPanelBase:Extend("UMG_LobbyDownTips_C")

function UMG_LobbyDownTips_C:OnConstruct()
end

function UMG_LobbyDownTips_C:OnDestruct()
end

function UMG_LobbyDownTips_C:UpdateTipsData()
  if not self.CurrentTip and self.module then
    local tip = self.module:ExerciseTips()
    self:TipsPlay(tip)
  end
end

function UMG_LobbyDownTips_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_LobbyMessageDetails")
  if mappingContext then
    mappingContext:BindAction("IA_MessageDetails")
  end
end

function UMG_LobbyDownTips_C:UnBindInputAction()
  self:RemoveInputMappingContext("IMC_LobbyMessageDetails")
end

function UMG_LobbyDownTips_C:OnDisable()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:UnBindInputAction()
end

function UMG_LobbyDownTips_C:OnEnable()
  if self.module.TipsPause then
    return
  end
  self:BindInputAction()
  if self.module and self.module:IsNeedShowDownTips() then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_LobbyDownTips_C:OpenMessageDetailsUI()
  if self.CurrentTip then
    if 0 == self.CurrentTip.type then
      self.UMG_BookPrompt:OnbtnOpenHanbook()
    elseif 1 == self.CurrentTip.type then
      self.UMG_Pass_Accomplish:OnClickButton_57()
    elseif 2 == self.CurrentTip.type then
      self.TeachingUnlockTips:OpenPanel()
    end
  end
end

function UMG_LobbyDownTips_C:IsShowPanel(isShow)
  if isShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UMG_BookPrompt:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UMG_Pass_Accomplish:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TeachingUnlockTips:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UMG_BookPrompt:ContinueDelayTimer()
  else
    self.UMG_BookPrompt:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_Pass_Accomplish:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TeachingUnlockTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if isShow and not self.CurrentTip then
    self:UpdateTipsData()
  end
end

function UMG_LobbyDownTips_C:OnActive()
  self:UpdateTipsData()
  self:IsShowPanel(self.module:IsNeedShowDownTips())
end

function UMG_LobbyDownTips_C:TipsPlay(tip)
  self.CurrentTip = tip
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40008001, "UMG_BookPrompt_C:OnConstruct")
  self:OnSwitcherNRCSwitcher_19(tip.type)
  local isStart = false
  if 0 == tip.type then
    isStart = true
    self.UMG_BookPrompt:ConsumeTip(tip, self)
  elseif 1 == tip.type then
    isStart = true
    self.UMG_Pass_Accomplish:OnActive(tip, self)
  elseif 2 == tip.type then
    if self.TeachingUnlockTips and self.TeachingUnlockTips.OnActive then
      isStart = true
      self.TeachingUnlockTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.TeachingUnlockTips:OnActive(tip, self)
    else
      Log.Error("self.TeachingUnlockTips or self.TeachingUnlockTips.OnActive Not Found")
    end
  end
  if isStart then
    _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.LOBBY_DOWN_TIPS_START)
  end
end

function UMG_LobbyDownTips_C:TipsEnd()
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.LOBBY_DOWN_TIPS_END)
  self.CurrentTip = nil
  self:DoClose()
end

function UMG_LobbyDownTips_C:StopTips()
end

function UMG_LobbyDownTips_C:PlayTips()
end

function UMG_LobbyDownTips_C:TipsNext()
  if self.CurrentTip then
    self.CurrentTip:MarkFinished()
  end
  if not self.module:IsNeedShowDownTips() then
    self.module.isTipsOpening = false
    self:TipsEnd()
    return
  end
  local tip = self.module:ExerciseTips()
  if tip then
    self:TipsPlay(tip)
  else
    self:TipsEnd()
  end
end

function UMG_LobbyDownTips_C:OnSwitcherNRCSwitcher_19(SwitcherIndex)
  self.NRCSwitcher_19:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_LobbyDownTips_C
