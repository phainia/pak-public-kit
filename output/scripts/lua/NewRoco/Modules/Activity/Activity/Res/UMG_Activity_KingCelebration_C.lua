local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_KingCelebration_C = Base:Extend("UMG_Activity_KingCelebration_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")

function UMG_Activity_KingCelebration_C:OnConstruct()
  Base.OnConstruct(self)
  self.RedDot:SetupKey(444)
  self.RedDot:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:AddButtonListener(self.ClickButton, self.OnClickButton)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshSpringFestivalActivityData, self.OnRefreshSpringFestivalActivityData)
  _G.NRCEventCenter:RegisterEvent("UMG_Activity_KingCelebration_C", self, TaskModuleEvent.OnTaskUpdated, self.OnTaskUpdated)
  self.deltaTime = 0.016
  self.AnimDuration = 0.6
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnVItemChanged)
end

function UMG_Activity_KingCelebration_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveButtonListener(self.BtnClaimHeatReward)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshSpringFestivalActivityData)
  _G.NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.OnTaskUpdated, self.OnTaskUpdated)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnVItemChanged)
end

function UMG_Activity_KingCelebration_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.MythicalCreaturesBG
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  uiElements.desireActivityType = _G.Enum.ActivityType.ATP_SPRING_FESTIVAL
  return uiElements
end

function UMG_Activity_KingCelebration_C:OnEnable()
  Log.Debug("[KingCelebration] OnEnable called, activityInst:", self.activityInst ~= nil)
  if self.activityInst then
    self:RefreshSubActivityEntrance()
    self:OnInitSpringUI()
  end
  if self.In then
    self:PlayAnimation(self.In)
  end
  self.newLastGlobalNum = 0
end

function UMG_Activity_KingCelebration_C:OnInitSpringUI()
  Log.Debug("[KingCelebration] OnInitSpringUI start")
  if self.Text_Personal then
    self.Text_Personal:SetText(LuaText.spring_festival_owner_text)
  end
  if self.Text_AllServers then
    self.Text_AllServers:SetText(LuaText.spring_festival_all_text)
  end
  local subProgress = {}
  if self.activityInst then
    local partID = self.activityInst:GetSinglePartId()
    Log.Debug("[KingCelebration] OnInitSpringUI partID:", partID)
    if partID then
      local activitySpringConf = _G.DataConfigManager:GetActivitySpringFestivalConf(partID)
      if activitySpringConf then
        subProgress = activitySpringConf.progressarray
        Log.Debug("[KingCelebration] OnInitSpringUI subProgress:", table.concat(subProgress or {}, ","))
      end
    end
  end
  self.SubProgress = subProgress
  local globalTaskData = {}
  if self.activityInst and self.activityInst.springFestivalData and self.activityInst.springFestivalData.global_popularity_task_ids then
    for _, value in pairs(self.activityInst.springFestivalData.global_popularity_task_ids) do
      table.insert(globalTaskData, {
        taskID = value,
        taskType = ActivityEnum.SprintTaskType.ServerPopularityTask
      })
    end
  end
  table.sort(globalTaskData, function(a, b)
    return a.taskID < b.taskID
  end)
  self.GlobalTaskData = globalTaskData
  Log.Debug("[KingCelebration] OnInitSpringUI globalTaskData count:", #globalTaskData)
  self.StageRewards:InitGridView(globalTaskData)
  self:InitProgressBar()
  local lastNum = self.activityInst:GetLastSpringFestivalNum()
  Log.Debug("[KingCelebration] OnInitSpringUI lastNum (cached):", lastNum)
  if 0 == lastNum then
    local currentNum = self:GetPersonalCur()
    Log.Debug("[KingCelebration] OnInitSpringUI lastNum is 0, show currentNum instead:", currentNum)
    self.Text_Time:SetText(currentNum)
  else
    self.Text_Time:SetText(lastNum)
  end
  local lastGlobalTaskID = globalTaskData[#globalTaskData] and globalTaskData[#globalTaskData].taskID
  local taskInfo = lastGlobalTaskID and self.activityInst and self.activityInst:GetSpringTaskInfo(lastGlobalTaskID)
  local currentGlobalNum = 0
  if taskInfo and taskInfo.task_target_list and taskInfo.task_target_list[1] then
    currentGlobalNum = taskInfo.task_target_list[1]
    self.Text_Time_1:SetText(ActivityUtils.GetSprintFormatText(currentGlobalNum))
  end
  self.newLastGlobalNum = currentGlobalNum
  Log.Debug("[KingCelebration] OnInitSpringUI currentGlobalNum:", currentGlobalNum)
end

function UMG_Activity_KingCelebration_C:OnDisable()
  local currentSprintNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_SPRING_FESTIVAL_COIN) or 0
  if self.activityInst and self.activityInst.SetLastSpringFestivalNum then
    self.activityInst:SetLastSpringFestivalNum(currentSprintNum)
    self.activityInst:SetLastGlobalNum(self.newLastGlobalNum)
  end
  if self.Out then
    self:PlayAnimation(self.Out)
  end
  if self.PersonalAnimTimer then
    self.PersonalAnimTimer:Clear()
    self.PersonalAnimTimer = nil
  end
  if self.GlobalAnimTimer then
    self.GlobalAnimTimer:Clear()
    self.GlobalAnimTimer = nil
  end
end

function UMG_Activity_KingCelebration_C:OnRefreshSpringFestivalActivityData()
  Log.Debug("[KingCelebration] OnRefreshSpringFestivalActivityData called, activityInst:", self.activityInst ~= nil)
  if self.activityInst then
    self:RefreshOnlineTaskUI()
  end
end

function UMG_Activity_KingCelebration_C:OnVItemChanged()
  Log.Debug("[KingCelebration] OnVItemChanged start")
  self.LastPersonalProgress = self.CurrentPersonalProgress or 0
  
  local function getPersonalCurFunc()
    return self:GetPersonalCur()
  end
  
  self.CurrentPersonalProgress = self:CalcWeightedProgress(getPersonalCurFunc, 2)
  Log.Debug("[KingCelebration] OnVItemChanged RefreshProgressBar from personal:", self.LastPersonalProgress, "to:", self.CurrentPersonalProgress)
end

function UMG_Activity_KingCelebration_C:CalcWeightedProgress(getCurVal, condIndex)
  Log.Debug("[KingCelebration] CalcWeightedProgress start, condIndex:", condIndex)
  local prog = 0
  local prevTargetSum = 0
  local prevCurVal = 0
  local subProgress = self.SubProgress
  for idx, stage in ipairs(self.GlobalTaskData) do
    local taskConf = _G.DataConfigManager:GetTaskConf(stage.taskID)
    if idx > #subProgress then
      Log.Warning("subProgress length is less than idx: ", idx)
      break
    end
    local weight = subProgress[idx] or 0
    if taskConf and taskConf.task_condition and taskConf.task_condition[condIndex] then
      local totalTarget = taskConf.task_condition[condIndex].count or 0
      local totalCurVal = getCurVal(stage.taskID) or 0
      Log.Debug("[KingCelebration] CalcWeightedProgress stage:", idx, "taskID:", stage.taskID, "weight:", weight, "totalTarget:", totalTarget, "totalCurVal:", totalCurVal, "prevTargetSum:", prevTargetSum)
      local stageTarget = math.max(totalTarget - prevTargetSum, 0)
      local stageCurVal = math.max(totalCurVal - prevTargetSum, 0)
      if stageTarget > 0 then
        local ratio = stageCurVal / stageTarget
        Log.Debug("[KingCelebration] CalcWeightedProgress stage:", idx, "stageTarget:", stageTarget, "stageCurVal:", stageCurVal, "ratio:", ratio)
        if ratio <= 0 then
          ratio = 0
          prog = prog + weight * ratio
          break
        elseif ratio < 1 then
          ratio = math.min(ratio, 1)
          prog = prog + weight * ratio
          break
        else
          prog = prog + weight
        end
      end
      prevTargetSum = totalTarget
      prevCurVal = totalCurVal
    end
  end
  Log.Debug("[KingCelebration] CalcWeightedProgress result prog:", prog)
  return prog
end

function UMG_Activity_KingCelebration_C:GetGlobalCur(taskID)
  if not self.activityInst then
    return 0
  end
  local info = self.activityInst:GetSpringTaskInfo(taskID)
  local result = 0
  if info and info.task_target_list and info.task_target_list[1] then
    result = info.task_target_list[1]
  end
  Log.Debug("[KingCelebration] GetGlobalCur taskID:", taskID, "result:", result)
  return result
end

function UMG_Activity_KingCelebration_C:GetPersonalCur(bLog)
  local currentSprintNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_SPRING_FESTIVAL_COIN) or 0
  if nil == bLog or bLog then
    Log.Debug("[KingCelebration] GetPersonalCur currentSprintNum:", currentSprintNum)
  end
  return currentSprintNum
end

function UMG_Activity_KingCelebration_C:RefreshOnlineTaskUI()
  local globalTaskData = {}
  if self.activityInst and self.activityInst.springFestivalData and self.activityInst.springFestivalData.global_popularity_task_ids then
    for _, value in pairs(self.activityInst.springFestivalData.global_popularity_task_ids) do
      table.insert(globalTaskData, {
        taskID = value,
        taskType = ActivityEnum.SprintTaskType.ServerPopularityTask
      })
    end
  end
  table.sort(globalTaskData, function(a, b)
    return a.taskID < b.taskID
  end)
  self.GlobalTaskData = globalTaskData
  self.StageRewards:InitGridView(globalTaskData)
end

function UMG_Activity_KingCelebration_C:UpdateProgressBarAnimation(progressBar, lastProgress, currentProgress, easeT)
  if not (progressBar and lastProgress) or not currentProgress then
    Log.Debug("[KingCelebration] UpdateProgressBarAnimation early return, progressBar:", nil ~= progressBar, "lastProgress:", lastProgress, "currentProgress:", currentProgress)
    return
  end
  local progressDiff = currentProgress - lastProgress
  local animatedProgress = lastProgress + progressDiff * easeT
  progressBar:SetPercent(animatedProgress)
end

function UMG_Activity_KingCelebration_C:UpdateNumberTextAnimation(textWidget, lastNum, currentNum, easeT)
  if not (textWidget and lastNum) or not currentNum then
    Log.Debug("[KingCelebration] UpdateNumberTextAnimation early return, textWidget:", nil ~= textWidget, "lastNum:", lastNum, "currentNum:", currentNum)
    return
  end
  local deltaNum = currentNum - lastNum
  if deltaNum > 0 then
    local animatedNum = lastNum + math.floor(deltaNum * easeT)
    textWidget:SetText(animatedNum)
  else
    Log.Debug("[KingCelebration] UpdateNumberTextAnimation deltaNum <= 0, skipping animation, deltaNum:", deltaNum)
  end
end

function UMG_Activity_KingCelebration_C:OnPersonalAnimTimerUpdate()
  if not self.PersonalAnimTimer then
    Log.Debug("[KingCelebration] OnPersonalAnimTimerUpdate early return, PersonalAnimTimer is nil")
    return
  end
  local elapsedTime = self.PersonalAnimTimer.duration - self.PersonalAnimTimer.leftTime
  local t = math.min(elapsedTime / self.PersonalAnimTimer.duration, 1.0)
  local easeT = 1 - (1 - t) ^ 3
  self:UpdateProgressBarAnimation(self.ProgressBar2, self.LastPersonalProgress, self.CurrentPersonalProgress, easeT)
  local lastPersonalNum = self.activityInst:GetLastSpringFestivalNum()
  local currentPersonalNum = self:GetPersonalCur(false)
  self:UpdateNumberTextAnimation(self.Text_Time, lastPersonalNum, currentPersonalNum, easeT)
  local deltaNum = currentPersonalNum - lastPersonalNum
  local animatedPersonalNum = lastPersonalNum + math.floor(deltaNum * easeT)
  _G.NRCEventCenter:DispatchEvent(ActivityModuleEvent.OnKingCelebrationProgressAnimUpdate, {personalNum = animatedPersonalNum, globalNum = nil})
end

function UMG_Activity_KingCelebration_C:OnPersonalAnimTimerComplete()
  Log.Debug("[KingCelebration] OnPersonalAnimTimerComplete called")
  if self.ProgressBar2 and self.CurrentPersonalProgress then
    self.ProgressBar2:SetPercent(self.CurrentPersonalProgress)
    Log.Debug("[KingCelebration] OnPersonalAnimTimerComplete set ProgressBar2 to:", self.CurrentPersonalProgress)
  end
  if self.Text_Time then
    local currentPersonalNum = self:GetPersonalCur()
    self.Text_Time:SetText(currentPersonalNum)
    Log.Debug("[KingCelebration] OnPersonalAnimTimerComplete set Text_Time to:", currentPersonalNum)
  end
  local currentPersonalNum = self:GetPersonalCur(false)
  Log.Debug("[KingCelebration] OnPersonalAnimTimerComplete dispatch final personalNum:", currentPersonalNum)
  _G.NRCEventCenter:DispatchEvent(ActivityModuleEvent.OnKingCelebrationProgressAnimUpdate, {personalNum = currentPersonalNum, globalNum = nil})
  self.PersonalAnimTimer = nil
end

function UMG_Activity_KingCelebration_C:OnGlobalAnimTimerUpdate()
  if not self.GlobalAnimTimer then
    Log.Debug("[KingCelebration] OnGlobalAnimTimerUpdate early return, GlobalAnimTimer is nil")
    return
  end
  local elapsedTime = self.GlobalAnimTimer.duration - self.GlobalAnimTimer.leftTime
  local t = math.min(elapsedTime / self.GlobalAnimTimer.duration, 1.0)
  local easeT = 1 - (1 - t) ^ 3
  self:UpdateProgressBarAnimation(self.ProgressBar, self.LastGlobalProgress, self.CurrentGlobalProgress, easeT)
  local lastGlobalNum = self.activityInst:GetLastGlobalNum() or 0
  local currentGlobalNum = self.newLastGlobalNum or 0
  local deltaNum = currentGlobalNum - lastGlobalNum
  local animatedGlobalNum = lastGlobalNum + math.floor(deltaNum * easeT)
  _G.NRCEventCenter:DispatchEvent(ActivityModuleEvent.OnKingCelebrationProgressAnimUpdate, {personalNum = nil, globalNum = animatedGlobalNum})
end

function UMG_Activity_KingCelebration_C:OnGlobalAnimTimerComplete()
  Log.Debug("[KingCelebration] OnGlobalAnimTimerComplete called")
  if self.ProgressBar and self.CurrentGlobalProgress then
    self.ProgressBar:SetPercent(self.CurrentGlobalProgress)
    Log.Debug("[KingCelebration] OnGlobalAnimTimerComplete set ProgressBar to:", self.CurrentGlobalProgress)
  end
  local currentGlobalNum = self.newLastGlobalNum or 0
  Log.Debug("[KingCelebration] OnGlobalAnimTimerComplete dispatch final globalNum:", currentGlobalNum)
  _G.NRCEventCenter:DispatchEvent(ActivityModuleEvent.OnKingCelebrationProgressAnimUpdate, {personalNum = nil, globalNum = currentGlobalNum})
  self.GlobalAnimTimer = nil
end

function UMG_Activity_KingCelebration_C:InitProgressBar()
  Log.Debug("[KingCelebration] InitProgressBar start")
  local lastGlobalNum = self.activityInst:GetLastGlobalNum()
  Log.Debug("[KingCelebration] InitProgressBar lastGlobalNum (cached):", lastGlobalNum)
  
  local function getGlobalCurFunc(taskID)
    return self:GetGlobalCur(taskID)
  end
  
  local globalProgress = self:CalcWeightedProgress(getGlobalCurFunc, 1)
  self.CurrentGlobalProgress = globalProgress
  Log.Debug("[KingCelebration] InitProgressBar globalProgress:", globalProgress)
  if 0 == lastGlobalNum then
    Log.Debug("[KingCelebration] InitProgressBar setting ProgressBar directly to:", globalProgress)
    self.ProgressBar:SetPercent(globalProgress)
  else
    local function getLastGlobalNumFunc(taskID)
      return self.activityInst:GetLastGlobalNum()
    end
    
    local lastGlobalProgress = self:CalcWeightedProgress(getLastGlobalNumFunc, 1)
    self.LastGlobalProgress = lastGlobalProgress
    Log.Debug("[KingCelebration] InitProgressBar lastGlobalProgress:", lastGlobalProgress, "will animate from this to:", globalProgress)
    self.ProgressBar:SetPercent(lastGlobalProgress)
  end
  
  local function getPersonalCurFunc()
    return self:GetPersonalCur()
  end
  
  local personalProgress = self:CalcWeightedProgress(getPersonalCurFunc, 2)
  self.CurrentPersonalProgress = personalProgress
  Log.Debug("[KingCelebration] InitProgressBar personalProgress:", personalProgress)
  local lastSpringFestivalNum = self.activityInst:GetLastSpringFestivalNum()
  Log.Debug("[KingCelebration] InitProgressBar lastSpringFestivalNum (cached):", lastSpringFestivalNum)
  if 0 == lastSpringFestivalNum then
    Log.Debug("[KingCelebration] InitProgressBar setting ProgressBar2 directly to:", personalProgress)
    self.ProgressBar2:SetPercent(personalProgress)
  else
    local function getLastPersonalNumFunc()
      return self.activityInst:GetLastSpringFestivalNum()
    end
    
    local lastPersonalProgress = self:CalcWeightedProgress(getLastPersonalNumFunc, 2)
    self.LastPersonalProgress = lastPersonalProgress
    Log.Debug("[KingCelebration] InitProgressBar lastPersonalProgress:", lastPersonalProgress, "will animate from this to:", personalProgress)
    self.ProgressBar2:SetPercent(lastPersonalProgress)
  end
  Log.Debug("[KingCelebration] InitProgressBar end")
end

function UMG_Activity_KingCelebration_C:OnAnimationFinished(Animation)
  if Animation == self.Add_1 then
    Log.Debug("[KingCelebration] OnAnimationFinished Add_1, LastPersonalProgress:", self.LastPersonalProgress, "CurrentPersonalProgress:", self.CurrentPersonalProgress)
    if self.LastPersonalProgress and self.CurrentPersonalProgress then
      _G.NRCAudioManager:PlaySound2DAuto(40100005, "UMG_Activity_KingCelebration_C:OnPersonalAnimTimerUpdate")
      self.PersonalAnimTimer = _G.TimerManager:CreateTimer(self, "UMG_Activity_KingCelebration_C:PersonalAnimTimer", self.AnimDuration, self.OnPersonalAnimTimerUpdate, self.OnPersonalAnimTimerComplete, self.deltaTime)
    else
      Log.Debug("[KingCelebration] OnAnimationFinished Add_1 skipped animation, LastPersonalProgress or CurrentPersonalProgress is nil")
    end
    if self.Add_2 then
      self:PlayAnimation(self.Add_2)
    end
  elseif Animation == self.Add_2 then
    Log.Debug("[KingCelebration] OnAnimationFinished Add_2")
    if self.icon then
      self.icon:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if self.Text_Time_1 then
      self.Text_Time_1:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if self.Add_3 then
      self:PlayAnimation(self.Add_3)
    end
  elseif Animation == self.Add_3 then
    Log.Debug("[KingCelebration] OnAnimationFinished Add_3, LastGlobalProgress:", self.LastGlobalProgress, "CurrentGlobalProgress:", self.CurrentGlobalProgress)
    if self.LastGlobalProgress and self.CurrentGlobalProgress then
      self.GlobalAnimTimer = _G.TimerManager:CreateTimer(self, "UMG_Activity_KingCelebration_C:GlobalAnimTimer", self.AnimDuration, self.OnGlobalAnimTimerUpdate, self.OnGlobalAnimTimerComplete, self.deltaTime)
    else
      Log.Debug("[KingCelebration] OnAnimationFinished Add_3 skipped animation, LastGlobalProgress or CurrentGlobalProgress is nil")
    end
  else
    if Animation == self.In then
      local currentSprintNum = self:GetPersonalCur()
      local lastSpringFestivalNum = self.activityInst:GetLastSpringFestivalNum()
      Log.Debug("[KingCelebration] OnAnimationFinished In, currentSprintNum:", currentSprintNum, "lastSpringFestivalNum:", lastSpringFestivalNum)
      if lastSpringFestivalNum and lastSpringFestivalNum > 0 then
        local deltaNum = currentSprintNum - lastSpringFestivalNum
        Log.Debug("[KingCelebration] OnAnimationFinished In deltaNum:", deltaNum)
        if deltaNum > 0 then
          self.Text_Time_4:SetText(deltaNum)
          if self.Add_1 then
            Log.Debug("[KingCelebration] OnAnimationFinished In playing Add_1 animation")
            self:PlayAnimation(self.Add_1)
          end
        else
          Log.Debug("[KingCelebration] OnAnimationFinished In deltaNum <= 0, setting Text_Time directly")
          if self.Text_Time then
            local currentPersonalNum = self:GetPersonalCur()
            self.Text_Time:SetText(currentPersonalNum)
          end
        end
      else
        Log.Debug("[KingCelebration] OnAnimationFinished In lastSpringFestivalNum is 0 or nil, setting Text_Time directly")
        if self.Text_Time then
          local currentPersonalNum = self:GetPersonalCur()
          self.Text_Time:SetText(currentPersonalNum)
        end
      end
    else
    end
  end
end

function UMG_Activity_KingCelebration_C:RefreshSubActivityEntrance()
  if self.activityInst then
    local partID = self.activityInst:GetSinglePartId()
    if partID then
      local activitySpringConf = _G.DataConfigManager:GetActivitySpringFestivalConf(partID)
      if activitySpringConf and self.NRCImage_124 then
        self.NRCImage_124:SetPath(activitySpringConf.part_0_img)
      end
    end
    local state = self.activityInst.GetSubActivityState and self.activityInst:GetSubActivityState() or ActivityEnum.SprintSubActivityState.NotStarted
    local taskName = self.activityInst:GetCurTaskName()
    if taskName then
      self.EventNameText:SetText(taskName)
    end
    self.BgMask:SetRenderOpacity(1)
    self.Seal:SetRenderOpacity(1)
    if state == ActivityEnum.SprintSubActivityState.NotStarted then
      self.BgMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Ticket:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Seal:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif state == ActivityEnum.SprintSubActivityState.InProgress then
      self.BgMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Ticket:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Seal:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif state == ActivityEnum.SprintSubActivityState.Ended then
      self.BgMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Ticket:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Seal:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_Activity_KingCelebration_C:OnTaskUpdated()
  self:RefreshSubActivityEntrance()
end

function UMG_Activity_KingCelebration_C:OnClaimHeatReward()
  self.activityInst:ReqGetGlobalAndPersonalFestivalTaskData()
end

function UMG_Activity_KingCelebration_C:OnClickButton()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_KingCelebration_C:OnClickButton")
  if self.activityInst then
    local state = self.activityInst:GetSubActivityState()
    if state == ActivityEnum.SprintSubActivityState.InProgress then
      self.activityInst:OnSubActivityClick()
    end
  end
end

return UMG_Activity_KingCelebration_C
