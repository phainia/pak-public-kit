local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionReceiveCampPetReportBonus = Base:Extend("NPCActionReceiveCampPetReportBonus")

function NPCActionReceiveCampPetReportBonus:ExecuteWithModel()
  if not self.RewardID and self.Info and self.Info.begin_act_params then
    local CampPetReportConf = _G.DataConfigManager:GetCampPetReportConf(self.Info.begin_act_params[1])
    if CampPetReportConf then
      self.RewardID = CampPetReportConf.reward_id
    end
  end
  if self.RewardID then
    _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.ActionOpenNPCShopItemRewardsPanel, self.RewardID, self)
  end
end

function NPCActionReceiveCampPetReportBonus:EndAction()
  self:Finish()
end

function NPCActionReceiveCampPetReportBonus:IsNeedCloseDialogueUI()
  return false
end

return NPCActionReceiveCampPetReportBonus
