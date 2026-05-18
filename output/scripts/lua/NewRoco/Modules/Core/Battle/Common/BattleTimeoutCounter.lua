local BattleTimeoutCounter = NRCClass:Extend("BattleTimeoutCounter")

function BattleTimeoutCounter.Get(name)
  return BattleTimeoutCounter(name)
end

function BattleTimeoutCounter:Ctor(name)
  self.name = name or "Nameless"
end

function BattleTimeoutCounter:Start(value, timeoutCallbackCaller, timeoutCallback, reconnectCallback, isPassiveTick)
  self.isRunning = true
  self.isStop = false
  self.isPause = false
  self.isPassiveTick = false
  self.curTime = 0
  self.networkTime = 0
  self.networkTimeoutValue = 2
  self.needReconnectTimeout = false
  self.enableNetworkTimeout = false
  self.timeoutValue = value
  self.timeoutCallbackCaller = timeoutCallbackCaller
  self.maxTimeoutValue = 120
  self.timeoutCallback = timeoutCallback
  self.reconnectCallback = reconnectCallback
  if not isPassiveTick then
    _G.UpdateManager:Register(self, true)
  end
  self:AddEvent()
end

function BattleTimeoutCounter:SetPassiveTick(boo)
  self.isPassiveTick = boo
  if boo then
    _G.UpdateManager:Register(self, true)
  else
    _G.UpdateManager:UnRegister(self)
  end
end

function BattleTimeoutCounter:AddTimeoutValue(value)
  self.timeoutValue = self.timeoutValue + value
end

function BattleTimeoutCounter:ResetTimeoutValue(value)
  self.timeoutValue = value
end

function BattleTimeoutCounter:AddEvent()
  if not self.isAddedEvent then
    NRCEventCenter:RegisterEvent(self.name, self, NRCGlobalEvent.OnApplicationWillEnterBackground, self.OnApplicationWillEnterBackground)
    NRCEventCenter:RegisterEvent(self.name, self, NRCGlobalEvent.OnApplicationHasEnteredForeground, self.OnApplicationHasEnteredForeground)
    NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_LOGIN, self.OnReciviceLogin)
    NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
    NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
    self.isAddedEvent = true
  end
end

function BattleTimeoutCounter:RemoveEvent()
  if self.isAddedEvent then
    NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnApplicationWillEnterBackground, self.OnApplicationWillEnterBackground)
    NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnApplicationHasEnteredForeground, self.OnApplicationHasEnteredForeground)
    NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_LOGIN, self.OnReciviceLogin)
    NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
    NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
    self.isAddedEvent = false
  end
end

function BattleTimeoutCounter:OnDisconnect()
  Log.Msg("BattleTimeoutCounter:OnDisconnect:", self.name)
  self.needReconnectTimeout = true
  self.networkTime = 0
  self.enableNetworkTimeout = false
end

function BattleTimeoutCounter:OnReconnect()
  Log.Msg("BattleTimeoutCounter:OnReconnect:", self.name)
  self.networkTime = 0
  self.enableNetworkTimeout = true
  self.needReconnectTimeout = true
end

function BattleTimeoutCounter:OnApplicationWillEnterBackground()
  self.isActionInForeground = true
  self:Pause()
end

function BattleTimeoutCounter:OnApplicationHasEnteredForeground()
  self.isActionInForeground = false
  self:Resume()
end

function BattleTimeoutCounter:Stop()
  self.curTime = 0
  self.networkTime = 0
  self.isRunning = false
  self.isStop = true
  self.needReconnectTimeout = false
  self.enableNetworkTimeout = false
  self:RemoveEvent()
  _G.UpdateManager:UnRegister(self)
end

function BattleTimeoutCounter:Pause()
  self.isPause = true
  self.enableNetworkTimeout = false
end

function BattleTimeoutCounter:Resume()
  self.isPause = false
  self.enableNetworkTimeout = true
end

function BattleTimeoutCounter:OnReciviceLogin()
end

function BattleTimeoutCounter:IsTimeout()
  if not self.isRunning then
    return false
  end
  if self:IsMainTimeout() then
    if self.needReconnectTimeout then
      if self:IsNetworkTimeout() then
        Log.Error("BattleTimeoutCounter:\229\143\140\233\135\141\232\182\133\230\151\182\230\157\161\228\187\182\230\187\161\232\182\179\239\188\140\232\167\166\229\143\145\232\182\133\230\151\182")
        return true
      else
        Log.Msg("BattleTimeoutCounter:\231\189\145\231\187\156\233\135\141\232\191\158\232\182\133\230\151\182\230\156\170\232\190\190\229\136\176\239\188\140\228\184\141\232\167\166\229\143\145\232\182\133\230\151\182:", self, self.name)
        return false
      end
    end
    Log.Error("BattleTimeoutCounter:\230\151\160\233\156\128\231\189\145\231\187\156\233\135\141\232\191\158\230\163\128\230\159\165\239\188\140\231\155\180\230\142\165\232\167\166\229\143\145\232\182\133\230\151\182")
    return true
  end
  return false
end

function BattleTimeoutCounter:IsMainTimeout()
  return self.curTime >= self.timeoutValue
end

function BattleTimeoutCounter:IsNetworkTimeout()
  return self.networkTime >= self.networkTimeoutValue
end

function BattleTimeoutCounter:IsMaxTimeout()
  return self.curTime >= self.maxTimeoutValue
end

function BattleTimeoutCounter:GetRemainTime()
  if not self.isRunning then
    return 0
  end
  return self.timeoutValue - self.curTime
end

function BattleTimeoutCounter:TriggerTimeout()
  if self.timeoutCallback then
    self.timeoutCallback(self.timeoutCallbackCaller)
  end
  self:Stop()
end

function BattleTimeoutCounter:TriggerReconnect()
  if self.reconnectCallback then
    self.reconnectCallback(self.timeoutCallbackCaller)
  end
  self:Stop()
end

function BattleTimeoutCounter:OnTick(DeltaTime)
  if self.isRunning and not self.isPause then
    self.curTime = self.curTime + DeltaTime
    if self.needReconnectTimeout and self.enableNetworkTimeout and not self:IsNetworkTimeout() then
      self.networkTime = self.networkTime + DeltaTime
    end
    if self:IsTimeout() then
      self:TriggerTimeout()
    end
    if self:IsMaxTimeout() then
      self:Stop()
    end
  end
end

function BattleTimeoutCounter:Release()
end

return BattleTimeoutCounter
