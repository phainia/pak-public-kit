local Delegate = require("Utils.Delegate")
local TouchEmptyHide = Class("TouchEmptyHide")

function TouchEmptyHide:Ctor(Panel)
  self.Panel = Panel
  self.OnTouchEmpty = Delegate()
end

function TouchEmptyHide:Bind()
  _G.NRCEventCenter:RegisterEvent(self.Panel.panelName, self, NRCGlobalEvent.OnRocoTouchEnd, self.OnPreTouched)
end

function TouchEmptyHide:UnBind()
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnRocoTouchEnd, self.OnPreTouched)
end

function TouchEmptyHide:OnPreTouched()
  if self.DelayJudgeTouched then
    self.Panel:CancelDelayByID(self.DelayJudgeTouched)
    self.DelayJudgeTouched = nil
  end
  self.DelayJudgeTouched = self.Panel:DelayFrames(1, function()
    self.DelayJudgeTouched = nil
    self.OnTouchEmpty:Invoke()
  end)
end

function TouchEmptyHide:NotifyTouched()
  if self.DelayJudgeTouched then
    self.Panel:CancelDelayByID(self.DelayJudgeTouched)
    self.DelayJudgeTouched = nil
  end
end

return TouchEmptyHide
