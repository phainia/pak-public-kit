local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")
local UMG_Travel_PetList_C = _G.NRCViewBase:Extend("UMG_Travel_PetList_C")

function UMG_Travel_PetList_C:OnActive()
  self.screenToggle = false
  self.curPetDatas = nil
  self.IsReversalSort = false
  self.FilterCondition = {}
  local petInfos = self:GetPetInfos()
  self.petInfos = petInfos
  self:SetCommonComboBoxInfo(self.ComboBox)
  self:InitSort()
  self.Btn_Close_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Travel_PetList_C:SetCommonComboBoxInfo(ComboBox, ComboBoxText, ComboBoxIcon)
  local CommonDropDownListData = _G.NRCCommonDropDownListData()
  if ComboBoxText then
    CommonDropDownListData.DropDownListText = ComboBoxText
  end
  if ComboBoxIcon then
    CommonDropDownListData.DropDownListIcon = ComboBoxIcon
  end
  CommonDropDownListData.Call = self
  CommonDropDownListData.Btn_LeftHandler = self.OnFilter
  CommonDropDownListData.Btn_MidHandler = self.OnSort
  CommonDropDownListData.Btn_RightHandler = self.OnReversePetList
  ComboBox:SetPanelInfo(CommonDropDownListData)
end

function UMG_Travel_PetList_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Travel_PetList_C:OnDestruct()
  _G.NRCModuleManager:GetModule("PetUIModule"):UnRegisterEvent(self, PetUIModuleEvent.TypeChooseChanged, self.OnTypeChooseChanged)
  _G.NRCEventCenter:UnRegisterEvent(self, TravelModuleEvent.OnChangPetSkillTipsState, self.ChangPetSkillTipsState)
  _G.NRCEventCenter:UnRegisterEvent(self, TravelModuleEvent.UnSelectPetListItem, self.UnSelectPetListItem)
end

function UMG_Travel_PetList_C:OnAddEventListener()
  _G.NRCModuleManager:GetModule("PetUIModule"):RegisterEvent(self, PetUIModuleEvent.TypeChooseChanged, self.OnTypeChooseChanged)
  _G.NRCEventCenter:RegisterEvent("UMG_Travel_PetList_C", self, TravelModuleEvent.OnChangPetSkillTipsState, self.ChangPetSkillTipsState)
  _G.NRCEventCenter:RegisterEvent("UMG_Travel_PetList_C", self, TravelModuleEvent.UnSelectPetListItem, self.UnSelectPetListItem)
  self.ScrollBox_27.OnUserScrolled:Add(self, self.OnScrollCallback)
end

function UMG_Travel_PetList_C:OnFilter()
  for i = 1, #self.petInfos do
    local filterData = {}
    filterData.petbase_id = self.petInfos[i].baseId
    filterData.gid = self.petInfos[i].gid
    filterData.gender = self.petInfos[i].gender
    local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(self.petInfos[i].speciality_id)
    filterData.filter_enum_value = PetTalentConf and PetTalentConf.filter_enum_value
    filterData.partner_mark = self.petInfos[i].partner_mark
    self.petInfos[i].filterData = filterData
  end
  _G.NRCEventCenter:RegisterEvent("UMG_Travel_PetList_C", self, BagModuleEvent.OnFilter, self.FilterPets)
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenFilterPanel, self.petInfos, _G.DataConfigManager.ConfigTableId.TRAVEL_FILTER_CONF, self.FilterCondition)
end

function UMG_Travel_PetList_C:UnSelectPetListItem(gid, rightIdx)
  local isOpenState = self:GetVisibility() == UE4.ESlateVisibility.Visible
  if false == isOpenState then
    return
  end
  local isUnSelectList = false
  for i = 1, self.List:GetItemCount() do
    local item = self.List:GetItemByIndex(i - 1)
    if item.data and item.data.gid == gid then
      item:UnSelect()
      isUnSelectList = true
    end
  end
  if false == isUnSelectList then
    _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.SelectTravelPet, rightIdx, -1, -1, 0)
  end
end

function UMG_Travel_PetList_C:ChangPetSkillTipsState(isOpen)
  if isOpen then
    self:PlayAnimation(self.Black_close)
  else
    self:PlayAnimation(self.Black_open)
  end
end

function UMG_Travel_PetList_C:FilterPets(filterList, condition)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.OnFilter, self.FilterPets)
  self.FilterCondition = condition
  local isSwitch = #condition.FilterDepartCondition > 0 or #condition.FilterGenderCondition > 0 or #condition.FilterSpecialityCondition > 0 or #condition.FilterPetMarkCondition > 0
  if isSwitch then
    self.ComboBox.ScreeningBtn:ChangeIconSelectState(2)
  else
    self.ComboBox.ScreeningBtn:ChangeIconSelectState(1)
  end
  self:OnShowPetList(filterList)
end

function UMG_Travel_PetList_C:OnSort()
  _G.NRCEventCenter:RegisterEvent("UMG_Travel_PetList_C", self, BagModuleEvent.UpdateSort, self.SortPets)
  local list = {}
  for i = 1, 2 do
    local sortInfo = {}
    local sortId = i
    local name = _G.DataConfigManager:GetTravelSequenceConf(sortId).sequence_desc
    sortInfo.text = name
    sortInfo.sequence = sortId
    table.insert(list, sortInfo)
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenBagSortPanel, list, self.curSortId, true)
end

function UMG_Travel_PetList_C:SortPets(sortIndex, sortData)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.UpdateSort, self.SortPets)
  local datas
  self.curSortId = sortIndex
  if 1 == sortIndex then
    datas = self:SortPetLevel(self.curPetDatas)
  else
    datas = self:SortPetTime(self.curPetDatas)
  end
  local name = _G.DataConfigManager:GetTravelSequenceConf(sortIndex).sequence_desc
  local selectData = {}
  table.insert(selectData, 1)
  self.ComboBox:SetComboText(name)
  self.curPetDatas = datas
  if self.IsReversalSort then
    self:ReversePetList()
  else
    self.List:InitGridView(datas)
  end
end

function UMG_Travel_PetList_C:InitSort()
  self.curSortId = 1
  local datas = self:SortPetLevel(self.petInfos)
  local name = _G.DataConfigManager:GetTravelSequenceConf(self.curSortId).sequence_desc
  local selectData = {}
  table.insert(selectData, 1)
  self.ComboBox:SetComboText(name)
  self.curPetDatas = datas
  self.List:InitGridView(datas)
end

function UMG_Travel_PetList_C:OnReversePetList()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:ReversePetList()
  self.IsReversalSort = not self.IsReversalSort
  if self.IsReversalSort then
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(-1, 1))
  else
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(-1, -1))
  end
end

function UMG_Travel_PetList_C:ReversePetList()
  local function reversal(list)
    local reversedList = {}
    
    for i = #list, 1, -1 do
      table.insert(reversedList, list[i])
    end
    return reversedList
  end
  
  local otherPetList = {}
  local TopPetList = {}
  local petList = {}
  for i = 1, #self.curPetDatas do
    if 0 ~= self.curPetDatas[i].sortNumber and self.curPetDatas[i].sortNumber ~= -999 then
      table.insert(otherPetList, self.curPetDatas[i])
    elseif self.curPetDatas[i].sortNumber == -999 then
      table.insert(TopPetList, self.curPetDatas[i])
    else
      table.insert(petList, self.curPetDatas[i])
    end
  end
  petList = reversal(petList)
  for i = 1, #otherPetList do
    table.insert(petList, otherPetList[i])
  end
  
  local function TopPetListSort(a, b)
    return a.speciality_priority < b.speciality_priority
  end
  
  table.sort(TopPetList, TopPetListSort)
  for i = 1, #TopPetList do
    table.insert(petList, i, TopPetList[i])
  end
  self.curPetDatas = petList
  self.List:InitGridView(self.curPetDatas)
end

function UMG_Travel_PetList_C:OnCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_Travel_C:OnDepartBtn")
  _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnCloseTravelPetListPanel)
end

function UMG_Travel_PetList_C:OnTypeChooseChanged(typeList)
  local type = typeList[1]
  local PetInfos = self:GetPetInfos()
  local chooseDatas = {}
  for i = 1, #PetInfos do
    local petInfo = PetInfos[i]
    local isAdd = false
    for j = 1, #petInfo.unitType do
      local petType = petInfo.unitType[j]
      if nil == type or type == petType then
        isAdd = true
        break
      end
    end
    if isAdd then
      table.insert(chooseDatas, petInfo)
    end
  end
  self:OnShowPetList(chooseDatas)
end

function UMG_Travel_PetList_C:SetGoodAndBadTypeList(goodDatas, badDatas)
  self.goodDatas = goodDatas
  self.badDatas = badDatas
end

function UMG_Travel_PetList_C:GetAdvantageNumber(types)
  local advantage = 0
  if self.goodDatas and self.badDatas then
    for i = 1, #types do
      local petType = types[i]
      for j = 1, #self.goodDatas do
        local goodType = self.goodDatas[j]
        if petType == goodType then
          advantage = advantage + 1
        end
      end
      for k = 1, #self.badDatas do
        local badType = self.badDatas[k]
        if petType == badType then
          advantage = advantage - 1
        end
      end
    end
  end
  return advantage
end

function UMG_Travel_PetList_C:SortPetDatas(datas)
  table.sort(datas, function(a, b)
    if a.sortNumber == b.sortNumber then
      return a.gid < b.gid
    else
      return a.sortNumber < b.sortNumber
    end
  end)
  return datas
end

function UMG_Travel_PetList_C:SortPetLevel(datas)
  table.sort(datas, function(a, b)
    if a.sortNumber == b.sortNumber then
      if a.level == b.level then
        return a.gid > b.gid
      else
        return a.level > b.level
      end
    else
      return a.sortNumber < b.sortNumber
    end
  end)
  return datas
end

function UMG_Travel_PetList_C:SortPetSpeciality(datas)
  table.sort(datas, function(a, b)
    if a.sortNumber == b.sortNumber then
      if a.speciality_priority == b.speciality_priority then
        return a.gid < b.gid
      else
        return a.speciality_priority < b.speciality_priority
      end
    else
      return a.sortNumber < b.sortNumber
    end
  end)
  return datas
end

function UMG_Travel_PetList_C:SortPetTime(datas)
  table.sort(datas, function(a, b)
    if a.sortNumber == b.sortNumber then
      if a.addTime == b.addTime then
        return a.gid < b.gid
      else
        return a.addTime > b.addTime
      end
    else
      return a.sortNumber < b.sortNumber
    end
  end)
  return datas
end

function UMG_Travel_PetList_C:OnShowPetList(petList)
  local datas = self:SortPetDatas(petList)
  if 1 == self.curSortId then
    datas = self:SortPetLevel(datas)
  elseif #self.FilterCondition.FilterSpecialityCondition > 0 then
    datas = self:SortPetSpeciality(datas)
  else
    datas = self:SortPetTime(datas)
  end
  for i = 1, #datas do
    local petData = datas[i]
    petData.selectIndex = self:GetPetSelectIndex(petData.gid)
  end
  self.curPetDatas = datas
  if self.IsReversalSort then
    self:ReversePetList()
  else
    self.List:InitGridView(datas)
  end
end

function UMG_Travel_PetList_C:OnScrollCallback(offest)
  if 1 == math.ceil(offest) % 5 then
    local selectItem = _G.NRCModeManager:DoCmd(TravelModuleCmd.OnGetSelectPetSkillTipsItem)
    if selectItem then
      selectItem:OnStopUpdate()
      _G.NRCModuleManager:DoCmd(TravelModuleCmd.OnSetSelectPetSkillTipsItem, nil)
    end
  end
end

function UMG_Travel_PetList_C:OnReset()
  self.curPetDatas = self:GetPetInfos()
end

function UMG_Travel_PetList_C:GetPetInfos()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  local bagPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  local petList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().pet_data
  local petList1 = self:CreatPetDatas(battlePetList)
  local petList2 = self:CreatPetDatas(bagPetList)
  local petList3 = self:CreatPetDatas(petList)
  local petDataDic = {}
  local petDataList = {}
  for i, v in ipairs(petList1) do
    petDataDic[v.gid] = v
  end
  for i, v in ipairs(petList2) do
    petDataDic[v.gid] = v
  end
  for i, v in ipairs(petList3) do
    petDataDic[v.gid] = v
  end
  for i, v in pairs(petDataDic) do
    table.insert(petDataList, v)
  end
  return petDataList
end

function UMG_Travel_PetList_C:CreatPetDatas(petList)
  local petDatas = {}
  for i = 1, #petList do
    local teamGids, battleTeamGids = self:CreatPetTeamDatas()
    local petInfo = petList[i]
    local petData = {}
    petData.gid = petInfo.gid
    petData.speciality_id = petInfo.speciality_id
    local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(petInfo.speciality_id)
    petData.filter_enum_value = PetTalentConf and PetTalentConf.filter_enum_value
    petData.speciality_priority = PetTalentConf and PetTalentConf.priority
    petData.speciality_type = PetTalentConf and PetTalentConf.type
    petData.baseId = petInfo.base_conf_id
    petData.addTime = petInfo.add_time
    petData.level = petInfo.level
    petData.gender = petInfo.gender
    petData.types = petInfo.skill_dam_type
    petData.isTeam = self:IsPetTeam(petInfo.gid, teamGids)
    if 1 ~= petData.isTeam then
      petData.isTeam = _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.IsHasLevelSelectionTeams, petInfo.gid) and 1 or 0
    end
    petData.isBattleTeam = self:IsPetTeam(petInfo.gid, battleTeamGids)
    petData.isTravel = self:IsPetTravel(petInfo.gid)
    if 1 == petData.isTravel then
      petData.IsTravelFinish = self:IsPetTravelFinish(petInfo.gid)
    else
      petData.IsTravelFinish = 0
    end
    petData.isInHome = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetPetIsInHome, petInfo.gid)
    petData.isInGuard = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePlantGuardPetGid) == petInfo.gid
    petData.isInTemporarilyStoreBackpack = _G.DataModelMgr.PlayerDataModel:IsInBackpack(petInfo.gid)
    petData.unitType = _G.DataConfigManager:GetPetbaseConf(petInfo.base_conf_id).unit_type
    petData.advantage = self:GetAdvantageNumber(petData.unitType)
    if 1 == petData.gid then
      petData.advantage = self:GetAdvantageNumber(petData.unitType)
    end
    petData.selectIndex = self:GetPetSelectIndex(petInfo.gid)
    petData.sortNumber = self:GeSortNumber(petData)
    petData.data = petInfo
    petData.partner_mark = petInfo.partner_mark
    local isExchange = petInfo.pet_status_flags and petInfo.pet_status_flags & _G.ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
    if not isExchange then
      table.insert(petDatas, petData)
    end
  end
  return petDatas
end

function UMG_Travel_PetList_C:CreatPetTeamDatas()
  local teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
  local teamGids = {}
  local battleTeamGids = {}
  for i = 1, #teamInfo.teams do
    if teamInfo.main_team_idx + 1 ~= i then
      local team = teamInfo.teams[i]
      if team.pet_infos then
        for j = 1, #team.pet_infos do
          local gid = team.pet_infos[j].pet_gid
          table.insert(teamGids, gid)
        end
      end
    else
      local team = teamInfo.teams[i]
      if team.pet_infos then
        for j = 1, #team.pet_infos do
          local gid = team.pet_infos[j].pet_gid
          table.insert(battleTeamGids, gid)
        end
      end
    end
  end
  return teamGids, battleTeamGids
end

function UMG_Travel_PetList_C:IsPetTeam(gid, gidList)
  for i = 1, #gidList do
    if gidList[i] == gid then
      return 1
    end
  end
  return 0
end

function UMG_Travel_PetList_C:IsPetTravel(gid)
  local TravelInfos = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetTravelInfos)
  if not TravelInfos then
    return 0
  end
  for i = 1, #TravelInfos do
    local gids = TravelInfos[i].pet_gid
    for j = 1, #gids do
      if gids[j] == gid then
        return 1
      end
    end
  end
  return 0
end

function UMG_Travel_PetList_C:IsPetTravelFinish(gid)
  local TravelInfos = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetTravelInfos)
  if not TravelInfos then
    return 0
  end
  for i = 1, #TravelInfos do
    local gids = TravelInfos[i].pet_gid
    for j = 1, #gids do
      if gids[j] == gid then
        if TravelInfos[i].travel_complete then
          return 1
        else
          return 0
        end
      end
    end
  end
  return 0
end

function UMG_Travel_PetList_C:GetPetSelectIndex(gid)
  local dic = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetSelectTravelPet)
  for key, value in pairs(dic) do
    local travelGid = value.gid
    if gid == travelGid then
      return key
    end
  end
  return 0
end

function UMG_Travel_PetList_C:GeSortNumber(petData)
  local sortNum = 0
  if 0 == petData.isTeam and 0 == petData.isBattleTeam and 0 == petData.isTravel and 2 ~= petData.speciality_type and not petData.isInGuard and not petData.isInHome and not petData.isInTemporarilyStoreBackpack then
    sortNum = 0
  elseif 1 == petData.isTravel and 0 == petData.IsTravelFinish then
    sortNum = 1
  elseif 1 == petData.isTravel and 1 == petData.IsTravelFinish then
    sortNum = 2
  elseif petData.isInGuard then
    sortNum = 3
  elseif petData.isInHome then
    sortNum = 4
  elseif 1 == petData.isBattleTeam then
    sortNum = 5
  elseif 1 == petData.isTeam then
    sortNum = 6
  elseif petData.isInTemporarilyStoreBackpack then
    sortNum = 7
  elseif 2 == petData.speciality_type then
    sortNum = -999
  end
  return sortNum
end

return UMG_Travel_PetList_C
