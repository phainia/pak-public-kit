local UMG_CompassList_C = _G.NRCPanelBase:Extend("UMG_CompassList_C")

function UMG_CompassList_C:OnActive()
  self.enable = false
end

function UMG_CompassList_C:OnDeactive()
end

function UMG_CompassList_C:OnAddEventListener()
end

function UMG_CompassList_C:Init(Desc)
  if Desc and "" ~= Desc then
    self.enable = true
    self.ListText:SetText(Desc)
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.enable = false
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.shouldPlay = false
  self.playTime = 0
  self.nextAnim = nil
end

function UMG_CompassList_C:ShowAfterTime(time, caller, finishCallback, callbackData)
  self.caller = caller
  self.callback = finishCallback
  self.callbackData = callbackData
  if self.enable then
    self.shouldPlay = true
    self.playTime = time
    self.nextAnim = self.In_Loop_Out
  else
    self:DoCallback()
  end
end

function UMG_CompassList_C:DoCallback()
  if self.caller and self.callback then
    self.callback(self.caller, self.callbackData)
  end
  self.caller = nil
  self.callback = nil
  self.callbackData = nil
end

function UMG_CompassList_C:HideAfterTime(time)
  if self.enable then
    self.shouldPlay = true
    self.playTime = time
    self.nextAnim = self.Out
  end
end

function UMG_CompassList_C:OnUpdate(deltaTime)
  if self.shouldPlay then
    self.playTime = self.playTime - deltaTime
    if self.playTime < 0 then
      if self.nextAnim then
        self:PlayAnimation(self.nextAnim)
      end
      self.shouldPlay = false
      self.nextAnim = nil
    end
  end
end

function UMG_CompassList_C:OnAnimationFinished(Animation)
  if Animation == self.In_Loop_Out then
    self:DoCallback()
  end
end

return UMG_CompassList_C
