local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_Review_C = _G.NRCPanelBase:Extend("UMG_Activity_Review_C")

function UMG_Activity_Review_C:OnActive(coCreationData)
  self:OnAddEventListener()
  self.moneyLimit = _G.DataConfigManager:GetActivityGlobalConfig("play_co_creation_vitem_max").num
  local vi_num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_INSPIRATION_COLOUR) or 0
  self.vi_num = vi_num
  local moneyData = {
    {
      IsShareButton = false,
      moneyType = _G.Enum.VisualItem.VI_INSPIRATION_COLOUR,
      sum = vi_num,
      IsShowBuyIcon = false
    }
  }
  self.MoneyBtn:InitGridView(moneyData)
  local moneyStr = string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_task").msg, vi_num, self.moneyLimit)
  self.MoneyBtn:GetItemByIndex(0):SetSumText(moneyStr, vi_num == self.moneyLimit)
  if not coCreationData or 0 == #coCreationData then
    self.TabList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ActivityRewards:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCSwitcher_51:SetVisibility(UE4.ESlateVisibility.Collapsed)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Activity_PlayerCoCreation_review_none_tips)
    return
  end
  self.coCreationData = coCreationData
  self.bFirst = true
  local coCreationConf = _G.DataConfigManager:GetActivityPlayerCoCreation(coCreationData[1].base_id)
  self.moneyCost = coCreationConf.expend_vitem_num
  self.moneyAddNum = coCreationConf.reward_vitem_num
  local allCoCreationConf = {}
  for _, v in pairs(coCreationData) do
    table.insert(allCoCreationConf, _G.DataConfigManager:GetActivityPlayerCoCreation(v.base_id))
  end
  local sortData = {}
  local allActivityConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ACTIVITY_CONF):GetAllDatas()
  for _, v in ipairs(allCoCreationConf) do
    local strArray = {}
    for _, activityConf in pairs(allActivityConf) do
      if activityConf.base_id[1] == v.id and activityConf.activity_type == _G.Enum.ActivityType.ATP_PLAYER_CO_CREATION_START then
        local startTime = activityConf.appear_time
        local strArray1 = startTime:split("-")
        local strArray2 = strArray1[#strArray1]:split(" ")
        local strArray3 = strArray2[#strArray2]:split(":")
        for i = 1, #strArray1 - 1 do
          table.insert(strArray, tonumber(strArray1[i]))
        end
        table.insert(strArray, tonumber(strArray2[1]))
        for i = 1, #strArray3 do
          table.insert(strArray, tonumber(strArray3[i]))
        end
        break
      end
    end
    local data = {conf = v, time = strArray}
    table.insert(sortData, data)
  end
  self:SortData(sortData, function(a, b)
    local a_time = a.time
    local b_time = b.time
    for i = 1, #a_time do
      if a_time[i] < b_time[i] then
        return true
      elseif a_time[i] > b_time[i] then
        return false
      end
    end
    return a.conf.activity_number < b.conf.activity_number
  end, 1, #sortData)
  local initData = {}
  for _, v in ipairs(sortData) do
    local data = {
      num = v.conf.activity_number,
      pet_base_id = v.conf.show_petbase_id,
      caller = self,
      handler = self.InitDetailPanel,
      activity_id = coCreationData[v.conf.activity_number].activity_id
    }
    table.insert(initData, data)
  end
  self.TabList:InitGridView(initData)
  self.tabInitData = initData
  local moneyPath, _ = ActivityUtils.GetItemIconAndQuality(_G.Enum.GoodsType.GT_VITEM, _G.Enum.VisualItem.VI_INSPIRATION_COLOUR)
  self.BtnReissued:SetTitleTextAndIcon(moneyPath, tostring(self.moneyCost))
  self.NotUnlocked:SetTitleTextAndIcon(moneyPath, tostring(self.moneyCost))
  self.Icon:SetPath(moneyPath)
  self.NotUnlocked:SetQuantityTextColor("AF3D3EFF")
  self.NotUnlocked:SetBtnText(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_UnlockTips").msg)
  self.NotUnlocked:SetShowLockIcon(false)
  self.TabList:SelectItemByIndex(0)
  for i = 0, self.TabList:GetItemCount() - 1 do
    if not coCreationData[initData[i + 1].num].co_creation_data.bIsStart then
      local cost = _G.DataConfigManager:GetActivityPlayerCoCreation(coCreationData[initData[i + 1].num].base_id).expend_vitem_num
      self.TabList:GetItemByIndex(i):SetRedVisibility(vi_num >= cost)
    end
  end
  self.HintText:SetText(_G.LuaText.Activity_PlayerCoCreation_review_vitem_tips)
  self.TextRecord:SetText(_G.LuaText.Activity_PlayerCoCreation_review_record)
end

function UMG_Activity_Review_C:InitDetailPanel(activityNum)
  if self.bFirst then
    self.bFirst = false
  else
    self:PlayAnimation(self.cut)
  end
  local coCreationData = self.coCreationData[activityNum]
  local coCreationConf = _G.DataConfigManager:GetActivityPlayerCoCreation(coCreationData.base_id)
  self.moneyCost = coCreationConf.expend_vitem_num
  self.moneyAddNum = coCreationConf.reward_vitem_num
  self.Num:SetText(string.format(_G.LuaText.report_ratio, tostring(self.moneyAddNum)))
  self.openNum = activityNum
  local num = activityNum
  local numStr = ""
  for i = 1, 3 do
    local modNum = num % 10
    numStr = tostring(modNum) .. numStr
    num = num // 10
  end
  local show_petbase_id = coCreationConf.show_petbase_id
  local pet_evolution_id = _G.DataConfigManager:GetPetbaseConf(show_petbase_id).pet_evolution_id[1]
  local evolution_chain = _G.DataConfigManager:GetPetEvolutionConf(pet_evolution_id).evolution_chain
  local evolutionStr = ""
  for i = 1, #evolution_chain do
    if 1 ~= i then
      evolutionStr = evolutionStr .. "-"
    end
    evolutionStr = evolutionStr .. evolution_chain[i].pet_name
  end
  self.NRCImage_Pet:SetPath(coCreationConf.review_pet_img2)
  self.NRCImage_Bg:SetPath(coCreationConf.review_pet_img)
  self.TextTitle:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_number_name").msg, numStr, evolutionStr))
  local activityConf = _G.DataConfigManager:GetActivityConf(coCreationData.activity_id)
  local appear_time = activityConf.appear_time:split("-")
  local disappear_time = activityConf.disappear_time:split("-")
  self.TextDate:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_number_time").msg, tonumber(appear_time[1]), tonumber(appear_time[2]), tonumber(string.sub(appear_time[3], 1, 2)), tonumber(disappear_time[1]), tonumber(disappear_time[2]), tonumber(string.sub(disappear_time[3], 1, 2))))
  if coCreationData.co_creation_data.bIsStart then
    self.redPointReward:SetupKey(424, coCreationData.activity_id)
    self.NRCSwitcher_51:SetActiveWidgetIndex(1)
    self.ActivityRewards:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if coCreationData.co_creation_data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
      self.Collected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Collected:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if coCreationData.co_creation_data.first_caught_ranking then
      self:InitDescribe(coCreationData.co_creation_data)
      self.BtnSearchPet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.BtnSearchPet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Text_Describe:SetText(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_NoRecord").msg)
    end
  else
    self.ActivityRewards:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if coCreationData.co_creation_data.first_caught_ranking then
      self:InitDescribe(coCreationData.co_creation_data)
      self.NRCSwitcher_51:SetActiveWidgetIndex(1)
      self.BtnSearchPet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.BtnReissued:SetRedDotExtraKey(425, coCreationData.activity_id)
      if coCreationData.co_creation_data.supply_egg_state == _G.ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
        self.SwitcherBtn:SetActiveWidgetIndex(2)
      elseif self.vi_num >= self.moneyCost then
        self.SwitcherBtn:SetActiveWidgetIndex(0)
      else
        self.SwitcherBtn:SetActiveWidgetIndex(1)
      end
      self.NRCSwitcher_51:SetActiveWidgetIndex(0)
      local rewardConf = _G.DataConfigManager:GetRewardConf(coCreationConf.egg_reward_id)
      self.TextName:SetText(rewardConf.DisplayName)
      if rewardConf.Icon then
        self.HeadIcon:SetPath(rewardConf.Icon)
      else
        local iconPath, _ = ActivityUtils.GetItemIconAndQuality(rewardConf.RewardItem[1].Type, rewardConf.RewardItem[1].Id)
        self.HeadIcon:SetPath(iconPath)
      end
      self.Text_Describe_1:SetText(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_EggDes").msg)
    end
  end
end

function UMG_Activity_Review_C:GetCurBaseActivityId()
  return self.coCreationData[self.openNum].base_id, self.coCreationData[self.openNum].activity_id
end

function UMG_Activity_Review_C:InitDescribe(coCreationData)
  local time = coCreationData.first_caught_timestamp
  local date = os.date("*t", time)
  local camp_ids = coCreationData.caught_camp
  local catchStr = ""
  if camp_ids then
    for i = 1, #camp_ids do
      if i > 1 then
        catchStr = catchStr .. "\227\128\129"
      end
      local camp_name = _G.DataConfigManager:GetCampConf(camp_ids[i]).camp_name
      catchStr = catchStr .. camp_name
    end
  end
  local recordStr = string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_record_des").msg, coCreationData.first_caught_ranking, date.year, date.month, date.day, date.hour, date.min, catchStr)
  self.Text_Describe:SetText(recordStr)
end

function UMG_Activity_Review_C:SortData(data, func, start, stop)
  if stop <= start then
    return
  end
  local baseItem = data[start]
  local left = start
  local right = stop
  local bRight = true
  while left < right do
    if bRight then
      if func(baseItem, data[right]) then
        data[left] = data[right]
        left = left + 1
        bRight = false
      else
        right = right - 1
      end
    elseif func(data[left], baseItem) then
      data[right] = data[left]
      right = right - 1
      bRight = true
    else
      left = left + 1
    end
  end
  data[left] = baseItem
  self:SortData(data, func, start, left - 1)
  self:SortData(data, func, left + 1, stop)
end

function UMG_Activity_Review_C:GetReward()
  if self.bWaitGetReward then
    return
  end
  if self.coCreationData[self.openNum].co_creation_data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT and self.vi_num < self.moneyLimit then
    local req = _G.ProtoMessage:newZoneReceiveActivityCoCreationRewardReq()
    req.activity_id = self.coCreationData[self.openNum].activity_id
    req.is_task_reward = false
    self.bWaitGetReward = true
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_ACTIVITY_CO_CREATION_REWARD_REQ, req, self, self.OnGetReward, false, true)
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, _G.Enum.VisualItem.VI_INSPIRATION_COLOUR, _G.Enum.GoodsType.GT_VITEM, false)
  end
end

function UMG_Activity_Review_C:OnGetReward(rsp)
  self.bWaitGetReward = false
  if rsp.ret_info and 0 == rsp.ret_info.ret_code then
    self.coCreationData[self.openNum].co_creation_data.reward_state = _G.ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE
    self.Collected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.vi_num = self.vi_num + self.moneyAddNum
    for i = 0, self.TabList:GetItemCount() - 1 do
      if not self.coCreationData[self.tabInitData[i + 1].num].co_creation_data.bIsStart then
        local cost = _G.DataConfigManager:GetActivityPlayerCoCreation(self.coCreationData[self.tabInitData[i + 1].num].base_id).expend_vitem_num
        self.TabList:GetItemByIndex(i):SetRedVisibility(cost <= self.vi_num)
      end
    end
    local moneyStr = string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_task").msg, self.vi_num, self.moneyLimit)
    self.MoneyBtn:GetItemByIndex(0):SetSumText(moneyStr, self.vi_num == self.moneyLimit)
    local popupInitData = {
      {
        id = _G.Enum.VisualItem.VI_INSPIRATION_COLOUR,
        type = _G.Enum.GoodsType.GT_VITEM,
        num = self.moneyAddNum
      }
    }
    _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNPCShopItemRewardsPanel, popupInitData)
  end
end

function UMG_Activity_Review_C:OpenRulerPanel()
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  Context:SetTitle(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_VitemTips_Title").msg):SetContent(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_VitemTips_TitleDes").msg):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true):SetCloseOnOK(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_Activity_Review_C:FindPet()
  local track_ids = _G.DataConfigManager:GetActivityPlayerCoCreation(self.coCreationData[self.openNum].base_id).track_petbase_id
  local npc_ids = {}
  for _, base_id in ipairs(track_ids) do
    local pet_track_npc_id = _G.DataConfigManager:GetPetbaseConf(base_id).pet_track_npc_id
    for _, npc_id in ipairs(pet_track_npc_id) do
      table.insert(npc_ids, npc_id)
    end
  end
  _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.SendZoneNpcTraceQueryReq, npc_ids)
end

function UMG_Activity_Review_C:GetPetEgg()
  if self.bWaitGetEgg then
    return
  end
  if self.vi_num >= self.moneyCost and self.coCreationData[self.openNum].co_creation_data.supply_egg_state ~= _G.ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
    local req = _G.ProtoMessage:newZoneSupplyActivityCoCreationRewardReq()
    req.activity_id = self.coCreationData[self.openNum].activity_id
    self.bWaitGetEgg = true
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SUPPLY_ACTIVITY_CO_CREATION_REWARD_REQ, req, self, self.OnGetEgg, false, true)
  end
end

function UMG_Activity_Review_C:OnGetEgg(rsp)
  self.bWaitGetEgg = false
  if rsp.ret_info and 0 == rsp.ret_info.ret_code then
    local reward_id = _G.DataConfigManager:GetActivityPlayerCoCreation(self.coCreationData[self.openNum].base_id).egg_reward_id
    local rewardData = _G.DataConfigManager:GetRewardConf(reward_id).RewardItem
    local popupInitData = {}
    for i = 1, #rewardData do
      local popupData = _G.ProtoMessage:newGoodsItem()
      popupData.id = rewardData[i].Id
      popupData.num = rewardData[i].Count
      popupData.type = rewardData[i].Type
      table.insert(popupInitData, popupData)
    end
    _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNPCShopItemRewardsPanel, popupInitData)
    self.vi_num = self.vi_num - self.moneyCost
    for i = 0, self.TabList:GetItemCount() - 1 do
      if not self.coCreationData[self.tabInitData[i + 1].num].co_creation_data.bIsStart then
        local cost = _G.DataConfigManager:GetActivityPlayerCoCreation(self.coCreationData[self.tabInitData[i + 1].num].base_id).expend_vitem_num
        self.TabList:GetItemByIndex(i):SetRedVisibility(cost <= self.vi_num)
      end
    end
    local moneyStr = string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_task").msg, self.vi_num, self.moneyLimit)
    self.MoneyBtn:GetItemByIndex(0):SetSumText(moneyStr, self.vi_num == self.moneyLimit)
    self.coCreationData[self.openNum].co_creation_data.supply_egg_state = _G.ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE
    self.SwitcherBtn:SetActiveWidgetIndex(2)
  end
end

function UMG_Activity_Review_C:CanChangeTab()
  if self.bWaitGetEgg or self.bWaitGetReward or self.bWaitOpenPlayeSWork then
    return false
  end
  return true
end

function UMG_Activity_Review_C:OpenPlayeSWork()
  if self.bWaitOpenPlayeSWork then
    return
  end
  self.bWaitOpenPlayeSWork = true
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OnCmdOpenPlayeSWork, self.coCreationData[self.openNum].activity_id)
end

function UMG_Activity_Review_C:OpenPlayeSWorkFinish()
  self.bWaitOpenPlayeSWork = false
end

function UMG_Activity_Review_C:ClosePanel()
  if self:CanChangeTab() then
    self:OnClose()
  end
end

function UMG_Activity_Review_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_Activity_Review_C:OnAddEventListener()
  self:AddButtonListener(self.Btn, self.GetReward)
  self:AddButtonListener(self.Particulars.btnLevelUp, self.OpenRulerPanel)
  self:AddButtonListener(self.BtnSearchPet.btnLevelUp, self.FindPet)
  self:AddButtonListener(self.BtnReissued.btnLevelUp, self.GetPetEgg)
  self:AddButtonListener(self.ViewBtn.btnLevelUp, self.OpenPlayeSWork)
  self:AddButtonListener(self.btnClose.btnClose, self.ClosePanel)
end

function UMG_Activity_Review_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.Btn)
  self:RemoveButtonListener(self.Particulars.btnLevelUp)
  self:RemoveButtonListener(self.BtnSearchPet.btnLevelUp)
  self:RemoveButtonListener(self.BtnReissued.btnLevelUp)
  self:RemoveButtonListener(self.ViewBtn.btnLevelUp)
  self:RemoveButtonListener(self.btnClose.btnClose)
end

return UMG_Activity_Review_C
