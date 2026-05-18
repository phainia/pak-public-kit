local NetworkStatusObserver = NRCClass()

function NetworkStatusObserver:Initialize(Owner)
  self.OwnerTask = Owner
end

function NetworkStatusObserver:Ctor()
  self.OwnerTask = nil
end

function NetworkStatusObserver:OnNetworkStateChanged(NetworkStatus)
  Log.Error("network status changed", NetworkStatus)
  if not self.CurrentNetworkStatus then
    self.CurrentNetworkStatus = 0
  end
  local LastNetworkStatus = self.CurrentNetworkStatus
  self.CurrentNetworkStatus = NetworkStatus
  if 2 ~= LastNetworkStatus and 2 == NetworkStatus then
    Log.Debug("[NetworkStatusObserver] network status changed to wifi")
    _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.OnNetworkStatusTurnToWifi)
  end
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.OnPufferNetworkChanged, NetworkStatus)
end

return NetworkStatusObserver
