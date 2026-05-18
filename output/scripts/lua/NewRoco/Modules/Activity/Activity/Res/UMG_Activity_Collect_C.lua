local UMG_Activity_Collect_C = _G.NRCPanelBase:Extend("UMG_Activity_Collect_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function UMG_Activity_Collect_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
  self:SetCommonPopUpInfo()
  self:RegisterEvent(self, ActivityModuleEvent.RefreshNoviceAchievementActivityData, self.OnRefreshNoviceAchievementActivityData)
end

function UMG_Activity_Collect_C:OnDestruct()
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshNoviceAchievementActivityData)
end

function UMG_Activity_Collect_C:OnActive(group_id, activityInst)
  self:LoadAnimation(0)
  if not group_id then
    Log.Error("group_id is nil")
    return
  end
  if not activityInst then
    Log.Error("activityInst is nil")
    return
  end
  self.group_id = group_id
  self.activityInst = activityInst
  self.priorityOrder = {
    [ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT] = 1,
    [ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH] = 2,
    [ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNOPEN] = 3,
    [ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE] = math.maxinteger
  }
  self:RefreshView()
end

function UMG_Activity_Collect_C:RefreshView()
  local conf = self.activityInst:GetSingleGroupConf(self.group_id)
  if conf then
    local listData = {}
    if conf.include_condition_id then
      for i, v in ipairs(conf.include_condition_id) do
        local reward_state = self.activityInst:GetSingleConditionState(self.group_id, v) or ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNOPEN
        local curProgress, totalProgress, RequiredType = self.activityInst:GetConditionRewardProgress(v)
        table.insert(listData, {
          conditionId = v,
          rewardState = reward_state,
          curProgress = math.min(curProgress, totalProgress),
          totalProgress = totalProgress
        })
      end
    end
    if #listData > 1 then
      table.sort(listData, function(a, b)
        if self.priorityOrder[a.rewardState] == self.priorityOrder[b.rewardState] then
          return a.conditionId < b.conditionId
        end
        return self.priorityOrder[a.rewardState] < self.priorityOrder[b.rewardState]
      end)
    end
    self.PopUp1:SetTitleTextInfo(conf.part_name)
    self.GridView:SetCustomData({
      activityInst = self.activityInst,
      groupId = self.group_id
    })
    self.GridView:InitGridView(listData)
  end
end

function UMG_Activity_Collect_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp1:SetPanelInfo(CommonPopUpData)
end

function UMG_Activity_Collect_C:OnRefreshNoviceAchievementActivityData(_activityId, condGroupData)
  if self.group_id and condGroupData and condGroupData.group_data then
    for i, v in ipairs(condGroupData.group_data) do
      if v.group_id == self.group_id then
        self:RefreshView()
      end
    end
  end
end

function UMG_Activity_Collect_C:OnPcClose()
  self:OnClose()
end

function UMG_Activity_Collect_C:OnClose()
  self:LoadAnimation(2)
end

function UMG_Activity_Collect_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Activity_Collect_C
