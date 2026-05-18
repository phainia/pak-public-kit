local UMG_Share_CameraLens_C = _G.NRCPanelBase:Extend("UMG_Share_CameraLens_C")

function UMG_Share_CameraLens_C:OnActive(shareData)
  self.OpenCb = shareData.openCb
  self.CloseCb = shareData.closeCb
  self.Camera = shareData.camera
  self.Gid = shareData.gid
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PlayShareVideoEnablePetMain, false)
  if shareData.camera and shareData.gid then
    if _G.NRCModuleManager:DoCmd(PetUIModuleCmd.IsShareRecordVideo) then
      _G.NRCModuleManager:DoCmd(ShareModuleCmd.EndRecordVideo, shareData.gid)
    end
    _G.NRCModuleManager:DoCmd(ShareModuleCmd.StartRecordVideo, shareData.camera, shareData.gid)
  else
    Log.Error("\231\178\190\231\129\181\232\167\134\233\162\145\229\136\134\228\186\171\231\154\132\229\143\130\230\149\176\230\156\137\232\175\175\239\188\129\239\188\129\239\188\129camera\239\188\140gid is ", shareData.camera, shareData.gid)
  end
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.CloseShareOverlayPanel)
end

function UMG_Share_CameraLens_C:OnDeactive()
end

function UMG_Share_CameraLens_C:OnAddEventListener()
end

function UMG_Share_CameraLens_C:PlayCloseAnim()
  self:PlayAnimation(self.Close)
end

function UMG_Share_CameraLens_C:OnPcClose()
end

function UMG_Share_CameraLens_C:OnAnimationFinished(anim)
  if anim == self.Open then
    if self.OpenCb then
      self.OpenCb()
    end
  elseif anim == self.Close and self.CloseCb then
    self.CloseCb()
  end
end

return UMG_Share_CameraLens_C
