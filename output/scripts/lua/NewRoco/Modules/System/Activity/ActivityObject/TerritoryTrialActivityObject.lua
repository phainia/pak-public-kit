local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local TerritoryTrialActivityObject = Base:Extend("FlowerAppearHardActivityObject")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function TerritoryTrialActivityObject:OnConstruct(_conf)
  Base.OnConstruct(self, _conf)
  self:AddActivityExpiredCallback("TerritoryTrialFinish", nil, function()
    local module = _G.NRCModuleManager:GetModule("ActivityModule")
    local panel = module:GetPanel("TerritoryTrialRewardPreview")
    if panel then
      panel:ClosePanel()
    end
  end)
end

function TerritoryTrialActivityObject:OnSvrUpdateActivityData(cmdId, _updateData, _initUpdate)
  if cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.activity_data = _updateData.territory_trial_data
    self:SendEvent(ActivityModuleEvent.RefreshTerritoryTrialActivityData, _updateData.territory_trial_data)
  end
end

function TerritoryTrialActivityObject:GetActivityData()
  return self.activity_data
end

function TerritoryTrialActivityObject:SyncActivityDataOnAvailable()
  Log.Info(string.format("TerritoryTrialActivityObject:SyncActivityDataOnAvailable \232\175\183\230\177\130\229\144\140\230\173\165\230\180\187\229\138\168\230\149\176\230\141\174 id: %s", self:GetActivityId()))
  self:ReqGetPlayerActivityData()
end

return TerritoryTrialActivityObject
