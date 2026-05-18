require("UnLuaEx")
local Base = require("NewRoco.AI.BehaviorTree.BTNode_LuaBase")
local BTService_LuaBase_C = Base:Extend("BTService_LuaBase_C")

function BTService_LuaBase_C:Ctor(LuaBTNodeBase)
  self.Name = "LuaServiceBase"
  self.BTNodeBase = LuaBTNodeBase
  self.LuaFileFolderPath = "NewRoco.AI.BehaviorTree.Services"
end

function BTService_LuaBase_C:ReceiveActivation(OwnerActor)
  self:Init()
end

function BTService_LuaBase_C:ReceiveDeactivation(OwnerActor)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnEnd, OwnerActor)
  end
end

function BTService_LuaBase_C:ReceiveSearchStart(OwnerActor)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnStart, OwnerActor)
  end
end

function BTService_LuaBase_C:ReceiveTick(OwnerActor, DeltaSeconds)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnUpdateService, OwnerActor, DeltaSeconds)
  end
end

function BTService_LuaBase_C:ReceiveActivationAI(OwnerController, ControlledPawn)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnStart, OwnerController)
  end
end

function BTService_LuaBase_C:ReceiveDeactivationAI(OwnerController, ControlledPawn)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnEnd, OwnerController)
  end
end

function BTService_LuaBase_C:ReceiveSearchStartAI(OwnerController, ControlledPawn)
  self:Init()
end

function BTService_LuaBase_C:ReceiveTickAI(OwnerController, ControlledPawn, DeltaSeconds)
  if self.Action then
    self:CallActionFunc(self.Action, self.Action.OnUpdateService, OwnerController, DeltaSeconds)
  end
end

return BTService_LuaBase_C
