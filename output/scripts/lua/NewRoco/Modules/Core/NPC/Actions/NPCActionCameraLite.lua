local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionCameraLite = Base:Extend("NPCActionCameraLite")

function NPCActionCameraLite:Ctor(Owner, Config, Info, View)
  Base.Ctor(self, Owner, Config, Info, View)
  self.DelayHandle = -1
end

function NPCActionCameraLite:Execute(playerId, needSendReq)
  if self.DelayHandle > 0 then
    return
  end
  self.CameraMoveConfID = tonumber(self.Config.action_param1) or 0
  self.CameraMoveConf = _G.DataConfigManager:GetCameraMoveLite(self.CameraMoveConfID)
  if not self.CameraMoveConfID then
    return
  end
  local LaunchTime = 0
  if self.CameraMoveConf.move_type == Enum.NpcInteractCameraMoveType.CAMERA_MOVE_LINE then
    local AreaConfig = DataConfigManager:GetAreaConf(self.CameraMoveConf.move_path)
    local TargetCameraLocation = self:AreaPosToTransform(AreaConfig)
    local CameraMotionInfo = NRCModuleManager:DoCmd(CameraModuleCmd.FillCameraMotionInfo, self.CameraMoveConf.move_type)
    CameraMotionInfo.TargetCameraTransform = TargetCameraLocation
    CameraMotionInfo.InitCameraTransform = self:GetBigWorldCameraTransform()
    CameraMotionInfo.CameraMoveTime = self.CameraMoveConf.camera_launch_time / 1000
    CameraMotionInfo.NonStoppableByObstacle = true
    CameraMotionInfo.CustomConfig = {
      bReverse = false,
      FocusNpcId = self.CameraMoveConf.focus_npc
    }
    LaunchTime = CameraMotionInfo.CameraMoveTime
    NRCModuleManager:DoCmd(CameraModuleCmd.RequestRocoCameraAndInit)
    NRCModuleManager:DoCmd(CameraModuleCmd.StartCameraMotion, CameraMotionInfo)
  elseif self.CameraMoveConf.move_type == Enum.NpcInteractCameraMoveType.CAMERA_MOVE_PATH then
    local CameraMotionInfo = NRCModuleManager:DoCmd(CameraModuleCmd.FillCameraMotionInfo, self.CameraMoveConf.move_type)
    CameraMotionInfo.CameraMoveTime = self.CameraMoveConf.camera_launch_time / 1000
    CameraMotionInfo.NonStoppableByObstacle = true
    CameraMotionInfo.CustomConfig = {
      AreaId = self.CameraMoveConf.move_path,
      bReverse = false,
      FocusNpcId = self.CameraMoveConf.focus_npc
    }
    LaunchTime = CameraMotionInfo.CameraMoveTime
    NRCModuleManager:DoCmd(CameraModuleCmd.RequestRocoCameraAndInit)
    NRCModuleManager:DoCmd(CameraModuleCmd.StartCameraMotion, CameraMotionInfo)
  end
  if LaunchTime > 0 then
    Base.Execute(self, playerId, needSendReq)
    self.DelayHandle = _G.DelayManager:DelaySeconds(LaunchTime, self.CameraMoveFinished, self)
  end
end

function NPCActionCameraLite:CameraMoveFinished()
  Log.Error("Camera Move Finished!!!!!!")
  self.DelayHandle = -1
  self:Finish(true)
end

function NPCActionCameraLite:UpdateInfo(Info, Reconnect)
  if not Reconnect then
    return
  end
  if self.DelayHandle > 0 then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = -1
  end
end

function NPCActionCameraLite:AreaPosToTransform(AreaConf)
  if not (AreaConf and AreaConf.pos) or 0 == #AreaConf.pos then
    return UE.FTransform()
  end
  local Location = AreaConf.pos[1].position_xyz
  local Rotation = AreaConf.pos[1].rotation_xyz
  local ResultTransform = UE4.FTransform()
  ResultTransform.Translation = UE4.FVector(Location[1], Location[2], Location[3])
  ResultTransform.Rotation = UE4.FRotator(Rotation[1], Rotation[2], Rotation[3])
  return ResultTransform
end

function NPCActionCameraLite:GetBigWorldCameraTransform()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Controller = player:GetUEController()
  local result = UE4.FTransform()
  result.Translation = player:GetActorLocation()
  result.Rotation = Controller.PlayerCameraManager.CameraRotation
  Log.Error(result.Translation, player:GetActorLocation())
  return result
end

return NPCActionCameraLite
