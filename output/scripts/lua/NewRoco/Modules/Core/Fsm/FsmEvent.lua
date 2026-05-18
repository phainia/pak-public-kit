local Class = _G.MakeSimpleClass
local FsmEvent = Class("FsmEvent")

function FsmEvent:Ctor(name, sender, preLimit)
  self.name = name
  self.sender = sender
  self.preLimit = preLimit
end

return FsmEvent
