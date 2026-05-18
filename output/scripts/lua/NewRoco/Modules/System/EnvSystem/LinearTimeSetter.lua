local Class = _G.MakeSimpleClass
local LinearTimeSetter = Class("LinearTimeSetter")

function LinearTimeSetter:Ctor()
  self.FinalTime = 0
  self.LerpTime = 3
end

function LinearTimeSetter:Start(FinalTime, LerpTime)
  if LerpTime then
    self.LerpTime = LerpTime
  end
  self:StartWithHour(FinalTime % 86400 / 3600)
end

function LinearTimeSetter:StartWithHour(FinalHour)
  local CurrentTime = self:GetGameTime()
  local FinalTimeInHour = FinalHour
  local Delta = FinalTimeInHour - CurrentTime
  if math.abs(Delta) <= 0.1 then
    return
  elseif Delta < 0 then
    self.FinalTime = FinalTimeInHour + 24
  else
    self.FinalTime = FinalTimeInHour
  end
  self.StartTime = CurrentTime
  self.PassedTime = 0
  self.TimeHandler = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.RegisterTime, CurrentTime)
  _G.UpdateManager:Register(self)
end

function LinearTimeSetter:OnTick(DeltaTime)
  self.PassedTime = self.PassedTime + DeltaTime
  local Alpha = math.clamp(self.PassedTime / self.LerpTime, 0, 1)
  self.CurrentTime = (self.FinalTime - self.StartTime) * Alpha + self.StartTime
  self.TimeHandler:UpdateTime(self.CurrentTime)
  if 1 == Alpha then
    self:Stop()
  end
end

function LinearTimeSetter:Stop()
  _G.UpdateManager:UnRegister(self)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ReleaseTime, self.TimeHandler)
  self.TimeHandler = nil
end

function LinearTimeSetter:GetGameTime()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  if not EnvSys then
    return 0
  end
  return EnvSys:GetGameTime()
end

return LinearTimeSetter
