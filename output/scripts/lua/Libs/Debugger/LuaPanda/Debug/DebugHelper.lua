local DebugHelper = {}
local config = {
  enabled = true,
  logLevel = 3,
  maxTableDepth = 5,
  maxTableItems = 100,
  showFileInfo = true,
  colorEnabled = false,
  defaultHost = "127.0.0.1",
  defaultPort = 8818
}
local LogLevel = {
  OFF = 0,
  ERROR = 1,
  WARNING = 2,
  INFO = 3,
  DEBUG = 4
}
local luaPanda

local function get_caller_info(level)
  level = level or 2
  local info = debug.getinfo(level, "Sl")
  if info then
    local source = info.source
    if source:sub(1, 1) == "@" then
      source = source:sub(2)
    end
    source = source:match("[^/\\]+$") or source
    return string.format("[%s:%d]", source, info.currentline or 0)
  end
  return "[unknown]"
end

local function format_timestamp()
  return os.date("%H:%M:%S")
end

local function format_log_prefix(level_name)
  local prefix = string.format("[%s]", level_name)
  if config.showFileInfo then
    prefix = prefix .. " " .. get_caller_info(4)
  end
  return prefix
end

local function safe_tostring(value)
  local ok, result = pcall(tostring, value)
  if ok then
    return result
  else
    return string.format("<%s: tostring failed>", type(value))
  end
end

local function is_array(t)
  if type(t) ~= "table" then
    return false
  end
  local max_index = 0
  local count = 0
  for k, _ in pairs(t) do
    if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
      return false
    end
    max_index = math.max(max_index, k)
    count = count + 1
  end
  return count == max_index
end

function DebugHelper.StartDebugger(host, port)
  host = host or config.defaultHost
  port = port or config.defaultPort
  local ok, LuaPanda = pcall(require, "Libs.Debugger.LuaPanda.LuaPanda")
  if not ok then
    print("[DebugHelper] Error: Failed to load LuaPanda module")
    print("  " .. tostring(LuaPanda))
    return false
  end
  luaPanda = LuaPanda
  print(string.format("[DebugHelper] Starting LuaPanda debugger at %s:%d", host, port))
  local success = LuaPanda.start(host, port)
  if success then
    print("[DebugHelper] Debugger started successfully")
    return true
  else
    print("[DebugHelper] Debugger start failed (will retry in attach mode)")
    return false
  end
end

function DebugHelper.StopDebugger()
  if luaPanda and luaPanda.disconnect then
    luaPanda.disconnect()
    print("[DebugHelper] Debugger disconnected")
  end
end

function DebugHelper.BreakPoint(condition)
  if not config.enabled then
    return
  end
  if condition then
    if type(condition) == "function" then
      local ok, result = pcall(condition)
      if not ok or not result then
        return
      end
    elseif not condition then
      return
    end
  end
  if luaPanda and luaPanda.BP then
    luaPanda.BP()
  else
    print("[DebugHelper] BreakPoint hit at " .. get_caller_info(2))
  end
end

local function log_internal(level, level_name, ...)
  if not config.enabled or level > config.logLevel then
    return
  end
  local prefix = format_log_prefix(level_name)
  local args = {
    ...
  }
  local messages = {}
  for i = 1, #args do
    table.insert(messages, safe_tostring(args[i]))
  end
  local message = table.concat(messages, " ")
  print(prefix .. " " .. message)
end

function DebugHelper.LogError(...)
  log_internal(LogLevel.ERROR, "ERROR", ...)
end

function DebugHelper.LogWarning(...)
  log_internal(LogLevel.WARNING, "WARN", ...)
end

function DebugHelper.LogInfo(...)
  log_internal(LogLevel.INFO, "INFO", ...)
end

function DebugHelper.LogDebug(...)
  log_internal(LogLevel.DEBUG, "DEBUG", ...)
end

function DebugHelper.Log(...)
  DebugHelper.LogInfo(...)
end

function DebugHelper.PrintTable(t, name, max_depth)
  if not config.enabled then
    return
  end
  name = name or "table"
  max_depth = max_depth or config.maxTableDepth
  local cache = {}
  local output_lines = {}
  local _print_table = function(tbl, depth, prefix)
    if depth > max_depth then
      table.insert(output_lines, prefix .. "... (max depth reached)")
      return
    end
    if "table" ~= type(tbl) then
      table.insert(output_lines, prefix .. safe_tostring(tbl))
      return
    end
    if cache[tbl] then
      table.insert(output_lines, prefix .. "... (circular reference)")
      return
    end
    cache[tbl] = true
    local count = 0
    for _ in pairs(tbl) do
      count = count + 1
    end
    if 0 == count then
      table.insert(output_lines, prefix .. "{}")
      return
    end
    table.insert(output_lines, prefix .. "{")
    local is_arr = is_array(tbl)
    local item_count = 0
    if is_arr then
      for i = 1, #tbl do
        item_count = item_count + 1
        if item_count > config.maxTableItems then
          table.insert(output_lines, prefix .. "  ... (" .. count - config.maxTableItems .. " more items)")
          break
        end
        local value = tbl[i]
        if "table" == type(value) then
          table.insert(output_lines, prefix .. "  [" .. i .. "] =")
          _print_table(value, depth + 1, prefix .. "    ")
        else
          table.insert(output_lines, string.format("%s  [%d] = %s", prefix, i, safe_tostring(value)))
        end
      end
    else
      for k, v in pairs(tbl) do
        item_count = item_count + 1
        if item_count > config.maxTableItems then
          table.insert(output_lines, prefix .. "  ... (" .. count - config.maxTableItems .. " more items)")
          break
        end
        local key_str = safe_tostring(k)
        if "table" == type(v) then
          table.insert(output_lines, prefix .. "  [" .. key_str .. "] =")
          _print_table(v, depth + 1, prefix .. "    ")
        else
          table.insert(output_lines, string.format("%s  [%s] = %s", prefix, key_str, safe_tostring(v)))
        end
      end
    end
    table.insert(output_lines, prefix .. "}")
  end
  print([[

========== ]] .. name .. " ==========")
  _print_table(t, 0, "")
  print(table.concat(output_lines, "\n"))
  print("========================================\n")
end

function DebugHelper.PrintTableSimple(t, name)
  if not config.enabled then
    return
  end
  name = name or "table"
  local parts = {}
  for k, v in pairs(t or {}) do
    table.insert(parts, string.format("%s=%s", tostring(k), tostring(v)))
  end
  print(string.format("[%s] { %s }", name, table.concat(parts, ", ")))
end

function DebugHelper.PrintCallStack(max_levels)
  if not config.enabled then
    return
  end
  max_levels = max_levels or 20
  print([[

========== Call Stack ==========]])
  local level = 2
  while max_levels >= level do
    local info = debug.getinfo(level, "Slnf")
    if not info then
      break
    end
    local source = info.source or "unknown"
    if source:sub(1, 1) == "@" then
      source = source:sub(2)
    end
    source = source:match("[^/\\]+$") or source
    local name = info.name or "<anonymous>"
    local line = info.currentline or 0
    print(string.format("  #%d %s at %s:%d", level - 1, name, source, line))
    level = level + 1
  end
  print("================================\n")
end

function DebugHelper.GetCallStackString(max_levels)
  max_levels = max_levels or 20
  local lines = {}
  local level = 2
  while max_levels >= level do
    local info = debug.getinfo(level, "Sl")
    if not info then
      break
    end
    local source = info.source or "unknown"
    if source:sub(1, 1) == "@" then
      source = source:sub(2)
    end
    source = source:match("[^/\\]+$") or source
    table.insert(lines, string.format("%s:%d", source, info.currentline or 0))
    level = level + 1
  end
  return table.concat(lines, " <- ")
end

function DebugHelper.MeasureTime(func, name)
  if not config.enabled then
    return func()
  end
  name = name or "function"
  local start_time = os.clock()
  local results = {
    pcall(func)
  }
  local end_time = os.clock()
  local elapsed = (end_time - start_time) * 1000
  if results[1] then
    print(string.format("[DebugHelper] %s executed in %.3f ms", name, elapsed))
    table.remove(results, 1)
    return unpack(results)
  else
    print(string.format("[DebugHelper] %s failed after %.3f ms: %s", name, elapsed, tostring(results[2])))
    error(results[2])
  end
end

local timers = {}

function DebugHelper.StartTimer(name)
  if not config.enabled then
    return
  end
  timers[name] = os.clock()
  print(string.format("[DebugHelper] Timer '%s' started", name))
end

function DebugHelper.StopTimer(name)
  if not config.enabled then
    return
  end
  local start_time = timers[name]
  if not start_time then
    print(string.format("[DebugHelper] Timer '%s' not found", name))
    return
  end
  local elapsed = (os.clock() - start_time) * 1000
  print(string.format("[DebugHelper] Timer '%s' stopped: %.3f ms", name, elapsed))
  timers[name] = nil
  return elapsed
end

local watches = {}

function DebugHelper.Watch(name, value_or_getter)
  if not config.enabled then
    return
  end
  local getter
  if type(value_or_getter) == "function" then
    getter = value_or_getter
  else
    function getter()
      return value_or_getter
    end
  end
  watches[name] = {getter = getter, last_value = nil}
  print(string.format("[DebugHelper] Watching '%s'", name))
end

function DebugHelper.Unwatch(name)
  if watches[name] then
    watches[name] = nil
    print(string.format("[DebugHelper] Stopped watching '%s'", name))
  end
end

function DebugHelper.PrintWatches()
  if not config.enabled then
    return
  end
  print([[

========== Watched Variables ==========]])
  for name, watch in pairs(watches) do
    local ok, value = pcall(watch.getter)
    if ok then
      local changed = ""
      if watch.last_value ~= nil and watch.last_value ~= value then
        changed = string.format(" (was: %s)", safe_tostring(watch.last_value))
      end
      print(string.format("  %s = %s%s", name, safe_tostring(value), changed))
      watch.last_value = value
    else
      print(string.format("  %s = <error: %s>", name, tostring(value)))
    end
  end
  print("=======================================\n")
end

function DebugHelper.PrintMemoryUsage()
  if not config.enabled then
    return
  end
  local memory_kb = collectgarbage("count")
  print(string.format("[DebugHelper] Memory Usage: %.2f KB (%.2f MB)", memory_kb, memory_kb / 1024))
end

function DebugHelper.ForceGC()
  if not config.enabled then
    return
  end
  local before = collectgarbage("count")
  collectgarbage("collect")
  local after = collectgarbage("count")
  local freed = before - after
  print(string.format("[DebugHelper] GC: %.2f KB -> %.2f KB (freed %.2f KB)", before, after, freed))
end

function DebugHelper.Assert(condition, message)
  if not condition then
    message = message or "Assertion failed"
    DebugHelper.LogError(message)
    DebugHelper.PrintCallStack()
    DebugHelper.BreakPoint()
    error(message)
  end
end

function DebugHelper.AssertEqual(actual, expected, message)
  if actual ~= expected then
    message = message or string.format("Expected %s, got %s", safe_tostring(expected), safe_tostring(actual))
    DebugHelper.Assert(false, message)
  end
end

function DebugHelper.AssertNotNil(value, message)
  message = message or "Value is nil"
  DebugHelper.Assert(nil ~= value, message)
end

function DebugHelper.SetConfig(key, value)
  if nil ~= config[key] then
    config[key] = value
    print(string.format("[DebugHelper] Config '%s' set to %s", key, tostring(value)))
  else
    print(string.format("[DebugHelper] Unknown config key: %s", key))
  end
end

function DebugHelper.GetConfig(key)
  return config[key]
end

function DebugHelper.Enable()
  config.enabled = true
  print("[DebugHelper] Debugging enabled")
end

function DebugHelper.Disable()
  config.enabled = false
  print("[DebugHelper] Debugging disabled")
end

function DebugHelper.SetLogLevel(level)
  config.logLevel = level
  local level_names = {
    "OFF",
    "ERROR",
    "WARNING",
    "INFO",
    "DEBUG"
  }
  print(string.format("[DebugHelper] Log level set to %s", level_names[level + 1] or "UNKNOWN"))
end

function DebugHelper.CheckType(value, name)
  if not config.enabled then
    return
  end
  name = name or "value"
  local t = type(value)
  print(string.format("[DebugHelper] %s: type=%s, value=%s", name, t, safe_tostring(value)))
  if "table" == t then
    local count = 0
    for _ in pairs(value) do
      count = count + 1
    end
    print(string.format("             table size: %d items", count))
  end
end

function DebugHelper.CompareTables(t1, t2, name1, name2)
  if not config.enabled then
    return
  end
  name1 = name1 or "table1"
  name2 = name2 or "table2"
  print(string.format([[

========== Comparing %s and %s ==========]], name1, name2))
  local differences = {}
  for k, v1 in pairs(t1 or {}) do
    local v2 = t2[k]
    if nil == v2 then
      table.insert(differences, string.format("  [%s] only in %s", tostring(k), name1))
    elseif v1 ~= v2 then
      table.insert(differences, string.format("  [%s] %s=%s, %s=%s", tostring(k), name1, tostring(v1), name2, tostring(v2)))
    end
  end
  for k in pairs(t2 or {}) do
    if nil == t1[k] then
      table.insert(differences, string.format("  [%s] only in %s", tostring(k), name2))
    end
  end
  if 0 == #differences then
    print("  Tables are identical")
  else
    for _, diff in ipairs(differences) do
      print(diff)
    end
  end
  print("===========================================\n")
end

DebugHelper.LogLevel = LogLevel
return DebugHelper
