local CameraModuleHead = NRCModuleHeadBase:Extend("CameraModuleHead")

function CameraModuleHead:OnConstruct()
  _G.CameraModuleCmd = reload("NewRoco.Modules.System.Camera.CameraModuleCmd")
  self:BindCmd(_G.CameraModuleCmd.RequestCamera, "RequestCamera")
  self:BindCmd(_G.CameraModuleCmd.StopCameraSkillPlaying, "StopCameraSkillPlaying")
  self:BindCmd(_G.CameraModuleCmd.CreateCameraRequestConfig, "CreateCameraRequestConfig")
  self:BindCmd(_G.CameraModuleCmd.RequestDefaultCameraOfType, "RequestDefaultCameraOfType")
  self:BindCmd(_G.CameraModuleCmd.ReturnCamera, "ReturnCamera")
  self:BindCmd(_G.CameraModuleCmd.FillCameraMotionInfo, "FillCameraMotionInfo")
  self:BindCmd(_G.CameraModuleCmd.StartCameraMotion, "StartCameraMotion")
  self:BindCmd(_G.CameraModuleCmd.RequestRocoCameraAndInit, "RequestRocoCameraAndInit")
  self:BindCmd(_G.CameraModuleCmd.OverlapRocoCameraWithBigWorldCamera, "OverlapRocoCameraWithBigWorldCamera")
  self:BindCmd(_G.CameraModuleCmd.PrepareBlendingToBigWorldCamera, "PrepareBlendingToBigWorldCamera")
  self:BindCmd(_G.CameraModuleCmd.EndCameraMotion, "EndCameraMotion")
  self:BindCmd(_G.CameraModuleCmd.GetCameraHolder, "GetCameraHolder")
  self:BindCmd(_G.CameraModuleCmd.RequestCameraDOF, "RequestCameraDOF")
end

return CameraModuleHead
