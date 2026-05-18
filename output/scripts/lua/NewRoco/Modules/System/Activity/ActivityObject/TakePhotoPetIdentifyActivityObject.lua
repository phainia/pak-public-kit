local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local TakePhotoPetIdentifyActivityObject = Base:Extend("FlowerAppearHardActivityObject")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function TakePhotoPetIdentifyActivityObject:OnConstruct(_conf)
  self:AddActivityExpiredCallback("TakePhotoPetIdentifyActivityObject", self, self.OnActivityExpired)
end

function TakePhotoPetIdentifyActivityObject:OnActivityExpired()
  self:SendEvent(ActivityModuleEvent.TakePhotoPetIdentifyActivityExpired)
end

function TakePhotoPetIdentifyActivityObject:OnSvrUpdateActivityData(cmdId, _updateData, _initUpdate)
  if cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.activity_data = _updateData.pet_photo_data
    self:SendEvent(ActivityModuleEvent.RefreshTakePhotoPetIdentifyActivityData, self:GetActivityData())
  end
end

function TakePhotoPetIdentifyActivityObject:GetActivityData()
  return self.activity_data
end

function TakePhotoPetIdentifyActivityObject:SyncActivityDataOnAvailable()
  Log.Info(string.format("TakePhotoPetIdentifyActivityObject:SyncActivityDataOnAvailable \232\175\183\230\177\130\229\144\140\230\173\165\230\180\187\229\138\168\230\149\176\230\141\174 id: %s", self:GetActivityId()))
  self:ReqGetPlayerActivityData()
end

return TakePhotoPetIdentifyActivityObject
