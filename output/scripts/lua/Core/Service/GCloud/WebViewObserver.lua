local WebViewObserver = NRCClass()
local NRCSDKManagerEvent = require("Core.Service.SDKManager.NRCSDKManagerEvent")

function WebViewObserver:OnWebViewOptNotify(webViewRet)
  _G.NRCSDKManager:SendEvent(NRCSDKManagerEvent.OnWebViewOptNotify, webViewRet)
end

function WebViewObserver:ListenPermissionRequest()
  Log.Debug("UNRCPermissionMgr :ListenPermissionRequest start")
  if RocoEnv.PLATFORM == "PLATFORM_ANDROID" or RocoEnv.IS_EDITOR then
    UE.UNRCPermissionMgr.RegisterRequestCallback({
      self,
      function(_, permissionType)
        Log.Debug("UNRCPermissionMgr \230\157\131\233\153\144\232\175\183\230\177\130\229\188\128\229\167\139", permissionType)
        local shouldShow = UE.UNRCPermissionMgr.ShouldShowRequestPermissionRationale(permissionType)
        Log.Debug("UNRCPermissionMgr \230\157\131\233\153\144\232\175\183\230\177\130\230\152\175\229\144\166\229\186\148\232\175\165\230\152\190\231\164\186", shouldShow)
        local permissionName = "RecordAudio"
        if UE.UNRCPermissionMgr.GetPermissionStringAsValue then
          permissionName = UE.UNRCPermissionMgr.GetPermissionStringAsValue(permissionType)
        end
        local isFirstTime = UE.UNRCPermissionMgr.IsFirstTimeRequest(permissionType)
        Log.Debug("UNRCPermissionMgr MainUIModule:OnPermissionRequestCallback", "permissionType:", permissionType, "permissionName:", permissionName, "isFirstTime:", isFirstTime)
        local TextKey = "ENRCPermissionType::" .. permissionName
        Log.Debug("MainUIModule:OnPermissionRequestCallback", "TextKey:", TextKey)
        local tips = LuaText[TextKey]
        Log.Debug("UNRCPermissionMgr MainUIModule:OnPermissionRequestCallback", "IsFirstTime:", isFirstTime)
        if _G.MainUIModuleCmd == nil then
          Log.Debug("UNRCPermissionMgr MainUIModule:OnPermissionRequestCallback", "MainUIModuleCmd is nil")
          return
        end
        if shouldShow then
          _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShowPermissionTips, true, tips)
        elseif isFirstTime then
          _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShowPermissionTips, true, tips)
        end
      end
    }, {
      self,
      function(_, requestCode, bGranted)
        Log.Debug("UNRCPermissionMgr \230\157\131\233\153\144\232\175\183\230\177\130\231\187\147\230\157\159 requestCode", requestCode, bGranted)
        if _G.MainUIModuleCmd == nil then
          Log.Debug("UNRCPermissionMgr MainUIModule:OnPermissionRequestCallback", "MainUIModuleCmd is nil")
          return
        end
        _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShowPermissionTips, false, "")
      end
    })
    Log.Debug("UNRCPermissionMgr :ListenPermissionRequest end")
  else
    Log.Debug("UNRCPermissionMgr :platform is not android")
  end
end

function WebViewObserver:UnRegister()
  UE.UNRCPermissionMgr.UnRegisterRequestCallback()
end

return WebViewObserver
