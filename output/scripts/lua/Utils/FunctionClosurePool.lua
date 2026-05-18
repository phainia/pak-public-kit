local FunctionClosureFactory = {}

function FunctionClosureFactory:New()
  local UpValues = {}
  
  local function Function()
    if not UpValues.func then
      Log.Error("FunctionClosure: __call: func is nil")
      return
    end
    if UpValues.caller then
      return UpValues.func(UpValues.caller, UpValues.arg1, UpValues.arg2, UpValues.arg3, UpValues.arg4, UpValues.arg5, UpValues.arg6)
    else
      return UpValues.func(UpValues.arg1, UpValues.arg2, UpValues.arg3, UpValues.arg4, UpValues.arg5, UpValues.arg6)
    end
  end
  
  local Closure = {
    UpValues = UpValues,
    Function = Function,
    SetParameters = function(self, caller, func, arg1, arg2, arg3, arg4, arg5, arg6)
      UpValues.caller = caller
      UpValues.func = func
      UpValues.arg1 = arg1
      UpValues.arg2 = arg2
      UpValues.arg3 = arg3
      UpValues.arg4 = arg4
      UpValues.arg5 = arg5
      UpValues.arg6 = arg6
    end
  }
  return Closure
end

local FunctionClosurePool = Class("FunctionClosurePool")
FunctionClosurePool.Pool = {}
FunctionClosurePool.StackTop = 0

function FunctionClosurePool:WarmingUp(Size)
  self.Pool = table.new(Size, 0)
  for i = 1, Size do
    self.Pool[i] = FunctionClosureFactory.New()
  end
end

function FunctionClosurePool:CreateFromPool()
  local Closure = table.remove(self.Pool)
  if not Closure then
    return FunctionClosureFactory.New()
  end
  return Closure
end

function FunctionClosurePool:ReturnToPool(Closure)
  table.insert(self.Pool, Closure)
end

return FunctionClosurePool
