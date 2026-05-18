local Class = _G.MakeSimpleClass
local FSM = Class("FSM")

function FSM:Ctor()
  self.stateDic = {}
  self.state = nil
end

function FSM:SetState(stateID, state)
  state.stateID = stateID
  self.stateDic[stateID] = state
end

function FSM:GetState(stateID)
  return self.stateDic[stateID]
end

function FSM:ChangeState(stateID, ...)
  local lastState
  if self.state then
    if self.state.stateID == stateID then
      return
    end
    if not self:CheckValid(self.state.stateID, stateID) then
      return
    end
    lastState = self.state.stateID
  end
  if self.state then
    self.state:OnExit()
    self.state.fsm = nil
    self.state.lastStateId = nil
    self:OnStateExit(self.state)
  end
  self.state = self:GetState(stateID)
  if self.state ~= nil then
    self.state.fsm = self
    self.state.lastStateId = lastState
    self:OnStateEnter(self.state)
    self.state:OnEnter(...)
  end
  return self.state
end

function FSM:OnStateExit(oldState)
end

function FSM:OnStateEnter(newState)
end

function FSM:OnTick(deltaTime)
  if self.state then
    self.state:OnTick(deltaTime)
  end
end

function FSM:OnDestroy()
  if self.state then
    self.state:OnExit()
    self.state = nil
  end
  self.stateDic = {}
end

function FSM:CheckValid(curState, nextState)
  return true
end

function FSM:InState(stateID)
  return self.state == self:GetState(stateID)
end

return FSM
