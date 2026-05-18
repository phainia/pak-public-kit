local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local RestoreCameraAction = Base:Extend("RestoreCameraAction")

function RestoreCameraAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  if properties.bIsMale then
    self.TargetAngle = -157.9
  else
    self.TargetAngle = 22.1
  end
  self.Event = LoginModuleEvent.RestoreCameraToCenter
  self.bIsMale = properties.bIsMale
end

function RestoreCameraAction:OnEnter()
  Log.Debug("RestoreCameraAction OnEnter:", self.name)
  self.ActorHolder = LoginUtils.GetUObjectHolder()
  self.PropertyHolder = LoginUtils.GetPropertyHolder()
  local controller = LoginUtils.GetLoginController()
  self.TotalRotation = controller:GetDeltaRotation(self.TargetAngle)
  if self.TotalRotation > 180 then
    self.TotalRotation = self.TotalRotation - 360
  end
  self.TotalTime = 1
  self.TimeLeft = self.TotalTime
  if 0 == self.fsm.BlockRestoreCameraActionFlag then
    _G.NRCAudioManager:PlaySound2DAuto(1095, "RestoreCameraAction:OnEnter")
  end
  self.fsm.BlockRestoreCameraActionFlag = 0
  NRCEventCenter:DispatchEvent(LoginModuleEvent.CantClickConfirmPanels)
end

function RestoreCameraAction:OnTick(DeltaTime)
  local TimeToRotate = DeltaTime
  local controller = UE4.UGameplayStatics.GetPlayerController(self.ActorHolder.Player1, 0)
  if 0.0 == self.TimeLeft then
    self:Finish()
    return
  end
  if DeltaTime > self.TimeLeft then
    TimeToRotate = self.TimeLeft
  end
  local AngleToRotate = self:MapTimeToAngle(TimeToRotate)
  self.TimeLeft = self.TimeLeft - TimeToRotate
  controller:AddPlayersRotation(AngleToRotate)
  local StartTime = (self.TotalTime - self.TimeLeft) / self.TotalTime
  local EndTime = (self.TotalTime - self.TimeLeft + TimeToRotate) / self.TotalTime
  local MappedDeltaTime = self.ActorHolder.RestoreCameraCurve:GetFloatValue(EndTime) - self.ActorHolder.RestoreCameraCurve:GetFloatValue(StartTime)
  if 0.0 == self.TimeLeft then
    self:Finish()
  end
end

function RestoreCameraAction:MapTimeToAngle(inTime)
  local StartTime = (self.TotalTime - self.TimeLeft) / self.TotalTime
  local EndTime = (self.TotalTime - self.TimeLeft + inTime) / self.TotalTime
  
  function InterpolationFunction(x)
    return self.ActorHolder.RestoreCameraCurve:GetFloatValue(x)
  end
  
  return (InterpolationFunction(EndTime) - InterpolationFunction(StartTime)) * self.TotalRotation
end

function RestoreCameraAction:OnExit()
  Log.Debug("RestoreCameraAction OnExit:", self.name)
end

return RestoreCameraAction
