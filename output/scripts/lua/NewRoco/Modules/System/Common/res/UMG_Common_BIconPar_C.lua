local UMG_Common_BIconPar_C = _G.NRCPanelBase:Extend("UMG_Common_BIconPar_C")

function UMG_Common_BIconPar_C:OnConstruct()
end

function UMG_Common_BIconPar_C:OnDestruct()
end

function UMG_Common_BIconPar_C:OnActive()
end

function UMG_Common_BIconPar_C:OnDeactive()
end

function UMG_Common_BIconPar_C:Open()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
end

function UMG_Common_BIconPar_C:CloseOpen()
  self:PlayAnimation(self.close)
end

function UMG_Common_BIconPar_C:Close()
  self:PlayAnimation(self.close)
end

function UMG_Common_BIconPar_C:PlayLoop()
  if UE4.UKismetSystemLibrary.IsValid(self.UMG_Common_BIconParItem) then
    self.UMG_Common_BIconParItem:PlayLoopAnimation()
  end
end

function UMG_Common_BIconPar_C:OnAnimationFinished(anim)
  if anim == self.close then
    self.UMG_Common_BIconParItem:StopLoop()
  elseif anim == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    if self.PlayLoop then
      self:PlayLoop()
    end
  end
end

function UMG_Common_BIconPar_C:OnDeactive()
end

return UMG_Common_BIconPar_C
