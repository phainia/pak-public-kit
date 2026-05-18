local co = coroutine
local assert = _ENV.assert
local type = _ENV.type
local t_remove = table.remove
local t_unpack = table.unpack
local t_insert = table.insert
local select = _ENV.select
local pcall = _ENV.pcall
local pairs = _ENV.pairs
local ipairs = _ENV.ipairs
local setmetatable = _ENV.setmetatable

local function pong(func, ...)
  local param = {
    ...
  }
  local callback
  if #param > 0 and "function" == type(param[#param]) then
    callback = t_remove(param)
  end
  callback = callback or function(noUncheckedError, ...)
  end
  if "function" == not type(func) then
    callback(false, "[async] sync func type error :: expected func")
    return nil
  end
  local thread = co.create(func)
  local step
  local context = {
    thread = thread,
    waitingStepIndex = 0,
    finished = false,
    killed = false,
    subContexts = setmetatable({}, {__mode = "v"}),
    step = nil
  }
  
  function step(...)
    local args = {
      ...
    }
    while true do
      if context.killed or co.status(thread) == "dead" then
        if not context.finished then
          context.finished = true
          callback(false, "[async] task is killed or dead")
        end
        return
      end
      context.waitingStepIndex = context.waitingStepIndex + 1
      local resumeResult = {
        co.resume(thread, t_unpack(args))
      }
      args = nil
      if not resumeResult[1] then
        if not context.finished then
          context.finished = true
          callback(false, resumeResult[2])
        end
        return
      end
      if co.status(thread) == "dead" then
        if not context.finished then
          context.finished = true
          callback(true, t_unpack(resumeResult, 2))
        end
        return
      else
        local write_index = 1
        local context_count = #context.subContexts
        for k, _ in pairs(context.subContexts) do
          if "number" == type(k) then
            context_count = math.max(context_count, k)
          end
        end
        for i = 1, context_count do
          local subContext = context.subContexts[i]
          if subContext and not subContext.killed and "dead" ~= co.status(subContext.thread) then
            if i ~= write_index then
              context.subContexts[write_index] = subContext
              context.subContexts[i] = nil
            end
            write_index = write_index + 1
          else
            context.subContexts[i] = nil
          end
        end
        local thunk = resumeResult[2]
        if "function" ~= type(thunk) then
          if not context.finished then
            context.finished = true
            callback(false, "[async] thunk callback type error :: expected func")
          end
          return
        end
        local stepIndex = context.waitingStepIndex
        local currentStack = true
        
        local function nextStep(...)
          if stepIndex ~= context.waitingStepIndex then
            return
          end
          if currentStack then
            args = {
              ...
            }
          else
            step(...)
          end
        end
        
        local status, rsl = pcall(thunk, nextStep)
        currentStack = false
        if not status then
          if not context.finished then
            context.finished = true
            callback(false, rsl)
          end
          return
        end
        if rsl and "table" == type(rsl) and rsl.__async_command__ then
          if rsl.__async_push_sub_context__ then
            t_insert(context.subContexts, rsl)
          end
          if rsl.__async_push_multi_sub_context__ then
            for _, v in ipairs(rsl) do
              t_insert(context.subContexts, v)
            end
          end
          if rsl.__async_get_context__ and nil == args then
            args = {context}
          end
        end
        if not args then
          return
        end
      end
    end
  end
  
  context.step = step
  step(t_unpack(param))
  context.__async_command__ = true
  context.__async_push_sub_context__ = true
  return context
end

local function wrap(func)
  assert("function" == type(func), "[async] type error :: expected func")
  
  local function factory(...)
    local params = {
      ...
    }
    local param_count = select("#", ...) + 1
    
    local function thunk(callback)
      params[param_count] = callback
      return func(t_unpack(params, 1, param_count))
    end
    
    return thunk
  end
  
  return factory
end

local function live(context)
  return co.status(context.thread) ~= "dead" and not context.killed
end

local function kill(context, lazy)
  local stack = {context}
  local anyAlive = false
  while #stack > 0 do
    local current = table.remove(stack)
    if live(current) then
      anyAlive = true
      current.killed = true
      if not lazy then
        current.step()
      end
      for i = #current.subContexts, 1, -1 do
        t_insert(stack, current.subContexts[i])
      end
    end
  end
  return anyAlive
end

local function join(thunks, by_map)
  local len
  if by_map then
    len = 0
    for _, _ in pairs(thunks) do
      len = len + 1
    end
  else
    len = #thunks
  end
  local thunksDone = {}
  local done = 0
  local acc = {}
  
  local function thunk(callback)
    if 0 == len then
      return callback()
    end
    local pendingContext = {__async_command__ = true, __async_push_multi_sub_context__ = true}
    for i, tk in (by_map and pairs or ipairs)(thunks) do
      assert("function" == type(tk), "[async] thunk must be function")
      
      local function internalCallback(...)
        assert(not thunksDone[i], "[async] callback that was passed in the thunk should not be called more than once")
        thunksDone[i] = true
        acc[i] = {
          ...
        }
        done = done + 1
        if done == len then
          if by_map then
            callback(acc)
          else
            callback(t_unpack(acc))
          end
        end
      end
      
      thunksDone[i] = false
      local newContext = tk(internalCallback)
      if newContext and newContext.thread then
        t_insert(pendingContext, newContext)
      end
    end
    return pendingContext
  end
  
  return thunk
end

local function race(thunks, by_map)
  local len
  if by_map then
    len = 0
    for _, _ in pairs(thunks) do
      len = len + 1
    end
  else
    len = #thunks
  end
  local done = false
  
  local function thunk(callback)
    if 0 == len then
      return callback(0)
    end
    local pendingContext = {__async_command__ = true, __async_push_multi_sub_context__ = true}
    for i, tk in (by_map and pairs or ipairs)(thunks) do
      assert("function" == type(tk), "[async] thunk must be function")
      
      local function internalCallback(...)
        if done then
          return
        end
        done = true
        callback(i, ...)
      end
      
      local newContext = tk(internalCallback)
      if newContext and newContext.thread then
        t_insert(pendingContext, newContext)
      end
    end
    return pendingContext
  end
  
  return thunk
end

local function async(func)
  return function(...)
    local params = {
      ...
    }
    return wrap(pong)(function()
      return func(t_unpack(params))
    end)
  end
end

local function await(defer)
  assert("function" == type(defer), "[async] type error :: expected func")
  return co.yield(defer)
end

local function await_all(defers, by_map)
  assert("table" == type(defers), "[async] type error :: expected table<function>")
  return co.yield(join(defers, by_map))
end

local function await_any(defers, by_map)
  assert("table" == type(defers), "[async] type error :: expected table<function>")
  return co.yield(race(defers, by_map))
end

local function cmd(item)
  local function thunk()
    return item
  end
  
  return co.yield(thunk)
end

local function trace(context)
  local result = {}
  local build_tree = function(ctx, prefix, has_sibling, depth)
    local full_trace = debug.traceback(ctx.thread, "", 0 == depth and 1 or 0)
    if "string" ~= type(full_trace) then
      return
    end
    local children = ctx.subContexts or {}
    local filter_patterns = {
      "^stack traceback:",
      "coroutine 0x%x+ %(.*%)",
      "async%.lua"
    }
    table.insert(result, (depth > 0 and prefix .. (not has_sibling and "\226\148\148\226\148\128  " or "\226\148\156\226\148\128  ") or "") .. "Coroutine [" .. tostring(ctx.thread) .. "]")
    for line in full_trace:gmatch([[
([^
]+)]]) do
      local should_include = true
      for _, pattern in ipairs(filter_patterns) do
        if line:match(pattern) then
          should_include = false
          break
        end
      end
      if should_include and "" ~= line then
        line = line:gsub("\t", "    ")
        local tmp_prefix = depth > 0 and prefix .. (not has_sibling and "    " or "\226\148\130   ") or ""
        table.insert(result, tmp_prefix .. (next(children) and "\226\148\130   " or "    ") .. line)
      end
    end
    for i, sub_ctx in ipairs(children) do
      local is_last = i == #children
      local child_prefix = depth > 0 and prefix .. (not has_sibling and "    " or "\226\148\130   ") or ""
      build_tree(sub_ctx, child_prefix, not is_last, depth + 1)
    end
  end
  build_tree(context, "", false, 0)
  local output = table.concat(result, "\n")
  return output
end

return {
  task = wrap(pong),
  sync = async,
  wait = await,
  wait_all = await_all,
  wait_any = await_any,
  wrap = wrap,
  live = live,
  kill = kill,
  trace = trace,
  cmd = cmd
}
