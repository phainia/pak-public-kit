local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_NoviceAchievement_Item1_C = Base:Extend("UMG_Activity_NoviceAchievement_Item1_C")

function UMG_Activity_NoviceAchievement_Item1_C:OnConstruct()
  self.ButtonClaim.OnClicked:Add(self, self.OnButtonClaimClick)
end

function UMG_Activity_NoviceAchievement_Item1_C:OnDestruct()
end

function UMG_Activity_NoviceAchievement_Item1_C:OnItemUpdate(_data, datalist, index)
  if not _data then
    Log.Error("UMG_Activity_NoviceAchievement_Item1_C:OnItemUpdate _data is nil")
    return
  end
  self.reward = _data
  local parentCustomData = self:GetParentCustomData()
  if parentCustomData then
    self.activityInst = parentCustomData.activityInst
    self.bigRewardState = parentCustomData.bigRewardState
  end
  self.ListItemIcon:OnItemUpdate(_data, nil, 1)
  self.redPointNew:ShowRedPoint(self.bigRewardState == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT)
  self.Completed:SetVisibility(self.bigRewardState == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self.lingqu:SetVisibility(self.bigRewardState == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if self:IsAnimationPlaying(self.Reward_get) then
    return
  end
  self:StopAllAnimations()
  if self.bigRewardState == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
    self:PlayAnimation(self.Reward_ready_loop)
  elseif self.bigRewardState == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
    self.Completed:SetRenderOpacity(1)
    self.lingqu:SetRenderOpacity(1)
  else
    self:PlayAnimation(self.In)
  end
end

function UMG_Activity_NoviceAchievement_Item1_C:OnButtonClaimClick()
  if self.activityInst and self.activityInst.condGroupData and self.activityInst.condGroupData.reward_state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
    self.activityInst:GetReward()
    self:StopAllAnimations()
    self:PlayAnimation(self.Reward_get)
  elseif self.reward then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.reward.itemId, self.reward.itemType)
  end
end

function UMG_Activity_NoviceAchievement_Item1_C:OnItemSelected(_bSelected)
end

function UMG_Activity_NoviceAchievement_Item1_C:OnDeactive()
end

function UMG_Activity_NoviceAchievement_Item1_C:OnAnimationFinished(Anim)
  if Anim == self.Reward_ready_loop then
    self:PlayAnimation(self.Reward_ready_loop)
  elseif Anim == self.Reward_get then
    self.Completed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

return UMG_Activity_NoviceAchievement_Item1_C
