local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local test_case = {}

function test_case.test_case_overview(cb)
  print("========= Case: Overview =========")
  local task = a.task(function()
    print("A. Simple Wait")
    print(a.wait(au.DelaySeconds(1.5)), "secs passed")
    print([[
--- 
B. Parallel Wait All]])
    local x, y, z = a.wait_all({
      au.DelaySeconds(1),
      au.DelaySeconds(2),
      au.DelaySeconds(1)
    })
    print(math.max(table.unpack(x), table.unpack(y), table.unpack(z)), "secs passed")
    local ByMap1 = a.wait_all({
      A = au.DelaySeconds(0.1),
      B = au.DelaySeconds(0.2),
      C = au.DelaySeconds(0.3)
    }, true)
    print(table.unpack(ByMap1.A), table.unpack(ByMap1.B), table.unpack(ByMap1.C), "joined by map waiting")
    print([[
--- 
C. Parallel Wait Any]])
    local index, anySeconds = a.wait_any({
      au.DelaySeconds(1.02),
      au.DelaySeconds(2),
      au.DelaySeconds(1.01)
    })
    print("DelaySeconds with index =", index, "win the race,", anySeconds, "secs passed")
    local keyByMap, anySecondsByMap = a.wait_any({
      A = au.DelaySeconds(0.1),
      B = au.DelaySeconds(0.2),
      C = au.DelaySeconds(0.3)
    }, true)
    print(keyByMap, anySecondsByMap, "raced by map waiting")
    print([[
---
D. Frame Wait]])
    local f = a.wait(au.DelayFrames(100))
    print(f, "frames passed")
  end)
  task(cb or function()
  end)
end

function test_case.test_case_custom_task(cb)
  print("========= Case: Wrap custom task =========")
  print("MainBegin")
  
  local function delayThunk(time, callback)
    print("DelayBegin")
    _G.DelayManager:DelaySeconds(time, function(...)
      print("DelayEnd")
      callback("from_delay")
    end)
  end
  
  local aDelay = a.wrap(delayThunk)
  local aTask = a.task(function(...)
    print("Task1Begin")
    local x = a.wait(aDelay(2))
    print("Task1End", x)
    return "from_task1_return"
  end)
  
  local function aTask_cb(...)
    print("MainCallback", ...)
    cb = cb or function()
    end
    cb()
  end
  
  aTask(aTask_cb)
  print("MainEnd")
end

function test_case.test_case_params(cb)
  print("========= Case: Params =========")
  
  local function echo(...)
    local param = {
      ...
    }
    return a.task(function()
      print(table.unpack(param))
    end)
  end
  
  local function WaitFromTick(in_tickTime)
    local tickTime = in_tickTime
    while tickTime > 0 do
      local dt = a.wait(au.NextTick())
      a.wait(echo(in_tickTime - tickTime, dt))
      tickTime = tickTime - 1
    end
  end
  
  local task = a.task(WaitFromTick, 100)
  task(function()
    echo("end")()
    cb = cb or function()
    end
    cb()
  end)
end

function test_case.test_case_subtask(cb)
  print("========= Case: Subtask =========")
  local sub_task = a.task(function()
    return "subtask_result"
  end)
  local sub_func = a.sync(function(something)
    print(something)
  end)
  local task = a.task(function()
    do
      local status, msg_or_result = a.wait(sub_task)
      if status then
        print(msg_or_result)
      else
        print("subtask \229\135\186\233\148\153", msg_or_result)
      end
    end
    do
      local status, msg_or_result = a.wait(sub_func("something"))
      if status then
        print(msg_or_result)
      else
        print("syncFunc \229\135\186\233\148\153", msg_or_result)
      end
    end
  end)
  task(cb or function()
  end)
end

function test_case.test_case_class_port(cb)
  print("========= Case: Class port =========")
  local Clazz = MakeSimpleClass("AsyncTestClazz")
  
  function Clazz:LegacyAsyncFunc(param1, callback)
    print("LegacyAsyncFunc", param1)
    _G.DelayManager:DelaySeconds(self.secs or 1, callback)
  end
  
  Clazz.AwaitableLegacyAsyncFunc = a.wrap(Clazz.LegacyAsyncFunc)
  
  function Clazz.LegacyAsyncFuncStatic(param2, secs, callback)
    print("LegacyAsyncFuncStatic", param2, secs)
    _G.DelayManager:DelaySeconds(secs, callback)
  end
  
  Clazz.AwaitableLegacyAsyncFuncStatic = a.wrap(Clazz.LegacyAsyncFuncStatic)
  
  function Clazz:MainWork(mainCallback)
    self.context = a.task(function()
      self.secs = 1
      a.wait(self:AwaitableLegacyAsyncFunc("yoo"))
      a.wait(self.AwaitableLegacyAsyncFuncStatic("yee", self.secs))
    end)(mainCallback)
  end
  
  Clazz.AwaitableMainWork = a.wrap(Clazz.MainWork)
  local task = a.task(function()
    local clazz = Clazz()
    a.wait(clazz:AwaitableMainWork())
  end)
  task(cb or function()
  end)
end

function test_case.test_case_lifetime(cb)
  print("========= Case: Lifetime =========")
  local task = a.task(function()
    print("task begin")
    a.wait(au.DelaySeconds(1))
    print("task end")
  end)
  local context = task()
  print("task alive?", a.live(context))
  local longer_task = a.task(function()
    a.wait(au.DelayFrames(2))
    print("longer_task: task alive?", a.live(context))
  end)
  longer_task(cb or function()
  end)
end

function test_case.test_case_early_kill(cb)
  print("========= Case: Early kill =========")
  local task = a.task(function()
    print("task begin")
    a.wait(au.DelaySeconds(2))
    print("task end")
  end)
  local context1, context2
  local task1_killer = a.task(function()
    a.wait(au.DelaySeconds(1))
    a.kill(context1, true)
    print("task1 alive?", a.live(context1))
  end)
  local task2_killer = a.task(function()
    a.wait(au.DelaySeconds(1))
    a.kill(context2)
    print("task2 alive?", a.live(context2))
  end)
  local run_context1, run_context2
  
  function run_context1()
    context1 = task(function()
      print("task1 callback")
      run_context2()
    end)
    print("task1 alive?", a.live(context1))
    task1_killer(function()
      print("killer1 callback")
    end)
  end
  
  function run_context2()
    context2 = task(function()
      print("task2 callback")
    end)
    task2_killer(function()
      print("killer2 callback")
      cb = cb or function()
      end
      cb()
    end)
  end
  
  run_context1()
end

function test_case.test_case_error_unchecked_task(cb)
  print("========= Case:Error handling/Unchecked task =========")
  print("MainBegin")
  
  local function delayThunk(time, callback)
    print("DelayBegin")
    _G.DelayManager:DelaySeconds(time, function(...)
      print("DelayEnd")
      callback("from_delay")
    end)
  end
  
  local aDelay = a.wrap(delayThunk)
  local aTask = a.task(function(...)
    print("Task1Begin")
    local x = a.wait(aDelay(2))
    print("x =", x)
    assert(false)
    local y = a.wait(aDelay(2))
    print("y =", y)
    print("Task1End")
    return "from_task1_return"
  end)
  
  local function aTask_cb(status, ...)
    if status then
      print("MainCallback", ...)
    else
      Log.Error("MainCallback \229\135\186\233\148\153", ...)
    end
    print("MainEnd")
    cb = cb or function()
    end
    cb()
  end
  
  aTask(aTask_cb)
end

function test_case.test_case_error_unchecked_awaitable(cb)
  print("========= Case: Error handling/Unchecked awaitable =========")
  print("MainBegin")
  
  local function delayThunk(time, callback)
    print("DelayBegin")
    assert(false)
    _G.DelayManager:DelaySeconds(time, function(...)
      print("DelayEnd")
      callback("from_delay")
    end)
  end
  
  local aDelay = a.wrap(delayThunk)
  local aTask = a.task(function(...)
    print("Task1Begin")
    local x = a.wait(aDelay(2))
    print("x =", x)
    print("Task1End")
    return "from_task1_return"
  end)
  
  local function aTask_cb(status, ...)
    if status then
      print("MainCallback", ...)
    else
      Log.Error("MainCallback \229\135\186\233\148\153", ...)
    end
    print("MainEnd")
    cb = cb or function()
    end
    cb()
  end
  
  aTask(aTask_cb)
end

function test_case.test_case_error_handling(cb)
  print("========= Case: Error handling/More =========")
  print("MainBegin")
  local manualError = a.wrap(function(any_params, callback)
    print("about to trigger error")
    callback(false, debug.traceback("test is nil"))
    do return end
    assert(false)
    callback(true, any_params)
  end)
  local subTaskError = a.task(function()
    assert(false)
    return "subtask_result"
  end)
  
  local function afterCallbackError(x, callback)
    callback(x + 1)
    assert(false)
  end
  
  local aTask = a.task(function(...)
    print("Task1Begin")
    do
      local status, msg_or_result = a.wait(manualError(2))
      if status then
        print("x =", msg_or_result)
      else
        Log.Error("aManualError \229\135\186\233\148\153", msg_or_result)
      end
    end
    do
      local status, msg_or_result = a.wait(subTaskError)
      if status then
        print(msg_or_result)
      else
        Log.Error("subTaskError \229\135\186\233\148\153", msg_or_result)
      end
    end
    do
      local xPlusOne = a.wait(a.wrap(afterCallbackError)(1))
      print("xPlusOne = ", xPlusOne)
    end
    print("Task1End")
    return "from_task1_return"
  end)
  
  local function aTask_cb(noUncheckedError, ...)
    if noUncheckedError then
      print("MainCallback", ...)
    else
      Log.Error("MainCallback \229\135\186\233\148\153", ...)
    end
    print("MainEnd")
    cb = cb or function()
    end
    cb()
  end
  
  aTask(aTask_cb)
end

function test_case.test_case_error_timeout(cb)
  print("========= Case: Error handling/timeout =========")
  local task = a.task(function()
    print("A. await block finishes in time")
    do
      local status, msg_or_result = au.WaitUntilTimeOut(au.DelaySeconds(1.01), 1.02)
      if status then
        print(msg_or_result, "secs passed")
      else
        Log.Error(msg_or_result)
      end
    end
    print("B. await block does not finish before time out")
    do
      local status, msg_or_result = au.WaitUntilTimeOut(au.DelaySeconds(1.01), 1)
      if status then
        print(msg_or_result, "secs passed")
      else
        Log.Error(msg_or_result)
      end
    end
  end)
  task(cb or function()
  end)
end

function test_case.test_case_trace(cb)
  print("========= Case: Trace =========")
  local delay1s = a.task(function()
    a.wait(au.DelaySeconds(1))
  end)
  local delayNs
  delayNs = a.sync(function(n, id)
    Log.Debug("delayNs :id=", id, "n=", n)
    local intSec = math.floor(n)
    if intSec > 1 then
      a.wait(delay1s)
      a.wait(delayNs(intSec - 1, id))
    else
      a.wait(delay1s)
    end
  end)
  local task = a.task(function()
    a.wait_all({
      delayNs(5, "#0"),
      delayNs(3, "#1"),
      au.DelaySeconds(7)
    })
  end)
  local context = task(function(...)
    Log.Debug("MainCallback", ...)
    cb()
  end)
  a.task(function()
    a.wait(au.DelaySeconds(1.5))
    do
      local log = a.trace(context)
      Log.Debug("Async Context Trace(1.5s):\n" .. log)
    end
    a.wait(au.DelaySeconds(1))
    do
      local log = a.trace(context)
      Log.Debug("Async Context Trace(2.5s):\n" .. log)
    end
    a.wait(au.DelaySeconds(3))
    a.kill(context)
  end)()
end

function test_case.test_case_cmd(cb)
  print("========= Case: cmd =========")
  local task = a.task(function()
    a.wait(au.DelaySeconds(1))
    local current_context = au.GetContext()
    print(a.trace(current_context))
    a.kill(current_context)
  end)
  task(cb or function()
  end)
end

function test_case.test_case_async_load(cb)
  print("========= Case: Async loading =========")
  local SOME_ASSET_PATH = _G.UEPath.NAV_MODER_AVOID
  local _self = {}
  local LoadAndSpawn = a.task(function()
    _self.req = _G.NRCResourceManager:LoadResAsync(nil, SOME_ASSET_PATH, 1, 10)
    local success, req, asset_or_msg = a.wait(au.ResRequestCallback(_self.req))
    if not success then
      print("asset not loaded", asset_or_msg)
      return
    end
    print("asset loaded", asset_or_msg)
  end)
  _self.task_context = LoadAndSpawn()
  local OnDestroy = a.task(function()
    a.kill(_self.task_context)
    if _self.req then
      _G.NRCResourceManager:UnLoadRes(_self.req)
      _self.req = nil
    end
  end)
  OnDestroy(cb or function()
  end)
end

function test_case.test_case_promise(cb)
  print("========= Case: Promise =========")
  local task = a.task(function()
    local promise = au.CreatePromise()
    print("start wait")
    DelayManager:DelaySeconds(1, promise.resolve, "hello")
    DelayManager:DelaySeconds(1.1, promise.resolve, " world")
    local _, msg1 = a.wait(promise.future)
    print(msg1)
    _, msg1 = a.wait(promise.future)
    print(msg1)
    local promise_imme = au.CreatePromise()
    promise_imme.resolve("hello 2")
    local _, msg2 = a.wait(promise_imme.future)
    print(msg2)
    local promise_lite = au.CreatePromiseLite()
    DelayManager:DelayFrames(1, promise_lite.resolve, "hello 3")
    local _, msg3 = a.wait(promise_lite.future)
    print(msg3)
  end)
  task(cb or function()
  end)
end

return test_case
