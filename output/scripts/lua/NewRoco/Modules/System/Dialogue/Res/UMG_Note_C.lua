local UMG_Note_C = _G.NRCPanelBase:Extend("UMG_Note_C")

function UMG_Note_C:OnActive(ReadID, Text, Action)
  self.Action = Action
  self.ReadID = ReadID
  self:SetText(Text)
  self:OnAddEventListener()
  self:PlayAnimationForward(self.In)
end

function UMG_Note_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  self:RemoveAllButtonListener()
  if self.Action then
    self.Action:Finish(true)
    self.Action = nil
  end
end

function UMG_Note_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.CloseSelf)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
end

function UMG_Note_C:OnDisconnect()
  self:DoClose()
end

function UMG_Note_C:SetText(Text)
  self.Dialogue:SetText(Text)
end

function UMG_Note_C:CloseSelf()
  self:PlayAnimationForward(self.Out)
end

function UMG_Note_C:OnAnimFinished(Animation)
  if Animation == self.Out then
    self:DoCmd(DialogueModuleCmd.SendZoneReportTaskReq, _G.ProtoEnum.TaskClientTriggerType.TCTT_READ_NOTE, self.ReadID)
    self:DelayFrames(1, self.DoClose, self)
  end
end

return UMG_Note_C
