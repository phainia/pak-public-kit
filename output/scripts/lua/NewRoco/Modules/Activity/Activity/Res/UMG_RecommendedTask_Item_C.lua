local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RecommendedTask_Item_C = Base:Extend("UMG_RecommendedTask_Item_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_RecommendedTask_Item_C:OnConstruct()
  self:AddButtonListener(self.TraceBtn.btnLevelUp, self.OnTraceBtnClick)
end

function UMG_RecommendedTask_Item_C:OnDestruct()
  self:RemoveButtonListener(self.TraceBtn.btnLevelUp)
end

function UMG_RecommendedTask_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local taskConf = _G.DataConfigManager:GetTaskConf(_data.taskId)
  self.Text_describe:SetText(taskConf and taskConf.name or "")
  local paragraphId = taskConf and taskConf.paragraph_id or 0
  if 0 ~= paragraphId then
    local paragraphConf = _G.DataConfigManager:GetParagraphConf(paragraphId)
    self.Title:SetText(paragraphConf and paragraphConf.title or "")
  else
    self.Title:SetText("")
  end
  local taskStyle = taskConf and _G.DataConfigManager:GetTaskStyleConf(taskConf.task_class, true)
  taskStyle = taskStyle or _G.DataConfigManager:GetTaskStyleConf(Enum.TaskClassType.TCT_NONE)
  local taskIcon = ""
  if taskStyle then
    if _data.taskStatus == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
      taskIcon = taskStyle.icon_open
    elseif _data.taskStatus == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
      taskIcon = taskStyle.icon_wait
    elseif _data.taskStatus == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      taskIcon = taskStyle.icon_done
    else
      taskIcon = taskStyle.icon_open
    end
  end
  if not string.IsNilOrEmpty(taskIcon) then
    self.Image_Task:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Task:SetPath(taskIcon)
  else
    self.Image_Task:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _data.taskStatus == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
    self.NRCSwitcher_Btn:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_Btn:SetActiveWidgetIndex(1)
  end
end

function UMG_RecommendedTask_Item_C:OnItemSelected(_bSelected)
end

function UMG_RecommendedTask_Item_C:OnTraceBtnClick()
  local data = self.data
  if data then
    ActivityUtils.SetTraceTask(data.taskId)
  end
end

return UMG_RecommendedTask_Item_C
