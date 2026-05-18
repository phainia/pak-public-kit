local Class = _G.MakeSimpleClass
local FSMState = Class("FSMState")
FSMState.fsm = nil
FSMState.stateID = nil

function FSMState:OnEnter()
  Log.Debug(self.name .. " OnEnter")
end

function FSMState:OnExit()
  Log.Debug(self.name .. " OnExit")
  self.fsm = nil
end

function FSMState:OnTick(deltaTime)
end

return FSMState
