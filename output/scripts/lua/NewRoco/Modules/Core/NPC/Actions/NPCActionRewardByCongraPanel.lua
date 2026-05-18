local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local NPCActionRewardByCongraPanel = Base:Extend("NPCActionRewardByCongraPanel")

function NPCActionRewardByCongraPanel:OnDialogueAction()
  self:OpenRewardsPanel()
  Base.OnDialogueAction(self)
end

function NPCActionRewardByCongraPanel:UpdateInfo(Info, Reconnect)
  if Reconnect then
    return
  end
  if Info.act_status == ProtoEnum.SpaceEnum_NpcActionStatus.ENUM.Executing then
    Base.UpdateInfo(self, Info, Reconnect)
  end
end

function NPCActionRewardByCongraPanel:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  self:OpenRewardsPanel()
end

function NPCActionRewardByCongraPanel:OpenRewardsPanel()
  if not self.RewardID and self.Info and self.Info.begin_act_params then
    self.RewardID = self.Info.begin_act_params[1]
  end
  if self.RewardID then
    _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.ActionOpenNPCShopItemRewardsPanel, self.RewardID, self, true)
    self:Finish(true)
  end
end

return NPCActionRewardByCongraPanel
