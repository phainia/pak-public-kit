local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local DebugTabPlayerMoveRecord = Base:Extend("DebugTabPlayerMoveRecord")

function DebugTabPlayerMoveRecord:Ctor()
  Base.Ctor(self)
end

function DebugTabPlayerMoveRecord:SetupTabs()
end

function DebugTabPlayerMoveRecord:ChangeAutoCamera()
  GlobalConfig.AutoCamera = not GlobalConfig.AutoCamera
end

function DebugTabPlayerMoveRecord:CreateTestPlayer()
  local gender = self:GetInputNumber(GlobalConfig.CharacterIndex)
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule:CreateTestPlayer(gender)
  local testPlayer = playerModule:GetTestPlayer()
  if testPlayer then
    return testPlayer.viewObj
  end
end

function DebugTabPlayerMoveRecord:StartMoveRecord()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule.movementRecorder:StartRecord()
end

function DebugTabPlayerMoveRecord:StopMoveRecord()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule.movementRecorder:StopRecord()
end

function DebugTabPlayerMoveRecord:StartMoveRecordLocal()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule.movementRecorder:StartRecordLocal()
end

function DebugTabPlayerMoveRecord:StopMoveRecordLocal()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule.movementRecorder:StopRecordLocal()
end

function DebugTabPlayerMoveRecord:GetMoveRecord()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local data = playerModule.movementRecorder:GetRecord("ReplicateMoveData.json")
  Log.Debug("GetMoveRecord data:")
  Log.Dump(data)
  local testPlayer = playerModule:GetTestPlayer()
  local nativeMovementComponent = testPlayer.viewObj.CharacterMovement
  if testPlayer:HasStatus(Enum.WorldPlayerStatusType.WPST_RIDEALL) then
    local ridePawn = self.owner.viewObj.BP_RideComponent.RidePet
    if ridePawn then
      nativeMovementComponent = ridePawn.CharacterReplicateMovement
    end
  end
  for i = 1, #data do
    local moveData = data[i]
    local targetPos = SceneUtils.ServerPos2ClientPos(moveData.to_pos)
    local targetRot = SceneUtils.ServerPos2ClientRotator(moveData.to_rot)
    local velocity = SceneUtils.ServerPos2ClientPos(moveData.speed)
    local acceleration = SceneUtils.ServerPos2ClientPos(moveData.acceleration)
    local moveMode = moveData.move_mode
    local timeStamp = moveData.time_stamp
    nativeMovementComponent:ReplicateMoveData(targetPos, targetRot, moveMode, velocity, acceleration, timeStamp)
  end
end

function DebugTabPlayerMoveRecord:GetSendMoveRecord()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local data = playerModule.movementRecorder:GetRecord("SendMoveData.json")
  local testPlayer = playerModule:GetTestPlayer()
  local nativeMovementComponent = testPlayer.viewObj.CharacterMovement
  if testPlayer.statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_RIDEALL) then
    local ridePawn = self.owner.viewObj.BP_RideComponent.RidePet
    if ridePawn then
      nativeMovementComponent = ridePawn.CharacterReplicateMovement
    end
  end
  for i = 1, #data do
    local moveData = data[i]
    local targetPos = SceneUtils.ServerPos2ClientPos(moveData.to_pos)
    local targetRot = SceneUtils.ServerPos2ClientRotator(moveData.to_rot)
    local velocity = SceneUtils.ServerPos2ClientPos(moveData.speed)
    local acceleration = SceneUtils.ServerPos2ClientPos(moveData.acceleration)
    local moveMode = moveData.move_mode
    local timeStamp = moveData.time_stamp
    nativeMovementComponent:ReplicateMoveData(targetPos, targetRot, moveMode, velocity, acceleration, timeStamp)
  end
end

function DebugTabPlayerMoveRecord:StartAutoMove()
  local debugModule = NRCModuleManager:GetModule("DebugModule")
  debugModule:StartAutoMove()
end

function DebugTabPlayerMoveRecord:StopAutoMove()
  local debugModule = NRCModuleManager:GetModule("DebugModule")
  debugModule:StopAutoMove()
end

function DebugTabPlayerMoveRecord:StartMainPlayerAutoMove()
  local debugModule = NRCModuleManager:GetModule("DebugModule")
  debugModule:StartMainPlayerAutoMove()
end

function DebugTabPlayerMoveRecord:ResetToBornPos()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local localPlayer = playerModule.playerModuleData.localPlayer
  localPlayer:SetActorLocation(playerModule._bornPos)
end

function DebugTabPlayerMoveRecord:ForceReconnect()
  ZoneServer:OpenDialog(LuaText.TIPS, "", LuaText.RETRY, LuaText.BACK, DialogContext.Mode.OK_CANCEL, ZoneServer.OnDialogResult, "")
  _G.DelayManager:DelayFrames(1, ZoneServer.DisConnect, ZoneServer)
end

function DebugTabPlayerMoveRecord:ToggleSyncMovement()
  GlobalConfig.SyncMovement = not GlobalConfig.SyncMovement
end

function DebugTabPlayerMoveRecord:DebugVisibleZoneInfo()
  GlobalConfig.DebugVisibleZoneInfo = not GlobalConfig.DebugVisibleZoneInfo
  if GlobalConfig.DebugVisibleZoneInfo then
    UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), "\229\188\128\229\144\175\230\152\190\231\164\186\229\143\175\232\167\129\229\140\186\228\191\161\230\129\175", true, true, UE4.FLinearColor(0, 1, 0, 1), 5)
  else
    UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), "\229\133\179\233\151\173\230\152\190\231\164\186\229\143\175\232\167\129\229\140\186\228\191\161\230\129\175", true, true, UE4.FLinearColor(0, 1, 0, 1), 5)
  end
end

function DebugTabPlayerMoveRecord:SetPlayerRotation(Name, Panel)
  local Player = self:GetPlayer()
  local Yaw = self:GetInputNumber(0)
  Player:SetActorRotation(UE.FRotator(0, Yaw, 0))
end

function DebugTabPlayerMoveRecord:SetCameraRotation(Name, Panel)
  local Player = self:GetPlayer()
  local Controller = Player:GetUEController()
  local Yaw = self:GetInputNumber(0)
  Controller:SetControlRotation(UE.FRotator(0, Yaw, 0))
end

function DebugTabPlayerMoveRecord:ShowMultipleArea(Name, Panel)
  local areaConfTable = _G.DataConfigManager:GetAllByName("AREA_VISIBLE_CONF")
  local allShowMultipleArea = _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.GetAllShowMultipleArea)
  if not allShowMultipleArea[1] then
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.SetAllShowMultipleArea, areaConfTable)
    local airWallMaterial = "MaterialInstanceConstant'/Game/ArtRes/Effects/Texture/Noise/Material/MI_Noise_01_MJ2.MI_Noise_01_MJ2'"
    if not GlobalConfig.IsShowMultipleArea then
      for i, area in pairs(areaConfTable) do
        _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.DisplayVisualWall, area.id, airWallMaterial)
      end
    else
      for i, area in pairs(areaConfTable) do
        _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.HideVisualWall, area.id, airWallMaterial)
      end
    end
  else
    local airWallMaterial = "MaterialInstanceConstant'/Game/ArtRes/Effects/Texture/Noise/Material/MI_Noise_01_MJ2.MI_Noise_01_MJ2'"
    if not GlobalConfig.IsShowMultipleArea then
      for i, area in pairs(allShowMultipleArea) do
        _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.DisplayVisualWall, area.id, airWallMaterial)
      end
    else
      for i, area in pairs(allShowMultipleArea) do
        _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.HideVisualWall, area.id, airWallMaterial)
      end
    end
  end
  GlobalConfig.IsShowMultipleArea = not GlobalConfig.IsShowMultipleArea
end

function DebugTabPlayerMoveRecord:SpeedUpTo()
  local Player = self:GetPlayer()
  local Speed = self:GetInputNumber(0)
  if Player and UE.UObject.IsValid(Player.viewObj) then
    Player.viewObj.CharacterMovement:SpeedUpTo(Speed)
  end
end

return DebugTabPlayerMoveRecord
