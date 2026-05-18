local UMG_WaitingUI_C = _G.NRCPanelBase:Extend("UMG_WaitingUI_C")
local DEFAULT_WAITING_UI_DELAY = 0.5

function UMG_WaitingUI_C:OnConstruct()
end

function UMG_WaitingUI_C:OnDestruct()
end

function UMG_WaitingUI_C:OnActive(content, delayShowTime)
  self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Hidden)
  UE4Helper.SetPCInputEnable(self, false, "UMG_WaitingUI_C")
  UE4Helper.ToggleInput(self, false, "UMG_WaitingUI_C")
  delayShowTime = delayShowTime or DEFAULT_WAITING_UI_DELAY
  self.WaitingUITimer = _G.TimerManager:CreateTimer(self, "WaitingUITimer", delayShowTime, nil, self.OnTimerComplete, 9999)
  self:SetData(content, delayShowTime)
  self:AddPcInputBlock()
end

function UMG_WaitingUI_C:OnDeactive()
  if self.WaitingUITimer ~= nil then
    self.WaitingUITimer:Clear()
    _G.TimerManager:RemoveTimer(self.WaitingUITimer)
    self.WaitingUITimer = nil
  end
  UE4Helper.SetPCInputEnable(self, true, "UMG_WaitingUI_C")
  UE4Helper.ToggleInput(self, true, "UMG_WaitingUI_C")
  self:RemovePcInputBlock()
end

function UMG_WaitingUI_C:AddPcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.AddBlockIMC, self, self.depth)
end

function UMG_WaitingUI_C:RemovePcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, self)
end

function UMG_WaitingUI_C:OnEnable()
  if self.WaitingUITimer ~= nil then
    self.WaitingUITimer:Restart()
  end
  self:AddPcInputBlock()
  self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_WaitingUI_C:OnDisable()
  if self.WaitingUITimer ~= nil then
    self.WaitingUITimer:Stop()
  end
  self:RemovePcInputBlock()
  UE4Helper.SetPCInputEnable(self, true, "UMG_WaitingUI_C")
  UE4Helper.ToggleInput(self, true, "UMG_WaitingUI_C")
end

function UMG_WaitingUI_C:OnTimerComplete()
  self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.LoopAnimation, 0, 0)
  UE4Helper.SetPCInputEnable(self, false, "UMG_WaitingUI_C")
  UE4Helper.ToggleInput(self, false, "UMG_WaitingUI_C")
end

function UMG_WaitingUI_C:UpdateText(newContent)
  if newContent then
    self.ProcessText:SetText(newContent)
  end
end

function UMG_WaitingUI_C:SetData(content, delayTime)
  self.ProcessText:SetText(content)
  if 0 == delayTime then
    if self.WaitingUITimer ~= nil then
      self.WaitingUITimer:Stop()
    end
    self:OnTimerComplete()
  else
    delayTime = delayTime or DEFAULT_WAITING_UI_DELAY
    if self.WaitingUITimer ~= nil then
      local oldDelayTime = self.WaitingUITimer.duration
      if oldDelayTime ~= delayTime then
        self.WaitingUITimer.duration = delayTime
      end
    else
      self.WaitingUITimer = _G.TimerManager:CreateTimer(self, "WaitingUITimer", delayTime, nil, self.OnTimerComplete, 9999)
    end
    self.WaitingUITimer:Restart()
  end
end

return UMG_WaitingUI_C
