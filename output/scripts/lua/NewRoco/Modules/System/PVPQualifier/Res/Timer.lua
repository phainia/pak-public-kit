local Timer = NRCClass("Timer")

function Timer:Ctor(seconds)
  self:Reset(seconds)
end

function Timer:IsExceed()
  return self.remainingSeconds <= 0
end

function Timer:Tick(deltaTime)
  if not self.bPaused and self.remainingSeconds > 0 then
    self.remainingSeconds = math.max(0, self.remainingSeconds - deltaTime)
  end
end

function Timer:Reset(seconds)
  self.totalSeconds = seconds or 0
  self.remainingSeconds = seconds or 0
  self:Proceed()
end

function Timer:ResetAndPause(seconds)
  self.totalSeconds = seconds or 0
  self.remainingSeconds = seconds or 0
  self.bPaused = true
end

function Timer:Pause()
  self.bPaused = true
end

function Timer:Proceed()
  self.bPaused = false
end

return Timer
