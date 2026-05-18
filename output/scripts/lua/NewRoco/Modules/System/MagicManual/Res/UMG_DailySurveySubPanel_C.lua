local UMG_DailySurveySubPanel_C = _G.NRCPanelBase:Extend("UMG_DailySurveySubPanel_C")

function UMG_DailySurveySubPanel_C:OnConstruct()
  self:SetChildViews(self.Time)
end

function UMG_DailySurveySubPanel_C:OnDestruct()
end

function UMG_DailySurveySubPanel_C:OnEnable(module, needShow)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  do return end
  self.needShow = needShow
  self.ClueItems = {
    self.Item_1,
    self.Item_2,
    self.Item_3,
    self.Item_4,
    self.Item_5
  }
  self.ClueSpecialNode = {}
  self.PermanentItems = {
    self.Item1,
    self.Item2,
    self.Item3
  }
  self.MaxLevel = 5
  self.CurDailyTaskIsFinish = false
  if not module then
    self.module = _G.NRCModuleManager:GetModule("MagicManualModule")
    Log.Error("\230\178\161\230\156\137module\239\188\140\229\176\157\232\175\149moduleManagerGet", self.module)
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  else
    self.module = module
  end
  self.data = self.module.data
  self.ClueTaskIdList = self:GetClueTaskIdList()
  if self.CurDailyTaskIsFinish then
    self.NRCImage_43:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.UMG_DailySurvey_Item3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.module:LeaveChallengeStopTick()
  self.module:LeaveChallengeBossStopTick()
  self:UpdateDailyView()
  if self.needShow then
    self:PlayAnimation(self.Change)
  end
  self:OnAddEventListener()
end

function UMG_DailySurveySubPanel_C:GetClueTaskIdList()
  local TaskId = self.data:GetCluemTaskList()
  local DailyTaskRewardConf = _G.DataConfigManager:GetAllByName("DAILY_TASK_REWARD_CONF")
  for _, v in pairs(DailyTaskRewardConf) do
    local taskList = v.task_id
    for _, Id in pairs(taskList) do
      if Id == TaskId[1].id then
        return v.task_id
      end
    end
  end
end

function UMG_DailySurveySubPanel_C:OnAnimationFinished(anim)
  if anim == self.Reward_get then
    self.ParticleSystemWidget2_45:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ParticleSystemWidget2_45:SetActivate(false)
    self.NRCSwitcher_62:SetActiveWidgetIndex(1)
    self:OnGetAllClueReward()
  end
end

function UMG_DailySurveySubPanel_C:SetBtnCanClick()
  local num = self.DailyItems:GetItemCount()
  for i = 1, num do
    local item = self.DailyItems:GetItemByIndex(i - 1)
    item:SetBtnCanClick()
  end
end

function UMG_DailySurveySubPanel_C:TitleBgIcon()
  local specialId = _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.GetDailyTaskSpecialRewardId)
  local itemConf
  if specialId and specialId > 0 then
    itemConf = _G.DataConfigManager:GetBagItemConf(specialId)
  end
  if itemConf then
    local petId = itemConf.item_behavior[1].ratio[1]
    if petId then
      local baseId = _G.DataConfigManager:GetPetConf(petId).base_id
      local types = _G.DataConfigManager:GetPetbaseConf(baseId).unit_type
      local conf = _G.DataConfigManager:GetTypeDictionary(types[1])
      if conf then
        self.Egg_Department:SetPath(conf.type_icon)
      end
      if types[1] == Enum.SkillDamType.SDT_COMMON then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Normal.img_Normal'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("347AA1FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("4087AFFF"))
      elseif types[1] == Enum.SkillDamType.SDT_GRASS then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_cao.img_cao'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("52901CFF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("6C9B27FF"))
      elseif types[1] == Enum.SkillDamType.SDT_FIRE then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_fire.img_fire'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("BF4800FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("CD5D02FF"))
      elseif types[1] == Enum.SkillDamType.SDT_WATER then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_water.img_water'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("4476B3FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("4F82C0FF"))
      elseif types[1] == Enum.SkillDamType.SDT_LIGHT then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Light.img_Light'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("128DB8FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("339ABAFF"))
      elseif types[1] == Enum.SkillDamType.SDT_STONE then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Ground.img_Ground'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("865C36FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("92673EFF"))
      elseif types[1] == Enum.SkillDamType.SDT_ICE then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_lce.img_lce'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("1A7DB5FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("228CC8FF"))
      elseif types[1] == Enum.SkillDamType.SDT_DRAGON then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Loong.img_Loong'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("B43535FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C23E3EFF"))
      elseif types[1] == Enum.SkillDamType.SDT_ELECTRIC then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Electric.img_Electric'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("BE7801FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C98A07FF"))
      elseif types[1] == Enum.SkillDamType.SDT_TOXIC then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Poison.img_Poison'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("A438A6FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("AD49B9FF"))
      elseif types[1] == Enum.SkillDamType.SDT_INSECT then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Bug.img_Bug'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("799F01FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("87AF0CFF"))
      elseif types[1] == Enum.SkillDamType.SDT_FIGHT then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Fighting.img_Fighting'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("B64D13FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C95A1DFF"))
      elseif types[1] == Enum.SkillDamType.SDT_WING then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Flying.img_Flying'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("238283FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("17999BFF"))
      elseif types[1] == Enum.SkillDamType.SDT_MOE then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Moe.img_Moe'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C33A5DFF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("CF4367FF"))
      elseif types[1] == Enum.SkillDamType.SDT_GHOST then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Ghost.img_Ghost'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("7631CCFF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("843BDEFF"))
      elseif types[1] == Enum.SkillDamType.SDT_DEMON then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Demon.img_Demon'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("AB367BFF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("B54788FF"))
      elseif types[1] == Enum.SkillDamType.SDT_MECHANIC then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Steel.img_Steel'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("248469FF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("1A9674FF"))
      elseif types[1] == Enum.SkillDamType.SDT_PHANTOM then
        self.NRCImage_20:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Phantom.img_Phantom'")
        self.Department_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("5958CAFF"))
        self.Department_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("6365D1FF"))
      end
    end
  end
end

function UMG_DailySurveySubPanel_C:SetInitPetDailyTicketRootStyle(_IsShow)
  if _IsShow then
    self.CurDailyTaskIsFinish = true
    self.NRCSwitcher_62:SetActiveWidgetIndex(1)
  else
    self.CurDailyTaskIsFinish = false
    self.NRCSwitcher_62:SetActiveWidgetIndex(0)
  end
end

function UMG_DailySurveySubPanel_C:GenerateClueTaskList()
  local clueInfoList = {}
  local clueDoneCount = 0
  local cluemTaskDic = self.data.CluemTaskDic
  for i = 1, #self.ClueTaskIdList do
    local clueInfo = {}
    local taskId = self.ClueTaskIdList[i]
    if cluemTaskDic[taskId] then
      local taskInfo = cluemTaskDic[taskId]
      clueInfo.taskInfo = taskInfo
      clueInfo.conf = _G.DataConfigManager:GetTaskConf(taskId)
      clueInfo.num = i
      table.insert(clueInfoList, clueInfo)
      if taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
        clueDoneCount = clueDoneCount + 1
      end
    end
  end
  return clueInfoList, clueDoneCount
end

function UMG_DailySurveySubPanel_C:ShowClueTaskDetail()
  local special_node = self.ClueTaskIdList[#self.ClueTaskIdList]
  self.canReceiveClueTaskIds = {}
  local list = self:GenerateClueTaskList()
  Log.Dump(list, 6, "UMG_MagicManual_C:ShowClueTaskDetail")
  for i = 1, #list do
    local item = self.ClueItems[i]
    local isSpecial = list[i].conf.id == special_node
    if isSpecial then
      self.NrcRedPoint:SetupKey(164, {
        list[i].conf.id
      })
      self.ClueSpecialNode = list[i] or {}
      local specialId = _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.GetDailyTaskSpecialRewardId)
      local itemConf
      if specialId and specialId > 0 then
        itemConf = _G.DataConfigManager:GetBagItemConf(specialId)
      end
      if itemConf then
      end
      self.NRCText_2:SetText(list[i].num)
      if list[i].taskInfo.state < _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
        self:SetInitPetDailyTicketRootStyle(false)
      else
        self:SetInitPetDailyTicketRootStyle(true)
      end
      if list[i].taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
        self:PlayAnimation(self.D_Waiting_to_receive)
        self.ParticleSystemWidget2_45:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.ParticleSystemWidget2_45:SetActivate(true)
      else
        self.ParticleSystemWidget2_45:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.ParticleSystemWidget2_45:SetActivate(false)
      end
      if list[i].taskInfo.state < _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
        self.NRCImage_43:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Right_di:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.NRCImage_43:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Right_di:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      item:OnActive(list[i])
      item:PlayAnimIn(0.03 * (i - 1))
    end
    local isCanReceive = list[i].taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT
    if isCanReceive then
      table.insert(self.canReceiveClueTaskIds, list[i].taskInfo.id)
    end
  end
  local completeNum = 0
  for i, task in pairs(self.data:GetDailTaskList()) do
    if task.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      local taskConf = _G.DataConfigManager:GetTaskConf(task.id)
      local rewardConf = _G.DataConfigManager:GetRewardConf(taskConf.Reward)
      completeNum = completeNum + (rewardConf and rewardConf.RewardItem[1] and rewardConf.RewardItem[1].Count) or 1
    end
  end
  for i, task in pairs(self.data:GetPermanentTaskList()) do
    if task.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      local taskConf = _G.DataConfigManager:GetTaskConf(task.id)
      local rewardConf = _G.DataConfigManager:GetRewardConf(taskConf.Reward)
      completeNum = completeNum + (rewardConf and rewardConf.RewardItem[1] and rewardConf.RewardItem[1].Count) or 1
    end
  end
  local maxNum = #list
  local curNum = math.clamp(completeNum, 0, maxNum)
  self.TextSchedule:SetText(string.format("%d/%d", curNum, maxNum))
  self.allAchieved = curNum / maxNum >= 1
end

function UMG_DailySurveySubPanel_C:ShowPermanentTaskDetail()
  self.canReceivePermanentTaskIds = {}
  self:ShowDailyTaskDetail()
end

function UMG_DailySurveySubPanel_C:GenerateDailyTaskList()
  local dailyInfoList = {}
  local dailyDoneCount = 0
  local dailyTaskList = self.data:GetDailTaskList()
  for i, taskInfo in pairs(dailyTaskList) do
    local dailyInfo = {}
    dailyInfo.taskInfo = taskInfo
    dailyInfo.conf = _G.DataConfigManager:GetTaskConf(taskInfo.id)
    dailyInfo.num = i
    dailyInfo.allAchieved = self.allAchieved
    dailyInfo.ClueSpecialNodeState = self.ClueSpecialNode.taskInfo.state
    table.insert(dailyInfoList, dailyInfo)
    if taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      dailyDoneCount = dailyDoneCount + 1
    end
  end
  table.sort(dailyInfoList, function(a, b)
    if a.taskInfo.state ~= b.taskInfo.state then
      return self:GetDailyTaskSortIndex(a.taskInfo.state) < self:GetDailyTaskSortIndex(b.taskInfo.state)
    end
    return self:GetDailySortIndex(a.taskInfo.id) < self:GetDailySortIndex(b.taskInfo.id)
  end)
  return dailyInfoList, dailyDoneCount
end

function UMG_DailySurveySubPanel_C:GetDailyTaskSortIndex(state)
  if state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    return 2
  elseif state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    return 0
  else
    return 1
  end
end

function UMG_DailySurveySubPanel_C:GetDailySortIndex(taskId)
  local taskModuleConf = _G.DataConfigManager:GetTaskModuleConf(taskId)
  if nil == taskModuleConf then
    return 999
  end
  local module_id = taskModuleConf.moduel_id
  local numList = _G.DataConfigManager:GetDailyGlobalConfig(5).numList
  local moduleIds = {}
  for i = 1, #numList do
    local num1, num2 = math.modf(i / 2)
    if 0 == num2 and 1 ~= i then
    else
      table.insert(moduleIds, numList[i])
    end
  end
  for i, moduleId in pairs(moduleIds) do
    if moduleId == module_id then
      return i
    end
  end
  return 999
end

function UMG_DailySurveySubPanel_C:ShowDailyTaskDetail()
  local list, num = self:GenerateDailyTaskList()
  for i = 1, #list do
    local taskInfo = list[i]
    local isCanReceive = taskInfo.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT
    if isCanReceive then
      table.insert(self.canReceivePermanentTaskIds, taskInfo.taskInfo.id)
    end
  end
  self.DailyItems:InitList(list)
  for i = 1, #list do
    local item = self.DailyItems:GetItemByIndex(i - 1)
    if 1 == i then
      item:PlayAnimation(item.In)
    else
      self:DelaySeconds(0.03 * (i - 1), function()
        item:PlayAnimation(item.In)
      end)
    end
  end
end

function UMG_DailySurveySubPanel_C:ShowCountDown()
  self.Time:InitializeData(self.data.DailyRemainTime, nil, false, self, self.RequestDailyViewDatas)
  self.Time:ShowCountDown()
end

function UMG_DailySurveySubPanel_C:RequestDailyViewDatas()
  if self.module then
    self.module:ZoneQueryInvestTaskReq()
  end
end

function UMG_DailySurveySubPanel_C:UpdateDailyView()
  self:TitleBgIcon()
  local sectionName = _G.DataConfigManager:GetLocalizationConf("daily_reward_string").msg
  self.allAchieved = false
  self.Section_Name:SetText(sectionName)
  self:ShowClueTaskDetail()
  self:ShowPermanentTaskDetail()
  self:ShowCountDown()
end

function UMG_DailySurveySubPanel_C:OnDisable()
  do return end
  if self.MaxLevel then
    for i = 1, self.MaxLevel - 1 do
      local item = self.ClueItems[i]
      item:CancelTick()
      item:CancelDelay()
      item:StopAllAnimations()
      item:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local num = self.DailyItems:GetItemCount()
  for i = 1, num do
    local item = self.DailyItems:GetItemByIndex(i - 1)
    item:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:PanelCloseClueTaskTips()
  self:OnRemoveEventListener()
end

function UMG_DailySurveySubPanel_C:PanelCloseClueTaskTips()
  self.ParticleSystemWidget2_45:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ParticleSystemWidget2_45:SetActivate(false)
  self.ClueTaskTipsIndex = nil
  self.UMG_DailySurvey_Item3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.UMG_DailySurvey_Item3.List:ClearSelection()
  self.CloseTipsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_DailySurveySubPanel_C:OnGetAllClueReward()
  if #self.canReceiveClueTaskIds > 0 then
    for i = 1, self.MaxLevel - 1 do
      local item = self.ClueItems[i]
      item:GetRewardAnim()
    end
    _G.NRCAudioManager:PlaySound2DAuto(41400001, "UMG_MagicManual_Main_C:OnClickBtnClose")
    _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.GetDailyTaskReward, self.canReceiveClueTaskIds)
  end
end

function UMG_DailySurveySubPanel_C:OnGetAllPermanentReward()
  if #self.canReceivePermanentTaskIds > 0 then
    _G.NRCAudioManager:PlaySound2DAuto(40008022, "UMG_MagicManual_Main_C:OnClickBtnClose")
    _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.GetDailyTaskReward, self.canReceivePermanentTaskIds)
  end
end

function UMG_DailySurveySubPanel_C:ShowClueTaskTips(index, rewards)
  if self.ClueTaskTipsIndex and self.ClueTaskTipsIndex == index then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagicManual_C:GetChapterReward")
  self.ClueTaskTipsIndex = index
  self.UMG_DailySurvey_Item3:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CloseTipsBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.UMG_DailySurvey_Item3:PlayInAnim()
  self.UMG_DailySurvey_Item3:SetReward(rewards)
  if index <= 4 then
    local pos = self.ClueItems[index].Slot:GetPosition()
    local offset = UE4.FVector2D(-189, 376.5)
    self.UMG_DailySurvey_Item3.Slot:SetPosition(UE4.FVector2D(pos.x + offset.x, pos.y + offset.y))
  else
    self.UMG_DailySurvey_Item3.Slot:SetPosition(UE4.FVector2D(-496.0, 312.0))
  end
end

function UMG_DailySurveySubPanel_C:GetEggReward()
  local canTrigger = _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.CanTipsTirgger)
  if false == canTrigger then
    return
  end
  local taskInfo = self.ClueSpecialNode.taskInfo
  if not self.ClueSpecialNode.conf then
    return
  end
  local rewardConf = _G.DataConfigManager:GetRewardConf(self.ClueSpecialNode.conf.Reward)
  if taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    if rewardConf then
      local rewardList = {}
      local eggShow = _G.DataConfigManager:GetDailyGlobalConfig(8).numList
      for i = 1, #rewardConf.RewardItem do
        local item = rewardConf.RewardItem[i]
        table.insert(rewardList, {
          Id = item.Id,
          Count = item.Count,
          Type = item.Type
        })
      end
      table.insert(rewardList, {
        Id = eggShow[1],
        Count = eggShow[2],
        Type = _G.Enum.GoodsType.GT_BAGITEM
      })
      self:ShowClueTaskTips(self.ClueSpecialNode.num, rewardList)
    end
  elseif taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self:PlayAnimation(self.Reward_get)
    _G.NRCAudioManager:PlaySound2DAuto(40006009, "UMG_MagicManual_C:GetChapterReward")
  elseif taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN and rewardConf then
    local rewardList = {}
    local eggShow = _G.DataConfigManager:GetDailyGlobalConfig(8).numList
    for i = 1, #rewardConf.RewardItem do
      local item = rewardConf.RewardItem[i]
      table.insert(rewardList, {
        Id = item.Id,
        Count = item.Count,
        Type = item.Type
      })
    end
    table.insert(rewardList, {
      Id = eggShow[1],
      Count = eggShow[2],
      Type = _G.Enum.GoodsType.GT_BAGITEM
    })
    self:ShowClueTaskTips(self.ClueSpecialNode.num, rewardList)
  end
end

function UMG_DailySurveySubPanel_C:CloseClueTaskTips()
  self.ClueTaskTipsIndex = nil
  self.UMG_DailySurvey_Item3:PlayOutAnim()
  self.CloseTipsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.UMG_DailySurvey_Item3.List:ClearSelection()
end

function UMG_DailySurveySubPanel_C:OnDailyKnowBtn()
  self:OnOpenLongDialog(LuaText.dailyresearch_manual)
end

function UMG_DailySurveySubPanel_C:OnOpenLongDialog(Content)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local title = _G.DataConfigManager:GetLocalizationConf("daily_task_string").msg
  Context:SetTitle(title):SetContent(Content):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true):SetCloseOnOK(true)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_DailySurveySubPanel_C:OnAddEventListener()
  if self.IsAddButtonListener then
    return
  end
  self.IsAddButtonListener = true
  self:AddButtonListener(self.EggBtn, self.GetEggReward)
  self:AddButtonListener(self.CloseTipsBtn, self.CloseClueTaskTips)
  self:AddButtonListener(self.DailyKnowBtn.btnLevelUp, self.OnDailyKnowBtn)
end

function UMG_DailySurveySubPanel_C:OnRemoveEventListener()
  self.IsAddButtonListener = false
  self:RemoveButtonListener(self.EggBtn)
  self:RemoveButtonListener(self.CloseTipsBtn)
  self:RemoveButtonListener(self.DailyKnowBtn.btnLevelUp)
end

return UMG_DailySurveySubPanel_C
