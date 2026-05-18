local UMG_BuildSuccess_C = _G.NRCPanelBase:Extend("UMG_BuildSuccess_C")

function UMG_BuildSuccess_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_BuildSuccess_C:OnActive(FurnitureConf)
  self.NRCText_51:SetText(FurnitureConf.name)
  _G.NRCAudioManager:PlaySound2DAuto(1220002061, "UMG_BuildSuccess_C:OnActive")
end

function UMG_BuildSuccess_C:OnDeactive()
end

function UMG_BuildSuccess_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnReqCloseTips)
end

function UMG_BuildSuccess_C:OnReqCloseTips()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  self:DispatchEvent(HomeIndoorSandbox.Event.OnUserConfirmBuildFinish)
  self:OnClose()
end

function UMG_BuildSuccess_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:OnClose()
  elseif Anim == self.In or Anim == self.Loop then
    self:PlayAnimation(self.Loop)
  end
end

return UMG_BuildSuccess_C
