local NRCEnv = Singleton:Extend("NRCEnv")

function NRCEnv:Ctor()
  Singleton.Ctor(self, self.name)
  self.curBuildVersion = nil
end

function NRCEnv:GetBuildVersion()
  if not self.curBuildVersion then
    self.curBuildVersion = UE4.UNRCStatics.GetBuildVersion()
  end
  Log.Debug("GetBuildVersion:", self.curBuildVersion)
  return self.curBuildVersion
end

function NRCEnv:CheckBuildVersionIsDebug()
  return 9 ~= self:GetBuildVersion()
end

function NRCEnv:CheckBuildVersionIsRelease()
  return 9 == self:GetBuildVersion()
end

function NRCEnv:IsLocalMode()
  local isLocalMode = not NRCModeManager:GetCurMode() or NRCModeManager:GetCurMode().modeName == "LocalMode" or NRCModeManager:GetCurMode().modeName == "BattleTestMapMode" or GlobalConfig.ForceLocalMode
  return isLocalMode
end

function NRCEnv:IsCreatePlayerMode()
  local isCreatePlayerMode = NRCModeManager:GetCurMode() and NRCModeManager:GetCurMode().modeName == "CreatePlayerMode"
  return isCreatePlayerMode
end

function NRCEnv:IsLocalBattleMode()
  local isLocalMode = not NRCModeManager:GetCurMode() or NRCModeManager:GetCurMode().modeName == "BattleTestMapMode"
  return isLocalMode
end

return NRCEnv
