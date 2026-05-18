local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local BossChallengeEventActivityObject = Base:Extend("BossChallengeEventActivityObject")

function BossChallengeEventActivityObject:OnConstruct(_conf)
  self.BossChallengeData = nil
  self.ActivityData = nil
  self.ActivityConf = _conf
  self.BossChallengeEventConf = _G.DataConfigManager:GetBossChallengeEventConf(self:GetSinglePartId())
  self.SecondTabIcon = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_jiaodou_png.img_jiaodou_png'"
end

function BossChallengeEventActivityObject:OnDestruct()
end

function BossChallengeEventActivityObject:IsPreviewActivity()
  return self:GetActivityType() == Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT
end

function BossChallengeEventActivityObject:GetBossChallengeData()
  return self.BossChallengeData
end

function BossChallengeEventActivityObject:GetCyclicalChallengeConf()
  return self.BossChallengeEventConf
end

function BossChallengeEventActivityObject:GetBossActivityId()
  return self.ActivityData.activity_id
end

function BossChallengeEventActivityObject:GetActivityConf()
  return self.ActivityConf
end

function BossChallengeEventActivityObject:GetBagPath()
  local Bag = string.format("%s%s%s%s%s%s%s", UEPath.CommonChallenge, self.BossChallengeEventConf.petbase, "/", UEPath.jiaodou, ".", UEPath.jiaodou, "'")
  return Bag
end

function BossChallengeEventActivityObject:GetBossPath()
  local Bag = string.format("%s%s%s%s%s%s%s", UEPath.CommonChallenge, self.BossChallengeEventConf.petbase, "/", UEPath.jiaodou_1, ".", UEPath.jiaodou_1, "'")
  return Bag
end

function BossChallengeEventActivityObject:GetMagicManualPath()
  local Bag = string.format("%s%s%s%s%s%s%s", UEPath.CommonChallenge, self.BossChallengeEventConf.petbase, "/", UEPath.jiaodou_2, ".", UEPath.jiaodou_2, "'")
  return Bag
end

function BossChallengeEventActivityObject:SetRewardState(star_required_num)
  local rewards = self.ActivityData.boss_challenge_data.rewards
  self:UpdateRewardState(rewards, star_required_num)
end

function BossChallengeEventActivityObject:UpdateRewardState(rewards, star_required_num)
  for j, reward in ipairs(rewards) do
    if reward.star_required_num == star_required_num then
      reward.state = ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE
      return
    end
  end
end

function BossChallengeEventActivityObject:GetFinishBossChallengeEventSchedule()
  return ActivityUtils.GetFinishBossChallengeEventSchedule(self.BossChallengeData, true)
end

function BossChallengeEventActivityObject:GetNPCChallengeEventStarNum()
  return ActivityUtils.GetNPCChallengeEventStarNum(self.BossChallengeEventConf)
end

function BossChallengeEventActivityObject:GetActivityEndTime()
  if self:IsPreviewActivity() then
    local BossChallengeStartTime = self.BossChallengeEventConf and self.BossChallengeEventConf.start_time
    if not string.IsNilOrEmpty(BossChallengeStartTime) then
      return ActivityUtils.ToTimestampByDays(BossChallengeStartTime, self.BossChallengeEventConf.period)
    end
  end
  return Base.GetActivityEndTime(self)
end

function BossChallengeEventActivityObject:OnReconnectFinish()
  self:ReqGetPlayerActivityData()
end

function BossChallengeEventActivityObject:SyncActivityDataOnAvailable()
  self:ReqGetPlayerActivityData()
  BattleBossChallengeUtils.ShowAdditionalTarget()
end

function BossChallengeEventActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.ActivityData = _updateData
    self.BossChallengeData = self.ActivityData and self.ActivityData.boss_challenge_data
    _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.UpdateAppearanceRate)
  end
end

return BossChallengeEventActivityObject
