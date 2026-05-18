local UMG_Scroll_C = _G.NRCPanelBase:Extend("UMG_Scroll_C")

function UMG_Scroll_C:OnActive(ReadID, Text, Action)
  self.Action = Action
  self.ReadID = ReadID
  self:SetText(Text)
  self:OnAddEventListener()
  self:PlayAnimationForward(self.In)
  UE4Helper.SetDesiredShowCursor(true, "UMG_Scroll_C")
end

function UMG_Scroll_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  if self.Action then
    self.Action:Finish(true)
    self.Action = nil
  end
  self:RemoveAllButtonListener()
  UE4Helper.ReleaseDesiredShowCursor("UMG_Scroll_C")
end

function UMG_Scroll_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.CloseSelf)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
end

function UMG_Scroll_C:OnDisconnect()
  self:DoClose()
end

function UMG_Scroll_C:CloseSelf()
  self:PlayAnimationForward(self.Out)
end

function UMG_Scroll_C:SetText(Text)
  self.Dialogue:SetText(Text)
end

function UMG_Scroll_C:OnAnimFinished(Animation)
  if Animation == self.Out then
    self:DoCmd(DialogueModuleCmd.SendZoneReportTaskReq, _G.ProtoEnum.TaskClientTriggerType.TCTT_READ_SCROLLS, self.ReadID)
    self:DelayFrames(1, self.DoClose, self)
  end
end

return UMG_Scroll_C
