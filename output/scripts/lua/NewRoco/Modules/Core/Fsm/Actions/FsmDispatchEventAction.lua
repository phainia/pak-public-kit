local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = FsmAction
local FsmDispatchEventAction = Base:Extend("FsmDispatchEventAction")
FsmUtils.MergeMembers(Base, FsmDispatchEventAction, {
  {name = "EventName", type = "string"}
})

function FsmDispatchEventAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function FsmDispatchEventAction:OnEnter()
  self:InjectProperties()
  if string.IsNilOrEmpty(self.EventName) then
    Log.Error("Event name is nil or empty")
  else
    _G.NRCEventCenter:DispatchEvent(self.EventName, self)
  end
  self:Finish()
end

return FsmDispatchEventAction
