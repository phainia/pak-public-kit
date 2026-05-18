local ResObjectState = require("NewRoco.Utils.ResObjectState")

local function RunCallback(Owner, Callback, ...)
  if not Callback then
    return
  end
  if Owner then
    Callback(Owner, ...)
  else
    Callback(...)
  end
end

local Class = _G.MakeSimpleClass
local IS_SHIPPING = _G.RocoEnv.IS_SHIPPING
local ResObjectBase = Class("ResObjectBase")

function ResObjectBase:Ctor()
  self.State = ResObjectState.Init
  self.StartTime = -1
  self.bSuccess = false
end

function ResObjectBase:DoLoad(...)
  Log.Error("\232\175\183\233\135\141\232\189\189DoLoad", self.className)
  self:FireCallback(true)
end

function ResObjectBase:DoRelease(...)
  Log.Error("\232\175\183\233\135\141\232\189\189DoRelease", self.className)
end

function ResObjectBase:DoGet(...)
  Log.Error("\232\175\183\233\135\141\232\189\189DoGet", self.className)
  return nil
end

function ResObjectBase:StartLoad(CallbackOwner, Callback, ...)
  if self.State ~= ResObjectState.Init then
    RunCallback(CallbackOwner, Callback, self, false)
    return
  end
  self.State = ResObjectState.Loading
  self.CallbackOwner = CallbackOwner
  self.Callback = Callback
  self.bSuccess = false
  if not IS_SHIPPING then
    self.StartTime = os.msTime()
  end
  self:DoLoad(...)
end

function ResObjectBase:Get(...)
  if self.State == ResObjectState.Init then
    self:StartLoad()
  end
  return self:DoGet(...)
end

function ResObjectBase:Release(...)
  self:DoRelease(...)
  self:FireCallback(false)
  self.State = ResObjectState.Init
  self.bSuccess = false
end

function ResObjectBase:IsLoading()
  return self.State == ResObjectState.Loading
end

function ResObjectBase:FireCallback(Success, ...)
  if self.State ~= ResObjectState.Loading then
    return
  end
  local CallbackOwner = self.CallbackOwner
  local Callback = self.Callback
  self.CallbackOwner = nil
  self.Callback = nil
  self.State = ResObjectState.Loaded
  self.bSuccess = Success
  if IS_SHIPPING then
    Log.Debug("[ResObjectBase] Finish", self.className, CallbackOwner and CallbackOwner.className or "Unknown", Success)
  else
    local Now = os.msTime()
    local Diff = Now - self.StartTime
    Log.Debug("[ResObjectBase] Finish", self.className, CallbackOwner and CallbackOwner.className or "Unknown", Success and "\230\136\144\229\138\159" or "\229\164\177\232\180\165", Diff / 1000)
  end
  RunCallback(CallbackOwner, Callback, self, Success, ...)
end

return ResObjectBase
