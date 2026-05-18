local CommonUtils = {}
local GAME_MATRIX_TYPE_H5 = "H5"

function CommonUtils.IsGameCloudEnv()
  if not _G.RocoEnv.PLATFORM_WINDOWS and not _G.RocoEnv.PLATFORM_ANDROID then
    return false
  end
  local GameInstance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not GameInstance then
    return false
  end
  local GameMatrixMgr = GameInstance:GetGameMatrixMgr()
  if not GameMatrixMgr then
    return false
  end
  Log.Debug("[CommonUtils.IsGameCloudEnv] --->")
  return GameMatrixMgr:IsCloudGameEnv()
end

function CommonUtils.GetGameMatrixMgrWithCheck()
  if not _G.RocoEnv.PLATFORM_WINDOWS and not _G.RocoEnv.PLATFORM_ANDROID then
    return nil
  end
  local GameInstance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not GameInstance then
    return nil
  end
  local GameMatrixMgr = GameInstance:GetGameMatrixMgr()
  if not GameMatrixMgr then
    return nil
  end
  if not GameMatrixMgr:IsCloudGameEnv() then
    return nil
  end
  return GameMatrixMgr
end

function CommonUtils.IsH5GameCloudEnv()
  local GameMatrixMgr = CommonUtils.GetGameMatrixMgrWithCheck()
  if not GameMatrixMgr then
    return false
  end
  Log.Debug("[CommonUtils.IsH5GameCloudEnv] --->", GameMatrixMgr:GetClientType())
  return GameMatrixMgr:GetClientType() == GAME_MATRIX_TYPE_H5
end

function CommonUtils.SendClientEventToCGSDK(Message)
  Log.Debug("[CommonUtils.SendClientEventToCGSDK]", Message)
  local GameMatrixMgr = CommonUtils.GetGameMatrixMgrWithCheck()
  if not GameMatrixMgr then
    return
  end
  GameMatrixMgr:SendClientEvent(Message)
end

return CommonUtils
