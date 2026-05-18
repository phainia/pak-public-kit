local LoginFsmEvent = {}
setmetatable(LoginFsmEvent, {
  __index = function(t, k)
    local value = rawget(t, k)
    if value then
      return value
    else
      Log.ErrorFormat("LoginEvent missing %s!!", k)
      value = string.format("LoginEvent.%s", k)
      rawset(t, k, value)
      return value
    end
  end
})
return LoginFsmEvent
