require("UnLuaEx")
local Base = require("NewRoco.AI.BehaviorTree.BTNode_LuaBase")
local BTDecorator_LuaBase_C = Base:Extend("BTDecorator_LuaBase_C")

function BTDecorator_LuaBase_C:Ctor(LuaBTNodeBase)
  self.LuaFileFolderPath = "NewRoco.AI.BehaviorTree.Decorators"
end

function BTDecorator_LuaBase_C:ReceiveTick(OwnerActor, DeltaSeconds)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnUpdate, OwnerActor, DeltaSeconds)
  end
end

function BTDecorator_LuaBase_C:ReceiveExecutionStart(OwnerActor)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnStart, OwnerActor)
  end
end

function BTDecorator_LuaBase_C:ReceiveExecutionFinish(OwnerActor, NodeResult)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnEnd, OwnerActor, NodeResult)
  end
end

function BTDecorator_LuaBase_C:ReceiveObserverActivated(OwnerActor)
  self:Init()
end

function BTDecorator_LuaBase_C:ReceiveObserverDeactivated(OwnerActor)
end

function BTDecorator_LuaBase_C:PerformConditionCheck(OwnerActor)
  if self.Action then
    return self:CallActionFunc(self.Action, self.Action.PerformConditionCheck, OwnerActor)
  end
  return false
end

function BTDecorator_LuaBase_C:ReceiveTickAI(OwnerController, ControlledPawn, DeltaSeconds)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnUpdate, OwnerController, DeltaSeconds)
  end
end

function BTDecorator_LuaBase_C:ReceiveExecutionStartAI(OwnerController)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnStart, OwnerController)
  end
end

function BTDecorator_LuaBase_C:ReceiveExecutionFinishAI(OwnerController, ControlledPawn, NodeResult)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnEnd, OwnerController, NodeResult)
  end
end

function BTDecorator_LuaBase_C:ReceiveObserverActivatedAI(OwnerController, ControlledPawn)
  self:Init()
end

function BTDecorator_LuaBase_C:ReceiveObserverDeactivatedAI(OwnerController, ControlledPawn)
end

function BTDecorator_LuaBase_C:PerformConditionCheckAI(OwnerController, ControlledPawn)
  self:Init()
  if self.Action then
    return self:CallActionFunc(self.Action, self.Action.PerformConditionCheck, OwnerController)
  end
  return false
end

return BTDecorator_LuaBase_C
