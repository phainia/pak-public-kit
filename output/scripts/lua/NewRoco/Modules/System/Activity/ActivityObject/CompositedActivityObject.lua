local CompositedActivityObject = {}
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function CompositedActivityObject.__index(t, k)
  local mt = getmetatable(t)
  if mt then
    local v = mt[k]
    if v then
      return v
    end
  end
  local _activityInst = rawget(t, "selectActivityInst")
  if _activityInst then
    return _activityInst[k]
  end
end

setmetatable(CompositedActivityObject, {
  __call = function(cls, ...)
    local instance = {}
    setmetatable(instance, CompositedActivityObject)
    instance:Ctor(...)
    return instance
  end
})

function CompositedActivityObject:Ctor(_activities)
  assert(type(_activities) == "table" and #_activities > 0, "_activities must be a valid table!")
  assert(nil ~= _activities[1], "_activities must has a valid value!")
  self.includeActivities = ActivityUtils.ShallowCopyElements(_activities) or {}
  self:OnIncludeActivityChanged()
  local firstActivityInst = self.includeActivities[1]
  if firstActivityInst then
    self:SwitchSelectActivity(firstActivityInst:GetActivityId())
  end
end

function CompositedActivityObject:OnIncludeActivityChanged()
  table.sort(self.includeActivities, function(a, b)
    return a:CompareTo(b)
  end)
end

function CompositedActivityObject:FindActivityInst(_activityId)
  for _, _activityInst in ipairs(self.includeActivities) do
    if _activityInst:GetActivityId() == _activityId then
      return _activityInst
    end
  end
end

function CompositedActivityObject:EraseNewActivityRedPoint()
  for _, _activityInst in ipairs(self.includeActivities) do
    _activityInst:EraseNewActivityRedPoint()
  end
end

function CompositedActivityObject:GetTabRedPointExtraKeyList()
  local extraKeyList = {}
  for _, _activityInst in ipairs(self.includeActivities) do
    local _tempExtraKeyList = _activityInst:GetTabRedPointExtraKeyList()
    for _, _extraKey in ipairs(_tempExtraKeyList) do
      table.insert(extraKeyList, _extraKey)
    end
  end
  return extraKeyList
end

function CompositedActivityObject:ReqGetPlayerActivityData()
  for _, _activityInst in ipairs(self.includeActivities) do
    _activityInst:ReqGetPlayerActivityData()
  end
end

function CompositedActivityObject:OnReconnectFinish()
  local ret = false
  for _, _activityInst in ipairs(self.includeActivities) do
    ret = ret or _activityInst:OnReconnectFinish()
  end
  return ret
end

function CompositedActivityObject:AddActivity(_activityInst)
  if not _activityInst then
    return
  end
  local activityId = _activityInst:GetActivityId()
  if self:FindActivityInst(activityId) then
    return
  end
  table.insert(self.includeActivities, _activityInst)
  self:OnIncludeActivityChanged()
end

function CompositedActivityObject:GetIncludeActivities()
  return self.includeActivities
end

function CompositedActivityObject:SwitchSelectActivity(_activityId)
  local selectInst = self.selectActivityInst
  if selectInst and selectInst:GetActivityId() == _activityId then
    return
  end
  local switchInst = self:FindActivityInst(_activityId)
  if not switchInst then
    return
  end
  local bindView = selectInst and selectInst:GetAttachView()
  if bindView then
    selectInst:DetachView()
    switchInst:AttachView(bindView)
  end
  self.selectActivityInst = switchInst
  self:SendEvent(ActivityModuleEvent.CompositedActivitySelectChange, self)
end

return CompositedActivityObject
