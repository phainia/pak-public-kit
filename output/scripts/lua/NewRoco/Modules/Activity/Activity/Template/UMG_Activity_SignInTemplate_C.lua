local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_SignInTemplate_C = Base:Extend("UMG_Activity_SignInTemplate_C")

function UMG_Activity_SignInTemplate_C:OnConstruct()
  Base.OnConstruct(self)
  self:RegisterEvent(self, ActivityModuleEvent.StageRewardStatusChange, self.OnStageRewardStatusChange)
  if self.uiElements.signStages and next(self.uiElements.signStages) then
    for _listView, _stages in pairs(self.uiElements.signStages) do
      if _listView.InitList then
        _listView:InitList(ActivityUtils.CreateActivityItemBaseDataForList(self, _stages))
      elseif _listView.InitGridView then
        _listView:InitGridView(ActivityUtils.CreateActivityItemBaseDataForList(self, _stages))
      end
    end
  else
    self:LogError("signStages can not be nil or empty!")
  end
end

function UMG_Activity_SignInTemplate_C:OnDestruct()
  Base.OnDestruct(self)
  self:UnRegisterEvent(self, ActivityModuleEvent.StageRewardStatusChange)
end

function UMG_Activity_SignInTemplate_C:ForeachSignInItem(_callbackSelf, _callbackFunc, ...)
  if not _callbackFunc then
    return
  end
  local callback = _G.MakeWeakFunctor(_callbackSelf, _callbackFunc)
  for _listView, _stages in pairs(self.uiElements.signStages) do
    for _index, _ in ipairs(_stages) do
      local itemInst = _listView:GetItemByIndex(_index - 1)
      if itemInst then
        callback(itemInst, ...)
      end
    end
  end
end

function UMG_Activity_SignInTemplate_C:GetItemByStage(_stage)
  for _listView, _stages in pairs(self.uiElements.signStages) do
    for _index, _tmpStage in ipairs(_stages) do
      if _tmpStage == _stage then
        return _listView:GetItemByIndex(_index - 1)
      end
    end
  end
end

function UMG_Activity_SignInTemplate_C:OnStageRewardStatusChange(_activityInst, _stage, _rewardStatus, _userOperation)
  if _activityInst and _activityInst == self.activityInst then
    if self.itemCaches == nil then
      self.itemCaches = _G.MakeWeakTable({}, "v")
    end
    local itemInst = self.itemCaches[_stage] or self:GetItemByStage(_stage)
    if itemInst then
      self.itemCaches[_stage] = itemInst
    end
    if _userOperation and _rewardStatus == ActivityEnum.RewardStatus.Received and itemInst and itemInst.PlayRewardGetAnimation then
      itemInst:PlayRewardGetAnimation()
    end
    if itemInst then
      itemInst:RefreshView()
    end
  end
end

return UMG_Activity_SignInTemplate_C
