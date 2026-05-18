local UMG_PlantProtectionMain_C = _G.NRCPanelBase:Extend("UMG_PlantProtectionMain_C")
local CommonBtnEnum = require("NewRoco.Modules.System.CommonBtn.CommonBtnEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local HomeModuleEvent = require("NewRoco/Modules/System/Home/HomeModuleEvent")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local ResQueue = require("NewRoco.Utils.ResQueue")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")

function UMG_PlantProtectionMain_C:OnEnable()
end

function UMG_PlantProtectionMain_C:OnDisable()
end

function UMG_PlantProtectionMain_C:OnActive(npcActionOpen)
  self:UpdateUIAnySelectable(false)
  if self.NoUnlockFormulaText then
    self.NoUnlockFormulaText:SetText(LuaText.plant_no_guard_text)
  end
  self.data = self.module.data
  self.data.NPCActionOpenGuard = npcActionOpen
  self.currentPetGid = 0
  self.loadingPetGid = 0
  self.firstSelectItem = true
  self.petInfoList = nil
  self.curPetDatas = nil
  self.isReversalSort = false
  self.currentIndex = 1
  self.curPetListSelectIndex = 1
  self.chooseTypeList = {
    DepartmentFilter = {},
    TalentFilter = {},
    NaturePositiveEffectFilter = {},
    AttributeFilter = {}
  }
  self.selectGid = nil
  self.petInfos = self:GetPetInfo()
  self.curPetDatas = self.petInfos
  self.currentSelectPet = nil
  self:OnAddEventListener()
  self:SetCommonTitle()
  self:InitSortComboBox()
  self.GuardBtn.Title_1:SetText(LuaText.plant_no_guard_btn_text)
  self.changeBtn4.Title_1:SetText(LuaText.plant_guard_btn_text)
  self.PromptText:SetText(LuaText.plant_no_guard_help_text)
  self:OnDetailPanelShow(2)
  self:UpdateSelectAndShowModel()
  self:PlayAnimation(self.open)
  self.GridView1:SetItemCanClickChecker(self.ItemClickChecker, self)
end

function UMG_PlantProtectionMain_C:OnDeactive()
  self:ReleaseResource()
  self:OnRemoveEventListener()
  if self.data and self.data.NPCActionOpenGuard and self.data.NPCActionOpenGuard.EndAction then
    self.data.NPCActionOpenGuard:EndAction()
    self.data.NPCActionOpenGuard = nil
  end
end

function UMG_PlantProtectionMain_C:GetPetInfo()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  local bagPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  local petList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().pet_data
  local battlePetDatas = self:CreatePetDatas(battlePetList)
  local bagPetDatas = self:CreatePetDatas(bagPetList)
  local petDatas = self:CreatePetDatas(petList)
  local petDataDic = {}
  local petDataList = {}
  for i, v in ipairs(battlePetDatas) do
    petDataDic[v.gid] = v
  end
  for i, v in ipairs(bagPetDatas) do
    petDataDic[v.gid] = v
  end
  for i, v in ipairs(petDatas) do
    petDataDic[v.gid] = v
  end
  for i, v in pairs(petDataDic) do
    v.IsHasPet = true
    v.panel = self
    table.insert(petDataList, v)
  end
  return petDataList
end

function UMG_PlantProtectionMain_C:CreatePetDatas(petList)
  local petDatas = {}
  for i = 1, #petList do
    local teamGids, battleTeamGids = self:CreatePetTeamData()
    local petInfo = petList[i]
    local petData = {}
    petData.gid = petInfo.gid
    petData.base_conf_id = petInfo.base_conf_id
    petData.addTime = petInfo.add_time
    petData.level = petInfo.level
    petData.gender = petInfo.gender
    petData.types = petInfo.skill_dam_type
    petData.isTeam = table.contains(teamGids, petInfo.gid) or _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.IsHasLevelSelectionTeams, petInfo.gid) and true or false
    petData.isBattleTeam = table.contains(battleTeamGids, petInfo.gid)
    petData.isTravel = self:IsPetInTravel(petInfo.gid)
    petData.bFinishTravel = petData.isTravel and self:IsPetFinishTravel(petInfo.gid) or false
    petData.unitType = _G.DataConfigManager:GetPetbaseConf(petInfo.base_conf_id).unit_type
    petData.advantage = self:GetAdvantageNum(petData.unitType)
    petData.selectIndex = 1
    petData.isInHome = self:IsInHome(petInfo.gid)
    petData.isInGuard = self:IsGuardingHomePlant(petInfo.gid)
    petData.sortNum = self:GetSortNum(petData)
    petData.data = petInfo
    local isExchange = petInfo.pet_status_flags and petInfo.pet_status_flags & _G.ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
    if not isExchange then
      table.insert(petDatas, petData)
    end
  end
  return petDatas
end

function UMG_PlantProtectionMain_C:CreatePetTeamData()
  local teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
  local teamGids = {}
  local battleTeamGids = {}
  for i = 1, #teamInfo.teams do
    if teamInfo.main_team_idx + 1 ~= i then
      local team = teamInfo.teams[i]
      if team.pet_infos ~= nil then
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

function UMG_PlantProtectionMain_C:InitSortComboBox()
  self.curSortId = -1
  local sortList = {}
  local sortText = {}
  for i = 0, 1 do
    local sortInfo = {}
    local sortId = i + 1
    local name = _G.DataConfigManager:GetTravelSequenceConf(sortId).sequence_desc
    local sequence_default = _G.DataConfigManager:GetTravelSequenceConf(sortId).sequence_default
    sortInfo.name = name
    sortInfo.uiIndex = i
    sortInfo.datalist = sequence_default
    sortInfo.ComType = CommonBtnEnum.ComboBoxType.HomePlantGuard
    table.insert(sortList, sortInfo)
    table.insert(sortText, name)
  end
  local commonDropDownListData = _G.NRCCommonDropDownListData()
  commonDropDownListData.DropDownListInfo = sortList
  commonDropDownListData.DropDownListText = sortText[self.currentIndex]
  commonDropDownListData.Call = self
  commonDropDownListData.Btn_LeftHandler = self.OpenFilterPanelBtnClick
  commonDropDownListData.Btn_RightHandler = self.OnReversePetList
  commonDropDownListData.DropDownListIndex = self.currentIndex
  commonDropDownListData.ComType = CommonBtnEnum.ComboBoxType.HomePlantGuard
  self.ComboBox:SetPanelInfo(commonDropDownListData)
  self.ComboBox.OnPopupVisibilityChanged = FPartial(self.OnPopupVisibilityChanged, self)
  self:OnPopupVisibilityChanged(false)
end

function UMG_PlantProtectionMain_C:OnPopupVisibilityChanged(bShow)
  if bShow then
    self.FullScreenBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.FullScreenBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PlantProtectionMain_C:CollapsedCombBoxPopUp()
  self.ComboBox:SetPopupVisible(false)
  self.FullScreenBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PlantProtectionMain_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn_1.btnClose, self.OnCloseBtnClicked)
  self:AddButtonListener(self.GuardBtn.btnLevelUp, self.OnClickBtnGuard)
  self:AddButtonListener(self.changeBtn4.btnLevelUp, self.OnClickBtnCancelGuard)
  self:AddButtonListener(self.Btn_Details, self.OnShowPetDetail)
  self:AddButtonListener(self.FullScreenBtn, self.CollapsedCombBoxPopUp)
  _G.NRCEventCenter:RegisterEvent("UMG_PlantProtectionMain_C", self, HomeModuleEvent.OnSelectGuardPetFilter, self.OnShowPetWithOrder)
  _G.NRCEventCenter:RegisterEvent("UMG_PlantProtectionMain_C", self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
  _G.NRCEventCenter:RegisterEvent("UMG_PlantProtectionMain_C", self, NPCModuleEvent.OnNpcMutationComplete, self.OnPetMutationDone)
  self:RegisterEvent(self, HomeModuleEvent.HomePlantGuardUpdate, self.OnHomePlantGuardUpdate)
  local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if petUIModule then
    petUIModule:RegisterEvent(self, PetUIModuleEvent.UpdatePetCollect, self.UpdatePetCollect)
  end
end

function UMG_PlantProtectionMain_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, HomeModuleEvent.OnSelectGuardPetFilter, self.OnShowPetWithOrder)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.OnNpcMutationComplete, self.OnPetMutationDone)
  local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if petUIModule then
    petUIModule:UnRegisterEvent(self, PetUIModuleEvent.UpdatePetCollect)
  end
  self:UnRegisterAllEvent()
end

function UMG_PlantProtectionMain_C:OnShowPetDetail()
  if self.currentSelectPet then
    _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_PlantProtectionMain_C:OnShowPetDetail")
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdOpenPanel, "PlantGuardPetDetail", true, self.currentSelectPet, self, self.OnDetailPanelShow)
  end
end

function UMG_PlantProtectionMain_C:OpenFilterPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PlantProtectionMain_C:OpenFilterPanelBtnClick")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenFilterPanel, PetUIModuleEnum.OpenSortType.HomePlantGuard, {
    HiddenParam = nil,
    chooseTypeList = self.chooseTypeList
  })
end

function UMG_PlantProtectionMain_C:SetCommonTitle()
  local titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  if not titleConf then
    return
  end
  self.titleConf = titleConf
  if self.titleConf.title then
    self.Title1:Set_MainTitle(self.titleConf.title)
  end
  if self.titleConf.head_icon then
    self.Title1:SetBg(self.titleConf.head_icon)
  end
  if self.titleConf.subtitle then
    self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
  end
end

function UMG_PlantProtectionMain_C:SetNameInfo(petInfo)
  if not petInfo or not petInfo.data then
    return
  end
  local petData = petInfo.data
  local petDataInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petData.gid)
  if not petDataInfo then
    return
  end
  local commonAttrData = {}
  local commonAttrData1 = {}
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(petDataInfo.blood_id)
  if petBaseConf then
    table.insert(commonAttrData, {
      Name = PetBloodConf.blood_name,
      Path = PetBloodConf.icon
    })
    if self.Attr then
      self.Attr:InitGridView(commonAttrData)
    end
    local petType = petBaseConf.unit_type
    for i = 1, 2 do
      if i <= #petType then
        local typeDic = _G.DataConfigManager:GetTypeDictionary(petType[i])
        if typeDic then
          table.insert(commonAttrData1, {
            Name = typeDic.short_name,
            Path = typeDic.type_icon
          })
        end
      end
    end
    if self.Attr1 then
      self.Attr1:InitGridView(commonAttrData1)
    end
  end
  self.CatchHardLv:Clear()
  local PetStarsList = PetUtils.GetPetStarsListByPetGID(petDataInfo.gid)
  self.CatchHardLv:InitGridView(PetStarsList)
  self.textPetName:SetText(petDataInfo.name)
  if petInfo.isInGuard then
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  end
end

function UMG_PlantProtectionMain_C:SortPetLevel(datas)
  table.sort(datas, function(a, b)
    if a.sortNum == b.sortNum then
      if a.level == b.level then
        return a.gid < b.gid
      else
        return a.level > b.level
      end
    else
      return a.sortNum < b.sortNum
    end
  end)
  return datas
end

function UMG_PlantProtectionMain_C:SortPetTime(datas)
  table.sort(datas, function(a, b)
    if a.sortNum == b.sortNum then
      if a.addTime == b.addTime then
        return a.gid < b.gid
      else
        return a.addTime > b.addTime
      end
    else
      return a.sortNum < b.sortNum
    end
  end)
  return datas
end

function UMG_PlantProtectionMain_C:OnFilterPet(typeChooseList)
  self.curPetDatas = self.petInfos
  local departmentFilter = {}
  local departList = {}
  if typeChooseList.DepartmentFilter then
    for i, v in pairs(typeChooseList.DepartmentFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(departmentFilter, enum)
      end
    end
  end
  if #departmentFilter > 0 then
    if not self.curPetDatas or #self.curPetDatas < 1 then
      return
    end
    for i = 1, #self.curPetDatas do
      if self.curPetDatas[i] then
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.curPetDatas[i].base_conf_id)
        for k = 1, #petBaseConf.unit_type do
          for j = 1, #departmentFilter do
            if petBaseConf.unit_type[k] == departmentFilter[j] and not self:HasGid(self.curPetDatas[i].gid, departList) then
              table.insert(departList, self.curPetDatas[i])
            end
          end
        end
      end
    end
  else
    departList = self.curPetDatas
  end
  local talentFilter = {}
  local talentList = {}
  if typeChooseList.TalentFilter then
    for i, v in pairs(typeChooseList.TalentFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(talentFilter, enum)
      end
    end
  end
  if #talentFilter > 0 then
    for i = 1, #departList do
      for j = 1, #talentFilter do
        if departList[i].data.talent_rank == talentFilter[j] then
          table.insert(talentList, departList[i])
          break
        end
      end
    end
  else
    talentList = departList
  end
  local naturePositiveEffectFilter = {}
  local naturePositiveEffectList = {}
  if typeChooseList.NaturePositiveEffectFilter then
    for i, v in pairs(typeChooseList.NaturePositiveEffectFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(naturePositiveEffectFilter, enum)
      end
    end
  end
  if #naturePositiveEffectFilter > 0 then
    for i = 1, #talentList do
      local naturePositive = talentList[i].data.changed_nature_pos_attr_type
      if not naturePositive or 0 == naturePositive then
        naturePositive = _G.DataConfigManager:GetNatureConf(talentList[i].data.nature).positive_effect
      else
        naturePositive = self:GetChangeAttrReqEnum(naturePositive)
      end
      for j = 1, #naturePositiveEffectFilter do
        if naturePositive == naturePositiveEffectFilter[j] then
          table.insert(naturePositiveEffectList, talentList[i])
          break
        end
      end
    end
  else
    naturePositiveEffectList = talentList
  end
  local attributeFilter = {}
  local attributeList = {}
  if typeChooseList.AttributeFilter then
    for i, v in pairs(typeChooseList.AttributeFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(attributeFilter, enum)
      end
    end
  end
  if #attributeFilter > 0 then
    for i = 1, #naturePositiveEffectList do
      for j = 1, #attributeFilter do
        if attributeFilter[j] == _G.Enum.AttributeType.AT_HPMAX and naturePositiveEffectList[i].data.attribute_info.hp.talent and naturePositiveEffectList[i].data.attribute_info.hp.talent > 0 then
          table.insert(attributeList, naturePositiveEffectList[i])
          break
        end
        if attributeFilter[j] == _G.Enum.AttributeType.AT_PHYATK and naturePositiveEffectList[i].data.attribute_info.attack.talent and naturePositiveEffectList[i].data.attribute_info.attack.talent > 0 then
          table.insert(attributeList, naturePositiveEffectList[i])
          break
        end
        if attributeFilter[j] == _G.Enum.AttributeType.AT_SPEATK and naturePositiveEffectList[i].data.attribute_info.special_attack.talent and naturePositiveEffectList[i].data.attribute_info.special_attack.talent > 0 then
          table.insert(attributeList, naturePositiveEffectList[i])
          break
        end
        if attributeFilter[j] == _G.Enum.AttributeType.AT_PHYDEF and naturePositiveEffectList[i].data.attribute_info.defense.talent and naturePositiveEffectList[i].data.attribute_info.defense.talent > 0 then
          table.insert(attributeList, naturePositiveEffectList[i])
          break
        end
        if attributeFilter[j] == _G.Enum.AttributeType.AT_SPEDEF and naturePositiveEffectList[i].data.attribute_info.special_defense.talent and naturePositiveEffectList[i].data.attribute_info.special_defense.talent > 0 then
          table.insert(attributeList, naturePositiveEffectList[i])
          break
        end
        if attributeFilter[j] == _G.Enum.AttributeType.AT_SPEED and naturePositiveEffectList[i].data.attribute_info.speed.talent and naturePositiveEffectList[i].data.attribute_info.speed.talent > 0 then
          table.insert(attributeList, naturePositiveEffectList[i])
          break
        end
      end
    end
  else
    attributeList = naturePositiveEffectList
  end
  local PartnerMarkerFilter = {}
  local PartnerMarkerList = {}
  if typeChooseList.PartnerMarkerFilter then
    for i, v in pairs(typeChooseList.PartnerMarkerFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(PartnerMarkerFilter, enum)
      end
    end
  end
  if #PartnerMarkerFilter > 0 then
    for i = 1, #attributeList do
      for j = 1, #PartnerMarkerFilter do
        if attributeList[i].data.partner_mark == PartnerMarkerFilter[j] then
          table.insert(PartnerMarkerList, attributeList[i])
          break
        end
      end
    end
  else
    PartnerMarkerList = attributeList
  end
  local SpecialityFilter = {}
  local SpecialityList = {}
  if typeChooseList.SpecialityFilter then
    for i, v in pairs(typeChooseList.SpecialityFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = v.data.filter_enum_value
        table.insert(SpecialityFilter, enum)
      end
    end
  end
  if #SpecialityFilter > 0 then
    for i = 1, #PartnerMarkerList do
      for j = 1, #SpecialityFilter do
        if PartnerMarkerList[i].data.speciality_id then
          local petTalentConf = _G.DataConfigManager:GetPetTalentConf(PartnerMarkerList[i].data.speciality_id)
          if petTalentConf and petTalentConf.filter_enum_value == SpecialityFilter[j] then
            table.insert(SpecialityList, PartnerMarkerList[i])
            break
          end
        end
      end
    end
  else
    SpecialityList = PartnerMarkerList
  end
  if #departmentFilter <= 0 and #talentFilter <= 0 and #naturePositiveEffectFilter <= 0 and #attributeFilter <= 0 and #PartnerMarkerFilter <= 0 and #SpecialityFilter <= 0 then
    self.curPetDatas = self.petInfos
    SpecialityList = self.petInfos
  elseif SpecialityList then
    self.curPetDatas = SpecialityList
  end
  self:DelayFrames(1, function()
    self:OnShowPetWithOrder(self.curSortId, nil)
  end)
end

function UMG_PlantProtectionMain_C:OnReversePetList()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PlantProtectionMain_C:OnReversePetList")
  self:ReversePetList()
  self.IsReversalSort = not self.IsReversalSort
  self.GridView1:InitList(self.curPetDatas, true)
end

function UMG_PlantProtectionMain_C:ReversePetList()
  local function reversal(list)
    if #list < 1 then
      return {}
    end
    local reversedList = {}
    for i = #list, 1, -1 do
      table.insert(reversedList, list[i])
    end
    return reversedList
  end
  
  local otherPetList = {}
  local petList = {}
  if not self.curPetDatas then
    Log.Error("self.curPetDatas nil")
    return
  end
  for i = 1, #self.curPetDatas do
    if 0 ~= self.curPetDatas[i].sortNum then
      table.insert(otherPetList, self.curPetDatas[i])
    else
      table.insert(petList, self.curPetDatas[i])
    end
  end
  petList = reversal(petList)
  for i = 1, #otherPetList do
    table.insert(petList, otherPetList[i])
  end
  self.curPetDatas = petList
end

function UMG_PlantProtectionMain_C:OnShowPetWithOrder(uiIndex, dataList)
  local datas
  self.curSortId = uiIndex
  if self.curSortId == Enum.PetSequenceSwitch.SEQUENCE_LEVEL_UP then
    datas = self:SortPetLevel(self.curPetDatas)
    self.curPetDatas = datas
  elseif self.curSortId == Enum.PetSequenceSwitch.SEQUENCE_CATCH_UP then
    datas = self:SortPetTime(self.curPetDatas)
    self.curPetDatas = datas
  end
  if self.isReversalSort then
    self:ReversePetList()
  end
  self.GridView1:InitList(self.curPetDatas)
  self:UpdateSelectAndShowModel()
end

function UMG_PlantProtectionMain_C:GetChangeAttrReqEnum(attribute)
  if not attribute then
    return nil
  end
  if attribute == Enum.AttributeType.AT_HPMAX then
    return Enum.AttributeType.AT_HPMAX_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYATK then
    return Enum.AttributeType.AT_PHYATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEATK then
    return Enum.AttributeType.AT_SPEATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYDEF then
    return Enum.AttributeType.AT_PHYDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEDEF then
    return Enum.AttributeType.AT_SPEDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEED then
    return Enum.AttributeType.AT_SPEED_PERCENT
  end
end

function UMG_PlantProtectionMain_C:HasGid(gid, table)
  if not table then
    return false
  end
  for i = 1, #table do
    if table[i].data.gid == gid then
      return true
    end
  end
  return false
end

function UMG_PlantProtectionMain_C:LastPetData(petDataList)
  for i, v in ipairs(petDataList) do
    if v.data == nil then
      return i
    else
      return i - 1
    end
  end
  return #petDataList
end

function UMG_PlantProtectionMain_C:GetAdvantageNum(types)
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
end

function UMG_PlantProtectionMain_C:IsPetInTravel(gid)
  local travelInfos = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetTravelInfos)
  if not travelInfos then
    return false
  end
  for i = 1, #travelInfos do
    local travelPetGids = travelInfos[i].pet_gid
    for j = 1, #travelPetGids do
      if travelPetGids[j] == gid then
        return true
      end
    end
  end
  return false
end

function UMG_PlantProtectionMain_C:IsPetFinishTravel(gid)
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

function UMG_PlantProtectionMain_C:IsInHome(gid)
  local res = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetPetIsInHome, gid)
  return res
end

function UMG_PlantProtectionMain_C:IsGuardingHomePlant(gid)
  return (gid or 0) > 0 and gid == _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetHomePlantGuardPetGid)
end

function UMG_PlantProtectionMain_C:GetSortNum(petData)
  local sortNum = 0
  if petData.isInGuard then
    sortNum = -1
  elseif not petData.isTeam and not petData.isBattleTeam and not petData.isTravel and not petData.isInHome then
    sortNum = 0
  elseif not petData.isTravel == false and not petData.IsTravelFinish then
    sortNum = 1
  elseif petData.isTravel and petData.IsPetFinishTravel then
    sortNum = 2
  elseif petData.isInHome then
    sortNum = 3
  elseif petData.isBattleTeam then
    sortNum = 4
  elseif petData.isTeam then
    sortNum = 5
  end
  return sortNum
end

function UMG_PlantProtectionMain_C:OnCloseBtnClicked()
  if self:ISAnimationPlaying(self.close) then
    return
  end
  self:PlayAnimation(self.close)
  _G.NRCAudioManager:PlaySound2DAuto(40002014, "UMG_PlantProtectionMain_C:OnDeactive")
end

function UMG_PlantProtectionMain_C:OnAnimationFinished(Anim)
  if Anim == self.close then
    self:DoClose()
  end
end

function UMG_PlantProtectionMain_C:OnClickBtnGuard()
  if self.currentSelectPet and self.currentSelectPet.data then
    _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_PlantProtectionMain_C:OnClickBtnGuard")
    if not self.currentSelectPet.isInGuard then
      _G.NRCModuleManager:DoCmd(HomeModuleCmd.SendPlantPetGuardReq, true, self.currentSelectPet.gid)
      self:OnCloseBtnClicked()
    end
  end
end

function UMG_PlantProtectionMain_C:OnClickBtnCancelGuard()
  if self.currentSelectPet and self.currentSelectPet.data and self.currentSelectPet.isInGuard then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.SendPlantPetGuardReq, false)
    self:OnCloseBtnClicked()
  end
end

function UMG_PlantProtectionMain_C:UpdateSelectAndShowModel()
  if not self.petInfos then
    Log.Warning("No pet with player")
    return
  end
  local preferSelectedIndex = 0
  if self.currentSelectPet then
    self.selectGid = self.currentSelectPet.gid
    for idx, petData in ipairs(self.curPetDatas) do
      if self.selectGid == petData.gid then
        preferSelectedIndex = idx - 1
        break
      end
    end
  end
  if preferSelectedIndex < #self.curPetDatas then
    self.GridView1:SelectItemByIndex(preferSelectedIndex)
  end
  local itemWidget = self.GridView1:GetItemByIndex(preferSelectedIndex)
  self:UpdateUIAnySelectable(itemWidget and itemWidget.clickable == true)
end

function UMG_PlantProtectionMain_C:OnScrollPetItemSelected(item, index, bNeedAudio, bOnlyPetData)
  if bNeedAudio then
    if self.firstSelectItem then
      self.firstSelectItem = false
    else
      _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_PlantProtectionMain_C:OnScrollPetItemSelected")
    end
  end
  self.curPetListSelectIndex = index
  if not (item and item.petInfo) or not item.petData then
    return
  end
  self.currentSelectPet = item.petInfo
  if not item.petInfo.base_conf_id then
    return
  end
  self.selectGid = item.petInfo.gid
  self:UpdateUIAnySelectable(true)
  self:SetNameInfo(item.petInfo)
  self:DispatchEvent(HomeModuleEvent.UpdateGuardDetailPanel, item.petInfo)
  self:StartGeneratePet(item.petInfo.base_conf_id, item.petInfo.gid)
end

function UMG_PlantProtectionMain_C:LockItemClick(bLock)
  self.bLockItemClick = bLock
end

function UMG_PlantProtectionMain_C:ReleaseResource()
  self:StopGeneratePet()
  if self.currentPetModel then
    self.currentPetModel:SetActorHiddenInGame(true)
    self.currentPetModel:K2_DestroyActor()
    self.currentPetModel = nil
    self.currentPetGid = 0
  end
end

function UMG_PlantProtectionMain_C:StartGeneratePet(petBaseId, petGid)
  if self.currentPetGid == petGid then
    Log.Debug("UMG_PlantProtectionMain_C:StartGeneratePet", petBaseId, petGid, self.currentPetGid, self.loadingPetGid)
    self:StopGeneratePet()
    return
  elseif self.loadingPetGid == petGid then
    Log.Debug("UMG_PlantProtectionMain_C:StartGeneratePet", petBaseId, petGid, self.currentPetGid, self.loadingPetGid)
    return
  end
  local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
  local PetModelId = petbaseConf.model_conf
  local PetModelConf = _G.DataConfigManager:GetModelConf(PetModelId)
  self:LockItemClick(true)
  self:StopGeneratePet()
  self.loadingPetGid = petGid
  local resQueue = ResQueue(30)
  self.LoadPetResQueue = resQueue
  resQueue:InsertObject("PetModel", PetModelConf.path)
  resQueue:StartLoad(self, self.OnPetModelLoaded)
end

function UMG_PlantProtectionMain_C:StopGeneratePet()
  if self.LoadPetResQueue then
    self.LoadPetResQueue:Release()
    self.LoadPetResQueue = nil
  end
  if self.loadingPetModel then
    self.loadingPetModel:K2_DestroyActor()
    self.loadingPetModel = nil
  end
  self.loadingPetGid = 0
end

function UMG_PlantProtectionMain_C:OnPetModelLoaded(InQueue, bSuccess)
  if bSuccess then
    local asset = InQueue:Get("PetModel")
    local params = {}
    params.inBattle = true
    local petModel = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(asset, UE4.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil, nil, params)
    if not petModel then
      return
    end
    self.loadingPetModel = petModel
    petModel:SetLoadPriority(PriorityEnum.UI_Pet_Mutation)
    if self.currentSelectPet then
      PetMutationUtils.PrepareMutationAssets(petModel, self.currentSelectPet.data)
    end
    petModel:InitOutSceneAsync(self, self.OnInitOutSceneComplete)
  else
    Log.Error("UMG_PlantProtectionMain_C:OnPetModelLoaded \229\138\160\232\189\189\229\164\177\232\180\165\228\186\134")
  end
end

function UMG_PlantProtectionMain_C:OnInitOutSceneComplete(petModel)
  if self.currentSelectPet and self.currentSelectPet.data then
    local heightModelScale = PetMutationUtils.GetHeightModelScaleByPetData(self.currentSelectPet.data)
    UE.UNRCCharacterUtils.SetCharacterMeshScale(petModel, heightModelScale)
    PetMutationUtils.DoMutation(petModel, self.currentSelectPet.data)
  else
    self:OnPetGenerateDone(petModel, false)
  end
end

function UMG_PlantProtectionMain_C:OnPetMutationDone(character)
  if not self.loadingPetModel or not character then
    return
  end
  if self.loadingPetModel == character then
    self:OnPetGenerateDone(self.loadingPetModel, true)
  end
end

function UMG_PlantProtectionMain_C:OnPetGenerateDone(petModel, bLegal)
  self:LockItemClick(false)
  if self.currentPetModel then
    self.currentPetModel:K2_DestroyActor()
    self.currentPetModel = nil
    self.currentPetGid = 0
  end
  self.loadingPetModel = nil
  self.loadingPetGid = 0
  if petModel then
    if bLegal then
      self.currentPetModel = petModel
      self.currentPetGid = self.selectGid
      petModel:SetActorEnableCollision(false)
      self:SetPetAndRocoPosition(petModel)
    else
      petModel:K2_DestroyActor()
    end
  end
end

function UMG_PlantProtectionMain_C:SetPetAndRocoPosition(petModel)
  if petModel then
    local PetPosition = UE4.FVector(0, 0, 0 + (petModel:GetHalfHeight() or 0))
    local PetRotation = UE4.FRotator(0, 69, 0)
    self:SetPosAndLockOnGround(petModel, PetPosition, PetRotation)
  end
end

function UMG_PlantProtectionMain_C:SetPosAndLockOnGround(Model, Position, Rotation)
  if not self.data.NPCActionOpenGuard then
    return
  end
  local npcViewObj = self.data.NPCActionOpenGuard:GetOwnerNPCView()
  if not npcViewObj then
    return
  end
  local MeshComponent = npcViewObj:K2_GetRootComponent()
  local RootComponent = Model:K2_GetRootComponent()
  RootComponent:K2_AttachToComponent(MeshComponent, "None", UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld)
  RootComponent:K2_SetRelativeLocation(Position, false, nil, false)
  RootComponent:K2_SetRelativeRotation(Rotation, false, nil, false)
  local ModelLocation = Model:Abs_GetTransform().Translation
  local ModelUnderLocation = ModelLocation
  local UnderLineBegin = UE4.FVector(ModelLocation.X, ModelLocation.Y, ModelLocation.Z + 500)
  local UnderLineEnd = UE4.FVector(ModelLocation.X, ModelLocation.Y, ModelLocation.Z - 500)
  local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel5)
  local Hits, Success = UE4.UKismetSystemLibrary.Abs_LineTraceMulti(_G.UE4Helper.GetCurrentWorld(), UnderLineBegin, UnderLineEnd, TraceChannel, false, nil, 0, nil)
  if Success then
    for _, Result in tpairs(Hits) do
      ModelUnderLocation.X = Result.ImpactPoint.X
      ModelUnderLocation.Y = Result.ImpactPoint.Y
      ModelUnderLocation.Z = Result.ImpactPoint.Z + Model:GetHalfHeight()
      break
    end
  end
  Model:Abs_K2_SetActorLocation_WithoutHit(ModelUnderLocation)
  Model:K2_DetachFromActor(UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld)
end

function UMG_PlantProtectionMain_C:OnHomePlantGuardUpdate()
  if not self.curPetDatas then
    return
  end
  for idx, petData in ipairs(self.curPetDatas) do
    local previousInGuard = petData.isInGuard
    petData.isInGuard = self:IsGuardingHomePlant(petData.gid)
    if previousInGuard ~= petData.isInGuard then
      local itemWidget = self.GridView1:GetItemByIndex(idx - 1)
      if itemWidget and itemWidget.ShowPetStatus then
        itemWidget:ShowPetStatus()
      end
      if petData.gid == self.selectGid then
        self:DispatchEvent(HomeModuleEvent.UpdateGuardDetailPanel)
      end
    end
  end
end

function UMG_PlantProtectionMain_C:OnDetailPanelShow(lifeCycle)
  if not lifeCycle then
    return
  end
  if 0 == lifeCycle then
    self.PromptText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 1 == lifeCycle then
    self:PlayAnimation(self.Plant_open)
    self.PromptText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif 2 == lifeCycle then
    self.PromptText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PlantProtectionMain_C:UpdatePetCollect(partner_mark)
  if not self.currentSelectPet or not self.currentSelectPet.data then
    return
  end
  if partner_mark == self.currentSelectPet.data.partner_mark then
    return
  end
  self.currentSelectPet.data.partner_mark = partner_mark
  local widget = self.GridView1:GetItemByIndex(self.curPetListSelectIndex - 1)
  if widget and widget.UpdatePartnerMark then
    widget:UpdatePartnerMark()
  end
end

function UMG_PlantProtectionMain_C:ItemClickChecker(item, index, userClick)
  if not userClick then
    return
  end
  return not self.bLockItemClick
end

function UMG_PlantProtectionMain_C:UpdateUIAnySelectable(bHavePetToSelect)
  if bHavePetToSelect then
    if self.CanvasPanel_63 then
      self.CanvasPanel_63:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.CanvasPanel_98 then
      self.CanvasPanel_98:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.CanvasPanel_142 then
      self.CanvasPanel_142:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Empty then
      self.Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    if self.CanvasPanel_63 then
      self.CanvasPanel_63:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.CanvasPanel_98 then
      self.CanvasPanel_98:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.CanvasPanel_142 then
      self.CanvasPanel_142:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.Empty then
      self.Empty:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

return UMG_PlantProtectionMain_C
