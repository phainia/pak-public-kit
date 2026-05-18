local serpent = require("Libs.serpent.serpent")
local FunctionClosurePool = require("Utils.FunctionClosurePool")

function _G.GlobalEmptyMsgFunc()
  return ""
end

function _G.GlobalIdentityFunc(x)
  return x
end

local ClosurePool = FunctionClosurePool()
ClosurePool:WarmingUp(10)

function _G.tcall(caller, func, arg1, arg2, arg3, arg4, arg5, arg6)
  local msgFunc = _G.GlobalIdentityFunc
  if not RocoEnv.IS_SHIPPING then
    msgFunc = debug.traceback
  end
  return _do_tcall(caller, func, arg1, arg2, arg3, arg4, arg5, arg6)
end

function _G.tcallForBattle(caller, func, arg1, arg2, arg3, arg4, arg5, arg6)
  return _do_tcall(caller, func, arg1, arg2, arg3, arg4, arg5, arg6)
end

function _G._do_tcall(caller, func, arg1, arg2, arg3, arg4, arg5, arg6)
  local FunctionClosure = ClosurePool:CreateFromPool()
  FunctionClosure:SetParameters(caller, func, arg1, arg2, arg3, arg4, arg5, arg6)
  local status, err, ret = xpcall(FunctionClosure.Function, debug.traceback)
  ClosurePool:ReturnToPool(FunctionClosure)
  if not status then
    Log.Error(err)
  end
  return status, err, ret
end

function _G.FPartial(f, p1, p2, p3, p4, p5, p6)
  if nil ~= p6 then
    return function(...)
      return f(p1, p2, p3, p4, p5, p6, ...)
    end
  elseif nil ~= p5 then
    return function(...)
      return f(p1, p2, p3, p4, p5, ...)
    end
  elseif nil ~= p4 then
    return function(...)
      return f(p1, p2, p3, p4, ...)
    end
  elseif nil ~= p3 then
    return function(...)
      return f(p1, p2, p3, ...)
    end
  elseif nil ~= p2 then
    return function(...)
      return f(p1, p2, ...)
    end
  elseif nil ~= p1 then
    return function(...)
      return f(p1, ...)
    end
  else
    return f
  end
end

function _G.MakeWeakTable(table, mode)
  return setmetatable(table or {}, {
    __mode = mode or "kv"
  })
end

function _G.do_wait_until(cond_func, func, arg1, arg2, arg3, arg4, arg5, arg6)
  if cond_func() then
    func(arg1, arg2, arg3, arg4, arg5, arg6)
    return
  end
  local update_target = {
    name = "do_wait_until_target",
    OnTick = function(self)
      if cond_func() then
        func(arg1, arg2, arg3, arg4, arg5, arg6)
        _G.UpdateManager:UnRegister(self)
      end
    end
  }
  _G.UpdateManager:Register(update_target)
end

function os.msTime()
  return UE4.UNRCStatics.GetTimestampMS()
end

function _G.TableToString(t, ...)
  if not _G.EnableLogInfo then
    return ""
  end
  return serpent.block(t, ...)
end

function table.tostring(t, ...)
  if not _G.EnableLogInfo then
    return ""
  end
  return serpent.block(t, ...)
end

function table.tostringLine(t)
  if not _G.EnableLogInfo then
    return ""
  end
  local result = {}
  for k, v in pairs(t) do
    table.insert(result, tostring(v))
  end
  return table.concat(result, " ")
end

function table.len(t)
  local i = 0
  for k, v in pairs(t) do
    i = i + 1
  end
  return i
end

function table.isNil(t)
  return next(t) == nil
end

function string.safeFormat(fmt, ...)
  if type(fmt) ~= "string" then
    return ""
  end
  local ok, result = pcall(string.format, fmt, ...)
  if ok then
    return result
  else
    local errMsg = tostring(result)
    Log.Error(string.format("[string.safeformat] %s Format error: %s\n", fmt, errMsg))
    return fmt
  end
end

function string.urlEncode(str)
  if str then
    str = string.gsub(str, "([^%w%-%.%_%~])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    return str
  end
  return ""
end
