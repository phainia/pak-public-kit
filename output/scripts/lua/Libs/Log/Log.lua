local IS_EDITOR = _G.RocoEnv.IS_EDITOR
local Log = {}
Log.Breakpoints = {}
Log.LOG_LEVEL = {
  ELogTrace = 1,
  ELogDebug = 2,
  ELogInfo = 3,
  ELogWarn = 4,
  ELogError = 5,
  ELogFatal = 6
}
Log.LOG_CALLBACK = {}
local ELogTrace = Log.LOG_LEVEL.ELogTrace
local ELogDebug = Log.LOG_LEVEL.ELogDebug
local ELogInfo = Log.LOG_LEVEL.ELogInfo
local ELogWarn = Log.LOG_LEVEL.ELogWarn
local ELogError = Log.LOG_LEVEL.ELogError
local ELogFatal = Log.LOG_LEVEL.ELogFatal
local LogLevel = ELogTrace
local levelInfo = {
  [ELogTrace] = "[Trace]",
  [ELogDebug] = "[Debug]",
  [ELogInfo] = "[Info]",
  [ELogWarn] = "[Warn]",
  [ELogError] = "[Error]",
  [ELogFatal] = "[Fatal]"
}
local showSrcInfo = true

function Log.SetPrintCallback(logLevel, callback)
  Log.LOG_CALLBACK[logLevel] = callback
end

function Log.SetLogLevel(newLogLevel)
  local levelType = type(newLogLevel)
  if "number" ~= levelType then
    Log.Error("SetLogLevel, error newloglevel", newLogLevel)
  else
    LogLevel = newLogLevel
  end
end

function Log.GetLogLevel()
  return LogLevel
end

function Log.LogInner(logLevel, debugLevel, ...)
  local params = {
    ...
  }
  if nil == logLevel then
    logLevel = ELogInfo
  end
  local logFunc = Log.LOG_CALLBACK[logLevel] or print
  if _G.EnableLogInfo then
    local info = debug.getinfo(debugLevel, "Sl")
    local src_info = info.short_src
    if src_info:find("%[string") then
      src_info = string.sub(src_info, 10, -3)
    end
    table.insert(params, "[" .. src_info .. ":" .. info.currentline .. "]")
    if logLevel == ELogTrace or logLevel >= ELogWarn then
      table.insert(params, "\n")
      table.insert(params, debug.traceback(nil, debugLevel))
    end
  elseif logLevel == ELogTrace or logLevel >= ELogWarn then
    table.insert(params, "\n")
    table.insert(params, debug.traceback(nil, debugLevel))
  end
  logFunc(table.unpack(params))
  if not IS_EDITOR then
    return
  end
  if 0 == #Log.Breakpoints then
    return
  end
  if not UE.UNRCEditorLuaLibrary then
    return
  end
  if not UE.UNRCEditorLuaLibrary.PausePIE then
    return
  end
  local Hit = false
  for Index, Param in ipairs(params) do
    if Index > 8 then
      break
    end
    Param = tostring(Param)
    for _, Breakpoint in ipairs(Log.Breakpoints) do
      local Start, _ = string.find(Param, Breakpoint)
      if Start and Start > 0 then
        Hit = true
        break
      end
    end
    if Hit then
      break
    end
  end
  if Hit then
    UE.UNRCEditorLuaLibrary.PausePIE()
  end
end

function Log.Trace(...)
  if LogLevel <= ELogTrace then
    Log.LogInner(Log.LOG_LEVEL.ELogTrace, 3, ...)
  end
end

function Log.LogWithLevel(logLevel, debugLevel, ...)
  if logLevel >= LogLevel then
    Log.LogInner(logLevel, debugLevel, ...)
  end
end

function Log.Msg(...)
  if not RocoEnv.IS_SHIPPING then
    Log.PrintScreenMsgBlue(...)
    Log.Trace(...)
  end
end

function Log.PrintScreenMsg(format, ...)
  if LogLevel <= ELogInfo then
    local content = string.format(format, ...)
    UE4Helper.PrintScreenMsg(content)
    Log.LogInner(Log.LOG_LEVEL.ELogInfo, 3, content)
  end
end

function Log.PrintScreenMsgRed(format, ...)
  if LogLevel <= ELogInfo then
    local content = string.format(format, ...)
    UE4Helper.PrintScreenMsgRed(content)
    Log.LogInner(Log.LOG_LEVEL.ELogInfo, 3, content)
  end
end

function Log.PrintScreenMsgBlue(...)
  if LogLevel <= ELogInfo then
    local params = {
      ...
    }
    local content = table.tostringLine(params)
    UE4Helper.PrintScreenMsgBlue(content)
    Log.LogInner(Log.LOG_LEVEL.ELogInfo, 3, content)
  end
end

function Log.Debug(...)
  if LogLevel <= ELogDebug then
    Log.LogInner(Log.LOG_LEVEL.ELogDebug, 3, ...)
  end
end

function Log.Info(...)
  if LogLevel <= ELogInfo then
    Log.LogInner(Log.LOG_LEVEL.ELogInfo, 3, ...)
  end
end

function Log.Warning(...)
  if LogLevel <= ELogWarn then
    Log.LogInner(Log.LOG_LEVEL.ELogWarn, 3, ...)
  end
end

function Log.Error(...)
  if LogLevel <= ELogError then
    Log.LogInner(Log.LOG_LEVEL.ELogError, 3, ...)
  end
end

function Log.SimpleError(...)
  if LogLevel <= ELogError then
    Log.LogInner(Log.LOG_LEVEL.ELogError, 3, ...)
  end
end

function Log.Fatal(...)
  if LogLevel <= ELogFatal then
    Log.LogInner(Log.LOG_LEVEL.ELogFatal, 3, ...)
  end
end

function Log.TraceFormat(format, ...)
  if LogLevel <= ELogTrace then
    Log.LogInner(Log.LOG_LEVEL.ELogTrace, 3, string.format(format, ...))
  end
end

function Log.DebugFormat(format, ...)
  if LogLevel <= ELogDebug then
    Log.LogInner(Log.LOG_LEVEL.ELogDebug, 3, string.format(format, ...))
  end
end

function Log.InfoFormat(format, ...)
  if LogLevel <= ELogInfo then
    Log.LogInner(Log.LOG_LEVEL.ELogInfo, 3, string.format(format, ...))
  end
end

function Log.WarningFormat(format, ...)
  if LogLevel <= ELogWarn then
    Log.LogInner(Log.LOG_LEVEL.ELogWarn, 3, string.format(format, ...))
  end
end

function Log.ErrorFormat(format, ...)
  if LogLevel <= ELogError then
    Log.LogInner(Log.LOG_LEVEL.ELogError, 3, string.format(format, ...))
  end
end

function Log.FatalFormat(format, ...)
  if LogLevel <= ELogFatal then
    Log.LogInner(Log.LOG_LEVEL.ELogFatal, 3, string.format(format, ...))
  end
end

function Log.TraceFunc(func, ...)
  if LogLevel <= ELogTrace then
    assert(type(func) == "function", "Log.TraceFunc need a function")
    local result = func(...)
    assert(type(result) == "string", "Log.TraceFunc 's function should return a string")
    Log.LogInner(Log.LOG_LEVEL.ELogTrace, 3, result)
  end
end

function Log.DebugFunc(func, ...)
  if LogLevel <= ELogDebug then
    assert(type(func) == "function", "Log.DebugFunc need a function")
    local result = func(...)
    assert(type(result) == "string", "Log.DebugFunc 's function should return a string")
    Log.LogInner(Log.LOG_LEVEL.ELogDebug, 3, result)
  end
end

function Log.InfoFunc(func, ...)
  if LogLevel <= ELogInfo then
    assert(type(func) == "function", "Log.InfoFunc need a function")
    local result = func(...)
    assert(type(result) == "string", "Log.InfoFunc 's function should return a string")
    Log.LogInner(Log.LOG_LEVEL.ELogInfo, 3, result)
  end
end

function Log.WarningFunc(func, ...)
  if LogLevel <= ELogWarn then
    assert(type(func) == "function", "Log.WarningFunc need a function")
    local result = func(...)
    assert(type(result) == "string", "Log.WarningFunc 's function should return a string")
    Log.LogInner(Log.LOG_LEVEL.ELogWarn, 3, result)
  end
end

function Log.ErrorFunc(func, ...)
  if LogLevel <= ELogError then
    assert(type(func) == "function", "Log.ErrorFunc need a function")
    local result = func(...)
    assert(type(result) == "string", "Log.ErrorFunc 's function should return a string")
    Log.LogInner(Log.LOG_LEVEL.ELogError, 3, result)
  end
end

function Log.FatalFunc(func, ...)
  if LogLevel <= ELogFatal then
    assert(type(func) == "function", "Log.FatalFunc need a function")
    local result = func(...)
    assert(type(result) == "string", "Log.FatalFunc 's function should return a string")
    Log.LogInner(Log.LOG_LEVEL.ELogFatal, 3, result)
  end
end

local levelFunc = {
  [ELogTrace] = Log.Trace,
  [ELogDebug] = Log.Debug,
  [ELogInfo] = Log.Info,
  [ELogWarn] = Log.Warning,
  [ELogError] = Log.Error,
  [ELogFatal] = Log.Fatal
}
local IS_SHIPPING = _G.RocoEnv.IS_SHIPPING

function Log.Dump(object, nesting, label, isReturnContents, level)
  if not label or "" == label then
    Log.Error("Dump\233\156\128\232\166\129\229\184\166\228\184\138\229\144\141\229\173\151\239\188\140\231\166\129\230\173\162\228\189\191\231\148\168\229\140\191\229\144\141Dump")
    return
  end
  if LogLevel > ELogDebug then
    return
  end
  label = label or "<var>"
  level = level or ELogDebug
  if type(nesting) ~= "number" then
    nesting = 4
  end
  if IS_SHIPPING then
    Log.Debug(object, nesting, label, isReturnContents, level)
    return ""
  end
  local lookupTable = {}
  local result = {}
  
  local function _v(v)
    if type(v) == "string" then
      v = "\"" .. v .. "\""
    end
    return tostring(v)
  end
  
  if not RocoEnv.IS_EDITOR then
    UE4Helper.PrintScreenMsg("Log.Dump : " .. label)
  end
  local echo = levelFunc[level]
  local _dump = function(object, label, indent, nest, keylen)
    label = label or "<var>"
    local spc = ""
    if type(keylen) == "number" then
      spc = string.rep(" ", keylen - string.len(_v(label)))
    end
    if type(object) ~= "table" then
      result[#result + 1] = string.format("%s%s%s = %s", indent, _v(label), spc, _v(object))
    elseif lookupTable[object] then
      result[#result + 1] = string.format("%s%s%s = *REF*", indent, label, spc)
    else
      lookupTable[object] = true
      if type(label) == "string" and "class" == label then
        result[#result + 1] = string.format("%s%s = *Ignored*", indent, label)
        return
      end
      if nest > nesting then
        result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, label)
      else
        result[#result + 1] = string.format("%s%s = {", indent, _v(label))
        local indent2 = indent .. "    "
        local keys = {}
        local keylen = 0
        local values = {}
        for k, v in pairs(object) do
          keys[#keys + 1] = k
          local vk = _v(k)
          local vkl = string.len(vk)
          if keylen < vkl then
            keylen = vkl
          end
          values[k] = v
        end
        table.sort(keys, function(a, b)
          if type(a) == "number" and type(b) == "number" then
            return a < b
          else
            return tostring(a) < tostring(b)
          end
        end)
        for i, k in ipairs(keys) do
          _dump(values[k], k, indent2, nest + 1, keylen)
        end
        result[#result + 1] = string.format("%s}", indent)
      end
    end
  end
  _dump(object, label, "- ", 1)
  if isReturnContents then
    return table.concat(result, "\n")
  end
  local tempResult = {}
  for i = 1, #result do
    table.insert(tempResult, result[i])
    if 0 == i % 50 then
      tempResult[1] = "  " .. tempResult[1]
      echo(table.concat(tempResult, [[

	]]))
      tempResult = {}
      showSrcInfo = false
    end
  end
  if 0 ~= #tempResult then
    tempResult[1] = "  " .. tempResult[1]
    echo(table.concat(tempResult, [[

	]]))
  end
  showSrcInfo = true
end

function Log.VarDump(object, label)
  label = label or "<var>"
  if nil == object then
    return label .. "nil"
  end
  local lookupTable = {}
  local result = {}
  
  local function _v(v)
    if type(v) == "string" then
      v = "\"" .. v .. "\""
    end
    return tostring(v)
  end
  
  local _vardump = function(object, label, indent, nest)
    label = label or "<var>"
    local postfix = ""
    if nest > 1 then
      postfix = ","
    end
    if type(object) ~= "table" then
      if type(label) == "string" then
        result[#result + 1] = string.format("%s%s = %s%s", indent, label, _v(object), postfix)
      else
        result[#result + 1] = string.format("%s%s%s", indent, _v(object), postfix)
      end
    elseif not lookupTable[object] then
      lookupTable[object] = true
      if type(label) == "string" then
        result[#result + 1] = string.format("%s%s = {", indent, label)
      else
        result[#result + 1] = string.format("%s{", indent)
      end
      local indent2 = indent .. "    "
      local keys = {}
      local values = {}
      for k, v in pairs(object) do
        keys[#keys + 1] = k
        values[k] = v
      end
      table.sort(keys, function(a, b)
        if type(a) == "number" and type(b) == "number" then
          return a < b
        else
          return tostring(a) < tostring(b)
        end
      end)
      for i, k in ipairs(keys) do
        _vardump(values[k], k, indent2, nest + 1)
      end
      result[#result + 1] = string.format("%s}%s", indent, postfix)
    end
  end
  _vardump(object, label, "", 1)
  return table.concat(result, "\n")
end

function Log.Inspect(level)
  if not _G.RocoEnv.IS_EDITOR then
    return
  end
  level = level or 2
  local info = debug.getinfo(level, "Sunf")
  if not info then
    return
  end
  local Ups, Params, Locals
  local i = 1
  while true do
    local PName, Value = debug.getlocal(level, i)
    if nil == PName then
      break
    end
    if i <= info.nparams then
      Params = Params or {}
      Params[PName] = Value
    else
      Locals = Locals or {}
      Locals[PName] = Value
    end
    i = i + 1
  end
  local Count = 0
  for j = 1, info.nups do
    local UName, Val = debug.getupvalue(info.func, j)
    if "_ENV" == UName then
    elseif nil ~= Val then
      Ups = Ups or {}
      Ups[UName] = Val
      Count = Count + 1
    end
  end
  if info or Ups or Params or Locals then
    local Summary = {
      Info = info,
      UpValues = Ups,
      Params = Params,
      Locals = Locals
    }
    Log.Dump(Summary, 3, info.source)
    return Summary
  end
  return nil
end

local JsonUtils, rapidjson
local TempVisit = {}

function Log.DumpSingleLine(object, nesting, label, ignoreFunctions)
  if LogLevel > ELogDebug then
    return
  end
  if not JsonUtils then
    JsonUtils = require("Common.JsonUtils")
  end
  if not JsonUtils then
    return
  end
  if not rapidjson then
    rapidjson = require("rapidjson")
  end
  nesting = nesting or 3
  label = label or "<Unknown>"
  local PureObject = JsonUtils.ExtractTable(object, TempVisit, nesting, ignoreFunctions)
  Log.DebugFormat("%s:%s", label, rapidjson.encode(PureObject))
  table.clear(TempVisit)
end

return Log
