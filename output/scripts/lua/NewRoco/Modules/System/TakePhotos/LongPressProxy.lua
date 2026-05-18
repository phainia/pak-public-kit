local LongPressProxy = Class()

function LongPressProxy:Ctor()
  self.threshold = TakePhotosEnum.TPGlobalNum("takephoto_tripod_long_press_time", 10000) / 10000
  self.elapsed = 0
  self.triggered = false
  self.bind = false
  self.dirty = false
end

function LongPressProxy:Cleanup()
  if self.dirty then
    UpdateManager:UnRegister(self)
  end
end

function LongPressProxy:SetThreshold(Threshold)
  self.threshold = Threshold
end

function LongPressProxy:Bind(Btn, Caller, OnLongTickingDelegate, OnEndDelegate, OnLongStart, OnStartDelegate)
  assert(not self.bind)
  self.bind = true
  self.Caller = Caller
  self.OnLongStart = OnLongStart
  self.OnLongTickingDelegate = OnLongTickingDelegate
  self.OnEndDelegate = OnEndDelegate
  self.OnStartDelegate = OnStartDelegate
  if not UE.UObject.IsValid(Caller) then
    Log.Error("Invalid")
    return
  end
  Btn.OnPressed:Add(Caller, function(_, ...)
    self.elapsed = 0
    self.triggered = false
    self.dirty = true
    UpdateManager:Register(self)
    if self.OnStartDelegate then
      self.OnStartDelegate(self.Caller, ...)
    end
  end)
  Btn.OnReleased:Add(Caller, function(_, ...)
    self.dirty = false
    UpdateManager:UnRegister(self)
    if self.OnEndDelegate then
      self.OnEndDelegate(self.Caller, self.triggered, self.elapsed, ...)
    end
    self.elapsed = 0
    self.triggered = false
  end)
end

function LongPressProxy:OnTick(Dt)
  self.elapsed = self.elapsed + Dt
  if self.elapsed > self.threshold then
    if not self.triggered then
      self.triggered = true
      if self.OnLongStart then
        self.OnLongStart(self.Caller)
      end
    elseif self.OnLongTickingDelegate then
      self.OnLongTickingDelegate(self.Caller, Dt)
    end
  end
end

return LongPressProxy
