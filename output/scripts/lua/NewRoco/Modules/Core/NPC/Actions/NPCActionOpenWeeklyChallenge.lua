local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionOpenWeeklyChallenge = Base:Extend("NPCActionOpenNPCChallenge")

function NPCActionOpenWeeklyChallenge:ExecuteWithModel()
  local View = self:GetOwnerNPCView()
  if not View then
    self:Finish(false)
    return true
  end
  self.WeeklyChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT)
  if not self.WeeklyChallengeEventActivityObject or not self.WeeklyChallengeEventActivityObject[1] then
    self:Finish(false)
    return true
  end
  local weekly_challenge_data = self.WeeklyChallengeEventActivityObject[1]:GetWeeklyChallengeData()
  if not weekly_challenge_data then
    self:Finish(false)
    return true
  end
  _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.OpenStarlightPhoto, self, 0)
end

function NPCActionOpenWeeklyChallenge:Finish(success, data, param)
  Base.Finish(self, success, data, param)
end

return NPCActionOpenWeeklyChallenge
