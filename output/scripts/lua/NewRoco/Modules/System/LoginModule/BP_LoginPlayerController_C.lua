require("UnLuaEx")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local BP_LoginPlayerController_C = NRCClass("BP_LoginPlayerController_C")

function BP_LoginPlayerController_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.RestoreCameraToCenter, self.RestoreCameraToCenterWithInit)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.EnableSelection, self.EnableSelection)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.DisableSelection, self.DisableSelection)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.ChangeLoginDragAcceleration, self.ChangeLoginDragAcceleration)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.ChangeLoginDragRatio, self.ChangeLoginDragRatio)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.ChangeLoginReleaseAcceleration, self.ChangeLoginReleaseAcceleration)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.ChangeLoginReleaseRatio, self.ChangeLoginReleaseRatio)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.GmChangeRotationAutoSpeed, self.GmChangeRotationAutoSpeed)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.GmChangeRotationSensitive, self.GmChangeRotationSensitive)
  _G.NRCEventCenter:RegisterEvent("BP_LoginPlayerController_C", self, LoginModuleEvent.GmChangeRotationFriction, self.GmChangeRotationFriction)
end

function BP_LoginPlayerController_C:ReceiveEndPlay(Reason)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.RestoreCameraToCenter, self.RestoreCameraToCenterWithInit)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.EnableSelection, self.EnableSelection)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.DisableSelection, self.DisableSelection)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.ChangeLoginDragAcceleration, self.ChangeLoginDragAcceleration)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.ChangeLoginDragRatio, self.ChangeLoginDragRatio)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.ChangeLoginReleaseAcceleration, self.ChangeLoginReleaseAcceleration)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.ChangeLoginReleaseRatio, self.ChangeLoginReleaseRatio)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.GmChangeRotationAutoSpeed, self.GmChangeRotationAutoSpeed)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.GmChangeRotationSensitive, self.GmChangeRotationSensitive)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.GmChangeRotationFriction, self.GmChangeRotationFriction)
  self.Overridden.ReceiveEndPlay(self, Reason)
end

function BP_LoginPlayerController_C:Ctor()
  self.bSpinPrepared = false
end

function BP_LoginPlayerController_C:ChangeLoginDragAcceleration(inValue)
  Log.Error("change normal acceleration to ", inValue)
  self.OnClickDraggingAcceleration = inValue
end

function BP_LoginPlayerController_C:ChangeLoginDragRatio(inValue)
  Log.Error("change total drag ratio to ", inValue)
  self.DraggingToRotationRatio = inValue
end

function BP_LoginPlayerController_C:ChangeLoginReleaseAcceleration(inValue)
  Log.Error("change release acceleration to ", inValue)
  self.ReleaseDraggingAcceleration = inValue
end

function BP_LoginPlayerController_C:ChangeLoginReleaseRatio(inValue)
  Log.Error("change release drag ratio to ", inValue)
  self.ReleaseDraggingToRotationRatio = inValue
end

function BP_LoginPlayerController_C:GmChangeRotationAutoSpeed(inValue)
  Log.Error("change auto speed to ", inValue)
  self.AutoSpeed = inValue
end

function BP_LoginPlayerController_C:GmChangeRotationSensitive(inValue)
  Log.Error("change sensitive to ", inValue)
  self.Sensitive = inValue
end

function BP_LoginPlayerController_C:GmChangeRotationFriction(inValue)
  Log.Error("change rotation friction to ", inValue)
  self.Friction = inValue
end

function BP_LoginPlayerController_C:EnableSelection()
  self.bPlayerSelected = false
  self.bInSpinPhase = true
end

function BP_LoginPlayerController_C:DisableSelection()
  if not self.bInSpinPhase then
    return
  end
  self.bInSpinPhase = false
  self.bPlayerSelected = true
end

function BP_LoginPlayerController_C:RestoreCameraToCenterWithInit()
  self:RestoreCameraToCenter()
end

function BP_LoginPlayerController_C:RestorePlayerPosition(caller, callback)
  local AngleToRotate = self:GetDeltaRotation()
  local TimeToUse = 2 * AngleToRotate / 360
  self.AngleToRotate = AngleToRotate
  self.InterpSpeed = 1 / TimeToUse
  _G.DelayManager:DelaySeconds(TimeToUse, function()
    callback(caller)
    self.AngleToRotate = 0
  end)
end

function BP_LoginPlayerController_C:OnPressEscape(bPress)
  if bPress then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.PressEscape, UE.EInputEvent.IE_Pressed)
  else
    NRCEventCenter:DispatchEvent(LoginModuleEvent.PressEscape, UE.EInputEvent.IE_Released)
  end
end

return BP_LoginPlayerController_C
