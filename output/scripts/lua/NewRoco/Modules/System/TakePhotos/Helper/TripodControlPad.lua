local VisibilityMutex = require("NewRoco.Modules.System.TakePhotos.Helper.VisibilityMutex")
local LongPressProxy = require("NewRoco/Modules/System/TakePhotos/LongPressProxy")
local TripodControlPad = Class("TripodControlPad")

function TripodControlPad:Ctor(Panel)
  self.Panel = Panel
  self.ControlPad = self.Panel.BracketPhotographyCanvas
  self._BtnTripodDownOperation = Panel.BtnBelow
  self._BtnTripodRightOperation = Panel.BtnRight
  self._BtnTripodLeftOperation = Panel.BtnLeft
  self._BtnTripodUpOperation = Panel.BtnUp
  self.DownLongPressProxy = LongPressProxy()
  self.UpLongPressProxy = LongPressProxy()
  self.LeftLongPressProxy = LongPressProxy()
  self.RightLongPressProxy = LongPressProxy()
  self.DownLongPressProxy:Bind(self._BtnTripodDownOperation.btnLevelUp, self.Panel, function(_, ...)
    self:OnLongPressTripodDown(...)
  end, function(_, ...)
    self:OnBtnTripodDownOperationClicked(...)
  end, nil, function(_, ...)
    self:OnTouchControlStart(...)
  end)
  self.UpLongPressProxy:Bind(self._BtnTripodUpOperation.btnLevelUp, self.Panel, function(_, ...)
    self:OnLongPressTripodUp(...)
  end, function(_, ...)
    self:OnBtnTripodUpOperationClicked(...)
  end, nil, function(_, ...)
    self:OnTouchControlStart(...)
  end)
  self.LeftLongPressProxy:Bind(self._BtnTripodLeftOperation.btnLevelUp, self.Panel, function(_, ...)
    self:OnLongPressTripodLeft(...)
  end, function(_, ...)
    self:OnBtnTripodLeftOperationClicked()
  end, nil, function(_, ...)
    self:OnTouchControlStart(...)
  end)
  self.RightLongPressProxy:Bind(self._BtnTripodRightOperation.btnLevelUp, self.Panel, function(_, ...)
    self:OnLongPressTripodRight(...)
  end, function(_, ...)
    self:OnBtnTripodRightOperationClicked(...)
  end, nil, function(_, ...)
    self:OnTouchControlStart(...)
  end)
  self.VisibilityMutex = VisibilityMutex(self.ControlPad, false)
  self.Panel.OnDestroyMultiDelegate:Add(self, self.Reset)
end

function TripodControlPad:Reset()
  self.DownLongPressProxy:Cleanup()
  self.UpLongPressProxy:Cleanup()
  self.LeftLongPressProxy:Cleanup()
  self.RightLongPressProxy:Cleanup()
end

function TripodControlPad:SetVisible(bVisible, Reason)
  self.VisibilityMutex:SetVisible(bVisible, Reason)
end

function TripodControlPad:IsVisible()
  return self.VisibilityMutex:IsVisible()
end

function TripodControlPad:OnLongPressTripodDown()
  if self.Panel:IsTakingPhotos() then
    return
  end
  if not self:IsVisible() then
    return
  end
  local Mode = self.Panel.CurrMode
  if Mode and Mode.DecTripodHeight then
    Mode:DecTripodHeight()
  end
end

function TripodControlPad:OnTouchControlStart()
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "OnBtnTripodDownOperationClicked")
end

function TripodControlPad:OnBtnTripodDownOperationClicked(bLongPress)
  if bLongPress then
    return
  end
  self:OnLongPressTripodDown()
end

function TripodControlPad:OnLongPressTripodUp()
  if self.Panel:IsTakingPhotos() then
    return
  end
  if not self:IsVisible() then
    return
  end
  local Mode = self.Panel.CurrMode
  if Mode and Mode.IncTripodHeight then
    Mode:IncTripodHeight()
  end
end

function TripodControlPad:OnBtnTripodUpOperationClicked(bLongPress)
  if bLongPress then
    return
  end
  self:OnLongPressTripodUp()
end

function TripodControlPad:OnLongPressTripodLeft()
  if self.Panel:IsTakingPhotos() then
    return
  end
  if not self:IsVisible() then
    return
  end
  local Mode = self.Panel.CurrMode
  if Mode and Mode.MoveTripodLeft then
    Mode:MoveTripodLeft()
  end
end

function TripodControlPad:OnBtnTripodLeftOperationClicked(bLongPress)
  if bLongPress then
    return
  end
  self:OnLongPressTripodLeft()
end

function TripodControlPad:OnLongPressTripodRight()
  if self.Panel:IsTakingPhotos() then
    return
  end
  if not self:IsVisible() then
    return
  end
  local Mode = self.Panel.CurrMode
  if Mode and Mode.MoveTripodRight then
    Mode:MoveTripodRight()
  end
end

function TripodControlPad:OnBtnTripodRightOperationClicked(bLongPress)
  if bLongPress then
    return
  end
  self:OnLongPressTripodRight()
end

return TripodControlPad
