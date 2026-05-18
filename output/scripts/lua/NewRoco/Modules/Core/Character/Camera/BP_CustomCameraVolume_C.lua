require("UnLuaEx")
local BP_CustomCameraVolume_C = NRCClass()

function BP_CustomCameraVolume_C:NotBinded()
  return false
end

function BP_CustomCameraVolume_C:RefreshInEditor()
  self:ActiveCustom()
end

function BP_CustomCameraVolume_C:ActiveCustom()
  local Camera = self:GetCamera()
  if not Camera then
    return
  end
  Camera.GM_Camera = true
  Camera.GM_FOV = self.FOV
  Camera.GM_BlendIn = self.BendInTime
  Camera.GM_BlendOut = self.BendOutTime
  Camera.GM_PivotOffset_X = self.PivotOffset_X
  Camera.GM_PivotOffset_Y = self.PivotOffset_Y
  Camera.GM_PivotOffset_Z = self.PivotOffset_Z
  Camera.GM_CameraOffset_X = self.CameraOffset_X
  Camera.GM_CameraOffset_Y = self.CameraOffset_Y
  Camera.GM_CameraOffset_Z = self.CameraOffset_Z
  Camera.GM_PivotLagSpeed_X = self.PivotLagSpeed_X
  Camera.GM_PivotLagSpeed_Y = self.PivotLagSpeed_Y
  Camera.GM_PivotLagSpeed_Z = self.PivotLagSpeed_Z
  Camera.GM_RotationLagSpeed = self.RotationLagSpeed
  Camera.GM_RotationOffset_Pitch = self.RotationOffsetPitch
  Camera.GM_RotationOffset_Roll = self.RotationOffsetRoll
  Camera.GM_RotationOffset_Yaw = self.RotationOffsetYaw
end

function BP_CustomCameraVolume_C:DeActiveCustom()
  local Camera = self:GetCamera()
  if not Camera then
    return
  end
  Camera.GM_Camera = false
end

function BP_CustomCameraVolume_C:GetCamera()
  if not PlayerModuleCmd then
    return nil
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return nil
  end
  local CameraManager = localPlayer:GetUEController().PlayerCameraManager
  return CameraManager:GetCameraAnimInstance()
end

return BP_CustomCameraVolume_C
