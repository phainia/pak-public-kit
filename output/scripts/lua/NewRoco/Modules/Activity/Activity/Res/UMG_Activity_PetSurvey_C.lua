local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_PetSurvey_C = _G.NRCPanelBase:Extend("UMG_Activity_PetSurvey_C")

local function SortHandBookInfo(a, b)
  return a.pet_raise_task_id < b.pet_raise_task_id
end

local function _ConvertExtraKey(extraKey)
  if type(extraKey) == "table" then
    local t = {}
    for i, value in ipairs(extraKey) do
      if type(value) == "number" then
        value = tostring(value)
      end
      t[1 + #t] = value
    end
    return t
  elseif type(extraKey) == "number" then
    return tostring(extraKey)
  end
  return extraKey
end

function UMG_Activity_PetSurvey_C:OnConstruct()
  self.Time.NRCSwitcher_0:SetActiveWidgetIndex(0)
end

function UMG_Activity_PetSurvey_C:OnActive(activityInst)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    return
  end
  self.skipAudio = true
  self:SetCommonTitle()
  self:SetInfo(activityInst)
  self:OnAddEventListener()
  self.TabList:SelectItemByIndex(0)
end

local function SortTask(a, b)
  local function GetState(State)
    if State == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
      return 3
    end
    if State < _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
      return 2
    end
    if State > _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
      return 1
    end
  end
  
  local StateA = GetState(a.task_state)
  local StateB = GetState(b.task_state)
  if StateA == StateB then
    return a.Index < b.Index
  end
  return StateA > StateB
end

function UMG_Activity_PetSurvey_C:OnSelectTabIndex(pet_raise_task_id)
  if self.skipAudio then
    self.skipAudio = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(1220002026, "UMG_Activity_PetSurvey_C:OnSelectTabIndex")
  end
  local sub_task_info = {}
  local TaskList = {}
  self.select_pet_raise_task_id = pet_raise_task_id
  for i, v in pairs(self.HandBookInfo) do
    if v.pet_raise_task_id == pet_raise_task_id then
      local rewardsTable = {}
      local RewardId = _G.DataConfigManager:GetTaskConf(v.final_task_info.task_id).Reward
      local rewardsGroup = _G.DataConfigManager:GetRewardConf(RewardId).RewardItem
      if rewardsGroup then
        for _, _reward in ipairs(rewardsGroup) do
          local itemData = {}
          itemData.itemType = _reward.Type
          itemData.itemId = _reward.Id
          itemData.itemNum = _reward.Count
          itemData.bShowNum = true
          itemData.bShowTip = true
          table.insert(rewardsTable, itemData)
        end
      end
      if v.final_task_info.task_state == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
        self.Switcher:SetActiveWidgetIndex(0)
      elseif v.final_task_info.task_state < ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
        self.Switcher:SetActiveWidgetIndex(1)
      elseif v.final_task_info.task_state > ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
        self.Switcher:SetActiveWidgetIndex(2)
      end
      local raiseTaskConf = _G.DataConfigManager:GetActivityPetRaiseTaskConf(pet_raise_task_id)
      if raiseTaskConf and raiseTaskConf.cover_page then
        self.TitleImage:SetPath(raiseTaskConf.cover_page)
      end
      TaskList = raiseTaskConf.task_id
      self.final_task_id = v.final_task_info.task_id
      _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPoint, 250, _ConvertExtraKey({
        self.activityInst:GetActivityId(),
        v.pet_raise_task_id
      }))
      self.AwardList:InitGridView(rewardsTable)
      local targetNum = _G.DataConfigManager:GetTaskConf(v.final_task_info.task_id).task_condition[1].count
      self.Textquantity:SetText(string.format("%d/%d", v.final_task_info.task_target, targetNum))
      sub_task_info = v.sub_task_info
      break
    end
  end
  for j, id in pairs(TaskList) do
    for i, TaskInfo in pairs(sub_task_info) do
      if TaskInfo.task_id == id then
        TaskInfo.Index = j
        TaskInfo.IsActivityExpired = self.IsActivityExpired
        break
      end
    end
  end
  table.sort(sub_task_info, SortTask)
  self.List:InitGridView(sub_task_info)
end

function UMG_Activity_PetSurvey_C:BtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41400001, "UMG_Activity_PetSurvey_C:BtnClick")
  if self.IsActivityExpired then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2235)
    return
  end
  self:ZoneTaskRewardReq({
    self.final_task_id
  })
end

function UMG_Activity_PetSurvey_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Activity_PetSurvey_C:SetInfo(activityInst)
  self.activityInst = activityInst
  self.activityStartTime = self.activityInst:GetActivityStartTime()
  self.IsActivityExpired = self.activityInst:IsActivityExpired(ActivityUtils.GetSvrTimestamp())
  self.Time:InitializeData(self.activityInst:GetActivityTimeLeft(), nil, true)
  self.Time:ShowCountDown()
  self.FlowerSeedInfo = activityInst:GetPlayerLimitedFlowerSeedInfo()
  self.HandBookInfo = self.FlowerSeedInfo.handbook_task_info
  if not self.HandBookInfo then
    Log.Error("UMG_Activity_PetSurvey_C:SetInfo:HandBookInfo is nil")
    return
  end
  local tabInfo = {}
  for i, v in pairs(self.HandBookInfo) do
    local temp = {
      activityId = self.activityInst:GetActivityId(),
      pet_raise_task_id = v.pet_raise_task_id,
      taskId = v.final_task_info.task_id,
      num = v.final_task_info.task_target
    }
    table.insert(tabInfo, temp)
  end
  table.sort(tabInfo, SortHandBookInfo)
  self.TabList:InitGridView(tabInfo)
end

function UMG_Activity_PetSurvey_C:OnRefreshPlayerLimitedFlowerSeedInfo(activityInst)
  self:SetInfo(activityInst)
  local Num = self.List:GetItemCount()
  for i = 1, Num do
    local item = self.List:GetItemByIndex(i - 1)
    for _, v in pairs(self.HandBookInfo) do
      if v.pet_raise_task_id == self.select_pet_raise_task_id then
        local SubTaskList = v.sub_task_info
        for _, Task in pairs(SubTaskList) do
          if Task.task_id == item.uiData.task_id then
            item.uiData = Task
            item:SetInfo()
            break
          end
        end
        break
      end
    end
  end
end

function UMG_Activity_PetSurvey_C:ZoneTaskRewardReq(task_id_list)
  local req = _G.ProtoMessage:newZoneTaskRewardReq()
  req.task_list = task_id_list
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_REWARD_REQ, req, self, self.ZoneTaskRewardRsp, false, true)
end

function UMG_Activity_PetSurvey_C:ZoneTaskRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local CurRewardConf = rsp.ret_info.goods_reward
    for i, v in pairs(self.HandBookInfo) do
      if v.final_task_info.task_id == self.final_task_id then
        v.final_task_info.task_state = ProtoEnum.EMTaskState.EM_TASK_STATE_DONE
        break
      end
    end
    if #CurRewardConf.rewards > 0 then
      _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, CurRewardConf.rewards, "")
    end
    self.Switcher:SetActiveWidgetIndex(3)
  else
    local key = string.format("Error_Code_%d", rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText[key])
  end
end

function UMG_Activity_PetSurvey_C:OnDeactive()
  self:UnRegisterEvent(self, ActivityModuleEvent.SelectLimitedFlowerHandbookTabIndex)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshLimitedFlowerHandbook)
end

function UMG_Activity_PetSurvey_C:ParticularsClick()
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local ContentTitle = _G.DataConfigManager:GetLocalizationConf("TIPS").msg
  local ContentText = LuaText.activity_pet_raise_task_rule_tips
  Context:SetTitle(ContentTitle):SetContent(ContentText):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true):SetCloseOnOK(true):SetClickAnywhereClose(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_Activity_PetSurvey_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_Activity_PetSurvey_C:ClosePanel")
  self:PlayAnimation(self.Close)
end

function UMG_Activity_PetSurvey_C:OnAddEventListener()
  self:AddButtonListener(self.OpenActivityPetHouseBtn.btnLevelUp, self.OpenActivityPetHouse)
  self:AddButtonListener(self.BtnGet.btnLevelUp, self.BtnClick)
  self:AddButtonListener(self.Particulars.btnLevelUp, self.ParticularsClick)
  self:AddButtonListener(self.btnClose.btnClose, self.ClosePanel)
  self:RegisterEvent(self, ActivityModuleEvent.SelectLimitedFlowerHandbookTabIndex, self.OnSelectTabIndex)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshLimitedFlowerHandbook, self.RefreshInfo)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshPlayerLimitedFlowerSeedInfo, self.OnRefreshPlayerLimitedFlowerSeedInfo)
end

function UMG_Activity_PetSurvey_C:RefreshInfo(TaskId)
  local EraseRedList = {}
  for i, v in pairs(self.HandBookInfo) do
    local sub_task_info = v.sub_task_info
    for j, SubTask in pairs(sub_task_info) do
      if SubTask.task_id == TaskId then
        table.insert(EraseRedList, {
          self.activityInst:GetActivityId(),
          v.pet_raise_task_id,
          SubTask.task_id
        })
        self:OnSelectTabIndex(v.pet_raise_task_id)
        break
      end
    end
  end
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPointWithExtraKeyList, 249, EraseRedList)
end

function UMG_Activity_PetSurvey_C:OnAnimationFinished(Anim)
  if Anim == self.Btn_press then
    self:PlayAnimation(self.Btn_up)
  end
  if Anim == self.Close then
    self:DoClose()
  end
end

function UMG_Activity_PetSurvey_C:OpenActivityPetHouse()
  self:PlayAnimation(self.Btn_press)
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  if self:EliminateFreePet(petInfoList) then
    _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenLimitedFlowerParticipation, self.activityInst)
  else
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local Context = DialogContext()
    local ContentText = LuaText.activity_pet_raise_task_pet_tips_01
    Context:SetTitle(LuaText.umg_systemsettingmain_4):SetContent(ContentText):SetMode(DialogContext.Mode.OK_CANCEL):SetCloseOnCancel(true):SetCloseOnOK(true):SetButtonText(LuaText.umg_systemsettingmain_5, LuaText.umg_systemsettingmain_6):SetContentBase(string.format(LuaText.activity_pet_raise_task_pet_tips_03, os.date("%Y\229\185\180%m\230\156\136%d\230\151\165", self.activityInst:GetActivityStartTime()))):SetClickAnywhereClose(true)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialogWithBase, Context)
  end
end

function UMG_Activity_PetSurvey_C:EliminateFreePet(petInfoList)
  local PetData = petInfoList.pet_data
  local unit_type_list = self.activityInst:GetPetRaiseConf().unit_type or {}
  if PetData then
    for i, PetInfo in ipairs(PetData) do
      local IsUnit = false
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetInfo.base_conf_id)
      for j, unit_type in pairs(unit_type_list) do
        local petUnitType = petBaseConf.unit_type
        for k, pet_unit_type in pairs(petUnitType) do
          if unit_type == pet_unit_type then
            IsUnit = true
            break
          end
        end
        if IsUnit then
          break
        end
      end
      local isExchange = PetInfo.pet_status_flags and PetInfo.pet_status_flags & ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
      if not isExchange and (not petBaseConf.ban_free or 1 ~= petBaseConf.ban_free) and IsUnit and PetInfo.add_time >= self.activityStartTime then
        return true
      end
    end
  end
  return false
end

return UMG_Activity_PetSurvey_C
