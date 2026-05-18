local Base = require("Common.Singleton.Singleton")
local JsonUtils = require("Common.JsonUtils")
local UserSettingManager = Base:Extend("UserSettingManager")

function UserSettingManager:Ctor(name)
  self.name = name or "UserSettingManager"
  Base.Ctor(self, self.name)
  self:InitCameraRotateSetting()
  self:InitDialogueSetting()
end

function UserSettingManager:Free()
  Base.Free(self)
end

function UserSettingManager:InitCameraRotateSetting()
  self.camera_rotate_yaw = 0.065
  self.camera_rotate_yaw_pc = 0.065
  self.camera_rotate_pitch = 0.025
  self.camera_rotate_pitch_pc = 0.025
  self.camera_rotate_aim_yaw = 0.065
  self.camera_rotate_aim_pitch = 0.025
  local _SoundConfigFilename = "NrcSoundConfig"
  local soundConfig = JsonUtils.LoadSaved(_SoundConfigFilename, {})
  local SettingValue
  SettingValue = soundConfig.HorizontalLens or 6
  self:ChangeCameraRotateSetting("HorizontalLens", SettingValue)
  SettingValue = soundConfig.VerticalLens or 6
  self:ChangeCameraRotateSetting("VerticalLens", SettingValue)
  SettingValue = soundConfig.HorizontalLensAim or 6
  self:ChangeCameraRotateSetting("HorizontalLensAim", SettingValue)
  SettingValue = soundConfig.VerticalLensAim or 6
  self:ChangeCameraRotateSetting("VerticalLensAim", SettingValue)
end

function UserSettingManager:InitDialogueSetting()
  local ConfigFilename = "NrcDialogueLocalConfig"
  local Config = JsonUtils.LoadSaved(ConfigFilename, {})
  self.bDialogueAutoPlay = Config.bAutoPlay or false
  self.DialogueAutoPlayChangedCallback = {}
end

function UserSettingManager:IsDialogueAutoPlayOn()
  return self.bDialogueAutoPlay or false
end

function UserSettingManager:SetDialogueAutoPlay(InBool)
  if self.bDialogueAutoPlay == InBool then
    return
  end
  self.bDialogueAutoPlay = InBool
  local ConfigFilename = "NrcDialogueLocalConfig"
  local Config = {
    bAutoPlay = self.bDialogueAutoPlay
  }
  JsonUtils.DumpSaved(ConfigFilename, Config)
  for _, CallPair in pairs(self.DialogueAutoPlayChangedCallback) do
    CallPair.callback(CallPair.caller)
  end
end

function UserSettingManager:RegisterDialogueAutoPlayChangedCallback(caller, callback)
  self.AutoPlayChangedCallbackID = self.AutoPlayChangedCallbackID or 1
  self.DialogueAutoPlayChangedCallback[self.AutoPlayChangedCallbackID] = {caller = caller, callback = callback}
  self.AutoPlayChangedCallbackID = self.AutoPlayChangedCallbackID + 1
  return self.AutoPlayChangedCallbackID - 1
end

function UserSettingManager:UnregisterDialogueAutoPlayChangedCallback(ID)
  if ID and ID > 0 then
    self.DialogueAutoPlayChangedCallback[ID] = nil
  end
end

function UserSettingManager:ChangeCameraRotateSetting(name, value)
  if "HorizontalLens" == name then
    self.camera_rotate_yaw = self:SafeGetConfig("camera_rotate_speed_yaw", value + 1, 65) / 1000
    self.camera_rotate_yaw_pc = self:SafeGetConfig("camera_rotate_speed_yaw_pc", value + 1, 65) / 500
  end
  if "VerticalLens" == name then
    self.camera_rotate_pitch = self:SafeGetConfig("camera_rotate_speed_pitch", value + 1, 25) / 1000
    self.camera_rotate_pitch_pc = self:SafeGetConfig("camera_rotate_speed_pitch_pc", value + 1, 25) / 500
  end
  if "HorizontalLensAim" == name then
    self.camera_rotate_aim_yaw = self:SafeGetConfig("camera_rotate_aim_speed_yaw", value + 1, 65) / 1000
  end
  if "VerticalLensAim" == name then
    self.camera_rotate_aim_pitch = self:SafeGetConfig("camera_rotate_aim_speed_pitch", value + 1, 25) / 1000
  end
  if PlayerModuleCmd then
    local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      localPlayer:GetUEController().PlayerCameraManager:RefreshPCCameraRotateSetting()
    end
  end
end

function UserSettingManager:SafeGetConfig(name, key, default)
  default = default or 50
  if not (name and key and _G.DataConfigManager) or not _G.DataConfigManager.GetGlobalConfig then
    return default
  end
  local tempConfig = _G.DataConfigManager:GetGlobalConfig(name)
  if not tempConfig or not tempConfig.numList then
    return default
  end
  if not tempConfig.numList[key] then
    return default
  end
  return tempConfig.numList[key]
end

return UserSettingManager
