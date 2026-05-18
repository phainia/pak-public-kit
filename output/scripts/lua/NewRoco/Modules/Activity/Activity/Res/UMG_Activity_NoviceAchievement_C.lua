local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_NoviceAchievement_C = Base:Extend("UMG_Activity_NoviceAchievement_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function UMG_Activity_NoviceAchievement_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = _G.Enum.ActivityType.ATP_CONDITION_GROUP_REWARD
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.BG
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  return uiElements
end

function UMG_Activity_NoviceAchievement_C:OnConstruct()
  Base.OnConstruct(self)
  self:OnAddEventListener()
  self.dialogSubIndex = 0
end

function UMG_Activity_NoviceAchievement_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelay(self.DelayId)
    self.DelayId = nil
  end
  self:RemoveAllButtonListener()
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshNoviceAchievementActivityData)
end

function UMG_Activity_NoviceAchievement_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  if firstLoad then
    self.dialogTextList = self.activityInst:GetDialogTextList()
    self.playerGender = Enum.ESexValue.SEX_MALE
    local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player then
      self.playerGender = player.gender
    end
    if self.activityInst.activityGroupConf then
      self.fashionBondConf = _G.DataConfigManager:GetFashionBondConf(self.activityInst.activityGroupConf.fashion_bond_id)
    end
    self:RefreshFixedView()
  end
  self.activityInst:RefreshAllConditionProgress()
  if self.activityInst:GetCondGroupData() then
    self:OnRefreshNoviceAchievementActivityData(self.activityInst:GetActivityId())
  end
  self:RefreshDialogue(true)
end

function UMG_Activity_NoviceAchievement_C:OnAddEventListener()
  self:AddButtonListener(self.PictureButton, self.OnExplorationGroupClick)
  self:AddButtonListener(self.PictureButton_1, self.OnPetGroupClick)
  self:AddButtonListener(self.PictureButton_2, self.OnBattleGroupClick)
  self:AddButtonListener(self.PictureButton_3, self.OnFriendGroupClick)
  self:AddButtonListener(self.PictureButton_4, self.OnDialogueClick)
  self:AddButtonListener(self.PictureButton_5, self.OnDialogueClick)
  self:AddButtonListener(self.GorgeousMagicBtn, self.OnGorgeousMagicBtnClick)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshNoviceAchievementActivityData, self.OnRefreshNoviceAchievementActivityData)
end

function UMG_Activity_NoviceAchievement_C:RefreshFixedView()
  self.TitleText:SetText(self.activityInst:GetGroupConfName(Enum.ActivityConditionTaskGroup.ACTG_GROUP_1))
  self.TitleText_1:SetText(self.activityInst:GetGroupConfName(Enum.ActivityConditionTaskGroup.ACTG_GROUP_2))
  self.TitleText_2:SetText(self.activityInst:GetGroupConfName(Enum.ActivityConditionTaskGroup.ACTG_GROUP_3))
  self.TitleText_3:SetText(self.activityInst:GetGroupConfName(Enum.ActivityConditionTaskGroup.ACTG_GROUP_4))
end

function UMG_Activity_NoviceAchievement_C:RefreshView()
  local notLockShow = LuaText.Activity_New_player_unlock_group_tips
  local progress1, hasRewardWait1, bLock1 = self.activityInst:GetSingleGroupProgressInfo(Enum.ActivityConditionTaskGroup.ACTG_GROUP_1)
  local progress2, hasRewardWait2, bLock2 = self.activityInst:GetSingleGroupProgressInfo(Enum.ActivityConditionTaskGroup.ACTG_GROUP_2)
  local progress3, hasRewardWait3, bLock3 = self.activityInst:GetSingleGroupProgressInfo(Enum.ActivityConditionTaskGroup.ACTG_GROUP_3)
  local progress4, hasRewardWait4, bLock4 = self.activityInst:GetSingleGroupProgressInfo(Enum.ActivityConditionTaskGroup.ACTG_GROUP_4)
  local bigRewardState, completedGroupNum, totalGroupNum = self.activityInst:GetBigRewardProgressInfo()
  self.ProgressText_1:SetText(bLock1 and string.format("%s%%", progress1) or notLockShow)
  self.ProgressText_2:SetText(bLock2 and string.format("%s%%", progress2) or notLockShow)
  self.ProgressText_3:SetText(bLock3 and string.format("%s%%", progress3) or notLockShow)
  self.ProgressText_4:SetText(bLock4 and string.format("%s%%", progress4) or notLockShow)
  self.PictureFrame:SetActiveWidgetIndex(100 == progress1 and bLock1 and 1 or 0)
  self.PictureFrame_1:SetActiveWidgetIndex(100 == progress2 and bLock2 and 1 or 0)
  self.PictureFrame_2:SetActiveWidgetIndex(100 == progress3 and bLock3 and 1 or 0)
  self.PictureFrame_3:SetActiveWidgetIndex(100 == progress4 and bLock4 and 1 or 0)
  self.redPointNew_1:ShowRedPoint(hasRewardWait1 and bLock1)
  self.redPointNew_2:ShowRedPoint(hasRewardWait2 and bLock2)
  self.redPointNew_3:ShowRedPoint(hasRewardWait3 and bLock3)
  self.redPointNew_4:ShowRedPoint(hasRewardWait4 and bLock4)
  self.Text_Describe:SetText(string.format(self.activityInst.activityGroupConf.reward_des, completedGroupNum, totalGroupNum))
  self.GridView_List:SetCustomData({
    activityInst = self.activityInst,
    bigRewardState = bigRewardState
  })
  self.GridView_List:InitGridView(self.activityInst:GetBigRewardInfo())
end

function UMG_Activity_NoviceAchievement_C:RefreshDialogue(bRandom)
  if bRandom then
    if #self.dialogTextList > 0 then
      self.dialogIndex = math.random(1, #self.dialogTextList)
    else
      self.dialogIndex = 0
    end
  else
    self.dialogIndex = self.dialogIndex and self.dialogIndex + 1 or 1
    if self.dialogIndex > #self.dialogTextList then
      self.dialogIndex = 1
    end
  end
  self.dialogSubIndex = 1
  self:RefreshSubDialogue()
end

function UMG_Activity_NoviceAchievement_C:RefreshSubDialogue()
  if not (self and UE4.UObject.IsValid(self)) or not self.dialogSubIndex then
    return
  end
  self.dialogSubIndex = self.dialogSubIndex + 1
  local totalStr = self.dialogTextList[self.dialogIndex]
  local subStr = string.sub(totalStr, 1, self.dialogSubIndex)
  self.NRCText_0:SetText(subStr)
  if self.dialogSubIndex < #totalStr then
    if self.DelayId then
      _G.DelayManager:CancelDelay(self.DelayId)
      self.DelayId = nil
    end
    self.DelayId = _G.DelayManager:DelaySeconds(0.02, function()
      self:RefreshSubDialogue()
    end)
  end
end

function UMG_Activity_NoviceAchievement_C:OnRefreshNoviceAchievementActivityData(_activityId, condGroupData)
  if self.activityInst:GetActivityId() == _activityId then
    self:RefreshView()
  end
end

function UMG_Activity_NoviceAchievement_C:OnGroupClick(groupId)
  if not self.activityInst:SingleGroupIsLock(groupId, true) then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenActivityCollectPanel, groupId, self.activityInst)
end

function UMG_Activity_NoviceAchievement_C:OnExplorationGroupClick()
  self:PlayAnimation(self.Click_press_1)
  self:OnGroupClick(Enum.ActivityConditionTaskGroup.ACTG_GROUP_1)
end

function UMG_Activity_NoviceAchievement_C:OnPetGroupClick()
  self:PlayAnimation(self.Click_press_2)
  self:OnGroupClick(Enum.ActivityConditionTaskGroup.ACTG_GROUP_2)
end

function UMG_Activity_NoviceAchievement_C:OnBattleGroupClick()
  self:PlayAnimation(self.Click_press_3)
  self:OnGroupClick(Enum.ActivityConditionTaskGroup.ACTG_GROUP_3)
end

function UMG_Activity_NoviceAchievement_C:OnFriendGroupClick()
  self:PlayAnimation(self.Click_press_4)
  self:OnGroupClick(Enum.ActivityConditionTaskGroup.ACTG_GROUP_4)
end

function UMG_Activity_NoviceAchievement_C:OnDialogueClick()
  self:PlayAnimation(self.Dialog_box_click)
  self:RefreshDialogue()
end

function UMG_Activity_NoviceAchievement_C:OnGorgeousMagicBtnClick()
  if self.fashionBondConf then
    local fashionBondConf = self.fashionBondConf
    local context = {
      bIsShiningMedal = true,
      title = LuaText.popup_magic_award,
      image = self.playerGender == Enum.ESexValue.SEX_MALE and fashionBondConf.fashion_bond_album_male or fashionBondConf.fashion_bond_album_female,
      leftImage = fashionBondConf.fashion_bond_icon,
      desc = fashionBondConf.popup_text,
      bondId = fashionBondConf.id
    }
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenShiningMedalDetailPanel, context)
  end
end

function UMG_Activity_NoviceAchievement_C:OnAnimationFinished(Anim)
  if Anim == self.Reward_ready_loop then
    self:PlayAnimation(self.Reward_ready_loop)
  elseif Anim == self.Reward_get then
    self.Completed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif Anim == self.Click_press_1 then
    self:PlayAnimation(self.Click_UP_1)
  elseif Anim == self.Click_press_2 then
    self:PlayAnimation(self.Click_UP_2)
  elseif Anim == self.Click_press_3 then
    self:PlayAnimation(self.Click_UP_3)
  elseif Anim == self.Click_press_4 then
    self:PlayAnimation(self.Click_UP_4)
  end
end

return UMG_Activity_NoviceAchievement_C
