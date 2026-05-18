local JsonUtils = require("Common.JsonUtils")
local DebugTabPlayerCamera = require("NewRoco.Modules.System.Debug.Tabs.DebugTabPlayerCamera")
local DebugTabScenePublic = require("NewRoco.Modules.System.Debug.Tabs.DebugTabScenePublic")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local TeleportCachePsoAutomation = {}
local configFileName = "TeleportCachePSO"
local SpinSpeed = 90
local SwitchInterval = 4
local bigWorldName = "/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release"

function TeleportCachePsoAutomation:Reset()
  if self.cacheVisitInfos == nil then
    self:ReadVisitInfos()
  end
  if nil == self.worldTable then
    self.worldTable = _G.DataConfigManager:GetAllByTableID(_G.DataConfigManager.ConfigTableId.SCENE_RES_CONF)
    for _, conf in pairs(self.worldTable) do
      if not conf.is_unused then
        Log.Info(conf.source)
      end
    end
  end
  self.player = nil
  self.currentVisitIndex = 1
end

function TeleportCachePsoAutomation:ReadVisitInfos()
  local config = JsonUtils.LoadSaved(configFileName)
  if not config then
    Log.Error("Failed to load TeleportCachePSO config file")
    return
  end
  self.cacheVisitInfos = config.VisitInfo
end

function TeleportCachePsoAutomation:InitPlayer()
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.player or not self.player.ueController then
    Log.Error("Failed to get local player")
    return
  end
  self.player:SetViewVisible(false, true)
  self.player.ueController.PlayerCameraManager.bEnableMainUICamera = true
end

function TeleportCachePsoAutomation:ProcessVisitInfo()
  if self.currentVisitIndex == #self.cacheVisitInfos + 1 then
    self:OnProcessEnd()
    return
  end
  local info = self.cacheVisitInfos[self.currentVisitIndex]
  local array = string.split(info, ",")
  local maxLodNum = array[1]
  local actorName = array[2]
  Log.Debug(string.format("[PSO] \229\189\147\229\137\141\232\191\155\229\186\166 \227\128\144%d/%d\227\128\145 %s", self.currentVisitIndex, #self.cacheVisitInfos, actorName))
  local worldPackageName = array[3]
  local validWorldPackageName = self:GetValidWorldPackageName(worldPackageName)
  if not validWorldPackageName then
    self.currentVisitIndex = self.currentVisitIndex + 1
    Log.Warning(string.format("[PSO] \230\151\160\230\149\136\231\154\132\228\184\150\231\149\140\229\140\133\229\144\141 \227\128\144%s\227\128\145", worldPackageName))
    self:ProcessVisitInfo()
    return
  end
  if self.currentWorldPackageName ~= validWorldPackageName then
    self.currentWorldPackageName = validWorldPackageName
    _G.NRCEventCenter:RegisterEvent("TeleportCachePsoAutomation", self, _G.SceneEvent.LoadMapFinish, self.OnSceneReady)
    NRCModuleManager:DoCmd(PlayerModuleCmd.CLEAR_ALL)
    self.player = nil
    LevelHelper:OpenLevel(validWorldPackageName)
    return
  end
  local boundInfo = array[4]
  local boundArray = string.split(boundInfo, "#")
  local boundMinX = tonumber(boundArray[1])
  local boundMinY = tonumber(boundArray[2])
  local boundMinZ = tonumber(boundArray[3])
  local boundMaxX = tonumber(boundArray[4])
  local boundMaxY = tonumber(boundArray[5])
  local boundMaxZ = tonumber(boundArray[6])
  local centerX = (boundMinX + boundMaxX) / 2
  local centerY = (boundMinY + boundMaxY) / 2
  local centerZ = (boundMinZ + boundMaxZ) / 2
  if math.abs(centerX) < 0.1 and math.abs(centerY) < 0.1 and math.abs(centerZ) < 0.1 then
    Log.Warning("Invalid bound info")
    self.currentVisitIndex = self.currentVisitIndex + 1
    self:ProcessVisitInfo()
    return
  end
  self.player.viewObj:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(centerX, centerY, centerZ), false, false)
  local sizeX = boundMaxX - boundMinX
  local sizeY = boundMaxY - boundMinY
  local sizeZ = boundMaxZ - boundMinZ
  local maxSize = math.abs(math.max(sizeX, sizeY, sizeZ))
  local CameraInstance = self.player.ueController.PlayerCameraManager:GetCameraAnimInstance()
  CameraInstance.GM_CameraOffset_X = maxSize * -2
  local SwitchLodInterval = SwitchInterval / maxLodNum
  for i = 0, maxLodNum - 1 do
    _G.DelayManager:DelaySeconds(SwitchLodInterval * i, function()
      UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), string.format("r.ForceLOD %d", i))
    end)
  end
  _G.DelayManager:DelaySeconds(SwitchInterval, function()
    self:ProcessVisitInfo()
  end)
  self.currentVisitIndex = self.currentVisitIndex + 1
end

function TeleportCachePsoAutomation:OnSceneReady()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.LoadMapFinish, self.OnSceneReady)
  _G.DelayManager:DelaySeconds(3, function()
    self:InitPlayer()
    self:ProcessVisitInfo()
  end)
end

function TeleportCachePsoAutomation:Start()
  NRCEventCenter:RegisterEvent("CinematicAutomation", self, SceneEvent.BigWorldPrepared, self.OnSceneInit)
  _G.NRCBigWorldPreloader:StartPreload(nil, function()
    NRCModeManager:ActiveMode("LocalMode")
    LevelHelper:OpenLevel(bigWorldName)
  end)
  self.currentWorldPackageName = bigWorldName
end

function TeleportCachePsoAutomation:OnSceneInit()
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.BigWorldPrepared, self.OnSceneInit)
  _G.DelayManager:DelaySeconds(3, function()
    self:Reset()
    DebugTabPlayerCamera:SwitchCustomCamera(nil, nil)
    DebugTabScenePublic:GhostMode()
    self:InitPlayer()
    self:ProcessVisitInfo()
    _G.UpdateManager:Register(self)
  end)
end

function TeleportCachePsoAutomation:GetValidWorldPackageName(worldPackageName)
  if string.StartsWith(worldPackageName, "/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/") then
    return bigWorldName
  end
  for _, conf in pairs(self.worldTable) do
    if conf.source == worldPackageName then
      if conf.is_unused then
        return nil
      end
      return conf.source
    end
  end
  return nil
end

function TeleportCachePsoAutomation:OnProcessEnd()
  _G.UpdateManager:UnRegister(self)
  DebugTabPlayerCamera:SwitchCustomCamera(nil, nil)
  DebugTabScenePublic:GhostMode()
  self.player:SetViewVisible(true, true)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.ForceLOD -1")
end

function TeleportCachePsoAutomation:OnTick(dt)
  if not self.player then
    return
  end
  self.player.ueController.Pawn:AddControllerYawInput(dt * SpinSpeed)
end

return TeleportCachePsoAutomation
