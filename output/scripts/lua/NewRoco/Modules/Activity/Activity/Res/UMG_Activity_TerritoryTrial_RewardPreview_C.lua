local UMG_Activity_TerritoryTrial_RewardPreview_C = _G.NRCPanelBase:Extend("UMG_Activity_TerritoryTrial_RewardPreview_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function UMG_Activity_TerritoryTrial_RewardPreview_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
  self:RegisterEvent(self, ActivityModuleEvent.OnSelectedActivityByOpenCmd, self.ClosePanel)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshTerritoryTrialRewardPreview, self.RefreshList)
end

function UMG_Activity_TerritoryTrial_RewardPreview_C:OnActive(rewardData)
  local data = _G.NRCCommonPopUpData()
  data.Call = self
  data.ClosePanelHandler = self.ClosePanel
  self.PopUp2:SetPanelInfo(data)
  for _, v in ipairs(rewardData) do
    v.parent = self
  end
  self.SubjectList:InitList(rewardData)
  self:LoadAnimation(0)
end

function UMG_Activity_TerritoryTrial_RewardPreview_C:OnDeactive()
  self:UnRegisterEvent(self, ActivityModuleEvent.OnSelectedActivityByOpenCmd)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshTerritoryTrialRewardPreview)
end

function UMG_Activity_TerritoryTrial_RewardPreview_C:OnAddEventListener()
end

function UMG_Activity_TerritoryTrial_RewardPreview_C:RefreshList(rewardData)
  for _, v in ipairs(rewardData) do
    v.parent = self
  end
  self.SubjectList:InitList(rewardData, true)
end

function UMG_Activity_TerritoryTrial_RewardPreview_C:ClosePanel()
  self:LoadAnimation(2)
end

function UMG_Activity_TerritoryTrial_RewardPreview_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Activity_TerritoryTrial_RewardPreview_C:SetRewardId(reward_id)
  self.idRecorder = reward_id
end

function UMG_Activity_TerritoryTrial_RewardPreview_C:GetRewardId()
  return self.idRecorder
end

return UMG_Activity_TerritoryTrial_RewardPreview_C
