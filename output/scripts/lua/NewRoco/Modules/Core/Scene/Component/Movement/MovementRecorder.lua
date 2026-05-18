local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local RapidJson = require("rapidjson")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local MovementRecorder = Class()

function MovementRecorder:Ctor()
  local dir = UE4.UBlueprintPathsLibrary.HasProjectPersistentDownloadDir() and UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir()
  if not UE4.UBlueprintPathsLibrary.DirectoryExists(dir) then
    dir = UE4.UBlueprintPathsLibrary.ProjectSavedDir()
  end
  Log.Debug("MovementRecorder save dir ", dir)
  self.saveDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(dir)
  Log.Debug("MovementRecorder save full dir ", self.saveDir)
end

function MovementRecorder:StartRecord()
  self.data = {}
  self.send_data = {}
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  if playerModule then
    playerModule:RegisterEvent(self, PlayerModuleEvent.ON_RECEIVE_MOVE_DATA, self.Record)
    playerModule:RegisterEvent(self, PlayerModuleEvent.ON_SEND_MOVE_DATA, self.RecordSendMove)
  end
end

function MovementRecorder:Record(data)
  local playerUin = data.actor_id
  if not self.uin then
    self.uin = playerUin
  end
  if self.uin == playerUin and 0 ~= data.move_mode then
    local newData = {}
    newData.to_pos = data.to_pos
    newData.to_rot = data.to_rot
    newData.speed = data.speed
    newData.acceleration = data.acceleration
    newData.move_mode = data.move_mode
    newData.custom_mode = data.custom_mode
    newData.time_stamp = data.time_stamp
    table.insert(self.data, newData)
  end
end

function MovementRecorder:RecordSendMove(data)
  if not self.uin then
    self.uin = 0
  end
  if 0 ~= data.move_mode then
    local newData = {}
    newData.to_pos = data.to_pos
    newData.to_rot = data.to_rot
    newData.speed = data.speed
    newData.acceleration = data.acceleration
    newData.move_mode = data.move_mode
    newData.time_stamp = data.time_stamp
    table.insert(self.send_data, newData)
  end
end

function MovementRecorder:StopRecord()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  if playerModule then
    playerModule:UnRegisterEvent(self, PlayerModuleEvent.ON_RECEIVE_MOVE_DATA)
    playerModule:UnRegisterEvent(self, PlayerModuleEvent.ON_SEND_MOVE_DATA)
  end
  local fileName = string.format("%s%s.json", self.saveDir, "/ReplicateMoveData")
  RapidJson.dump(self.data, fileName)
  self.data = nil
  self.uin = nil
  local sendFileName = string.format("%s%s.json", self.saveDir, "/SendMoveData")
  RapidJson.dump(self.send_data, sendFileName)
  self.send_data = nil
end

function MovementRecorder:StartRecordLocal()
  self.data = {}
  self.send_data = {}
  local debugModule = NRCModuleManager:GetModule("DebugModule")
  if debugModule then
    debugModule:StartRecordLocal()
  end
end

function MovementRecorder:RecordLocal()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return
  end
  local nativeMovementComponent = localPlayer.ueController.Pawn.CharacterMovement
  local moveMode = nativeMovementComponent.MovementMode
  if moveMode == UE4.EMovementMode.MOVE_None then
    moveMode = UE4.EMovementMode.MOVE_Custom
  end
  local updatedComponent = nativeMovementComponent.UpdatedComponent
  local newData = {}
  local location = updatedComponent:Abs_K2_GetComponentLocation()
  newData.to_pos = SceneUtils.ClientPos2ServerPos(location)
  local rotation = updatedComponent:K2_GetComponentRotation()
  newData.to_rot = SceneUtils.ClientRotator2ServerPos(rotation)
  newData.speed = SceneUtils.ClientPos2ServerPos(nativeMovementComponent.Velocity)
  newData.acceleration = SceneUtils.ClientPos2ServerPos(nativeMovementComponent:GetCurrentAcceleration())
  newData.time_stamp = UE4.UNRCStatics.GetTimestampMS()
  newData.cam_rot = SceneUtils.ClientRotator2ServerPos(localPlayer.ueController:GetControlRotation())
  table.insert(self.data, newData)
  table.insert(self.send_data, newData)
end

function MovementRecorder:StopRecordLocal()
  local debugModule = NRCModuleManager:GetModule("DebugModule")
  if debugModule then
    debugModule:StopRecordLocal()
  end
  local fileName = string.format("%s%s.json", self.saveDir, "/ReplicateMoveData")
  RapidJson.dump(self.data, fileName)
  self.data = nil
  self.uin = nil
  local sendFileName = string.format("%s%s.json", self.saveDir, "/SendMoveData")
  RapidJson.dump(self.send_data, sendFileName)
  self.send_data = nil
end

function MovementRecorder:GetRecord(fileName)
  local filePath = string.format("%s/%s", self.saveDir, fileName)
  local data = RapidJson.uload(filePath)
  return data
end

return MovementRecorder
