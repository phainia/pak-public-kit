local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local DebugTabPlayerCamera = Base:Extend("DebugTabPlayerCamera")

function DebugTabPlayerCamera:SetupTabs()
  self:Add("\230\139\183\232\180\157\229\189\147\229\137\141\233\149\156\229\164\180", self.CopyCurCameraParams, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\136\135\230\141\162\232\135\170\229\174\154\228\185\137", self.SwitchCustomCamera, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\166\134\231\155\150\229\133\168\233\135\143\230\149\176\230\141\174", self.SetAll, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\152\190\231\164\186\231\155\174\230\160\135\229\143\138\231\188\147\229\138\168", self.SwitchDebug, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("FOV", self.SetFOV, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\155\174\230\160\135\229\129\143\231\167\187X", self.SetPivotOffsetX, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\155\174\230\160\135\229\129\143\231\167\187Y", self.SetPivotOffsetY, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\155\174\230\160\135\229\129\143\231\167\187Z", self.SetPivotOffsetZ, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\149\156\229\164\180\229\129\143\231\167\187X", self.SetCameraOffsetX, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\149\156\229\164\180\229\129\143\231\167\187Y", self.SetCameraOffsetY, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\149\156\229\164\180\229\129\143\231\167\187Z", self.SetCameraOffsetZ, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\188\147\229\138\168\233\128\159\229\186\166X", self.SetPivotLagSpeedX, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\188\147\229\138\168\233\128\159\229\186\166Y", self.SetPivotLagSpeedY, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\188\147\229\138\168\233\128\159\229\186\166Z", self.SetPivotLagSpeedZ, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\151\139\232\189\172\231\188\147\229\138\168\233\128\159\229\186\166", self.SetRotationLagSpeed, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\149\156\229\164\180\230\151\139\232\189\172Pitch", self.SetRotationOffsetPitch, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\149\156\229\164\180\230\151\139\232\189\172Yaw", self.SetRotationOffsetYaw, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\149\156\229\164\180\230\151\139\232\189\172Roll", self.SetRotationOffsetRoll, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\174\190\231\189\174\233\149\156\229\164\180\231\129\181\230\149\143\229\186\166", self.ChangeCameraRotateSetting, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\133\179\231\155\184\230\156\186\231\149\153\229\189\177\230\168\161\229\188\143", self.ChangeCameraFilmMode, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabPlayerCamera:GetCamera()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local CameraManager = localPlayer:GetUEController().PlayerCameraManager
  return CameraManager:GetCameraAnimInstance()
end

function DebugTabPlayerCamera:GetCurCameraParams()
  local Camera = self:GetCamera()
  local CameraParams = {}
  CameraParams.GM_FOV = Camera:GetCurveValue("FOV")
  CameraParams.GM_PivotOffset_X = Camera:GetCurveValue("PivotOffset_X")
  CameraParams.GM_PivotOffset_Y = Camera:GetCurveValue("PivotOffset_Y")
  CameraParams.GM_PivotOffset_Z = Camera:GetCurveValue("PivotOffset_Z")
  CameraParams.GM_CameraOffset_X = Camera:GetCurveValue("CameraOffset_X")
  CameraParams.GM_CameraOffset_Y = Camera:GetCurveValue("CameraOffset_Y")
  CameraParams.GM_CameraOffset_Z = Camera:GetCurveValue("CameraOffset_Z")
  CameraParams.GM_PivotLagSpeed_X = Camera:GetCurveValue("PivotLagSpeed_X")
  CameraParams.GM_PivotLagSpeed_Y = Camera:GetCurveValue("PivotLagSpeed_Y")
  CameraParams.GM_PivotLagSpeed_Z = Camera:GetCurveValue("PivotLagSpeed_Z")
  CameraParams.GM_RotationLagSpeed = Camera:GetCurveValue("RotationLagSpeed")
  CameraParams.GM_RotationOffset_Pitch = Camera:GetCurveValue("RotationOffsetPitch")
  CameraParams.GM_RotationOffset_Roll = Camera:GetCurveValue("RotationOffsetRoll")
  CameraParams.GM_RotationOffset_Yaw = Camera:GetCurveValue("RotationOffsetYaw")
  return CameraParams
end

function DebugTabPlayerCamera:CopyCurCameraParams()
  local table_to_lua_string = function(tbl, indent)
    indent = indent or ""
    local lua_str = "{\n"
    for k, v in pairs(tbl) do
      lua_str = lua_str .. indent .. "    [\"" .. tostring(k) .. "\"] = "
      if type(v) == "table" then
        lua_str = lua_str .. table_to_lua_string(v, indent .. "    ") .. ",\n"
      else
        lua_str = lua_str .. tostring(v) .. ",\n"
      end
    end
    lua_str = lua_str .. indent .. "}"
    return lua_str
  end
  local Params = self:GetCurCameraParams()
  local CopyText = table_to_lua_string(Params)
  UE4.UNRCStatics.ClipboardCopy(CopyText)
end

function DebugTabPlayerCamera:SwitchCustomCamera(name, panel)
  local Camera = self:GetCamera()
  local Params = self:GetCurCameraParams()
  for key, value in pairs(Params) do
    Camera[key] = value
  end
  Camera.GM_Camera = not Camera.GM_Camera
  Log.Error(Camera.GM_Camera and "\232\135\170\229\174\154\228\185\137\230\168\161\229\188\143" or "\232\191\152\229\142\159\231\155\184\230\156\186")
end

function DebugTabPlayerCamera:SwitchDebug(name, panel)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local CameraManager = localPlayer:GetUEController().PlayerCameraManager
  CameraManager.bDebug = not CameraManager.bDebug
end

function DebugTabPlayerCamera:SetAll(name, panel)
  local function lua_string_to_table(lua_str)
    local func, err = load("return " .. lua_str)
    
    if not func then
      error(err)
    end
    return func()
  end
  
  local Camera = self:GetCamera()
  local Text = panel.InputBox:GetText()
  local Params = lua_string_to_table(Text)
  for key, value in pairs(Params) do
    Camera[key] = value
  end
end

function DebugTabPlayerCamera:SetFOV(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_FOV = newValue
end

function DebugTabPlayerCamera:SetPivotOffsetX(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_PivotOffset_X = newValue
end

function DebugTabPlayerCamera:SetPivotOffsetY(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_PivotOffset_Y = newValue
end

function DebugTabPlayerCamera:SetPivotOffsetZ(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_PivotOffset_Z = newValue
end

function DebugTabPlayerCamera:SetCameraOffsetX(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_CameraOffset_X = newValue
end

function DebugTabPlayerCamera:SetCameraOffsetY(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_CameraOffset_Y = newValue
end

function DebugTabPlayerCamera:SetCameraOffsetZ(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_CameraOffset_Z = newValue
end

function DebugTabPlayerCamera:SetPivotLagSpeedX(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_PivotLagSpeed_X = newValue
end

function DebugTabPlayerCamera:SetPivotLagSpeedY(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_PivotLagSpeed_Y = newValue
end

function DebugTabPlayerCamera:SetPivotLagSpeedZ(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_PivotLagSpeed_Z = newValue
end

function DebugTabPlayerCamera:SetRotationLagSpeed(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_RotationLagSpeed = newValue
end

function DebugTabPlayerCamera:SetRotationOffsetPitch(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_RotationOffset_Pitch = newValue
end

function DebugTabPlayerCamera:SetRotationOffsetRoll(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_RotationOffset_Roll = newValue
end

function DebugTabPlayerCamera:SetRotationOffsetYaw(name, panel)
  local newValue = panel:GetInputNumber()
  local Camera = self:GetCamera()
  Camera.GM_RotationOffset_Yaw = newValue
end

function DebugTabPlayerCamera:ChangeCameraRotateSetting(name, panel)
  local inputText = panel.InputBox:GetText()
  local params = string.split(inputText, ",")
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  if tonumber(params[1]) then
    _G.UserSettingManager.camera_rotate_yaw = tonumber(params[1]) / 1000
    _G.UserSettingManager.camera_rotate_yaw_pc = tonumber(params[1]) / 10
  end
  if tonumber(params[2]) then
    _G.UserSettingManager.camera_rotate_pitch = tonumber(params[2]) / 1000
    _G.UserSettingManager.camera_rotate_pitch_pc = tonumber(params[2]) / 10
  end
  if tonumber(params[3]) then
    _G.UserSettingManager.camera_rotate_aim_yaw = tonumber(params[3]) / 1000
  end
  if tonumber(params[4]) then
    _G.UserSettingManager.camera_rotate_aim_pitch = tonumber(params[4]) / 1000
  end
  if playerModule.playerModuleData.localPlayer then
    playerModule.playerModuleData.localPlayer:GetUEController().PlayerCameraManager:RefreshPCCameraRotateSetting()
  end
end

function DebugTabPlayerCamera:ChangeCameraFilmMode(name, Panel)
  local newPlayer = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Panel then
    local players = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_ALL_PLAYER)
    for _, v in pairs(players) do
      if v.serverData.base.logic_id == Panel:GetInputNumber() then
        newPlayer = v
        break
      end
    end
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerCameraManager = localPlayer:GetUEController().PlayerCameraManager
  if playerCameraManager and newPlayer then
    if playerCameraManager.ECurrentFilmingMode == UE.EFilmingMode.None then
      playerCameraManager:BeginFilming(newPlayer.viewObj)
    else
      playerCameraManager:EndFilming()
    end
  end
end

return DebugTabPlayerCamera
