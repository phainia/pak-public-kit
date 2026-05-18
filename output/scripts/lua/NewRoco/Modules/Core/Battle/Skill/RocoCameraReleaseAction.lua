local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local RocoCameraReleaseAction = RocoSkillAction:Extend("RocoCameraReleaseAction")

function RocoCameraReleaseAction:ActionStart()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerController = localPlayer:GetUEController()
  local final_rotation
  if self.CameraReleaseMode == UE4.ECameraReleaseMode.KeepRotation then
    final_rotation = playerController:GetControlRotation()
  elseif self.CameraReleaseMode == UE4.ECameraReleaseMode.BackToDefault then
    final_rotation = localPlayer.viewObj:K2_GetActorRotation()
  elseif self.CameraReleaseMode == UE4.ECameraReleaseMode.ReleaseNow then
    final_rotation = playerController:GetViewTarget():K2_GetActorRotation()
  elseif self.CameraReleaseMode == UE4.ECameraReleaseMode.WithCertainRotation then
    final_rotation = self.RealTargetRotation
  end
  playerController:SetControlRotation(final_rotation)
  local playerCameraManager = playerController.PlayerCameraManager
  self.TargetLocation, self.TargetRotation, self.TargetFov = playerCameraManager:GetBigWorldCameraFinalPOV()
  playerCameraManager:ResetLerpCameraArmLength()
  self.camera_switched = false
end

function RocoCameraReleaseAction:ActionTick()
  if self.camera_switched == false then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local playerController = localPlayer:GetUEController()
    playerController:SetViewTargetWithBlend(self.LerpCamera)
    self.camera_switched = true
  end
end

function RocoCameraReleaseAction:ActionEnd()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerController = localPlayer:GetUEController()
  playerController:ReleaseRocoCamera()
end

return RocoCameraReleaseAction
