local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local MagicManualUtils = require("NewRoco.Modules.System.MagicManual.MagicManualUtils")
local WeeklyChallengeBattleModuleEvent = require("NewRoco.Modules.System.WeeklyChallengeBattle.WeeklyChallengeBattleModuleEvent")
local WeeklyChallengeEventActivityObject = Base:Extend("WeeklyChallengeEventActivityObject")

function WeeklyChallengeEventActivityObject:OnConstruct(_conf)
  self.ActivityData = nil
  self.WeeklyChallengeData = nil
  self.ActivityConf = _conf
  self.WeeklyChallengeEventConf = _G.DataConfigManager:GetWeeklyChallengeEventConf(self:GetSinglePartId())
  self.SecondTabIcon = "PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/Frames/img_Starlight_png.img_Starlight_png'"
end

function WeeklyChallengeEventActivityObject:OnDestruct()
end

function WeeklyChallengeEventActivityObject:SyncActivityDataOnAvailable()
  Log.Info(string.format("WeeklyChallengeEventActivityObject:SyncActivityDataOnAvailable \232\175\183\230\177\130\229\144\140\230\173\165\230\180\187\229\138\168\230\149\176\230\141\174 id: %s", self:GetActivityId()))
  self:ReqGetPlayerActivityData()
end

function WeeklyChallengeEventActivityObject:GetCyclicalChallengeConf()
  return self.WeeklyChallengeEventConf
end

function WeeklyChallengeEventActivityObject:GetActivityConf()
  return self.ActivityConf
end

function WeeklyChallengeEventActivityObject:GetFinishWeeklyChallengeEventSchedule()
  return MagicManualUtils.GetFinishWeeklyChallengeEventSchedule(self.WeeklyChallengeData)
end

function WeeklyChallengeEventActivityObject:GetWeeklyChallengeEventStarNum()
  return MagicManualUtils.GetWeeklyChallengeStarNum(self.WeeklyChallengeData)
end

function WeeklyChallengeEventActivityObject:SetRewardState(starRequiredNum)
  local rewards = self.ActivityData.weekly_challenge_data.rewards
  self:UpdateRewardState(rewards, starRequiredNum)
end

function WeeklyChallengeEventActivityObject:UpdateRewardState(rewards, star_required_num)
  for j, reward in ipairs(rewards) do
    if reward.star_required_num == star_required_num then
      reward.state = ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE
      return
    end
  end
end

function WeeklyChallengeEventActivityObject:IsPreviewActivity()
  return self:GetActivityType() == _G.Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT
end

function WeeklyChallengeEventActivityObject:GetWeeklyChallengeData()
  return self.WeeklyChallengeData
end

function WeeklyChallengeEventActivityObject:GetWeeklyChallengeActivityId()
  if self.ActivityData then
    return self.ActivityData.activity_id
  else
    Log.Warning("WeeklyChallengeEventActivityObject:GetWeeklyChallengeActivityId", "ActivityData is nil")
    return nil
  end
end

function WeeklyChallengeEventActivityObject:GetActivityEndTime()
  if self:IsPreviewActivity() then
    local WeeklyChallengeStartTime = self.WeeklyChallengeEventConf and self.WeeklyChallengeEventConf.start_time
    if not string.IsNilOrEmpty(WeeklyChallengeStartTime) then
      return ActivityUtils.ToTimestampByDays(WeeklyChallengeStartTime, self.WeeklyChallengeEventConf.period)
    end
  end
  return Base.GetActivityEndTime(self)
end

function WeeklyChallengeEventActivityObject:OnReconnectFinish()
  self:ReqGetPlayerActivityData()
end

function WeeklyChallengeEventActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.ActivityData = _updateData
    self.WeeklyChallengeData = self.ActivityData and self.ActivityData.weekly_challenge_data
    _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.UpdateAppearanceRate)
    _G.NRCEventCenter:DispatchEvent(WeeklyChallengeBattleModuleEvent.OnActivityUpdate)
  end
end

return WeeklyChallengeEventActivityObject
