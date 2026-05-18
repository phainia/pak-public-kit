local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local CameraMoveInstance = NRCClass()

function CameraMoveInstance:Ctor(ID)
  self.ID = ID
  self.CameraMoveConf = _G.DataConfigManager:GetCameraMoveLite(ID)
  self.MoveHandler = -1
  self.DestroyHandler = -1
end

function CameraMoveInstance:GetTargetLocation()
  local RefreshID = self.CameraMoveConf.focus_npc[1]
  if not RefreshID then
    return nil
  end
  local NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByRefreshID, RefreshID)
  if NPC then
    local Abs = NPC:GetActorLocation()
    local Rot = NPC:GetActorRotation()
    local Yaw = Rot.Yaw
    local View = NPC.viewObj
    local Root = View:K2_GetRootComponent()
    if Root and Root:IsA(UE.UMeshComponent) then
      Yaw = Yaw + 90
      Abs.Z = Abs.Z + self.CameraMoveConf.height_adjustment
    end
    return SceneUtils.ConvertAbsoluteToRelative(Abs), Yaw
  end
  local RefreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(RefreshID)
  if not RefreshConf then
    return nil
  end
  local AreaConf = _G.DataConfigManager:GetAreaConf(RefreshConf.refresh_param)
  local Pos = AreaConf.pos[1]
  if not Pos then
    return nil
  end
  local X, Y, Z = Pos.position_xyz[1], Pos.position_xyz[2], Pos.position_xyz[3]
  local Abs = UE.FVector(X or 0, Y or 0, (Z or 0) + self.CameraMoveConf.height_adjustment)
  local Rot = Pos.rotation_xyz[3]
  return SceneUtils.ConvertAbsoluteToRelative(Abs), Rot or 0
end

function CameraMoveInstance:GetPlayer()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  return player
end

function CameraMoveInstance:GetCameraLocation(Player)
  if not Player then
    return
  end
  local CameraManager = Player:GetUEController().PlayerCameraManager
  if not CameraManager then
    return
  end
  return CameraManager:K2_GetActorLocation()
end

function CameraMoveInstance:Start(Caller, Callback, ...)
  local Player = self:GetPlayer()
  local CameraPos = self:GetCameraLocation(Player)
  local TargetPos, TargetYaw = self:GetTargetLocation()
  if not (Player and CameraPos) or not TargetPos then
    if Caller then
      Callback(Caller, ...)
    else
      Callback(...)
    end
    return false
  end
  self.CallbackOwner = Caller
  self.Callback = Callback
  self.CallbackArgs = table.pack(...)
  if self.Camera then
    self.Camera:K2_SetActorLocation(TargetPos, false)
  else
    self.Camera = self:SpawnCamera(TargetPos)
  end
  local SpringArmComp = self.Camera:GetComponentByClass(UE4.URocoSpringArmComponent)
  SpringArmComp:K2_SetWorldRotation(UE4.FRotator(0, TargetYaw + 180, 0), false, nil, false)
  local Distance = CameraPos:Dist(TargetPos)
  SpringArmComp.TargetArmLength = Distance
  local CameraComp = self.Camera:GetComponentByClass(UE4.UCameraComponent)
  CameraComp.FieldOfView = self:CalcFOV(self.CameraMoveConf.zoom / 1000)
  local PlayerKamVec = CameraPos - TargetPos
  local NewKamVec = CameraComp:K2_GetComponentLocation() - TargetPos
  PlayerKamVec:Normalize()
  NewKamVec:Normalize()
  local DotValue = PlayerKamVec:Dot(NewKamVec)
  local AngleInDegree = math.deg(math.acos(DotValue))
  local AngleVelocity = self.CameraMoveConf.angular_velocity
  local DT = AngleInDegree / AngleVelocity
  if DT < 0 then
    DT = 0
  end
  self:InternalStart(DT)
  self.MoveHandler = _G.DelayManager:DelaySeconds(DT + (self.CameraMoveConf.focus_time or 0), self.OnCameraMoveFinish, self, DT)
  return true
end

function CameraMoveInstance:OnCameraMoveFinish(DT)
  self:InternalStop(DT)
  self:FireCallback()
end

function CameraMoveInstance:CalcFOV(Zoom)
  return 3.9018 * Zoom * Zoom - 42.432 * Zoom + 123
end

function CameraMoveInstance:SpawnCamera(Location)
  local Klass = UE4.UClass.Load("/Game/NewRoco/Modules/System/MiniGame/Res/BP_MiniGameSpringArmActor")
  local Camera = UE4Helper.GetCurrentWorld():SpawnActor(Klass, UE.FTransform(UE4.FRotator(0, 0, 0), Location), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  return Camera
end

function CameraMoveInstance:InternalStart(DT)
  local Player = self:GetPlayer()
  local InputComp = Player.inputComponent
  if InputComp then
    InputComp:SetCameraControlEnable(self, false)
    InputComp:SetInputEnable(self, false)
  end
  Log.Error("Go custom delta time", DT)
  Player:GetUEController():ChangeToCustomCamera(self.Camera, DT)
end

function CameraMoveInstance:InternalStop(DT)
  local Player = self:GetPlayer()
  local InputComp = Player.inputComponent
  if InputComp then
    InputComp:SetCameraControlEnable(self, true)
    InputComp:SetInputEnable(self, true)
  end
  Log.Error("leave custom delta time", DT)
  Player:GetUEController():ReleaseRocoCamera(DT)
  if DT > 0 then
    self.DestroyHandler = _G.DelayManager:DelaySeconds(DT, self.ReleaseCamera, self)
  else
    self:ReleaseCamera()
  end
end

function CameraMoveInstance:ReleaseCamera()
  if not self.Camera then
    return
  end
  self.Camera:K2_DestroyActor()
  self.Camera = nil
end

function CameraMoveInstance:Destroy()
  self:ReleaseCamera()
  if self.MoveHandler > 0 then
    _G.DelayManager:CancelDelayById(self.MoveHandler)
    self.MoveHandler = -1
  end
  if self.DestroyHandler > 0 then
    _G.DelayManager:CancelDelayById(self.DestroyHandler)
    self.DestroyHandler = -1
  end
end

function CameraMoveInstance:FireCallback()
  local Caller = self.CallbackOwner
  local Callback = self.Callback
  local Args = self.CallbackArgs
  self.CallbackOwner = nil
  self.Callback = nil
  self.CallbackArgs = nil
  if Caller then
    Callback(Caller, table.unpack(Args))
  else
    Callback(table.unpack(Args))
  end
end

return CameraMoveInstance
