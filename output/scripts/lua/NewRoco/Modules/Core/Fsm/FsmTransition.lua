local Class = _G.MakeSimpleClass
local FsmTransition = Class("FsmTransition")
FsmTransition:SetMemberCount(2)

function FsmTransition:Ctor(event, next)
  self.event = event
  self.next = next
end

return FsmTransition
