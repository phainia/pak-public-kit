local LogExtend = {}

function LogExtend:Attach(target, prefix, enableLog)
  target.enableLog = enableLog or false
  
  function target:Log(...)
    if self.enableLog then
      Log.Debug(prefix, ...)
    end
  end
  
  function target:LogWarning(...)
    if self.enableLog then
      Log.Warning(prefix, ...)
    end
  end
  
  function target:LogError(...)
    if self.enableLog then
      Log.Error(prefix, ...)
    end
  end
end

return LogExtend
