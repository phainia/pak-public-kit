local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local QuickTeleport = Class()

function QuickTeleport:Ctor()
  self.Teleporting = false
  self.LastCheckTime = -1
  self.WorldToCheck = nil
  self.Block = false
  self.SendReq = true
end

function QuickTeleport:Go(AbsPos, Caller, Callback, ...)
  self:FireCallback(false)
  self.Caller = Caller
  self.Callback = Callback
  self.Args = table.pack(...)
  if not AbsPos then
    self:FireCallback(false)
    return
  end
  self:PreTeleport()
  local Player = self:GetPlayer()
  self:ToggleMovement(Player, false)
  self:TeleportCharacter(Player, AbsPos)
  self:CheckLevelReady()
end

function QuickTeleport:LevelLoaded()
  local Player = self:GetPlayer()
  self:ToggleMovement(Player, true)
  self:PostTeleport()
  self:FireCallback(true)
end

function QuickTeleport:PreTeleport()
  local Player = self:GetPlayer()
  Player.inputComponent:SetInputEnable(self, false)
  Player.inputComponent:SetCameraControlEnable(self, false)
  if Player.viewObj then
    Player.viewObj.CharacterMovement:ConsumeInputVector()
    Player.viewObj.CharacterMovement:ConsumeInputVector()
  end
  GlobalConfig.SyncMovement = false
  UE4.UNRCStatics.ChangeLevelStreamingMode(1)
  self.Teleporting = true
  _G.ZoneServer:Pause()
  _G.FunctionBanManager:AddPlayerConditionType(Enum.PlayerConditionType.PCT_TELEPORT, "QuickTeleport")
end

function QuickTeleport:PostTeleport()
  self.Teleporting = false
  _G.FunctionBanManager:RemovePlayerConditionType(Enum.PlayerConditionType.PCT_TELEPORT, "QuickTeleport")
  self:ResetCamera()
  if self.SendReq then
    local Player = self:GetPlayer()
    self:SendTeleportReq(Player)
  end
  UE4.UNRCStatics.ChangeLevelStreamingMode(0)
  _G.ZoneServer:Resume()
  local Player = self:GetPlayer()
  Player.inputComponent:SetInputEnable(self, true)
  Player.inputComponent:SetCameraControlEnable(self, true)
  GlobalConfig.SyncMovement = true
end

function QuickTeleport:FireCallback(Success)
  local Caller = self.Caller
  local Callback = self.Callback
  local Args = self.Args
  self.Callback = nil
  self.Caller = nil
  self.Args = nil
  if not Callback then
    return
  end
  if Caller then
    Callback(Caller, Success, table.unpack(Args))
  else
    Callback(Success, table.unpack(Args))
  end
end

function QuickTeleport:ToggleMovement(Character, Enabled)
  if not Character then
    return
  end
  if not Character.viewObj then
    return
  end
  if Character.isLocal then
    Character:SetCharacterMovementTickEnable(self, Enabled)
  else
    local Movement = Character.viewObj.CharacterMovement
    if Movement then
      Movement:SetComponentTickEnabled(Enabled)
    end
  end
end

function QuickTeleport:TeleportCharacter(Character, Pos)
  local CharacterMovement = Character.viewObj and Character.viewObj.CharacterMovement
  if CharacterMovement then
    CharacterMovement.UpdatedComponent:Abs_K2_SetWorldLocation(Pos, false, nil, false)
  else
    Character:SetActorLocation(Pos)
  end
end

function QuickTeleport:SendTeleportReq(Player, Caller, Callback)
  Log.Error("Start Set Player Location")
  local nativeMovementComponent = Player.ueController.Pawn.CharacterMovement
  local MoveReq = _G.ProtoMessage:newZoneSceneMoveReq()
  local moveMode = nativeMovementComponent.MovementMode
  if moveMode == UE.EMovementMode.MOVE_None then
    moveMode = UE.EMovementMode.MOVE_Custom
  end
  MoveReq.move_mode = moveMode
  MoveReq.custom_mode = nativeMovementComponent.CustomMovementMode
  local updatedComponent = nativeMovementComponent.UpdatedComponent
  local location = updatedComponent:Abs_K2_GetComponentLocation()
  MoveReq.to_pos = SceneUtils.ClientPos2ServerPos(location)
  local rotation = updatedComponent:K2_GetComponentRotation()
  MoveReq.to_rot = SceneUtils.ClientRotator2ServerPos(rotation)
  MoveReq.speed = SceneUtils.ClientPos2ServerPos(nativeMovementComponent.Velocity)
  MoveReq.acceleration = SceneUtils.ClientPos2ServerPos(nativeMovementComponent:GetCurrentAcceleration())
  MoveReq.time_stamp = _G.ZoneServer:GetServerTime()
  if Caller and Callback then
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MOVE_REQ, MoveReq, Caller, Callback)
  else
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MOVE_REQ, MoveReq, self, self.DefaultReportCallback)
  end
end

function QuickTeleport:DefaultReportCallback(Rsp)
  Log.Error("Move Rsp", Rsp.ret_info.ret_code)
end

function QuickTeleport:CheckLevelReady(World)
  World = World or _G.UE4Helper.GetCurrentWorld()
  UE.UNRCStatics.ForceTickCamera(1)
  UE.UNRCStatics.UpdateStreamingState(World)
  self.WorldToCheck = World
  self.LastCheckTime = _G.UpdateManager.Timestamp + 0.2
  if self.Block then
    UE.UNRCStatics.BlockTillLevelStreamingCompleted(World)
    self:LevelLoaded()
    self.WorldToCheck = nil
  else
    _G.UpdateManager:Register(self)
  end
end

function QuickTeleport:OnTick(DeltaTime)
  local Now = _G.UpdateManager.Timestamp
  if Now - self.LastCheckTime <= 0.1 then
    return
  end
  self.LastCheckTime = Now
  if UE.UNRCStatics.StreamingLevelIsLoading(_G.UE4Helper.GetCurrentWorld(), _G.FVectorZero) then
    Log.Debug("teleporting...")
    return
  end
  _G.UpdateManager:UnRegister(self)
  self:LevelLoaded()
  self.WorldToCheck = nil
end

function QuickTeleport:GetPlayer()
  return _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
end

function QuickTeleport:ResetCamera()
  local Player = self:GetPlayer()
  local Controller = Player:GetUEController()
  if Controller then
    Controller:ReleaseRocoCamera(0, UE4.EViewTargetBlendFunction.VTBlend_EaseOut, 0)
    Controller:ResetCtrlRotation(10000.0)
  end
end

return QuickTeleport
