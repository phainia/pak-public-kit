local NRCModeEntrance = NRCClass:Extend("NRCModeEntrance")

function NRCModeEntrance:Ctor()
  NRCClass.Ctor(self)
end

function NRCModeEntrance:RegisterMapChangeCompleteEvent()
  _G.NRCEventCenter:RegisterEvent("NRCLuaEntrance", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnNRCLuaEntranceHookMapLoaded)
end

function NRCModeEntrance:UnRegisterMapChangeCompleteEvent()
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnNRCLuaEntranceHookMapLoaded)
end

function NRCModeEntrance:OnNRCLuaEntranceHookMapLoaded()
  self:UnRegisterMapChangeCompleteEvent()
  Log.Debug("NRCModeEntrance:OnNRCLuaEntranceHookMapLoaded ", RocoEnv.PLATFORM)
  self:ActiveModeByCurLevel()
end

function NRCModeEntrance:ActiveModeByCurLevel()
  local GameInstance = UE4.UNRCPlatformGameInstance.GetInstance()
  if GameInstance then
    GameInstance:SetBackToLoginLoadingUMG(nil)
  end
  local curLevelName = LevelHelper:GetLevelName()
  Log.Debug("NRCModeEntrance:ActiveModeByCurLevel ", curLevelName, RocoEnv.PLATFORM)
  if "Login" == curLevelName then
    self:ActiveLoginMode()
  elseif "UpdateLevel" == curLevelName then
    self:ActiveUpdateMode()
  end
end

function NRCModeEntrance:ActiveLoginMode()
  NRCModeManager:ActiveMode("LoginMode")
end

function NRCModeEntrance:ActiveUpdateMode()
  NRCModeManager:ActiveMode("UpdateMode")
end

function NRCModeEntrance:ActiveMode()
  local curLevelName = LevelHelper:GetLevelName()
  Log.Debug("NRCModeEntrance:ActiveMode", curLevelName, RocoEnv.PLATFORM)
  if not RocoEnv.IS_EDITOR and ("UpdateLevel" == curLevelName or "Login" == curLevelName) then
    Log.Debug("[NRCModeEntrance:ActiveMode] map already loaded, active mode right now")
    self:ActiveModeByCurLevel()
  elseif "UpdateLevel" == curLevelName and (RocoEnv.PLATFORM == "PLATFORM_WINDOWS" or RocoEnv.PLATFORM == "PLATFORM_MAC") then
    self.ActiveLoginDelayTimer = _G.TimerManager:CreateTimer(self, "ActiveLoginDelayTimer", 0.1, nil, self.OnTimerComplete, 9999)
  elseif "Login" == curLevelName and (RocoEnv.PLATFORM == "PLATFORM_WINDOWS" or RocoEnv.PLATFORM == "PLATFORM_MAC") then
    self.ActiveLoginDelayTimer = _G.TimerManager:CreateTimer(self, "ActiveLoginDelayTimer", 0.1, nil, self.OnTimerComplete, 9999)
  elseif not UE4.UNRCStatics.IsEditor() and (RocoEnv.PLATFORM == "PLATFORM_WINDOWS" or RocoEnv.PLATFORM == "PLATFORM_MAC") then
    self.ActiveLoginDelayTimer = _G.TimerManager:CreateTimer(self, "ActiveLoginDelayTimer", 0.1, nil, self.OnTimerComplete, 9999)
  elseif RocoEnv.PLATFORM ~= "PLATFORM_WINDOWS" then
    self:RegisterMapChangeCompleteEvent()
  end
end

function NRCModeEntrance:OnTimerComplete()
  self:ActiveModeByCurLevel()
  _G.TimerManager:RemoveTimer(self.ActiveLoginDelayTimer)
end

return NRCModeEntrance
