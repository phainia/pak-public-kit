require("UnLuaEx")
local Base = require("NewRoco.AI.BehaviorTree.BTNode_LuaBase")
local BTTask_LuaBase_C = Base:Extend("BTTask_LuaBase_C")

function BTTask_LuaBase_C:Ctor(LuaBTNodeBase)
  self.LuaFileFolderPath = "NewRoco.AI.BehaviorTree.Actions"
end

function BTTask_LuaBase_C:ReceiveExecute(OwnerActor)
  self:Init()
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnStart, OwnerActor)
  end
end

function BTTask_LuaBase_C:ReceiveExecuteAI(OwnerController, ControlledPawn)
  self:Init()
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnStart, OwnerController)
  end
end

function BTTask_LuaBase_C:ReceiveTick(OwnerActor, DeltaSeconds)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnUpdate, OwnerActor, DeltaSeconds)
  end
end

function BTTask_LuaBase_C:ReceiveTickAI(OwnerController, ControlledPawn, DeltaSeconds)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnUpdate, OwnerController, DeltaSeconds)
  end
end

function BTTask_LuaBase_C:ReceiveAbort(OwnerActor)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnInterrupt, OwnerActor)
  end
end

function BTTask_LuaBase_C:ReceiveAbortAI(OwnerController, ControlledPawn)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnInterrupt, OwnerController)
  end
end

function BTTask_LuaBase_C:Finish(...)
  local args = {
    ...
  }
  if #args < 1 then
    Log.Error("Arguments length error")
  end
  local success = args[1]
  self.Overridden.FinishExecute(self, success)
end

return BTTask_LuaBase_C
