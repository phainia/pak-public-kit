local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Delegate = require("Utils.Delegate")
local LongPressProxy = require("NewRoco/Modules/System/TakePhotos/LongPressProxy")
local VisibilityMutex = require("NewRoco.Modules.System.TakePhotos.Helper.VisibilityMutex")
local FovProgressBar = Class("FovProgressBar")

function FovProgressBar:Ctor(Panel)
  self.Panel = Panel
  self.Holder = Panel.left_buttons
  self.VisibilityMutex = VisibilityMutex(self.Holder, true)
  self.IncFovBtn = Panel.btnScaleMin
  self.DecFovBtn = Panel.btnScaleMax
  self.Slider = Panel.mapScaleSlider
  self.AddFovPressProxy = LongPressProxy()
  self.DecFovPressProxy = LongPressProxy()
  self.AddFovPressProxy:Bind(self.IncFovBtn, self.Panel, function(_, ...)
    self:OnLongPressAddFov(...)
  end, function(_, ...)
    self:OnBtnPressAddFov(...)
  end, nil, function(_, ...)
    self:OnTouchAddFovStart(...)
  end)
  self.DecFovPressProxy:Bind(self.DecFovBtn, self.Panel, function(_, ...)
    self:OnLongPressDecFov(...)
  end, function(_, ...)
    self:OnBtnPressDecFov(...)
  end, nil, function(_, ...)
    self:OnTouchDecFovStart(...)
  end)
  self.AddFovPressProxy:SetThreshold(0.15)
  self.DecFovPressProxy:SetThreshold(0.15)
  Panel.OnTickMultiDelegate:Add(self, self.OnTick)
  Panel.OnModeChangedDelegate:Add(self, self.OnModeChanged)
  Panel.Adapter.OnFovChanged:Add(self, self.OnFovChanged)
  self.Slider.OnValueChanged:Add(self.Panel, function(_, ...)
    self:OnFovSliderValueChanged(...)
  end)
  self.ElapsedFovInput = 0
end

function FovProgressBar:OnDestroy()
  self.AddFovPressProxy:Cleanup()
  self.DecFovPressProxy:Cleanup()
end

function FovProgressBar:OnReqChangeFov(DeltaValue)
  self.ElapsedFovInput = self.ElapsedFovInput + DeltaValue
end

function FovProgressBar:OnFovSliderValueChanged(Fov)
  self.ElapsedFovInput = 0
  self.Panel.Adapter:ChangeModeFov(Fov)
end

function FovProgressBar:OnLongPressAddFov()
  self:OnReqChangeFov(self:GetFovDelta(self.Panel.CurrMode, 0.1))
end

function FovProgressBar:OnTouchAddFovStart()
  _G.NRCAudioManager:PlaySound2DAuto(40007002, "OnTouchAddFovStart")
end

function FovProgressBar:OnTouchDecFovStart()
  _G.NRCAudioManager:PlaySound2DAuto(40007002, "OnTouchDecFovStart")
end

function FovProgressBar:OnBtnPressAddFov(bLongPress)
  self:OnLongPressAddFov()
end

function FovProgressBar:OnLongPressDecFov()
  self:OnReqChangeFov(-self:GetFovDelta(self.Panel.CurrMode, 0.1))
end

function FovProgressBar:OnBtnPressDecFov(bLongPress)
  self:OnLongPressDecFov()
end

function FovProgressBar:OnTick(Dt)
  if 0 ~= self.ElapsedFovInput then
    self.Panel.Adapter:ChangeModeFov(self:GetFov() + self.ElapsedFovInput)
    self.Slider:SetValue(self:GetFov())
    self.ElapsedFovInput = 0
  end
end

function FovProgressBar:GetFovDelta(Mode, Percent)
  return Percent * (Mode:GetMaxiFov() - Mode:GetMiniFov())
end

function FovProgressBar:GetFov()
  return self.Panel.CurrMode:GetFov()
end

function FovProgressBar:UpdateFromValue()
  local Mode = self.Panel.CurrMode
  self.Slider:SetMaxValue(Mode:GetMaxiFov())
  self.Slider:SetMinValue(Mode:GetMiniFov())
  self.Slider:SetValue(Mode:GetFov())
end

function FovProgressBar:Reset()
  self:UpdateFromValue()
end

function FovProgressBar:OnModeChanged()
  self:UpdateFromValue()
end

function FovProgressBar:OnFovChanged()
  self:UpdateFromValue()
end

return FovProgressBar
