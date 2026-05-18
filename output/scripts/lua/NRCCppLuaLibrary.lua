local DeviceUtils = require("NewRoco.Modules.Core.App.DeviceUtils")
local DeviceEvent = require("NewRoco.Modules.Core.App.DeviceEvent")
local NRCSDKManagerEvent = require("Core.Service.SDKManager.NRCSDKManagerEvent")
CppLuaLibrary = {}

function CppLuaLibrary.SetQualities(ImageQuality, FrameQuality, MemoryQuality)
  Log.Debug("CppLuaLibrary.SetQualities")
  DeviceUtils.ImageQuality = ImageQuality
  DeviceUtils.FrameQuality = FrameQuality
  DeviceUtils.MemoryQuality = MemoryQuality
  local bSimulator, simuName = _G.NRCSDKManager:IsSimulator()
  if bSimulator then
    Log.Debug("CppLuaLibrary.SetQualities is simulator ", simuName)
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "r.CheckFramebufferFetchSupport 1")
  else
    Log.Debug("CppLuaLibrary.SetQualities not simulator")
  end
  DeviceUtils.EventDispatcher:SendEvent(DeviceEvent.OnQualityChange, ImageQuality, FrameQuality, MemoryQuality)
end

function CppLuaLibrary.SetResolution(ResolutionX, ResolutionY)
  Log.Debug("CppLuaLibrary.SetResolution")
  DeviceUtils.ResolutionX = ResolutionX
  DeviceUtils.ResolutionY = ResolutionY
  DeviceUtils.EventDispatcher:SendEvent(DeviceEvent.OnResolutionChange, ResolutionX, ResolutionY)
end

function CppLuaLibrary.OpenWebView()
  _G.NRCSDKManager:SendEvent(NRCSDKManagerEvent.OnOpenWebView)
end

function CppLuaLibrary.CheckIsSimulator()
  local bSimulator, simuName = _G.NRCSDKManager:IsSimulator()
  if bSimulator then
    Log.Debug("CppLuaLibrary.CheckIsSimulator\239\188\154 is simulator ", simuName)
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "r.ForceUseMobileLiteHDR 0")
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "r.CheckFramebufferFetchSupport 1")
  else
    Log.Debug("CppLuaLibrary.CheckIsSimulator\239\188\154 not simulator")
  end
end

return CppLuaLibrary
