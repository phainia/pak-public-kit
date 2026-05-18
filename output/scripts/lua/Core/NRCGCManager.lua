local NRCGCManager = _G.Singleton:Extend("NRCGCManager")

function NRCGCManager:Ctor()
  self.gcInterval = 300000
  self.accumulatedWeight = 0
  self:SetGCTime()
  Log.PrintScreenMsg("SetGCTime")
end

function NRCGCManager:SetGCTime()
  self.lastGCTime = UE4.UNRCStatics.GetMilliSeconds()
end

function NRCGCManager:IsGCAble()
  local NormalizedTime = UE4.UNRCStatics.GetMilliSeconds() + self.gcInterval * self.accumulatedWeight / 100
  return NormalizedTime - self.lastGCTime >= self.gcInterval
end

function NRCGCManager:DoGC()
  NRCSDKManager:SetGC()
  Log.PrintScreenMsg("NRCGCManager DoGC")
  collectgarbage("collect")
  UE4.UNRCStatics.ForceGarbageCollection(true)
  UE4.UNRCStatics.RemovePendingKillObject()
  self:SetGCTime()
  NRCSDKManager:EndGC()
  self.accumulatedWeight = 0
end

function NRCGCManager:TryGC(force, weight)
  if weight then
    self.accumulatedWeight = self.accumulatedWeight + weight
  end
  if not force then
    if self:IsGCAble() then
      self:DoGC()
      return true
    end
  else
    self:DoGC()
    return true
  end
  return false
end

return NRCGCManager
