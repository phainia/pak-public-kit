local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local CountDownHandler = {}

local function GetTimeFormatStr(_leftSeconds, _formatterHandler)
  if _formatterHandler then
    return _formatterHandler(_leftSeconds)
  end
  return ActivityUtils.GetTimeFormatStr(_leftSeconds)
end

local function RefreshCtrlText(ctrl, leftSeconds, ctrlData, endTimeStamp)
  if ctrl and UE4.UObject.IsValid(ctrl) then
    local text = GetTimeFormatStr(leftSeconds, ctrlData and ctrlData.formatterHandler)
    ctrl:SetText(text)
    if ctrlData and ctrlData.textChangeHandler then
      ctrlData.textChangeHandler(ctrl, text, endTimeStamp)
    end
  end
end

local CountDownObject = Class("CountDownObject")

function CountDownObject:Ctor(...)
  self.ctrlGroup = {}
  self.listeners = {}
  self:OnConstruct(...)
end

function CountDownObject:OnConstruct(...)
end

function CountDownObject:GetEndTimestamp()
  return 0
end

function CountDownObject:BindCtrl(_ctrl, _formatterDelegate, _formatterCaller, _textChangeDelegate, _textChangeCaller)
  if not _ctrl then
    return
  end
  local addNew = false
  local ctrlData = self.ctrlGroup[_ctrl]
  if not ctrlData then
    ctrlData = {}
    if _formatterDelegate then
      ctrlData.formatterHandler = _G.MakeWeakFunctor(_formatterCaller, _formatterDelegate)
    end
    if _textChangeDelegate then
      ctrlData.textChangeHandler = _G.MakeWeakFunctor(_textChangeCaller, _textChangeDelegate)
    end
    self.ctrlGroup[_ctrl] = ctrlData
    addNew = true
  end
  local leftSeconds, endTimeStamp = self:GetLeftTime()
  RefreshCtrlText(_ctrl, leftSeconds, ctrlData, endTimeStamp)
  if addNew then
    self:RefreshTickStatus()
  end
end

function CountDownObject:UnbindCtrl(_ctrl)
  if not _ctrl then
    return
  end
  local ctrlData = self.ctrlGroup[_ctrl]
  if ctrlData then
    self.ctrlGroup[_ctrl] = nil
    self:RefreshTickStatus()
  end
end

function CountDownObject:AddListener(name, listener, handler, ...)
  if string.IsNilOrEmpty(name) or not handler then
    return
  end
  self.listeners[name] = _G.MakeWeakFunctor(listener, handler, ...)
  self:RefreshTickStatus()
end

function CountDownObject:RemoveListener(name)
  if string.IsNilOrEmpty(name) then
    return
  end
  if self.listeners[name] then
    self.listeners[name] = nil
    self:RefreshTickStatus()
  end
end

function CountDownObject:ForceRefreshLeftTime()
  local leftSeconds, endTimeStamp = self:GetLeftTime()
  for ctrl, ctrlData in pairs(self.ctrlGroup) do
    RefreshCtrlText(ctrl, leftSeconds, ctrlData, endTimeStamp)
  end
  for _, listener in pairs(self.listeners) do
    listener(leftSeconds)
  end
  self:RefreshTickStatus(leftSeconds)
end

function CountDownObject:RefreshTickStatus(_leftSeconds)
  local leftSeconds = _leftSeconds or self:GetLeftTime()
  local _enable = next(self.ctrlGroup) ~= nil or nil ~= next(self.listeners)
  if _enable and leftSeconds > 0 then
    if not self.tickUpdateId then
      self.tickUpdateId = _G.DelayManager:DelaySeconds(math.min(leftSeconds, 60), self.UpdateLeftTimeOnce, self)
    end
  elseif self.tickUpdateId then
    _G.DelayManager:CancelDelayById(self.tickUpdateId)
    self.tickUpdateId = nil
  end
end

function CountDownObject:GetLeftTime()
  local endTimeStamp = self:GetEndTimestamp() or 0
  local svrTimestamp = ActivityUtils.GetSvrTimestamp()
  return endTimeStamp - svrTimestamp, endTimeStamp
end

function CountDownObject:UpdateLeftTimeOnce()
  self.tickUpdateId = nil
  self:ForceRefreshLeftTime()
end

local CountDownObject_TimeStamp = CountDownObject:Extend("CountDownObject_TimeStamp")

function CountDownObject_TimeStamp:OnConstruct(endTimestamp)
  assert(endTimestamp, "endTimestamp is nil")
  self.endTimestamp = endTimestamp
end

function CountDownObject_TimeStamp:GetEndTimestamp()
  return self.endTimestamp
end

local CountDownObject_TimeFunction = CountDownObject:Extend("CountDownObject_TimeFunction")

function CountDownObject_TimeFunction:OnConstruct(caller, callback, ...)
  assert(callback, "callback is nil")
  self.getEndTimestamp = _G.MakeWeakFunctor(caller, callback, ...)
end

function CountDownObject_TimeFunction:GetEndTimestamp()
  if self.getEndTimestamp then
    return self.getEndTimestamp()
  end
  return 0
end

function CountDownHandler.CreateCountDownObjectByTimestamp(endTimestamp)
  return CountDownObject_TimeStamp(endTimestamp)
end

function CountDownHandler.CreateCountDownObjectByTimeFunction(callback, caller, ...)
  return CountDownObject_TimeFunction(caller, callback, ...)
end

return CountDownHandler
