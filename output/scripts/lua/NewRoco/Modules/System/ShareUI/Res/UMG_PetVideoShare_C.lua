local UMG_PetVideoShare_C = _G.NRCPanelBase:Extend("UMG_PetVideoShare_C")

function UMG_PetVideoShare_C:Init(petGid)
  self.gid = petGid
  self:PlayAnimation(self.Stamp_in, 0)
  self:PauseAnimation(self.Stamp_in)
end

function UMG_PetVideoShare_C:PlayStampInAnim()
  self:PlayAnimation(self.Stamp_in)
end

function UMG_PetVideoShare_C:OnAnimationFinished(Animation)
  if Animation == self.Stamp_in then
    _G.NRCModuleManager:DoCmd(ShareModuleCmd.EndRecordVideo, self.gid)
  end
end

return UMG_PetVideoShare_C
