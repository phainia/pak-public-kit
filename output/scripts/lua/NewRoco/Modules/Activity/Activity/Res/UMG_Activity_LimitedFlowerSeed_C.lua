local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_LimitedFlowerSeed_C = Base:Extend("UMG_Activity_LimitedFlowerSeed_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Activity_LimitedFlowerSeed_C:OnConstruct()
  Base.OnConstruct(self)
  self.Text_Title:SetText(self.activityInst:GetActivityName())
  self.Text_Describe:SetText(self.activityInst:GetActivityPromptText())
  self:OnRefreshLimitedFlowerSeedTaskState(self.activityInst)
  self:OnRefreshPlayerLimitedFlowerSeedInfo(self.activityInst)
  local petRaiseConf = self.activityInst:GetPetRaiseConf()
  if petRaiseConf and not string.IsNilOrEmpty(petRaiseConf.umg_texture_path) then
    self.Image_Bg:SetPath(petRaiseConf.umg_texture_path)
  end
  self.Attr:InitGridView(ActivityUtils.CreatePetCommonAttrListData(petRaiseConf and petRaiseConf.unit_type))
  do
    local rewardsTable = {}
    local rewardsGroup = petRaiseConf and petRaiseConf.preview_reward_group
    if rewardsGroup then
      for _, _reward in ipairs(rewardsGroup) do
        local itemData = {}
        itemData.itemType = _reward.preview_reward_type
        itemData.itemId = _reward.preview_reward_param
        itemData.itemNum = _reward.preview_reward_count
        itemData.bShowNum = true
        itemData.bShowTip = true
        table.insert(rewardsTable, itemData)
      end
    end
    ActivityUtils.AdjustCtrlAutoSize(self.AwardList, #rewardsTable <= 4)
    ActivityUtils.AdjustCtrlSize(self.BG, {
      175,
      326,
      477,
      627,
      702
    }, #rewardsTable)
    self.AwardList:InitList(rewardsTable)
  end
  local activityId = self.activityInst:GetActivityId()
  self.redPointNew:SetupKey(253, {activityId})
  self.Btn_Claimable:SetRedDotExtraKey(248, {activityId})
  self.RedDot:SetupKey(251, {activityId})
  self.NotUnlocked:SetTitleTextColor("#c7494aFF")
  self:AddButtonListener(self.SelectionWizard, self.OnClickSelectInvestigatePet)
  self:AddButtonListener(self.BtnSurvey, self.OnClickOpenInvestigateHandbook)
  self:AddButtonListener(self.Btn_Claimable.btnLevelUp, self.OnClickTaskGuid)
  self:AddButtonListener(self.Btn_Claimable_1.btnLevelUp, self.OnClickGoToInvestigate)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshLimitedFlowerSeedTaskState, self.OnRefreshLimitedFlowerSeedTaskState)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshPlayerLimitedFlowerSeedInfo, self.OnRefreshPlayerLimitedFlowerSeedInfo)
end

function UMG_Activity_LimitedFlowerSeed_C:OnDestruct()
  Base.OnDestruct(self)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshLimitedFlowerSeedTaskState)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshPlayerLimitedFlowerSeedInfo)
end

function UMG_Activity_LimitedFlowerSeed_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_LimitedFlowerSeed_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  self.activityInst:SendZoneTaskQueryReq(self.activityInst:GetTaskList())
end

function UMG_Activity_LimitedFlowerSeed_C:OnClickSelectInvestigatePet()
  _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_Activity_LimitedFlowerSeed_C:OnClickSelectInvestigatePet")
  if not self.activityInst or not self.activityInst:IsInProgress() then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenLimitedFlowerSelectPet, self.activityInst)
end

function UMG_Activity_LimitedFlowerSeed_C:OnClickOpenInvestigateHandbook()
  _G.NRCAudioManager:PlaySound2DAuto(40004006, "UMG_Activity_LimitedFlowerSeed_C:OnClickSelectInvestigatePet")
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenLimitedFlowerHandbook, self.activityInst)
end

function UMG_Activity_LimitedFlowerSeed_C:OnClickGoToInvestigate()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_LimitedFlowerSeed_C:OnClickTaskGuid")
  local TaskState, TaskId = self.activityInst:GetInvestTaskInfo()
  if TaskId then
    _G.NRCPanelManager:CloseAllPanelByLayer(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
    _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnClickTaskTrackToWorldFast)
    _G.NRCModeManager:DoCmd(_G.TaskModuleCmd.OnSetTraceTaskInfo, TaskId, true)
  else
    Log.Debug("UMG_Activity_LimitedFlowerSeed_C:OnClickGoToInvestigate() -- not found TaskId")
  end
end

function UMG_Activity_LimitedFlowerSeed_C:OnClickTaskGuid()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_LimitedFlowerSeed_C:OnClickTaskGuid")
  local preTaskId = self.activityInst:GetPreTaskId()
  if preTaskId then
    _G.NRCPanelManager:CloseAllPanelByLayer(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
    _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnClickTaskTrackToWorldFast)
    _G.NRCModeManager:DoCmd(_G.TaskModuleCmd.OnSetTraceTaskInfo, preTaskId, true)
  else
    Log.Debug("UMG_Activity_LimitedFlowerSeed_C:OnClickTaskGuid() -- not found preTaskId")
  end
end

function UMG_Activity_LimitedFlowerSeed_C:OnRefreshLimitedFlowerSeedTaskState(_activityInst)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  local inProgress = _activityInst:IsInProgress()
  if inProgress then
    if _activityInst:GetInvestTaskInfo() ~= ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      self.SelectionWizard:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.SelectionWizard:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  else
    self.SelectionWizard:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.BtnSurvey:SetVisibility(inProgress and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if not _activityInst:HasAcceptedTask() then
    self.BtnSwitcher:SetActiveWidgetIndex(1)
    self.NotUnlocked:SetShowLockIcon(false)
    self.NotUnlocked:SetBtnText(_G.LuaText.Role_Award_Look_Last_Tips)
    self.NotUnlocked:SetTitleTextAndIcon(nil, nil, nil, nil, _activityInst:GetActivityBanText())
  elseif inProgress then
    local specFlowerSeedData = _activityInst:GetPlayerSelectSpecFlowerSeedData()
    local investTaskStatus = _activityInst:GetInvestTaskInfo()
    if specFlowerSeedData and investTaskStatus ~= ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.BtnSwitcher:SetActiveWidgetIndex(2)
      self.Btn_Claimable_1:SetBtnText(_G.LuaText.activity_button_tips_flower_task)
    else
      self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif _activityInst:GetSvrStatus() == ActivityEnum.ActivitySvrStatus.Available then
    self.BtnSwitcher:SetActiveWidgetIndex(0)
    self.Btn_Claimable:SetBtnText(_G.LuaText.activity_button_tips_previous_task)
  else
    self.BtnSwitcher:SetActiveWidgetIndex(1)
    self.NotUnlocked:SetTitleTextAndIcon()
    self.NotUnlocked:SetBtnText(_G.LuaText.Role_Award_Look_Last_Tips)
  end
end

function UMG_Activity_LimitedFlowerSeed_C:OnRefreshPlayerLimitedFlowerSeedInfo(_activityInst)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  local playerFlowerSeedInfo = _activityInst:GetPlayerLimitedFlowerSeedInfo()
  do
    local specFlowerSeedData = _activityInst:GetPlayerSelectSpecFlowerSeedData()
    if specFlowerSeedData then
      self.Switcher:SetActiveWidgetIndex(1)
      local iconMaterialFlag, iconPath = self.HeadIcon:SetIconPathAndMaterial(specFlowerSeedData.petBaseId)
      local investTaskStatus = _activityInst:GetInvestTaskInfo()
      if investTaskStatus ~= ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
        self.completed:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Text_2:SetText(_G.LuaText.activity_pet_raise_entry_button_ongoing)
      else
        self.SelectionWizard:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
        self.completed:SwitchToSetBrushFromMaterialInstanceMode(not not iconMaterialFlag)
        self.completed:SetPath(iconPath)
        self.completed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Text_2:SetText(_G.LuaText.activity_pet_raise_entry_button_completed)
        self.Text_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("ffc65fff"))
      end
      local bloodIcon = ""
      local petRaiseConf = _activityInst:GetPetRaiseConf()
      if petRaiseConf and playerFlowerSeedInfo then
        local seedId = playerFlowerSeedInfo.spec_flower_seed_id
        for _, _pet in ipairs(petRaiseConf.pet_group) do
          if _pet.activity_spec_flower_seed_conf_id == seedId then
            local bloodConf = _G.DataConfigManager:GetPetBloodConf(_pet.pet_blood_conf_id)
            bloodIcon = bloodConf and bloodConf.icon_activity_limited_flower_seed
            break
          end
        end
      end
      self.flower:SetPath(bloodIcon)
      self.Star:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Switcher:SetActiveWidgetIndex(0)
    end
  end
  do
    local finishCnt = 0
    local totalCnt = 0
    local handBookTasks = playerFlowerSeedInfo and playerFlowerSeedInfo.handbook_task_info
    if handBookTasks then
      for _, _handBookTask in ipairs(handBookTasks) do
        local _subTasks = _handBookTask.sub_task_info
        for _, _subTask in ipairs(_subTasks) do
          totalCnt = totalCnt + 1
          if _subTask.task_state == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT or _subTask.task_state == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
            finishCnt = finishCnt + 1
          end
        end
      end
    end
    self.Text_quantity:SetText(string.format("%d/%d", finishCnt, totalCnt))
  end
end

return UMG_Activity_LimitedFlowerSeed_C
