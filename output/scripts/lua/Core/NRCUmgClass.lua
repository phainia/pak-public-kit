local NRCUmgClass = _G.NRCClass:Extend("NRCUmgClass")
NRCUmgClass.ClassType = "NRCUmgClass"

function NRCUmgClass:__Ctor()
  _G.NRCClass.__Ctor(self)
  self.enableLog = true
  self.LogPrefix = string.format("[%s]", self.viewName or self.name)
  self.isConstruct = false
  self.isDestruct = false
end

function NRCUmgClass:__Initialize()
  self.__index = LuaClassIndex
  self.__newindex = LuaClassNewIndex
  if self.Ctor then
    self:Ctor()
  end
  self:Construct()
end

function NRCUmgClass:Construct()
  if not self.isConstruct then
    self.isConstruct = true
    self:OnConstruct()
  end
end

function NRCUmgClass:OnConstruct()
end

function NRCUmgClass:NConstruct()
end

function NRCUmgClass:NDestruct()
end

function NRCUmgClass:DoCmd(cmd, ...)
  NRCModeManager:DoCmd(cmd, ...)
end

function NRCUmgClass:Destruct()
  if self.isDestruct == false then
    self:OnDestruct()
    self:UnbindSelfRef()
    self.isDestruct = true
    self.class = nil
    self.Super = nil
    self:ReleaseForce()
  end
end

function NRCUmgClass:OnDestruct()
end

function NRCUmgClass:FilterType(v)
  for i = 1, #_G.FilterTypeLst do
    local idx, _ = string.find(tostring(v), _G.FilterTypeLst[i])
    if idx and idx >= 0 then
      return true
    end
  end
  return false
end

function NRCUmgClass:CleanupFunctions()
  UE4.UNRCStatics.CleanupFunctionsByClass(self)
end

function NRCUmgClass:Log(...)
  if self.enableLog then
    Log.LogWithLevel(Log.LOG_LEVEL.ELogDebug, 4, self.LogPrefix, ...)
  end
end

function NRCUmgClass:LogError(...)
  if self.enableLog then
    Log.LogWithLevel(Log.LOG_LEVEL.ELogError, 3, self.LogPrefix, ...)
  end
end

function NRCUmgClass:SafeCall(widget, funcName, ...)
  if widget then
    local func = widget[funcName]
    if func then
      func(widget, ...)
    end
  end
end

function NRCUmgClass:SafeSet(widget, k, v)
  if widget then
    widget[k] = v
  end
end

return NRCUmgClass
