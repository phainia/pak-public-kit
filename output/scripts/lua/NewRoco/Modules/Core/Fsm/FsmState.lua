local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local FsmEnum = require("NewRoco.Modules.Core.Fsm.FsmEnum")
local FsmTransition = require("NewRoco.Modules.Core.Fsm.FsmTransition")
local Base = require("NewRoco.Modules.Core.Fsm.FsmBaseObject")
local FsmState = Base:Extend("FsmState")
FsmState:SetMemberCount(16)

function FsmState:PreCtor()
  self.active = false
  self.entered = false
  self.finished = false
  self.timeout = 30
  self.index = 0
  self.fsm = nil
  self.InitState = nil
  self.isFinalState = false
end

function FsmState:Ctor(name, properties, mode, actions, transitions)
  Base.Ctor(self, name, properties)
  self.actions = actions or FsmUtils.Dummy
  self.transitions = transitions or FsmUtils.Dummy
  self.mode = mode or FsmEnum.StateMode.Sequential
  self.preloadingActions = table.new(0, #self.actions)
  self.activeActions = table.new(0, #self.actions)
  self.ChildrenState = {}
end

function FsmState:InitLazyAction()
  local lazyActionList = self.lazyActionList
  if lazyActionList then
    for i = 1, #lazyActionList do
      local Action = require(lazyActionList[i][2])
      self:AddAction(Action(lazyActionList[i][1], lazyActionList[i][3]))
    end
  end
  self.lazyActionList = nil
end

function FsmState:SetMode(mode)
  self.mode = mode
  return self
end

function FsmState:SetTransitions(transitions)
  if self.active then
    Log.Warning("it's not allowed to modify transitions after state starts")
    return
  end
  self.transitions = transitions or FsmUtils.Dummy
  return self
end

function FsmState:SetActions(actions)
  if self.active then
    Log.Warning("it's not allowed to modify actions after state starts")
    return
  end
  self.actions = actions or FsmUtils.Dummy
  return self
end

function FsmState:AddAction(action)
  if self.active then
    Log.Warning("it's not allowed to modify actions after state starts")
    return
  end
  if not self.actions or self.actions == FsmUtils.Dummy then
    self.actions = {}
  end
  table.insert(self.actions, action)
  return self
end

function FsmState:AddLazyAction(actionName, actionPath, param)
  if not self.lazyActionList then
    self.lazyActionList = {}
  end
  table.insert(self.lazyActionList, {
    actionName,
    actionPath,
    param
  })
end

function FsmState:AddTransition(transition)
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

function FsmState:AddTransitionToState(event, state)
  if state then
    local Transition = state:MakeTransition(event)
    return self:AddTransition(Transition)
  else
    Log.Error("Exception: FsmState:AddTransitionToState state is nil")
    return nil
  end
end

function FsmState:OnEnter(fsm)
  if self.entered then
    return
  end
  if not fsm then
    return
  end
  self:InitLazyAction()
  fsm:TriggerEvent(FsmEnum.Events.EnterState, self)
  Log.Debug("BattleStreamLog  ChangeFsmState  FsmStateName:" .. (self.name or "nil"))
  self.fsm = fsm
  self.active = true
  self.entered = true
  self.finished = false
  self.index = 0
  self:ClearActiveActions()
  self:CollectPreloadingActions()
  if not self:IsWaitPreload() then
    self:TryAddActiveActions(1, #self.actions)
  end
end

function FsmState:OnExit()
  if not self.active then
    return
  end
  self.fsm:TriggerEvent(FsmEnum.Events.ExitState, self)
  FsmUtils.Iterate(self.activeActions, "OnFinish")
  FsmUtils.Iterate(self.actions, "DoExit")
  self.active = false
  self.entered = false
  self.finished = false
  self:ClearActiveActions()
end

function FsmState:OnEvent(event)
  FsmUtils.Iterate(self.activeActions, "OnEvent", event)
end

function FsmState:OnTick(DeltaTime)
  if self:IsWaitPreload() then
    return
  end
  if not self.active or self.finished then
    return
  end
  FsmUtils.Iterate(self.activeActions, "DoTick", DeltaTime)
  self:CheckAllActionsFinished()
end

function FsmState:OnPause()
  FsmUtils.Iterate(self.activeActions, "OnPause")
end

function FsmState:OnResume()
  FsmUtils.Iterate(self.activeActions, "OnResume")
end

function FsmState:OnFinalize()
  FsmUtils.Iterate(self.actions, "DoFinalize")
  self.fsm = nil
end

function FsmState:AddPreloadingAction(action)
  if table.contains(self.preloadingActions, action) then
    return
  end
  self.timeout = math.max(self.timeout, action.timeout)
  table.insert(self.preloadingActions, action)
end

function FsmState:RemovePreloadingAction(action)
  for i, v in ipairs(self.preloadingActions) do
    if v == action then
      table.remove(self.preloadingActions, i)
      break
    end
  end
  if not self:IsWaitPreload() then
    self:TryAddActiveActions(1, #self.actions)
  end
end

function FsmState:GetTransition(event)
  return FsmUtils.GetTransition(self.transitions, event)
end

function FsmState:ClearActiveActions()
  if not self.activeActions then
    return
  end
  table.clear(self.activeActions)
end

function FsmState:CollectPreloadingActions()
  FsmUtils.Iterate(self.actions, "DoPreload", self)
end

function FsmState:IsWaitPreload()
  return #self.preloadingActions > 0
end

function FsmState:IsActiveAction(action)
  if not self.activeActions then
    return
  end
  for _, v in ipairs(self.activeActions) do
    if v == action then
      return true
    end
  end
  return false
end

function FsmState:TryAddActiveActions(startIndex, stopIndex)
  if stopIndex < startIndex then
    return
  end
  local retVal = false
  for i = startIndex, stopIndex do
    self.index = i
    local action = self.actions[i]
    if action then
      table.insert(self.activeActions, action)
      action.index = i
      action:DoEnter()
      if self:IsSequential() then
        self.timeout = self.timeout + action.timeout
      else
        self.timeout = math.max(self.timeout, action.timeout)
      end
    end
    retVal = #self.activeActions > 0
    if not (self:IsSequential() and retVal) or self.mode == FsmEnum.StateMode.Burst and action and action.finished then
    else
      break
    end
  end
  return retVal
end

function FsmState:IsSequential()
  if self.mode == FsmEnum.StateMode.Sequential then
    return true
  end
  if self.mode == FsmEnum.StateMode.Burst then
    return true
  end
  return false
end

function FsmState:CheckAllActionsFinished()
  for i = #self.activeActions, 1, -1 do
    local action = self.activeActions[i]
    if action.finished then
      table.remove(self.activeActions, i)
      action.entered = false
    end
  end
  if 0 == #self.activeActions then
    local HasNewActions = self:TryAddActiveActions(self.index + 1, #self.actions)
    if HasNewActions then
      return
    end
    self:Finish()
  end
end

function FsmState:Finish()
  self.finished = true
end

function FsmState:FindActionByName(Name)
  for _, Action in ipairs(self.actions) do
    if Action:GetName() == Name then
      return Action
    end
  end
  return nil
end

function FsmState:MakeTransition(event)
  return FsmTransition(event, self.name)
end

function FsmState:IsComposedState()
  return self.mode == FsmEnum.StateMode.Composed
end

function FsmState:SetInitState(InState)
  if not self:IsComposedState() then
    return false
  end
  self.InitState = InState
  return self.InitState ~= nil
end

function FsmState:GetInitState()
  return self.InitState
end

function FsmState:GetInitStateRecursive()
  local Terminal = self.InitState
  local LastTerminal
  while Terminal do
    LastTerminal = Terminal
    Terminal = Terminal:GetInitStateRecursive()
  end
  return LastTerminal
end

function FsmState:ContainChildState(InState)
  if not self:IsComposedState() then
    return false
  end
  return table.contains(self.ChildrenState, InState)
end

function FsmState:CreateChildSequentialState(name, properties)
  if not self:IsComposedState() then
    return nil
  end
  if not self.fsm then
    Log.Error("fsm not registered")
    return nil
  end
  local ComposedName = (self.name or "") .. ":" .. (name or "")
  local Child = self.fsm:CreateSequentialState(ComposedName, properties)
  if not Child then
    Log.Error("Create child stated fail")
    return nil
  end
  if 0 == #self.ChildrenState then
    self:SetInitState(Child)
  end
  table.insert(self.ChildrenState, Child)
  return Child
end

function FsmState:CreateChildBurstState(name, properties)
  if not self:IsComposedState() then
    return nil
  end
  if not self.fsm then
    Log.Error("fsm not registered")
    return nil
  end
  if not name then
    Log.Error("FsmState name is nil")
    return nil
  end
  local ComposedName = self.name .. ":" .. name
  local Child = self.fsm:CreateBurstState(ComposedName, properties)
  if not Child then
    Log.Error("Create child stated fail")
    return nil
  end
  if 0 == #self.ChildrenState then
    self:SetInitState(Child)
  end
  table.insert(self.ChildrenState, Child)
  return Child
end

function FsmState:CreateChildParallelState(name, properties)
  if not self:IsComposedState() then
    return nil
  end
  if not self.fsm then
    Log.Error("fsm not registered")
    return nil
  end
  local ComposedName = self.name .. ":" .. name
  local Child = self.fsm:CreateParallelState(ComposedName, properties)
  if not Child then
    Log.Error("Create child stated fail")
    return nil
  end
  if 0 == #self.ChildrenState then
    self:SetInitState(Child)
  end
  table.insert(self.ChildrenState, Child)
  return Child
end

function FsmState:CreateChildComposedState(name, properties)
  if not self:IsComposedState() then
    return nil
  end
  if not self.fsm then
    Log.Error("fsm not registered")
    return nil
  end
  local ComposedName = self.name .. ":" .. name
  local Child = self.fsm:CreateComposedState(ComposedName, properties)
  if not Child then
    Log.Error("Create child stated fail")
    return nil
  end
  if 0 == #self.ChildrenState then
    self:SetInitState(Child)
  end
  table.insert(self.ChildrenState, Child)
  return Child
end

return FsmState
