local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local FsmEvent = require("NewRoco.Modules.Core.Fsm.FsmEvent")
local FsmEnum = require("NewRoco.Modules.Core.Fsm.FsmEnum")
local FsmState = require("NewRoco.Modules.Core.Fsm.FsmState")
local FsmTimelineState = require("NewRoco.Modules.Core.Fsm.FsmTimelineState")
local Base = require("NewRoco.Modules.Core.Fsm.FsmBaseObject")
local Delegate = require("Utils.Delegate")
local Fsm = Base:Extend("Fsm")
Fsm:SetMemberCount(16)

function Fsm:Ctor(name, properties, states, transitions)
  Base.Ctor(self, name, properties)
  self.states = states or FsmUtils.Dummy
  self.transitions = transitions or FsmUtils.Dummy
  self.active = false
  self.paused = false
  self.finished = false
  self.eventQueue = table.new(0, 4)
  self.Callbacks = table.new(0, 4)
  self.nameToStates = {}
  WeakTable(self.nameToStates)
  self.terminalStateNames = {}
  self.ComposedStates = {}
  self.FsmManager = _G.FsmManager
end

function Fsm:SetStates(states)
  if self.active then
    Log.Warning("Can't change states after fsm started")
    return
  end
  self.states = states
  return self
end

function Fsm:SetTransitions(transitions)
  if self.active then
    Log.Warning("Can't change transitions after fsm started")
    return
  end
  self.transitions = transitions
  return self
end

function Fsm:AddTransition(transition)
  if self.active then
    Log.Warning("it's not allowed to modify transitions after state starts")
    return
  end
  if not self.transitions or self.transitions == FsmUtils.Dummy then
    self.transitions = {}
  end
  table.insert(self.transitions, transition)
  return self
end

function Fsm:AddTransitionToState(event, state)
  local Transition = state:MakeTransition(event)
  return self:AddTransition(Transition)
end

function Fsm:AddState(state)
  if self.active then
    Log.Warning("it's not allowed to modify actions after state starts")
    return
  end
  if not self.states or self.states == FsmUtils.Dummy then
    self.states = {}
  end
  self.nameToStates[state:GetName()] = state
  table.insert(self.states, state)
  return self
end

function Fsm:CreateNormalState(name, properties, mode)
  local State = self:GetState(name)
  if State then
    return State
  end
  State = FsmState(name, properties, mode)
  self:AddState(State)
  return State
end

function Fsm:CreateTimelineState(name, properties)
  local State = self:GetState(name)
  if State then
    return State
  end
  State = FsmTimelineState(name, properties)
  self:AddState(State)
  return State
end

function Fsm:CreateSequentialState(name, properties)
  return self:CreateNormalState(name, properties, FsmEnum.StateMode.Sequential)
end

function Fsm:CreateBurstState(name, properties)
  return self:CreateNormalState(name, properties, FsmEnum.StateMode.Burst)
end

function Fsm:CreateParallelState(name, properties)
  return self:CreateNormalState(name, properties, FsmEnum.StateMode.Parallel)
end

function Fsm:CreateComposedState(name, properties)
  local NewState = self:CreateNormalState(name, properties, FsmEnum.StateMode.Composed)
  table.insert(self.ComposedStates, NewState)
  NewState.fsm = self
  return NewState
end

function Fsm:SetInitStateName(name)
  self.initialStateName = name
  return self
end

function Fsm:SetInitState(state)
  self.initialStateName = state:GetName()
  return self
end

function Fsm:AddTerminalState(state)
  if FsmUtils.Contains(self.terminalStateNames, state) then
    return self
  end
  table.insert(self.terminalStateNames, state:GetName())
  return self
end

function Fsm:GetState(name)
  if not name then
    return nil
  end
  return self.nameToStates[name]
end

function Fsm:SendEvent(name, sender, preLimit)
  if not self.active then
    return
  end
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\230\142\165\230\148\182\228\186\139\228\187\182%s", self:GetName(), name)
  self:Resume()
  table.insert(self.eventQueue, FsmEvent(name, sender, preLimit))
end

function Fsm:Play()
  if self.active then
    return
  end
  if self.paused then
    return
  end
  self.active = true
  self.paused = false
  self.finished = false
  self.prevState = nil
  table.clear(self.eventQueue)
  self.nextState = self:GetState(self.initialStateName) or self.states[1]
  self.FsmManager:Play(self)
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\229\188\128\229\167\139\232\191\144\232\161\140", self:GetName())
end

function Fsm:Stop()
  if not self.active then
    return
  end
  self:ExitState(self.activeState)
  for _, state in ipairs(self.states) do
    state:OnFinalize()
  end
  self.active = false
  self.paused = false
  self.finished = true
  self.prevState = nil
  self.activeState = nil
  self.nextState = nil
  self:TriggerEvent(FsmEnum.Events.Stop)
  self:ClearAllEvents()
  self.FsmManager:Stop(self)
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\229\129\156\230\173\162\232\191\144\232\161\140", self:GetName())
end

function Fsm:Resume()
  if not self.paused then
    return
  end
  self.paused = false
  for _, state in ipairs(self.states) do
    state:OnResume()
  end
  self.FsmManager:Resume(self)
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\230\129\162\229\164\141\232\191\144\232\161\140", self:GetName())
end

function Fsm:Pause()
  if self.paused then
    return
  end
  self.paused = true
  for _, state in ipairs(self.states) do
    state:OnPause()
  end
  self.FsmManager:Pause(self)
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\230\154\130\229\129\156\232\191\144\232\161\140", self:GetName())
end

function Fsm:RegisterEvent(event, owner, callback)
  local Del = self.Callbacks[event]
  if not Del then
    Del = Delegate()
    self.Callbacks[event] = Del
  end
  Del:Add(owner, callback)
end

function Fsm:RemoveEvent(event, owner, callback)
  local Del = self.Callbacks[event]
  if not Del then
    return
  end
  Del:Remove(owner, callback)
end

function Fsm:ClearAllEvents()
  for _, Del in pairs(self.Callbacks) do
    Del:Clear()
  end
  table.clear(self.Callbacks)
end

function Fsm:FindParentComposedState(InState)
  if not InState then
    return nil
  end
  for _, ComposedState in ipairs(self.ComposedStates) do
    if ComposedState:ContainChildState(InState) then
      return ComposedState
    end
  end
end

function Fsm:ProcessEvents()
  local state = self.activeState
  if not state then
    if self.eventQueue and #self.eventQueue > 0 then
      Log.Warning("There's no active state, skip process event", self:GetName())
      table.clear(self.eventQueue)
    end
    return
  end
  local isNormalState = not FsmUtils.Contains(self.terminalStateNames, state)
  for _, event in ipairs(self.eventQueue) do
    if self:CheckCanProcessEvent(event) then
      local transition = state:GetTransition(event)
      transition = transition or FsmUtils.GetTransition(self.transitions, event)
      if not transition then
        local ComposedState = self:FindParentComposedState(self.activeState)
        while nil ~= ComposedState do
          local TransitionFromComposedState = ComposedState:GetTransition(event)
          if TransitionFromComposedState then
            transition = TransitionFromComposedState
            ComposedState = nil
          else
            ComposedState = self:FindParentComposedState(ComposedState)
          end
        end
      end
      if not transition then
        if isNormalState and event.name == "FINISHED" then
          Log.DebugFormat("Stop %s, no valid transition", self:GetName())
          self:Stop()
        else
          Log.WarningFormat("[Fsm]\230\137\190\228\184\141\229\136\176\229\143\175\228\187\165\229\136\135\230\141\162\231\154\132\231\138\182\230\128\129,\228\186\139\228\187\182:%s,\229\189\147\229\137\141\231\138\182\230\128\129:%s", event.name, self.activeState:GetName())
        end
      end
      local NextState = self:GetState(transition and transition.next)
      if NextState then
        if NextState:IsComposedState() then
          NextState = NextState:GetInitState()
        end
        if self.nextState then
          if self.nextState:GetName() ~= NextState:GetName() then
            if self.nextState.isFinalState then
              state:OnEvent(event)
              Log.WarningFormat("[Fsm]\229\183\178\231\187\143\229\134\179\229\174\154\232\166\129\232\183\179\232\189\172\229\136\176%s,\232\191\153\230\152\175\228\184\128\228\184\170\231\187\147\230\157\159\231\138\182\230\128\129,\228\184\141\230\142\165\229\143\151\229\133\182\228\187\150\228\187\187\228\189\149\232\183\179\232\189\172\232\175\183\230\177\130(%s)", self.nextState:GetName(), NextState:GetName())
              break
            else
              Log.WarningFormat("[Fsm]\230\156\172\230\157\165\232\166\129\232\183\179\232\189\172\229\136\176%s\239\188\140\228\189\134\230\152\175\230\156\137\230\150\176\231\154\132\228\186\139\228\187\182\229\175\188\232\135\180\232\183\179\232\189\172\229\136\176%s", self.nextState:GetName(), NextState:GetName())
            end
          end
        else
          state:OnEvent(event)
        end
      end
      self.nextState = NextState or self.nextState
      if self.nextState then
        self:Resume()
        local nextStateName = self.nextState and self.nextState:GetName() or "nil"
        local activeStateName = state and state:GetName() or "nil"
        Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\229\164\132\231\144\134\228\186\139\228\187\182%s\239\188\140\231\138\182\230\128\129\228\187\142%s\229\136\135\230\141\162\229\136\176%s", self:GetName(), event.name, activeStateName, nextStateName)
      end
    end
  end
  for i = #self.eventQueue, 1, -1 do
    table.remove(self.eventQueue, i)
  end
end

function Fsm:CheckCanProcessEvent(event)
  if event.preLimit then
    if self.nextState then
      return table.contains(event.preLimit, self.nextState.name)
    elseif self.activeState then
      return table.contains(event.preLimit, self.activeState.name)
    end
  end
  return true
end

function Fsm:OnTick(DeltaTime)
  local canTick = self.active and not self.paused and not self.finished
  if not canTick then
    return
  end
  self:TryEnterState()
  for _, state in ipairs(self.states) do
    state:OnTick(DeltaTime)
  end
  self:CheckStateFinished()
  self:ProcessEvents()
  self:TryExitState()
  self:CheckFsmFinished()
end

function Fsm:TriggerEvent(event, ...)
  local Del = self.Callbacks[event]
  if not Del then
    return
  end
  Del:Invoke(self, ...)
end

function Fsm:IsSwitchingState()
  return self.nextState ~= nil
end

function Fsm:TryEnterState()
  if not self:IsSwitchingState() then
    return
  end
  self:EnterState(self.nextState)
end

function Fsm:EnterState(state)
  if not state then
    return
  end
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\232\191\155\229\133\165\231\138\182\230\128\129%s", self:GetName() or "nil", state:GetName() or "nil")
  self.nextState = nil
  self.activeState = state
  self.activeState:OnEnter(self)
end

function Fsm:TryExitState()
  if not self:IsSwitchingState() then
    return
  end
  self:ExitState(self.activeState)
end

function Fsm:ExitState(state)
  if not state then
    return
  end
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\233\128\128\229\135\186\231\138\182\230\128\129%s", self:GetName() or "nil", state:GetName() or "nil")
  self.prevState = state
  self.activeState = nil
  state:OnExit()
end

function Fsm:CheckStateFinished()
  if not self.activeState or not self.activeState.finished then
    return
  end
  if self:GetEventNumber() > 0 then
    return
  end
  self:SendEvent("FINISHED", self)
end

function Fsm:CheckFsmFinished()
  local isSwitching = self:IsSwitchingState()
  local stateFinished = not isSwitching and self.activeState and self.activeState.finished
  local fsmFinished = stateFinished and FsmUtils.Contains(self.terminalStateNames, self.activeState)
  self.finished = fsmFinished
  if not fsmFinished then
    return
  end
  self:Stop()
  self:TriggerEvent(FsmEnum.Events.Finish)
end

function Fsm:GetActiveState()
  return self.activeState
end

function Fsm:GetActiveStateName()
  return self.activeState and self.activeState.name
end

function Fsm:GetNextStateName()
  return self.nextState and self.nextState.name
end

function Fsm:GetEventNumber()
  return #self.eventQueue
end

return Fsm
