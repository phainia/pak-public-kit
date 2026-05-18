local UMG_Tips_C = _G.NRCViewBase:Extend("UMG_Tips_C")
UMG_Tips_C.ContextData = nil

function UMG_Tips_C:OnConstruct()
  self:OnInit()
  self:OnBeforeOpen()
  _G.UpdateManager:Register(self)
end

function UMG_Tips_C:OnInit()
  self.startTime = -1
  self.curTime = 0
  self.BurnTime = 0
  self.showTime = 0.8
  self:SetRenderOpacity(0)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Tips_C:OnBeforeOpen()
  if self.contextData then
    self:SetContent(self.contextData.content, self.contextData.delayTime)
    if self.contextData.finishCb then
      self:SetEndEvent(self.contextData.finishCb)
    end
  else
    self:SetEndEvent()
  end
end

function UMG_Tips_C:OnDestruct()
end

function UMG_Tips_C:SetParent(parent)
  self.ParentPanel = parent
end

function UMG_Tips_C:OnTick(InDeltaTime)
  if -1 ~= self.startTime then
    self.curTime = self.curTime + InDeltaTime
  end
  if -1 ~= self.startTime and self.curTime >= self.startTime then
    Log.Debug("UMG_Tips_C:Animation Play")
    self.startTime = -1
  end
  if -1 == self.startTime then
    if self.bSessionDirty then
      return
    end
    if self.BurnTime <= 0 then
      return
    end
    self.BurnTime = self.BurnTime - InDeltaTime
    if self.BurnTime > 0 then
      return
    end
    self.BurnTime = 0
    self:PlayAnimation(self.TweenOut)
  end
end

function UMG_Tips_C:OnAnimationFinished(Animation)
  if Animation == self.TweenIn then
    self.BurnTime = self.showTime
    self.bSessionDirty = false
  elseif Animation == self.TweenOut and not self.bSessionDirty then
    self:SetRenderOpacity(0)
    self.ParentPanel.HUDTipsShow = false
    self.ParentPanel:TryCollapsed()
    _G.UpdateManager:UnRegister(self)
    self.ParentPanel:ConditionalQueueShowTips()
  end
end

function UMG_Tips_C:SetContent(content, delayTime, Color, showTime)
  _G.UpdateManager:Register(self)
  self.curTime = 0
  self.startTime = delayTime or -1
  self.BurnTime = 0
  Log.Debug("show tips : ", content)
  if Color then
    self.Text_Tips:SetText(string.format("%s%s</>", Color, content))
  else
    self.Text_Tips:SetText(content)
  end
  if showTime then
    self.showTime = showTime
  else
    self.showTime = 0.5
  end
  self:SetRenderOpacity(1)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ParentPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ParentPanel.HUDTipsShow = true
  self.bSessionDirty = true
  self:StopAllAnimations()
  self:PlayAnimation(self.TweenIn)
end

function UMG_Tips_C:HideTips()
  _G.UpdateManager:UnRegister(self)
  Log.Debug("hide tips : ")
  self:StopAllAnimations()
  self:PlayAnimation(self.TweenOut)
end

function UMG_Tips_C:SetEndEvent(func)
  self:BindToAnimationFinished(self.TweenOut, {
    SimpleDelegateFactory:CreateCallback(self, function()
      Log.Debug("UMG_Tips_Ctrl animation over")
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if func then
        func()
      end
    end)
  })
end

return UMG_Tips_C
