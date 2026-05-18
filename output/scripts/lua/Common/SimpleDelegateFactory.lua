local SimpleDelegateFactory = _G.Singleton:Extend("SimpleDelegateFactory")

function SimpleDelegateFactory:Ctor()
  _G.Singleton.Ctor(self, self.name)
  Log.Debug("SimpleDelegateFactory ctor")
  self.weakFunctionRefLst = setmetatable({}, {__mode = "v"})
end

function SimpleDelegateFactory:CreateUDelegate(panel, caller, handler)
  local function func(panel, ...)
    if NRCUtils.CheckUserWidgetExist(panel) then
      local arg1, arg2, arg3, arg4, arg5, arg6 = ...
      
      tcall(caller, handler, arg1, arg2, arg3, arg4, arg5, arg6)
    end
  end
  
  table.insert(self.weakFunctionRefLst, func)
  return func
end

function SimpleDelegateFactory:CreateCallback(caller, handler)
  local function func(target, ...)
    return handler(caller, ...)
  end
  
  table.insert(self.weakFunctionRefLst, func)
  return func
end

return SimpleDelegateFactory
