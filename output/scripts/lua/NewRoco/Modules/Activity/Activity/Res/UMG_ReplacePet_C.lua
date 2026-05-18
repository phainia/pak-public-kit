local UMG_ReplacePet_C = _G.NRCPanelBase:Extend("UMG_ReplacePet_C")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local CommonBtnEnum = require("NewRoco.Modules.System.CommonBtn.CommonBtnEnum")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetListRefreshReason = {
  Init = 1,
  SortChange = 2,
  ReversalSort = 3,
  Filter = 4
}
local FilterType = {
  DepartmentFilter = 1,
  TalentFilter = 2,
  NaturePositiveEffectFilter = 3,
  AttributeFilter = 4,
  PartnerMarkerFilter = 5,
  SpecialityFilter = 6
}

function UMG_ReplacePet_C:OnConstruct()
  self:SetChildViews(self.PetBaseInfo)
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.OnClickCloseBtn)
  self:AddButtonListener(self.FullScreenBtn, self.OnClickCollapsedCombBoxPopUp)
  _G.NRCEventCenter:RegisterEvent("UMG_ReplacePet_C", self, PetUIModuleEvent.FilterPetInherit, self.OnFilterPet)
  self.chooseTypeList = {
    DepartmentFilter = {},
    TalentFilter = {},
    NaturePositiveEffectFilter = {},
    AttributeFilter = {}
  }
  self.DescribeText:SetText(_G.LuaText.warehouse_filter_no_pet)
  self:SetCommonTitle()
  self:InitSortComboBox()
end

function UMG_ReplacePet_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.FilterPetInherit, self.OnFilterPet)
end

function UMG_ReplacePet_C:OnActive(petDataList, activityInst, partId)
  self.activityInst = activityInst
  self.partId = partId
  self.petDataList = petDataList
  local onSelectCallback = _G.MakeWeakFunctor(self, self.OnSelectPet)
  for _, petData in ipairs(petDataList) do
    petData.onSelectCallback = onSelectCallback
  end
  self:RefreshShowPetList(PetListRefreshReason.Init)
end

function UMG_ReplacePet_C:OnDeactive()
end

function UMG_ReplacePet_C:OnClickCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_ReplacePet_C:OnClickCloseBtn")
  self:OnClose()
end

function UMG_ReplacePet_C:SetCommonTitle()
  local titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  if titleConf then
    self.Title1:Set_MainTitle(titleConf.title)
    self.Title1:SetBg(titleConf.head_icon)
    self.Title1:SetSubtitle(titleConf.subtitle[1].subtitle)
  end
end

function UMG_ReplacePet_C:OnClickCollapsedCombBoxPopUp()
  self.ComboBox:SetPopupVisible(false)
  self.FullScreenBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ReplacePet_C:OnChangeComboBoxSort(sortId)
  self.curSortId = sortId
  self:RefreshShowPetList(PetListRefreshReason.SortChange)
end

function UMG_ReplacePet_C:InitSortComboBox()
  local sortList = {}
  for i = 1, 2 do
    local conf = _G.DataConfigManager:GetTravelSequenceConf(i)
    if conf then
      local sortInfo = {}
      sortInfo.name = conf.sequence_desc
      sortInfo.ComType = CommonBtnEnum.ComboBoxType.InheritanceReplacePet
      sortInfo.OnSelectDelegate = _G.MakeWeakFunctor(self, self.OnChangeComboBoxSort, conf.sequence_default)
      table.insert(sortList, sortInfo)
    end
  end
  local currentIndex = 1
  local commonDropDownListData = _G.NRCCommonDropDownListData()
  commonDropDownListData.DropDownListInfo = sortList
  commonDropDownListData.DropDownListText = sortList[currentIndex] and sortList[currentIndex].name or ""
  commonDropDownListData.Call = self
  commonDropDownListData.Btn_LeftHandler = self.OnClickOpenFilterPanel
  commonDropDownListData.Btn_RightHandler = self.OnClickReversePetList
  commonDropDownListData.DropDownListIndex = currentIndex
  commonDropDownListData.ComType = CommonBtnEnum.ComboBoxType.InheritanceReplacePet
  self.ComboBox:SetPanelInfo(commonDropDownListData)
  self.ComboBox.OnPopupVisibilityChanged = _G.MakeWeakFunctor(self, self.OnComboBoxPopupVisibilityChanged)
  self:OnComboBoxPopupVisibilityChanged(false)
end

function UMG_ReplacePet_C:OnComboBoxPopupVisibilityChanged(bShow)
  if bShow then
    self.FullScreenBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.FullScreenBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ReplacePet_C:OnClickOpenFilterPanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_ReplacePet_C:OnClickOpenFilterPanel")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenFilterPanel, PetUIModuleEnum.OpenSortType.PetInheritance, {
    HiddenParam = nil,
    chooseTypeList = self.chooseTypeList
  })
end

function UMG_ReplacePet_C:OnClickReversePetList()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_ReplacePet_C:OnClickReversePetList")
  self.isReversalSort = not self.isReversalSort
  self:RefreshShowPetList(PetListRefreshReason.ReversalSort)
end

function UMG_ReplacePet_C:SortPetData(petDataList, sortId, isReversal)
  local sortImpl
  if sortId == Enum.PetSequenceDefault.SEQUENCE_LEVEL_DOWN then
    function sortImpl(a, b)
      if a.level ~= b.level then
        return a.level > b.level
      end
    end
  elseif sortId == Enum.PetSequenceDefault.SEQUENCE_CATCH_DOWN then
    function sortImpl(a, b)
      if a.addTime ~= b.addTime then
        return a.addTime > b.addTime
      end
    end
  end
  if sortImpl then
    table.sort(petDataList, function(a, b)
      if a.sortNum == b.sortNum then
        local sortRet = sortImpl(a, b)
        if nil == sortRet then
          if a.gid == b.gid then
            return false
          elseif isReversal then
            return a.gid > b.gid
          end
          return a.gid < b.gid
        else
          if isReversal then
            return not sortRet
          end
          return sortRet
        end
      else
        return a.sortNum < b.sortNum
      end
    end)
  end
end

function UMG_ReplacePet_C:RefreshShowPetList(reason)
  local petDataList = self.petDataList
  if not petDataList then
    return
  end
  if reason == PetListRefreshReason.Init then
    self.showPetDataList = table.new(#petDataList, 0)
    local showPetDataList = self.showPetDataList
    table.copy(petDataList, showPetDataList)
    self:SortPetData(showPetDataList, self.curSortId, self.isReversalSort)
    self.GridView1:InitList(showPetDataList)
  else
    local showPetDataList = self.showPetDataList
    if showPetDataList then
      self:SortPetData(showPetDataList, self.curSortId, self.isReversalSort)
      self.GridView1:InitList(showPetDataList, self.GridView1:GetTotalItemNumber() == #showPetDataList)
    end
  end
  if self.GridView1:GetTotalItemNumber() > 0 then
    self.EmptyState:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.EmptyState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.GridView1:SelectItemByIndex(0)
end

function UMG_ReplacePet_C:OnFilterPet(typeChooseList)
  self.chooseTypeList = typeChooseList
  local petDataList = self.petDataList
  if not petDataList then
    return
  end
  self.showPetDataList = table.new(#petDataList, 0)
  local showPetDataList = self.showPetDataList
  table.copy(petDataList, showPetDataList)
  
  local function GetFilterDic(filterValues, filterType)
    if not filterValues then
      return
    end
    local filterDic = {}
    for _, v in pairs(filterValues) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum
        if filterType ~= FilterType.SpecialityFilter then
          enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        else
          enum = v.data.filter_enum_value
        end
        filterDic[enum] = true
      end
    end
    return filterDic
  end
  
  local function FilterProxy(petList, filterDic, filterFunc)
    local hasFilterConf = filterDic and next(filterDic) ~= nil
    if hasFilterConf and petList and filterFunc then
      for i = #petList, 1, -1 do
        if filterFunc(petList[i].PetData, filterDic) then
          table.remove(petList, i)
        end
      end
    end
  end
  
  FilterProxy(showPetDataList, GetFilterDic(typeChooseList.DepartmentFilter, FilterType.DepartmentFilter), function(petData, departmentFilter)
    local isFilter = true
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    for _, unitType in ipairs(petBaseConf.unit_type) do
      if departmentFilter[unitType] then
        isFilter = false
        break
      end
    end
    return isFilter
  end)
  FilterProxy(showPetDataList, GetFilterDic(typeChooseList.TalentFilter, FilterType.TalentFilter), function(petData, talentFilter)
    return not talentFilter[petData.talent_rank]
  end)
  FilterProxy(showPetDataList, GetFilterDic(typeChooseList.NaturePositiveEffectFilter, FilterType.NaturePositiveEffectFilter), function(petData, naturePositiveEffectFilter)
    local naturePositive = petData.changed_nature_pos_attr_type
    if not naturePositive or 0 == naturePositive then
      naturePositive = _G.DataConfigManager:GetNatureConf(petData.nature).positive_effect
    elseif naturePositive == Enum.AttributeType.AT_HPMAX then
      naturePositive = Enum.AttributeType.AT_HPMAX_PERCENT
    elseif naturePositive == Enum.AttributeType.AT_PHYATK then
      naturePositive = Enum.AttributeType.AT_PHYATK_PERCENT
    elseif naturePositive == Enum.AttributeType.AT_SPEATK then
      naturePositive = Enum.AttributeType.AT_SPEATK_PERCENT
    elseif naturePositive == Enum.AttributeType.AT_PHYDEF then
      naturePositive = Enum.AttributeType.AT_PHYDEF_PERCENT
    elseif naturePositive == Enum.AttributeType.AT_SPEDEF then
      naturePositive = Enum.AttributeType.AT_SPEDEF_PERCENT
    elseif naturePositive == Enum.AttributeType.AT_SPEED then
      naturePositive = Enum.AttributeType.AT_SPEED_PERCENT
    end
    return not naturePositiveEffectFilter[naturePositive]
  end)
  FilterProxy(showPetDataList, GetFilterDic(typeChooseList.AttributeFilter, FilterType.AttributeFilter), function(petData, attributeFilter)
    local isFilter = true
    local petAttr = petData.attribute_info
    if petAttr then
      for attr, _ in pairs(attributeFilter) do
        if attr == _G.Enum.AttributeType.AT_HPMAX and petAttr.hp and petAttr.hp.talent and petAttr.hp.talent > 0 then
          isFilter = false
          break
        end
        if attr == _G.Enum.AttributeType.AT_PHYATK and petAttr.attack and petAttr.attack.talent and petAttr.attack.talent > 0 then
          isFilter = false
          break
        end
        if attr == _G.Enum.AttributeType.AT_SPEATK and petAttr.special_attack and petAttr.special_attack.talent and petAttr.special_attack.talent > 0 then
          isFilter = false
          break
        end
        if attr == _G.Enum.AttributeType.AT_PHYDEF and petAttr.defense and petAttr.defense.talent and petAttr.defense.talent > 0 then
          isFilter = false
          break
        end
        if attr == _G.Enum.AttributeType.AT_SPEDEF and petAttr.special_defense and petAttr.special_defense.talent and petAttr.special_defense.talent > 0 then
          isFilter = false
          break
        end
        if attr == _G.Enum.AttributeType.AT_SPEED and petAttr.speed and petAttr.speed.talent and petAttr.speed.talent > 0 then
          isFilter = false
          break
        end
      end
    end
    return isFilter
  end)
  FilterProxy(showPetDataList, GetFilterDic(typeChooseList.PartnerMarkerFilter, FilterType.PartnerMarkerFilter), function(petData, partnerMarkerFilter)
    return not partnerMarkerFilter[petData.partner_mark]
  end)
  FilterProxy(showPetDataList, GetFilterDic(typeChooseList.SpecialityFilter, FilterType.SpecialityFilter), function(petData, specialityFilter)
    local isFilter = true
    local petTalentConf = _G.DataConfigManager:GetPetTalentConf(petData.speciality_id)
    if petTalentConf then
      isFilter = not specialityFilter[petTalentConf.filter_enum_value]
    end
    return isFilter
  end)
  self:RefreshShowPetList(PetListRefreshReason.Filter)
end

function UMG_ReplacePet_C:OnSelectPet(bSelected, petData)
  if not bSelected then
    return
  end
  self.PetBaseInfo:SetPetInfo(petData.PetData)
  local btnText = _G.LuaText.INHERITANCE_8
  local itemData = self.activityInst and self.activityInst:GetPartItemData(self.partId)
  if itemData and itemData.selectedPetData and itemData.selectedPetData.gid == petData.gid then
    btnText = _G.LuaText.INHERITANCE_9
  end
  self.PetBaseInfo:SetOneButtonWithoutRedpoint(btnText, self, self.OnConfirmSelectPet, petData)
end

function UMG_ReplacePet_C:OnConfirmSelectPet(petData)
  if not petData then
    return
  end
  local activityInst = self.activityInst
  if activityInst then
    activityInst:SendZoneChooseInheritPetReq(self.partId, petData.gid)
  end
  self:OnClose()
end

return UMG_ReplacePet_C
