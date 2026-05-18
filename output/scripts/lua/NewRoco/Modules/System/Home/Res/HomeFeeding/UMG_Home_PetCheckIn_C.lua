local PetUtils = require("NewRoco.Utils.PetUtils")
local HomeModuleEvent = require("NewRoco/Modules/System/Home/HomeModuleEvent")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local CommonBtnEnum = require("NewRoco.Modules.System.CommonBtn.CommonBtnEnum")
local UMG_Home_PetCheckIn_C = _G.NRCPanelBase:Extend("UMG_Home_PetCheckIn_C")

function UMG_Home_PetCheckIn_C:OnConstruct()
  self.homePetPreviewPanel:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Home_PetCheckIn_C:InitSortComboBox()
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
    sortInfo.ComType = CommonBtnEnum.ComboBoxType.PetFeeding
    sortInfo.isHideRedDot = true
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
  commonDropDownListData.ComType = CommonBtnEnum.ComboBoxType.PetFeeding
  self.ComboBox:SetPanelInfo(commonDropDownListData)
end

function UMG_Home_PetCheckIn_C:OnEnable(furnitureId)
  if furnitureId then
    self.currentFurnitureId = furnitureId
  end
end

function UMG_Home_PetCheckIn_C:OnActive(furnitureId)
  _G.NRCAudioManager:PlaySound2DAuto(40008035, "UMG_Home_PetCheckIn_C:OnActive")
  self:PlayAnimation(self.In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  self.hasFilter = false
  if furnitureId then
    self.currentFurnitureId = furnitureId
  end
  self.petInfoList = nil
  self.curPetDatas = nil
  self.isReversalSort = false
  self.currentIndex = 1
  self.curPetListSelectIndex = 1
  self.chooseTypeList = {
    DepartmentFilter = {},
    TalentFilter = {},
    NaturePositiveEffectFilter = {},
    AttributeFilter = {},
    PartnerMarkerFilter = {},
    SpecialityFilter = {}
  }
  self.currentSelectPet = nil
  self.selectGid = nil
  self.petInfos = self:GetPetInfo()
  self.curPetDatas = self.petInfos
  self:SetCommonTitle()
  self:InitSortComboBox()
  self:UpdateSelectAndShowModel()
end

function UMG_Home_PetCheckIn_C:SortPetLevel(datas)
  table.sort(datas, function(a, b)
    if a.sortNum == b.sortNum then
      if a.speciality_priority == b.speciality_priority then
        if a.level == b.level then
          return a.gid < b.gid
        else
          return a.level > b.level
        end
      else
        return a.speciality_priority < b.speciality_priority
      end
    else
      return a.sortNum < b.sortNum
    end
  end)
  return datas
end

function UMG_Home_PetCheckIn_C:SortPetTime(datas)
  table.sort(datas, function(a, b)
    if a.sortNum == b.sortNum then
      if a.speciality_priority == b.speciality_priority then
        if a.addTime == b.addTime then
          return a.gid < b.gid
        else
          return a.addTime > b.addTime
        end
      else
        return a.speciality_priority < b.speciality_priority
      end
    else
      return a.sortNum < b.sortNum
    end
  end)
  return datas
end

function UMG_Home_PetCheckIn_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn_1.btnClose, self.OnCloseBtnClicked)
  self:AddButtonListener(self.CheckIn.btnLevelUp, self.OnLivePetConfirm)
  self:AddButtonListener(self.BtnUnfold.btnLevelUp, self.OnShowPetDetail)
  _G.NRCEventCenter:RegisterEvent("UMG_HomePetChoose_C", self, HomeModuleEvent.OnSelectLivePetFilter, self.OnShowPetWithOrder)
  _G.NRCEventCenter:RegisterEvent("UMG_HomePetChoose_C", self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
end

function UMG_Home_PetCheckIn_C:OpenFilterPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Home_PetCheckIn_C:OpenFilterPanelBtnClick")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenFilterPanel, PetUIModuleEnum.OpenSortType.HomePetFeeding, {
    HiddenParam = nil,
    chooseTypeList = self.chooseTypeList
  })
end

function UMG_Home_PetCheckIn_C:ReversePetList()
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
  local TopPetList = {}
  local petList = {}
  if not self.curPetDatas then
    Log.Error("self.curPetDatas nil")
    return
  end
  for i = 1, #self.curPetDatas do
    if 0 ~= self.curPetDatas[i].sortNum and self.curPetDatas[i].sortNum ~= -999 then
      table.insert(otherPetList, self.curPetDatas[i])
    elseif self.curPetDatas[i].sortNum == -999 then
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
  self.GridView1:DeselectItemByIndex(self.curPetListSelectIndex)
  self.GridView1:InitList(self.curPetDatas)
  self.GridView1:SelectItemByIndex(0)
end

function UMG_Home_PetCheckIn_C:OnReversePetList()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Home_PetCheckIn_C:OnReversePetList")
  self:ReversePetList()
  self.IsReversalSort = not self.IsReversalSort
end

function UMG_Home_PetCheckIn_C:OnShowPetWithOrder(uiIndex, dataList)
  Log.Debug("UMG_Home_PetCheckIn_C OnShowPetFilter invoked uiIndex: ", uiIndex, ", sequence", dataList)
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
  self.GridView1:DeselectItemByIndex(self.curPetListSelectIndex)
  self.GridView1:InitList(self.curPetDatas)
  self.GridView1:SelectItemByIndex(0)
end

function UMG_Home_PetCheckIn_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
  _G.NRCEventCenter:UnRegisterEvent(self, HomeModuleEvent.OnSelectLivePetFilter, self.OnShowPetWithOrder)
end

function UMG_Home_PetCheckIn_C:OnCloseBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Home_Property_C:OnCloseBtnClicked")
  self:PlayAnimation(self.Out, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end

function UMG_Home_PetCheckIn_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:DispatchEvent(HomeModuleEvent.ClosePetLivePanel)
    self:DoClose()
  end
end

function UMG_Home_PetCheckIn_C:SwitchRightPanel(bClear)
  if bClear then
    self.CanvasPanel_63:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_63:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Home_PetCheckIn_C:ShowPetPreview()
  if not self.currentSelectPet then
    self:SwitchRightPanel(true)
    return
  end
  self:SwitchRightPanel(false)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.currentSelectPet.base_conf_id)
  if not petBaseConf then
    return
  end
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  local modelPath = modelConf.path
  self.homePetPreviewPanel:SetPetPreview(self, self.currentSelectPet.base_conf_id, self.mutationType, self.glassInfo)
end

function UMG_Home_PetCheckIn_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
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

function UMG_Home_PetCheckIn_C:OnScrollPetItemSelected(item, index)
  self.curPetListSelectIndex = index
  if not (item and item.petInfo) or not item.petData then
    return
  end
  self.currentSelectPet = item.petData
  if not item.petInfo.base_conf_id then
    return
  end
  self.selectGid = item.petInfo.gid
  if item.petData then
    self.mutationType = item.petData.mutation_type
    self.glassInfo = item.petData.glass_info
  end
  self:SetNameInfo(item.petData)
  self:DispatchEvent(HomeModuleEvent.SwitchDetailPanelData, self.currentSelectPet, self.currentFurnitureId)
end

function UMG_Home_PetCheckIn_C:UpdateSelectAndShowModel()
  if not self.petInfos then
    Log.Warning("No pet with player")
    self:DoClose()
    return
  end
  self.curPetListSelectIndex = 1
  if not self.hasFilter and not self.currentSelectPet and #self.petInfos > 0 then
    self.currentSelectPet = self.petInfos[self.curPetListSelectIndex].data
    self.GridView1:SelectItemByIndex(0)
  end
  self.selectGid = self.currentSelectPet.gid
  if self.currentSelectPet.base_conf_id then
    self:SetNameInfo(self.currentSelectPet)
  end
end

function UMG_Home_PetCheckIn_C:InitSort()
  local datas = self:SortPetLevel(self.petInfos)
  self.curPetDatas = datas
  if #self.curPetDatas > 0 then
    self.currentSelectPet = self.curPetDatas[1]
  end
  self:InitSortComboBox()
  self:OnShowPetWithOrder(1, nil)
  if datas then
    self.GridView1:InitList(datas[1])
  end
end

function UMG_Home_PetCheckIn_C:OnDestruct()
  Log.Debug("UMG_Home_PetCheckIn_C Destruct invoked")
end

function UMG_Home_PetCheckIn_C:OnDeactive()
  self.hasFilter = false
  self:OnRemoveEventListener()
  self.chooseTypeList = {
    DepartmentFilter = {},
    TalentFilter = {},
    NaturePositiveEffectFilter = {},
    AttributeFilter = {},
    PartnerMarkerFilter = {},
    SpecialityFilter = {}
  }
end

function UMG_Home_PetCheckIn_C:OnShowPetDetail()
  if self.currentSelectPet and self.currentFurnitureId then
    _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_Home_Property_C:OnActive")
    _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnCmdOpenPanel, "HomePetDetail", true, self.currentSelectPet, self.currentFurnitureId)
  end
end

function UMG_Home_PetCheckIn_C:OnLivePetConfirm()
  if not (self.selectGid and self.currentSelectPet) or not self.currentFurnitureId then
    Log.Error("no valid pet chosen :", self.selectGid, "or invalid nest:", self.currentFurnitureId)
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Home_Property_C:OnLivePetConfirm")
  _G.NRCModuleManager:DoCmd(HomeModuleCmd.ConfirmPetLive, self.selectGid, self.currentFurnitureId)
end

function UMG_Home_PetCheckIn_C:SetNameInfo(petData)
  local petDataInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petData.gid)
  if not petDataInfo then
    return
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  local nameInfoTable = {}
  local petType = petBaseConf.unit_type
  if table.len(petType) < 1 then
    return
  end
  for i = 1, table.len(petType) do
    if not petType[i] then
      break
    end
    local typeDic = _G.DataConfigManager:GetTypeDictionary(petType[i])
    if typeDic then
      table.insert(nameInfoTable, {
        Name = typeDic.short_name,
        Path = typeDic.type_icon
      })
    end
  end
  local petBloodConf = _G.DataConfigManager:GetPetBloodConf(petData.blood_id)
  if petBloodConf then
    table.insert(nameInfoTable, {
      Name = petBloodConf.blood_name,
      Path = petBloodConf.icon
    })
  end
  if nameInfoTable then
    self.AttrList:InitGridView(nameInfoTable)
  end
  self.CatchHardLv:Clear()
  local PetStarsList = PetUtils.GetPetStarsListByPetGID(petData.gid)
  self.CatchHardLv:InitGridView(PetStarsList)
  self.textPetName:SetText(petData.name)
end

function UMG_Home_PetCheckIn_C:GetChangeAttrReqEnum(attribute)
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

function UMG_Home_PetCheckIn_C:HasGid(gid, table)
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

function UMG_Home_PetCheckIn_C:OnFilterPet(typeChooseList)
  if self.curSortId > 0 then
    local datas
    self:OnShowPetWithOrder(self.curSortId, nil)
    if self.curSortId == Enum.PetSequenceSwitch.SEQUENCE_LEVEL_UP then
      datas = self:SortPetLevel(self.petInfos)
      self.curPetDatas = datas
    elseif self.curSortId == Enum.PetSequenceSwitch.SEQUENCE_CATCH_UP then
      datas = self:SortPetTime(self.petInfos)
      self.curPetDatas = datas
    end
    if self.isReversalSort then
      self:ReversePetList()
    end
  end
  local genderFilter = {}
  local genderList = {}
  if typeChooseList.GenderFilter then
    for i, v in pairs(typeChooseList.GenderFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(genderFilter, enum)
      end
    end
  end
  if #genderFilter > 0 then
    if not self.curPetDatas or #self.curPetDatas < 1 then
      return
    end
    for i = 1, #self.curPetDatas do
      if self.curPetDatas[i] and self.curPetDatas[i].gender then
        for j = 1, #genderFilter do
          if self.curPetDatas[i].gender == genderFilter[j] then
            table.insert(genderList, self.curPetDatas[i])
          end
        end
      end
    end
  else
    genderList = self.curPetDatas
  end
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
    if not genderList or #genderList < 1 then
      return
    end
    for i = 1, #genderList do
      if genderList[i] then
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(genderList[i].base_conf_id)
        for k = 1, #petBaseConf.unit_type do
          for j = 1, #departmentFilter do
            if petBaseConf.unit_type[k] == departmentFilter[j] and not self:HasGid(genderList[i].gid, departList) then
              table.insert(departList, genderList[i])
            end
          end
        end
      end
    end
  else
    departList = genderList
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
  if #genderFilter <= 0 and #departmentFilter <= 0 and #talentFilter <= 0 and #naturePositiveEffectFilter <= 0 and #attributeFilter <= 0 and #PartnerMarkerFilter <= 0 and #SpecialityFilter <= 0 then
    self.curPetDatas = self.petInfos
    SpecialityList = self.petInfos
  elseif SpecialityList then
    self.curPetDatas = SpecialityList
  end
  if SpecialityList[self.curPetListSelectIndex] and SpecialityList[self.curPetListSelectIndex].data then
    self.currentSelectPet = SpecialityList[self.curPetListSelectIndex].data
  else
    local index = self:LastPetData(PartnerMarkerFilter)
    if SpecialityList[index] and SpecialityList[index].data then
      self.currentSelectPet = SpecialityList[index].data
    elseif self.curPetDatas and #self.curPetDatas > 0 then
      self.currentSelectPet = self.curPetDatas[1]
    else
      self.currentSelectPet = nil
    end
  end
  _G.NRCViewBase:DelayFrames(1, function()
    self.GridView1:DeselectItemByIndex(self.curPetListSelectIndex)
    self.GridView1:InitList(SpecialityList)
    if self.curSortId > 0 then
      self:OnShowPetWithOrder(self.curSortId, nil)
    end
    self:UpdateSelectAndShowModel()
    self.GridView1:SelectItemByIndex(0)
  end)
end

function UMG_Home_PetCheckIn_C:LastPetData(petDataList)
  for i, v in ipairs(petDataList) do
    if v.data == nil then
      return i
    else
      return i - 1
    end
  end
  return #petDataList
end

function UMG_Home_PetCheckIn_C:GetAdvantageNum(types)
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

function UMG_Home_PetCheckIn_C:UpdateCollect(partner_mark)
  if not self.currentSelectPet or self.currentSelectPet.partner_mark == partner_mark then
    return
  end
  self.currentSelectPet.partner_mark = partner_mark
  if self.curPetListSelectIndex then
    self.GridView1:OpItemByIndex(self.curPetListSelectIndex, {
      type = 0,
      curPetData = self.currentSelectPet
    })
  end
end

function UMG_Home_PetCheckIn_C:IsPetInTravel(gid)
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

function UMG_Home_PetCheckIn_C:IsPetFinishTravel(gid)
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

function UMG_Home_PetCheckIn_C:IsInHome(gid)
  local res = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetPetIsInHome, gid)
  return res
end

function UMG_Home_PetCheckIn_C:GetSortNum(petData)
  local sortNum = 0
  if not petData.isTeam and not petData.isBattleTeam and not petData.isTravel and not petData.isInHome and not petData.isInGuard and 3 ~= petData.speciality_type then
    sortNum = 0
  elseif not petData.isTravel == false and not petData.IsTravelFinish then
    sortNum = 1
  elseif petData.isTravel and petData.IsPetFinishTravel then
    sortNum = 2
  elseif petData.isInGuard then
    sortNum = 3
  elseif petData.isInHome then
    sortNum = 4
  elseif petData.isBattleTeam then
    sortNum = 5
  elseif petData.isTeam then
    sortNum = 6
  elseif 3 == petData.speciality_type then
    sortNum = -999
  end
  return sortNum
end

function UMG_Home_PetCheckIn_C:CreatePetTeamData()
  local teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
  local teamGids = {}
  local battleTeamGids = {}
  if not teamInfo.teams then
    return teamGids, battleTeamGids
  end
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

function UMG_Home_PetCheckIn_C:CreatePetDatas(petList)
  local petDatas = {}
  if not petList or 0 == table.len(petList) then
    return petDatas
  end
  local guardingPetGid = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePlantGuardPetGid) or 0
  for i = 1, #petList do
    local teamGids, battleTeamGids = self:CreatePetTeamData()
    local petInfo = petList[i]
    local petData = {}
    petData.gid = petInfo.gid
    local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(petInfo.speciality_id)
    petData.speciality_type = PetTalentConf and PetTalentConf.type
    petData.speciality_priority = 3 == petData.speciality_type and PetTalentConf and PetTalentConf.priority or 0
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
    petData.isInGuard = petInfo.gid == guardingPetGid
    petData.sortNum = self:GetSortNum(petData)
    petData.data = petInfo
    local isExchange = petInfo.pet_status_flags and petInfo.pet_status_flags & _G.ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
    if not isExchange then
      table.insert(petDatas, petData)
    end
  end
  return petDatas
end

function UMG_Home_PetCheckIn_C:GetPetInfo()
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

return UMG_Home_PetCheckIn_C
