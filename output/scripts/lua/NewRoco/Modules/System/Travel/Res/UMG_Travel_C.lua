local BigMapModuleEvent = require("NewRoco.Modules.System.BigMap.BigMapModuleEvent")
local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")
local UMG_Travel_C = _G.NRCPanelBase:Extend("UMG_Travel_C")

function UMG_Travel_C:OnActive(arg, downTime, isMax)
  self:OpenPanel(arg, downTime, isMax)
end

function UMG_Travel_C:OnConstruct()
  self:SetChildViews(self.UMG_Travel_PetList)
  self.StrongPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ChangePetConfirm_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PetListCloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetUpBtnInfo()
  self:OnAddEventListener()
end

function UMG_Travel_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  _G.NRCEventCenter:UnRegisterEvent(self, TravelModuleEvent.OnSelectTimeTab, self.ChangeTimeTabSelectState)
  _G.NRCEventCenter:UnRegisterEvent(self, TravelModuleEvent.OnOpenTravelPetListPanel, self.OnOpenTravelPetListPanel)
  _G.NRCEventCenter:UnRegisterEvent(self, TravelModuleEvent.OnUpdateTravelInfos, self.OnUpdateTravelPanel)
  _G.NRCEventCenter:UnRegisterEvent(self, TravelModuleEvent.OnCloseTravelPetListPanel, self.OnCloseTravelPetListPanel)
  _G.NRCEventCenter:UnRegisterEvent(self, TravelModuleEvent.OnUpdateSelectTravelPet, self.OnUpdateSelectTravelPet)
  _G.NRCEventCenter:UnRegisterEvent(self, TravelModuleEvent.OnUpdateTravelCountdown, self.OnTravelCountdown)
  _G.NRCModuleManager:GetModule("TravelModule"):UnRegisterEvent(self, TravelModuleEvent.OnOpenPetSkillPanel, self.OnOpenPetSkillPanel)
end

function UMG_Travel_C:OnDeactive()
end

function UMG_Travel_C:OnAddEventListener()
  self.CloseBtn:SetStyle(2)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtn)
  self:AddButtonListener(self.StrongPoint.btnLevelUp, self.OnStrongPointBtn)
  self:AddButtonListener(self.Btn_Close_1, self.OnCloseStrongPointBtn)
  self:AddButtonListener(self.Depart.btnLevelUp, self.OnDepartBtn)
  self:AddButtonListener(self.Recall.btnLevelUp, self.OnRecallBtn)
  self:AddButtonListener(self.Get.btnLevelUp, self.OnRewardBtn)
  self:AddButtonListener(self.Btn_Close, self.OnCloseBtn)
  self:AddButtonListener(self.PetListCloseBtn, self.OnClosePetListPanel)
  _G.NRCEventCenter:RegisterEvent("TravelModule", self, TravelModuleEvent.OnSelectTimeTab, self.ChangeTimeTabSelectState)
  _G.NRCEventCenter:RegisterEvent("TravelModule", self, TravelModuleEvent.OnUpdateTravelInfos, self.OnUpdateTravelPanel)
  _G.NRCEventCenter:RegisterEvent("TravelModule", self, TravelModuleEvent.OnOpenTravelPetListPanel, self.OnOpenTravelPetListPanel)
  _G.NRCEventCenter:RegisterEvent("TravelModule", self, TravelModuleEvent.OnCloseTravelPetListPanel, self.OnCloseTravelPetListPanel)
  _G.NRCEventCenter:RegisterEvent("TravelModule", self, TravelModuleEvent.OnUpdateSelectTravelPet, self.OnUpdateSelectTravelPet)
  _G.NRCEventCenter:RegisterEvent("TravelModule", self, TravelModuleEvent.OnUpdateTravelCountdown, self.OnTravelCountdown)
  _G.NRCModuleManager:GetModule("TravelModule"):RegisterEvent(self, TravelModuleEvent.OnOpenPetSkillPanel, self.OnOpenPetSkillPanel)
end

function UMG_Travel_C:OnOpenPetSkillPanel(petData, isMark)
  if petData then
    if false == isMark then
      self.isOpen = true
      self.ChangePetConfirm_1.showStrongPoint = true
      self.ChangePetConfirm_1:SetPetInfo({PetData = petData})
      self.ChangePetConfirm_1:ShowInPetWarehouse()
      self.ChangePetConfirm_1:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      if self.isOpen then
        self.ChangePetConfirm_1:Hide(true, false)
      end
      self.isOpen = false
    end
  end
end

function UMG_Travel_C:OnUpdateTravelPanel(travelInfos)
  if self.travelInfo and travelInfos then
    for i = 1, #travelInfos do
      local travelInfo = travelInfos[i]
      if travelInfo.camp_content_id == self.travelInfo.camp_content_id then
        self.travelInfo = travelInfo
        local conf = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetCampLevelConf, travelInfo.camp_content_id, travelInfo.camp_lv)
        self:CreateItemList(conf)
        self:ShowPetStageState()
        break
      end
    end
  end
end

function UMG_Travel_C:OpenPanel(arg, downTime, isMax)
  _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.HideMainMapLoupe)
  self.IsNeedUnlockSelect = true
  self.TravelPetDatas = nil
  self.downTime = nil
  self.npcInfo = arg
  self.isOpenPetListPanel = false
  self.isSelect = false
  self.isMax = isMax
  self.travelInfo = nil
  if self.npcInfo then
    self.travelInfo = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetTravelInfo, self.npcInfo.npc_refresh_id)
  end
  self:ShowCampingIcon(self.npcInfo)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.Page_In)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1078, "UMG_Travel_C:OpenPanel")
  self.UMG_Travel_PetList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BlackHood:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.downTime = downTime
  local worldMapConf = _G.DataConfigManager:GetWorldMapConf(self.npcInfo.world_map_cfg_id)
  local CampingInfo = _G.DataConfigManager:GetCampConf(self.npcInfo.npc_refresh_id)
  local place = ""
  if CampingInfo then
    local AreaInfo = _G.DataConfigManager:GetAreaFuncConf(CampingInfo.area_id)
    if AreaInfo then
      place = AreaInfo.name
    end
  end
  if worldMapConf then
    local name = worldMapConf.element_text_name
    local desc = worldMapConf.worldmap_npc_des
    self.npcName:SetText(name)
    self.describe:SetText(desc)
  end
  self.Place_Names:SetText(place)
  local curCampLevelUpConfs = self:GetCampLevelUpConfs(self.npcInfo)
  self:CreateTimeTableList(curCampLevelUpConfs, nil, arg.status ~= _G.ProtoEnum.LockStatus.ENUM.UNLOCKED)
  if arg.status == _G.ProtoEnum.LockStatus.ENUM.UNLOCKED then
    if nil == self.travelInfo and isMax then
      self:ShowMaxTravelState()
      return
    end
    self:ShowPetStageState()
  else
    if isMax then
      self:ShowMaxTravelState()
      return
    end
    self:ShowLockedState()
  end
  self.campId = self.npcInfo.npc_refresh_id
end

function UMG_Travel_C:ShowCampingIcon(npcInfo)
  local path = ""
  if npcInfo.status ~= _G.ProtoEnum.LockStatus.ENUM.UNLOCKED then
    path = "PaperSprite'/Game/NewRoco/Modules/System/BigMap/Raw/Atlas/WorldMapNpc/Frames/img_weijiesuo_png.img_weijiesuo_png'"
  else
    path = "PaperSprite'/Game/NewRoco/Modules/System/BigMap/Raw/Atlas/WorldMapNpc/Frames/img_yijiesuo_png.img_yijiesuo_png'"
  end
  self.NRCImage_0:SetPath(path)
end

function UMG_Travel_C:GetCampLevelUpConf(npcInfo)
  local data = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetCampLevelConf, npcInfo.npc_refresh_id, npcInfo.npc_level)
  return data
end

function UMG_Travel_C:GetCampLevelUpConfs(npcInfo)
  local datas = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetCampLevelConfs, npcInfo.npc_refresh_id)
  return datas
end

function UMG_Travel_C:FormatTime(seconds)
  local hours = math.floor(seconds / 3600)
  return string.format(LuaText.umg_travel_1, hours)
end

function UMG_Travel_C:GetAdvantageNumber(types)
  local advantage = 0
  if self.advantage_type and self.disadvantage_type then
    for i = 1, #types do
      local petType = types[i]
      for j = 1, #self.advantage_type do
        local goodType = self.advantage_type[j]
        if petType == goodType then
          advantage = advantage + 1
        end
      end
      for k = 1, #self.disadvantage_type do
        local badType = self.disadvantage_type[k]
        if petType == badType then
          advantage = advantage - 1
        end
      end
    end
  end
  return advantage
end

function UMG_Travel_C:CreateTimeTableList(campLevelUpConfs, level, isLockAll)
  local timeDatas = {}
  if campLevelUpConfs then
    for i = 1, #campLevelUpConfs do
      local timeData = {}
      timeData.timeStr = self:FormatTime(campLevelUpConfs[i].travel_time)
      timeData.seconds = campLevelUpConfs[i].travel_time
      timeData.level = campLevelUpConfs[i].level or 1
      timeData.isLock = false
      if isLockAll then
        timeData.isLock = true
      end
      timeData.conf = campLevelUpConfs[i]
      table.insert(timeDatas, timeData)
    end
    table.sort(timeDatas, function(a, b)
      return a.level < b.level
    end)
    self.List_2:InitGridView(timeDatas)
    self:SelectTimeTabMaxIndex(3)
  end
end

function UMG_Travel_C:ChangeTimeTabSelectState(selectIndex, selectData)
  self.campLv = selectIndex
  local curLevel = self.npcInfo.npc_level
  for i = 1, 3 do
    local item = self.List_2:GetItemByIndex(i - 1)
    if item then
      if i == self.campLv then
        item:PlaySelect()
      else
        item:PlayUnSelect()
      end
    end
  end
  local conf = selectData.conf
  self:CreateItemList(conf)
  if self.travelInfo == nil and self.isMax then
    self:ShowMaxTravelState()
    return
  end
  if self.npcInfo.status == _G.ProtoEnum.LockStatus.ENUM.UNLOCKED then
    self.SelectPet:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:ShowLockedState()
  end
end

function UMG_Travel_C:OnOpenTravelPetListPanel(gid)
  if self.isOpenPetListPanel then
  else
    if self.travelInfo then
      local petDataDic = self:GetAllPetDataDic()
      local petData = petDataDic[gid]
      self:OnOpenPetSkillPanel(petData, false)
      return
    end
    self.isOpenPetListPanel = true
    self:PlayAnimation(self.Change_In)
    self.UMG_Travel_PetList:OnActive()
    local firstItem = self.List_3:GetItemByIndex(0)
    local firstItemSelect = firstItem.data.isSelect
    if false == firstItemSelect then
      firstItem.Select:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.isSelect = true
  end
end

function UMG_Travel_C:OnCloseTravelPetListPanel()
  self.isOpenPetListPanel = false
  self:PlayAnimation(self.Change_Out)
  self.PetListCloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Travel_C:OnUpdateSelectTravelPet()
  local dic = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetSelectTravelPet)
  local travelList = {}
  local selectCount = 0
  for key, value in pairs(dic) do
    local travel = {}
    travel.key = key
    travel.gid = value.gid
    travel.baseId = value.baseId
    travel.advantage = value.advantage
    travel.isSelect = self.isSelect
    if -1 ~= travel.gid then
      selectCount = selectCount + 1
    end
    table.insert(travelList, travel)
  end
  if 2 == selectCount then
    self.NRCSwitcher_102:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_102:SetActiveWidgetIndex(0)
  end
  if self.isSelect and 0 == selectCount then
    travelList[1].isSelect = true
    travelList[2].isSelect = false
  end
  self:ChangeSelectPetList(travelList, self.travelInfo ~= nil)
end

function UMG_Travel_C:SelectTimeTabMaxIndex(selectIndex)
  for i = 1, 3 do
    local item = self.List_2:GetItemByIndex(i - 1)
    if item and selectIndex == i then
      item:OnClickeBtn()
    end
  end
end

function UMG_Travel_C:CreateItemList(campLevelUpConf)
  if campLevelUpConf then
    self.campLevelUpConf = campLevelUpConf
    local datas = self:AddEggRewardItem(campLevelUpConf.reward_item)
    self.List_1:InitGridView(datas)
  end
end

function UMG_Travel_C:AddEggRewardItem(rewards)
  local datas = {}
  local eggData = {}
  local petDataDic = self:GetAllPetDataDic()
  
  local function GetRealNum(_num)
    local num
    if self.TalentEffectReward and #self.TalentEffectReward > 0 then
      for _, EffectPercent in ipairs(self.TalentEffectReward) do
        if EffectPercent then
          if num then
            num = num + math.ceil(EffectPercent * _num)
          else
            num = _num + math.ceil(EffectPercent * _num)
          end
        end
      end
    end
    return num or _num
  end
  
  for i, reward in pairs(rewards) do
    local itemIconData = {}
    itemIconData.itemType = reward.reward_item_type
    itemIconData.itemId = reward.reward_item_id
    itemIconData.itemNum = GetRealNum(reward.reward_item_num)
    itemIconData.bShowNum = true
    itemIconData.bShowTip = true
    itemIconData.isAddNum = itemIconData.itemNum > reward.reward_item_num
    itemIconData.isSubNum = itemIconData.itemNum < reward.reward_item_num
    table.insert(datas, itemIconData)
  end
  if self.travelInfo and self.travelInfo.will_lay_egg then
    self.NRCSwitcher_57:SetActiveWidgetIndex(self.travelInfo.will_lay_egg and 1 or 0)
    local eggId = 0
    for i, gid in pairs(self.travelInfo.pet_gid) do
      if petDataDic[gid] then
        local petData = petDataDic[gid]
        if 2 == petData.gender then
          local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
          if petbaseConf then
            eggId = petbaseConf.pet_egg
          end
        end
      end
    end
    if 0 ~= eggId then
      eggData.itemType = _G.Enum.GoodsType.GT_BAGITEM
      eggData.itemId = eggId
      eggData.itemNum = 1
      eggData.bShowAdditional = true
      eggData.isEgg = true
      eggData.bShowNum = true
      eggData.isOther = true
      table.insert(datas, eggData)
    end
  end
  return datas
end

function UMG_Travel_C:SetUpBtnInfo()
  self.Depart:SetClickAble(true)
  self.Recall:SetClickAble(true)
  self.Get:SetClickAble(true)
  self.SelectionPrompt:SetClickAble(false)
  self.SelectionPrompt.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local text = string.format("\233\156\128\232\166\129\233\128\137\230\139\169%s\229\143\170\231\178\190\231\129\181", 2)
  self.SelectionPrompt:SetTitleTextAndIcon(nil, nil, nil, nil, text)
  self.SelectionPrompt.Tips:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
  self.SelectionPrompt:SetBtnText("\230\151\133\232\161\140")
  self.UnlockCondition_1:SetClickAble(false)
  self.UnlockCondition_1:SetTitleTextAndIcon(nil, nil, nil, nil, "\233\156\128\232\166\129\230\191\128\230\180\187\233\173\148\229\138\155\228\185\139\230\186\144")
  self.UnlockCondition_1.Tips:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("c7494a"))
  self.Hint_1:SetClickAble(false)
  self.Hint_1.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Hint_1:SetTitleTextAndIcon(nil, nil, nil, nil, "\230\151\133\232\161\140\230\172\161\230\149\176\229\183\178\232\190\190\228\184\138\233\153\144")
  self.Hint_1.Tips:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("c7494a"))
end

function UMG_Travel_C:ChangeSelectPetList(petList, isTraveling)
  if not isTraveling then
    self.petInfoList = petList
  else
    self.petInfoList = self.travelInfo.pet_briefs and self.travelInfo.pet_briefs or {}
  end
  self.List_3:InitGridView(petList)
  self.TalentEffectReward = {}
  local TalentEffectIdDic = {}
  local talentList = {}
  for i, v in ipairs(self.petInfoList) do
    if v and v.gid and v.gid > 0 then
      local petData
      if not isTraveling then
        petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(v.gid)
      else
        petData = v
      end
      local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(petData.speciality_id)
      if PetTalentConf then
        if PetTalentConf.effect_group and #PetTalentConf.effect_group then
          for _, effect in ipairs(PetTalentConf.effect_group) do
            if effect.effect == Enum.PetTalentEffect.PTE_TRAVEL_REWARD then
              if #TalentEffectIdDic > 0 and TalentEffectIdDic[PetTalentConf.id] then
                if TalentEffectIdDic[PetTalentConf.id] >= PetTalentConf.can_add then
                  goto lbl_108
                else
                  TalentEffectIdDic[PetTalentConf.id] = TalentEffectIdDic[PetTalentConf.id] + 1
                end
              else
                TalentEffectIdDic[PetTalentConf.id] = 1
              end
              table.insert(self.TalentEffectReward, effect.effect_param / 10000)
            end
          end
        end
        ::lbl_108::
        if 2 == PetTalentConf.type then
          table.insert(talentList, PetTalentConf)
        end
      end
    end
  end
  if self.campLevelUpConf then
    self:CreateItemList(self.campLevelUpConf)
  end
  if #talentList > 0 then
    self.StrongPoint:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.StrongPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.DetailsOfSpecialties:SetPanelInfo(talentList)
end

function UMG_Travel_C:ShowUnlockedState()
  self.NRCSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SelectPet:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CanvasPanel_73:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Switcher:SetActiveWidgetIndex(1)
  self.NRCSwitcher_71:SetActiveWidgetIndex(0)
end

function UMG_Travel_C:ShowGoodAndBadList(goodDatas, badDatas)
  self.GoodAndBad:OnActive(goodDatas, badDatas)
  self.UMG_Travel_PetList:SetGoodAndBadTypeList(goodDatas, badDatas)
end

function UMG_Travel_C:ShowLockedState()
  self.NRCSwitcher:SetVisibility(UE4.ESlateVisibility.Visible)
  self.SelectPet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_73:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Switcher:SetActiveWidgetIndex(1)
  self.NRCSwitcher_71:SetActiveWidgetIndex(0)
  self.NRCSwitcher:SetActiveWidgetIndex(0)
end

function UMG_Travel_C:ShowMaxTravelState()
  self.NRCSwitcher:SetVisibility(UE4.ESlateVisibility.Visible)
  self.SelectPet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_73:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Switcher:SetActiveWidgetIndex(1)
  self.NRCSwitcher_71:SetActiveWidgetIndex(0)
  self.NRCSwitcher:SetActiveWidgetIndex(1)
end

function UMG_Travel_C:ShowPetStageState()
  self:ShowUnlockedState()
  if self.travelInfo then
    if self.travelInfo.travel_complete then
      self:ChangeReceiveState()
    else
      self.NRCSwitcher_102:SetActiveWidgetIndex(2)
    end
    self:ShowTravelPetIcon(self.travelInfo)
    self:SelectTimeTabMaxIndex(self.travelInfo.camp_lv)
    if self.downTime and self.downTime > 0 then
      self.NRCSwitcher_71:SetActiveWidgetIndex(1)
      local strEnd = self:FormatDownTime(self.downTime)
      self.TimeRemaining:SetText(strEnd)
    end
  else
    self.NRCSwitcher_102:SetActiveWidgetIndex(0)
    _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.ClearSelectTravelPet)
    self:OnUpdateSelectTravelPet()
  end
end

function UMG_Travel_C:ChangeReceiveState()
  self.NRCSwitcher_102:SetActiveWidgetIndex(3)
  self.NRCSwitcher_71:SetActiveWidgetIndex(2)
  if not self:IsAnimationPlaying(self.End_Seal) then
    self:PlayAnimation(self.End_Seal)
  end
end

function UMG_Travel_C:OnTravelCountdown(contentId, time)
  if self.travelInfo and self.travelInfo.camp_content_id == contentId then
    self.downTime = time
    local str = self:FormatDownTime(time)
    self.TimeRemaining:SetText(str)
    if self.downTime <= 0 then
      self:ChangeReceiveState()
    end
  end
end

function UMG_Travel_C:FormatDownTime(seconds)
  local hours = math.floor(seconds / 3600)
  seconds = seconds % 3600
  local minutes = math.floor(seconds / 60)
  seconds = seconds % 60
  return string.format(LuaText.umg_travel_4, hours, minutes, seconds)
end

function UMG_Travel_C:GetDownTime(travelInfo)
  local CampLevelInfo = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetCampLevelConf, travelInfo.camp_content_id, travelInfo.camp_lv)
  local svr_time = _G.ZoneServer:GetServerTime()
  local finishTime = travelInfo.start_travel_sec + CampLevelInfo.travel_time
  local downTime = finishTime - svr_time
  return downTime
end

function UMG_Travel_C:ShowTravelPetIcon(travelInfo)
  local gids = travelInfo.pet_gid
  local petDataDic = self:GetAllPetDataDic()
  local datas = {}
  for i = 1, #gids do
    local gid = gids[i]
    if petDataDic[gid] then
      local petData = petDataDic[gid]
      if petData.gid == gid then
        local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
        local types = petbaseConf.unit_type
        local info = {}
        info.gid = petData.gid
        info.baseId = petData.base_conf_id
        info.advantage = self:GetAdvantageNumber(types)
        if petData.level then
          info.level = petData.level
        end
        table.insert(datas, info)
      end
    end
  end
  self.TravelPetDatas = datas
  self:ChangeSelectPetList(datas, self.travelInfo ~= nil)
end

function UMG_Travel_C:GetAllPetDataDic()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  local bagPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  local petList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().pet_data
  local petDataDic = {}
  if battlePetList then
    for i, petData in pairs(battlePetList) do
      petDataDic[petData.gid] = petData
    end
  end
  if bagPetList then
    for i, petData in pairs(bagPetList) do
      petDataDic[petData.gid] = petData
    end
  end
  if petList then
    for i, petData in pairs(petList) do
      petDataDic[petData.gid] = petData
    end
  end
  return petDataDic
end

function UMG_Travel_C:OnClosePanel()
  self:ClosePanel()
end

function UMG_Travel_C:OnCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Travel_C:OnDepartBtn")
  if self.StrongPointOpen then
    self:OnCloseStrongPointBtn()
  elseif self.isOpenPetListPanel then
    self:OnCloseTravelPetListPanel()
  else
    self:ClosePanel()
  end
end

function UMG_Travel_C:OnClosePetListPanel()
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Travel_C:OnDepartBtn")
  _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnCloseTravelPetListPanel)
end

function UMG_Travel_C:OnStrongPointBtn()
  self.StrongPointOpen = true
  self.DetailsOfSpecialties:AnimOpen()
  self.Btn_Close_1:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_Travel_C:OnCloseStrongPointBtn()
  self.StrongPointOpen = false
  self.DetailsOfSpecialties:AnimClose()
  self.Btn_Close_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Travel_C:OnDepartBtn()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FT_MAP_PET_TRAVEL, true)
  if isBan then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1346, "UMG_Travel_C:OnDepartBtn")
  _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.ZoneStartPetTravelReq, self.campId, self.campLv)
  self:ClosePanel()
end

function UMG_Travel_C:OnRecallBtn()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FT_MAP_PET_TRAVEL, true)
  if isBan then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1346, "UMG_Travel_C:OnRecallBtn")
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local title = LuaText.umg_travel_5
  local des = LuaText.umg_travel_6
  local leftText = LuaText.umg_travel_7
  local rightText = LuaText.umg_travel_8
  local Context = DialogContext()
  Context:SetTitle(title):SetContent(des):SetMode(DialogContext.Mode.OK_CANCEL):SetClickAnywhereClose(true):SetCallback(self, self.RecallPet):SetCloseOnCancel(true):SetButtonText(rightText, leftText)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Context)
end

function UMG_Travel_C:RecallPet(isOk)
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FT_MAP_PET_TRAVEL, true)
  if isBan then
    return
  end
  if isOk then
    _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.ZoneRecallPetTravelReq, self.campId)
    self:ClosePanel()
  end
end

function UMG_Travel_C:OnRewardBtn()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FT_MAP_PET_TRAVEL, true)
  if isBan then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1066, "UMG_Travel_C:OnRewardBtn")
  _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.ZoneCompletePetTravelReq, self.campId, self.TravelPetDatas)
  self:ClosePanel()
end

function UMG_Travel_C:ClosePanel()
  self:PlayAnimation(self.Page_Out)
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function UMG_Travel_C:OnAnimationFinished(anim)
  if anim == self.Page_Out then
    _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.ClearSelectTravelPet)
    _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnCloseTravelPanel)
    self:DoClose()
  elseif anim == self.Page_In then
    if self.IsNeedUnlockSelect then
      local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "MainBigMap").TELEPORT
      _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BigMapModule", "MainBigMap", touchReasonType)
      self.IsNeedUnlockSelect = false
    end
  elseif anim == self.Change_In then
    self.PetListCloseBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif anim == self.Change_Out then
    self.UMG_Travel_PetList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local selectCount = 0
    if self.petInfoList then
      for i = 1, #self.petInfoList do
        if -1 == self.petInfoList[i].gid then
          selectCount = selectCount + 1
        end
      end
      if selectCount >= 2 then
        self.isSelect = false
        for i = 1, 2 do
          local item = self.List_3:GetItemByIndex(i - 1)
          if item then
            item.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        end
      end
    end
  end
end

function UMG_Travel_C:SetTravelItemClickAble(clickable)
  self.UMG_Travel_PetList.List:SetItemClickAble(clickable)
end

return UMG_Travel_C
