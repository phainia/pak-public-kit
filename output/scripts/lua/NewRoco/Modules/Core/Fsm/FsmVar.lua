local Class = _G.MakeSimpleClass
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local FsmVar = Class("FsmVar")
FsmVar:SetMemberCount(4)

function FsmVar:Ctor()
  self.isVar = false
end

function FsmVar:SetAsVar(name, properties)
  self.isVar = true
  self.name = name
  self.properties = properties
  FsmUtils.SetProperty(self, self.name, self.value)
  self.value = nil
end

function FsmVar:SetAsValue(value)
  self.isVar = false
  self.value = value or FsmUtils.GetProperty(self, self.name, value)
  self.properties = nil
  self.name = nil
end

function FsmVar:Get(default)
  if self.isVar then
    return FsmUtils.GetProperty(self, self.name, default)
  else
    return self.value or default
  end
end

function FsmVar:Set(value)
  if self.isVar then
    FsmUtils.SetProperty(self, self.name, value)
  else
    self.value = value
  end
end

function FsmVar.Resolve(Value, Default)
  if nil == Value then
    return Default
  end
  if type(Value) == "table" and Value.InstanceOf and Value:InstanceOf(FsmVar) then
    return Value:Get(Default)
  end
  return Value
end

function FsmVar.CreateVar(name, properties)
  local Var = FsmVar()
  Var.isVar = true
  Var.name = name
  Var.properties = properties
  return Var
end

function FsmVar.CreateValue(value)
  local Var = FsmVar()
  Var.isVar = false
  Var.value = value
  return Var
end

return FsmVar
