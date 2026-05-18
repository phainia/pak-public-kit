local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_WeekendLoginGiftBase = Base:Extend("UMG_Activity_WeekendLoginGiftBase")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_WeekendLoginGiftBase:BindUIElements()
  return {}
end

function UMG_Activity_WeekendLoginGiftBase:OnConstruct()
  Base.OnConstruct(self)
  self:RegisterEvent(self, ActivityModuleEvent.StageRewardStatusChange, self.OnStageRewardStatusChange)
end

function UMG_Activity_WeekendLoginGiftBase:OnDestruct()
  Base.OnDestruct(self)
  self:UnRegisterEvent(self, ActivityModuleEvent.StageRewardStatusChange)
end

function UMG_Activity_WeekendLoginGiftBase:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  if not firstLoad then
    for _index, _ in ipairs(self.signStages or {}) do
      self.listView:OpItemByIndex(_index, ActivityEnum.ItemOpType.Enable)
    end
  end
end

function UMG_Activity_WeekendLoginGiftBase:InitSignStages(activityInst, listView, signStages)
  if not activityInst or not listView then
    self:LogError("activityInst or listView can not be nil!")
    return
  end
  self.activityInst = activityInst
  self.listView = listView
  self.signStages = signStages or activityInst:GetSignStages()
  if listView.InitList then
    listView:InitList(ActivityUtils.CreateActivityItemBaseDataForList(self, self.signStages))
  elseif listView.InitGridView then
    listView:InitGridView(ActivityUtils.CreateActivityItemBaseDataForList(self, self.signStages))
  end
end

function UMG_Activity_WeekendLoginGiftBase:GetItemIndexByStage(_stage)
  local signStages = self.signStages
  for index, stage in ipairs(signStages or {}) do
    if stage == _stage then
      return index
    end
  end
end

function UMG_Activity_WeekendLoginGiftBase:OnStageRewardStatusChange(_activityInst, _stage, _rewardStatus, _userOperation)
  if _activityInst and _activityInst == self.activityInst then
    local itemIndex = self:GetItemIndexByStage(_stage)
    if itemIndex and self.listView then
      self.listView:OpItemByIndex(itemIndex, ActivityEnum.ItemOpType.RewardStatusChange, _userOperation)
    end
  end
end

function UMG_Activity_WeekendLoginGiftBase:OnItemSelected(_itemInst, _index, _stage, _bSelected)
  local _activityInst = self.activityInst
  if _bSelected and _activityInst then
    local rewardStatus = _activityInst:GetStageRewardStatus(_stage)
    if rewardStatus == ActivityEnum.RewardStatus.Available then
      _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.GetReward, _stage)
    elseif _activityInst:IsRewardExpired(_stage) then
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.activity_reward_expired_tips)
    end
  end
end

function UMG_Activity_WeekendLoginGiftBase:OnItemUpdate(_itemInst, _index, _stage)
  local _itemObject = self.activityInst
  if not _itemObject then
    return
  end
  if _itemInst then
    _itemInst:SetSignStage(_stage)
    _itemInst:SetupRedPoint(_itemObject:GetRewardRedPointData(_stage))
    local rewardIdList = _itemObject:GetStageRewardId(_stage, true) or {}
    local rewards = {}
    for _, rewardId in ipairs(rewardIdList) do
      local rewardCfg = _G.DataConfigManager:GetRewardConf(rewardId)
      if rewardCfg then
        for _, rewardData in ipairs(rewardCfg.RewardItem) do
          local rewardItem = ActivityUtils.ParseActivityRewardData(rewardData.Type, rewardData.Id, rewardData.Count)
          table.insert(rewards, rewardItem)
        end
      end
    end
    _itemInst:SetRewards(rewards)
    _itemInst:PlayInAnimation()
  end
  self:OnItemRefreshView(_itemInst, _index, _stage)
end

function UMG_Activity_WeekendLoginGiftBase:OnItemRefreshView(_itemInst, _index, _stage, _userOperation)
  local _itemObject = self.activityInst
  if not _itemObject then
    return
  end
  if _itemInst then
    local isExpired = _itemObject:IsRewardExpired(_stage)
    local tips
    local rewardStatus = _itemObject:GetStageRewardStatus(_stage)
    if rewardStatus == ActivityEnum.RewardStatus.UnAvailable then
      _itemInst:PlayRewardUnAvailableAnimation()
      local stageCfg = _itemObject:GetStageRewardsCfg(_stage)
      if stageCfg then
        tips = stageCfg.unlock_text
      end
    elseif rewardStatus == ActivityEnum.RewardStatus.Available then
      _itemInst:PlayRewardAvailableAnimation()
    elseif rewardStatus == ActivityEnum.RewardStatus.Received then
      if _userOperation then
        _itemInst:PlayRewardGetAnimation()
      else
        _itemInst:PlayRewardReceivedAnimation()
      end
    end
    if isExpired then
      tips = _G.LuaText.activity_expired_show_tip
    end
    _itemInst:SetRewardStatus(rewardStatus, isExpired, tips)
  end
end

function UMG_Activity_WeekendLoginGiftBase:OnItemOp(_itemInst, _index, _stage, _opType, _opParam)
  if _itemInst then
    if _opType == ActivityEnum.ItemOpType.RewardStatusChange then
      self:OnItemRefreshView(_itemInst, _index, _stage, _opParam)
    elseif _opType == ActivityEnum.ItemOpType.Enable then
      _itemInst:PlayInAnimation()
    end
  end
end

return UMG_Activity_WeekendLoginGiftBase
