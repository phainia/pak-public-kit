local EnvSystemTimeCallback = require("NewRoco.Modules.System.EnvSystem.EnvSystemTimeCallback")
local EnvSystemTimeScheduler = NRCClass()

function EnvSystemTimeScheduler:Init()
  self.timeStack = Array()
  self.CachedEnvSys = nil
  self.CachedInstance = nil
  self.last_game_time = -1
end

function EnvSystemTimeScheduler:OnTick()
  if self.timeStack:IsEmpty() then
    return
  end
  local current_time = self.timeStack:Last():GetTime()
  if not self.last_game_time then
    self.last_game_time = -1
  end
  if true or math.abs(self.last_game_time - current_time) > 0.008 then
    _G.NRCAudioManager:SetGlobalRTPC("World_Time", current_time, 0)
    local EnvSys = self:GetEnvSys()
    if not EnvSys then
      return
    end
    EnvSys:SetGameTime(current_time)
    self.last_game_time = current_time
  end
end

function EnvSystemTimeScheduler:RegisterTime(time)
  local callback = EnvSystemTimeCallback()
  callback:Init(self, time)
  self.timeStack:Add(callback)
  return callback
end

function EnvSystemTimeScheduler:ReleaseTime(callback)
  self.timeStack:Remove(callback)
end

function EnvSystemTimeScheduler:GetEnvSys()
  if UE.UObject.IsValid(self.CachedEnvSys) then
    return self.CachedEnvSys
  end
  if not UE.UObject.IsValid(self.CachedInstance) then
    self.CachedInstance = UE.UNRCPlatformGameInstance.GetInstance()
  end
  if not self.CachedInstance then
    return nil
  end
  self.CachedEnvSys = self.CachedInstance:GetWorldSubSystem()
  return self.CachedEnvSys
end

return EnvSystemTimeScheduler
