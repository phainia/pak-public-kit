local UMG_KingCelebrationHomepage_C = _G.NRCPanelBase:Extend("UMG_KingCelebrationHomepage_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_KingCelebrationHomepage_C:OnActive(_activityInst)
  self.activityInst = _activityInst
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:RefreshUI()
end

function UMG_KingCelebrationHomepage_C:OnCloseBtnClick()
  self:DoClose()
end

function UMG_KingCelebrationHomepage_C:RefreshUI()
  local globalTaskData = {}
  local personalTaskData = {}
  if self.activityInst then
    if self.activityInst and self.activityInst.springFestivalData and self.activityInst.springFestivalData.global_popularity_task_ids then
      for key, value in pairs(self.activityInst.springFestivalData.global_popularity_task_ids) do
        table.insert(globalTaskData, {
          taskID = value,
          taskType = ActivityEnum.SprintTaskType.ServerPopularityTask
        })
      end
    end
    table.sort(globalTaskData, function(a, b)
      return a.taskID < b.taskID
    end)
    self.StageRewards:InitGridView(globalTaskData)
  end
  local lastGlobalTaskID = globalTaskData[#globalTaskData].taskID
  local taskInfo = self.activityInst:GetSpringTaskInfo(lastGlobalTaskID)
  if taskInfo then
    local count = taskInfo.task_target_list[1]
    local countInWan = count / 10000
    local text = string.format("%.1fw", countInWan)
    self.QuantityText:SetText(text)
  end
  local SprintNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_SPRING_FESTIVAL_COIN) or 0
  self.QuantityText_2:SetText(SprintNum)
end

function UMG_KingCelebrationHomepage_C:OnDestruct()
  self:RemoveButtonListener(self.CloseBtn.btnClose)
end

return UMG_KingCelebrationHomepage_C
