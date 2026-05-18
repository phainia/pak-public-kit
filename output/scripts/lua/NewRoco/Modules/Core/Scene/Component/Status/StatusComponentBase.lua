local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatusComponentBase = Base:Extend("StatusComponentBase")

function StatusComponentBase:ApplyStatus(status, ...)
  if not self._statusDic[status] then
    self._statusDic[status] = 0
  end
  self._statusDic[status] = self._statusDic[status] + 1
  self.owner:SendEvent(PlayerModuleEvent.ON_APPLY_STATUS, status, self._statusDic[status], ...)
  self.owner:SendEvent(PlayerModuleEvent.ON_STATUS_CHANGED, status, self._statusDic[status], ...)
end

function StatusComponentBase:RemoveStatus(status, ...)
  local originStatusValue = self._statusDic[status] or 0
  if originStatusValue <= 0 then
    return
  end
  self._statusDic[status] = originStatusValue - 1
  self.owner:SendEvent(PlayerModuleEvent.ON_REMOVE_STATUS, status, self._statusDic[status], ...)
  self.owner:SendEvent(PlayerModuleEvent.ON_STATUS_CHANGED, status, self._statusDic[status], ...)
end

function StatusComponentBase:HasStatus(status)
  local statusValue = self._statusDic[status]
  if not statusValue or statusValue <= 0 then
    return false
  end
  return true
end

function StatusComponentBase:HasAnyStatus(...)
  local args = {
    ...
  }
  for _, v in pairs(args) do
    if self:HasStatus(v) then
      return true
    end
  end
  return false
end

function StatusComponentBase:ClearAll()
  for k, v in pairs(self._statusDic) do
    local status = k
    self._statusDic[status] = 0
    self.owner:SendEvent(PlayerModuleEvent.ON_REMOVE_STATUS, status, 0)
    self.owner:SendEvent(PlayerModuleEvent.ON_STATUS_CHANGED, status, 0)
  end
end

function StatusComponentBase:Destroy()
  self:ClearAll()
end

return StatusComponentBase
