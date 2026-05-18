local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_ActivitySurveyTab_C = Base:Extend("UMG_ActivitySurveyTab_C")

function UMG_ActivitySurveyTab_C:OnConstruct()
end

function UMG_ActivitySurveyTab_C:OnDestruct()
end

function UMG_ActivitySurveyTab_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetInfo(_data)
end

function UMG_ActivitySurveyTab_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:StopAllAnimations()
    self:PlayAnimation(self.Select)
    if self.uiData then
      _G.NRCModuleManager:GetModule("ActivityModule"):DispatchEvent(ActivityModuleEvent.SelectLimitedFlowerHandbookTabIndex, self.uiData.pet_raise_task_id)
    else
      Log.Error("UMG_ActivitySurveyTab uidata is nil")
    end
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Unselect)
  end
end

function UMG_ActivitySurveyTab_C:SetInfo(_data)
  local num = _data.num
  local petRaiseTask = _G.DataConfigManager:GetActivityPetRaiseTaskConf(_data.pet_raise_task_id)
  local taskConf = _G.DataConfigManager:GetTaskConf(_data.taskId)
  local targetNum = 0
  if taskConf and taskConf.task_condition[1] and taskConf.task_condition[1].count then
    targetNum = taskConf.task_condition[1].count
  end
  self.redPointReward:SetupKey(252, {
    _data.activityId,
    _data.pet_raise_task_id
  })
  self.redPointNew:SetupKey(250, {
    _data.activityId,
    _data.pet_raise_task_id
  })
  if self.redPointReward:IsRed() then
    self.redPointNew:SetRenderOpacity(0)
  end
  self.Title:SetText(petRaiseTask.task_type_name)
  self.icon:SetPath(petRaiseTask.icon_normal)
  self.selectImg:SetPath(petRaiseTask.icon_selected)
  self.Text_quantity:SetText(string.format("%d/%d", num or 0, targetNum))
end

function UMG_ActivitySurveyTab_C:OpItem(TableType)
end

function UMG_ActivitySurveyTab_C:OnDeactive()
end

return UMG_ActivitySurveyTab_C
