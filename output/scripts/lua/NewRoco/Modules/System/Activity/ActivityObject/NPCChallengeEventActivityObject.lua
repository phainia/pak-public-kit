local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local NPCChallengeEventActivityObject = Base:Extend("NPCChallengeEventActivityObject")

function NPCChallengeEventActivityObject:OnConstruct(_conf)
  self.NpcChallengeData = nil
  self.ActivityData = nil
  self.ActivityConf = _conf
  self.NpcChallengeEventConf = _G.DataConfigManager:GetNpcChallengeEventConf(self:GetSinglePartId())
  self.SecondTabIcon = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_jianying_png.img_jianying_png'"
end

function NPCChallengeEventActivityObject:OnDestruct()
end

function NPCChallengeEventActivityObject:IsPreviewActivity()
  return self:GetActivityType() == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT
end

function NPCChallengeEventActivityObject:GetNpcChallengeData()
  return self.NpcChallengeData
end

function NPCChallengeEventActivityObject:ChallengeSetModuleUnlockReadEd(module_id)
  if self.NpcChallengeData then
    for i, NpcChallenge in ipairs(self.NpcChallengeData.modules) do
      if module_id == NpcChallenge.module_id then
        NpcChallenge.is_readed = true
      end
    end
  end
end

function NPCChallengeEventActivityObject:GetCyclicalChallengeConf()
  return self.NpcChallengeEventConf
end

function NPCChallengeEventActivityObject:GetNpcActivityId()
  if self.ActivityData and self.ActivityData.activity_id then
    return self.ActivityData.activity_id
  end
  Log.Warning("\230\178\161\230\156\137ActivityData\230\136\150\232\128\133activity_id\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
  return nil
end

function NPCChallengeEventActivityObject:GetActivityConf()
  return self.ActivityConf
end

function NPCChallengeEventActivityObject:SetRewardState(star_required_num)
  local rewards = self.ActivityData.npc_challenge_data.rewards
  self:UpdateRewardState(rewards, star_required_num)
end

function NPCChallengeEventActivityObject:UpdateRewardState(rewards, star_required_num)
  for j, reward in ipairs(rewards) do
    if reward.star_required_num == star_required_num then
      reward.state = ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE
      return
    end
  end
end

function NPCChallengeEventActivityObject:GetFinishNPCChallengeEventSchedule()
  return ActivityUtils.GetFinishNPCChallengeEventSchedule(self.NpcChallengeData, true)
end

function NPCChallengeEventActivityObject:GetNPCChallengeEventStarNum()
  return ActivityUtils.GetNPCChallengeEventStarNum(self.NpcChallengeEventConf)
end

function NPCChallengeEventActivityObject:GetActivityEndTime()
  if self:IsPreviewActivity() then
    local NpcChallengeStartTime = self.NpcChallengeEventConf and self.NpcChallengeEventConf.start_time
    if not string.IsNilOrEmpty(NpcChallengeStartTime) then
      return ActivityUtils.ToTimestampByDays(NpcChallengeStartTime, self.NpcChallengeEventConf.period)
    end
  end
  return Base.GetActivityEndTime(self)
end

function NPCChallengeEventActivityObject:OnReconnectFinish()
  self:ReqGetPlayerActivityData()
end

function NPCChallengeEventActivityObject:SyncActivityDataOnAvailable()
  self:ReqGetPlayerActivityData()
end

function NPCChallengeEventActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.ActivityData = _updateData
    self.NpcChallengeData = self.ActivityData and self.ActivityData.npc_challenge_data
    _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.UpdateAppearanceRate)
  end
end

return NPCChallengeEventActivityObject
