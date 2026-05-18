local GRobotObserver = NRCClass()

function GRobotObserver:Initialize()
  Log.Debug("GRobotObserver:Initialize")
end

function GRobotObserver:OnGRobotShowCallback()
  Log.Debug("GRobotObserver:OnGRobotShowCallback")
end

function GRobotObserver:OnGRobotURLCallback(url)
  Log.Debug("GRobotObserver:OnGRobotURLCallback", url)
end

function GRobotObserver:OnGRobotCloseCallback()
  Log.Debug("GRobotObserver:OnGRobotCloseCallback")
end

return GRobotObserver
