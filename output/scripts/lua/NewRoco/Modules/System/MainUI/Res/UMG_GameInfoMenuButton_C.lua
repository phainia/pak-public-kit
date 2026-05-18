local UMG_GameInfoMenuButton_C = _G.NRCViewBase:Extend("UMG_GameInfoMenuButton_C")

function UMG_GameInfoMenuButton_C:OnConstruct()
end

function UMG_GameInfoMenuButton_C:OnDestruct()
  Log.Debug("UMG_GameInfoMenuButton_C:OnDestruct")
  self.data = nil
  self.icon1:ReleaseForce()
  self.icon2:ReleaseForce()
  self:ReleaseForce()
  collectgarbage("collect")
end

function UMG_GameInfoMenuButton_C:SetData(_data)
  self.data = _data
  if self.data then
    self:UpdateMenuInfo()
    self:SetSelectState(false)
  end
end

function UMG_GameInfoMenuButton_C:SetSelectState(_flag)
  self.selectFlag = _flag
  self:StopAllAnimations()
  if _flag then
    self:PlayAnimation(self.select, 0, 0, 0)
    self.activeState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.normalState:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self:PlayAnimation(self.normal)
    self.normalState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.activeState:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_GameInfoMenuButton_C:UpdateMenuInfo()
  local title = self.data and self.data.title or ""
  self.icon1:SetPath(self.data.icon1)
  self.icon2:SetPath(self.data.icon2)
  self.textNormalTitle:SetText(title)
  self.textActiveTitle:SetText(title)
end

function UMG_GameInfoMenuButton_C:OnTouchEnded(_myGeometry, _inTouchEvent)
  local data = self.data
  if data then
    if data.callbackCaller and data.callbackFunc then
      tcall(data.callbackCaller, data.callbackFunc, data.index or -1, nil, false)
    end
    if data.soundId then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(data.soundId, "UMG_GameInfoMenuButton_C:OnTouchEnded")
    end
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

return UMG_GameInfoMenuButton_C
