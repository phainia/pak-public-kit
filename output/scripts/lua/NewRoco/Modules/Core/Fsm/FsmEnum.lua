local FsmEnum = {}
local Index = 0

local function AutoIndex()
  Index = Index + 1
  return Index
end

FsmEnum.Events = {}
FsmEnum.Events.Stop = AutoIndex()
FsmEnum.Events.Finish = AutoIndex()
FsmEnum.Events.EnterState = AutoIndex()
FsmEnum.Events.ExitState = AutoIndex()
FsmEnum.Events.EnterAction = AutoIndex()
FsmEnum.Events.PostEnterAction = AutoIndex()
FsmEnum.Events.FinishAction = AutoIndex()
FsmEnum.Events.ExitAction = AutoIndex()
FsmEnum.StateMode = {}
FsmEnum.StateMode.Sequential = AutoIndex()
FsmEnum.StateMode.Burst = AutoIndex()
FsmEnum.StateMode.Parallel = AutoIndex()
FsmEnum.StateMode.Composed = AutoIndex()
FsmEnum.ManagerEvents = {}
FsmEnum.ManagerEvents.Changed = AutoIndex()
return FsmEnum
