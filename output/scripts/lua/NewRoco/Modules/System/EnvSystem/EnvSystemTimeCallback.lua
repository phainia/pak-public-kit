local EnvSystemTimeCallback = NRCClass()

function EnvSystemTimeCallback:Init(timeScheduler, time)
  self.timeScheduler = timeScheduler
  self.time = time
end

function EnvSystemTimeCallback:UpdateTime(time)
  self.time = time
end

function EnvSystemTimeCallback:GetTime()
  return self.time
end

return EnvSystemTimeCallback
