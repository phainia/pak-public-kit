local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local FreeRewardConf = _G.DataConfigManager:GetAllByName("PET_FREE_REWARD_CONF")
local UMG_PetWareHouseFree_C = _G.NRCPanelBase:Extend("UMG_PetWareHouseFree_C")

function UMG_PetWareHouseFree_C:OnConstruct()
  self:SetChildViews(self.UMG_PetRate, self.CommonPetDetails)
end

function UMG_PetWareHouseFree_C:OnActive(Action)
  self.data = self.module:GetData("PetUIModuleData")
  self.Action = Action
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self.IsReversedSort = false
  self.FreeLimit = _G.DataConfigManager:GetPetGlobalConfig("pet_depot_release_maximun").num
  self.descText = {}
  self.PetFreeAward = {}
  self.skillId = nil
  self.SortIndex = _G.Enum.PetSequenceDefault.SEQUENCE_LEVEL_DOWN
  self:UpdateInfo()
  self:DelayFrames(1, function()
    UE4Helper.SetEnableWorldRendering(false)
  end)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  self.ComboBox:ShowOrHideBtnMid(false)
  self:SetCommonTitle()
  self:SetCommonComboBoxInfo(self.ComboBox)
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.HideDialogueOverlay)
  self:UpdateFreeBtnClick()
  self:OnAddEventListener()
  self:RefreshFreeNumText()
end

function UMG_PetWareHouseFree_C:SetCommonComboBoxInfo(ComboBox, ComboBoxText, ComboBoxIcon)
  local CommonDropDownListData = _G.NRCCommonDropDownListData()
  if ComboBoxText then
    CommonDropDownListData.DropDownListText = ComboBoxText
  end
  if ComboBoxIcon then
    CommonDropDownListData.DropDownListIcon = ComboBoxIcon
  end
  CommonDropDownListData.Call = self
  CommonDropDownListData.Btn_LeftHandler = self.OpenFilterPanelBtnClick
  CommonDropDownListData.Btn_RightHandler = self.OnReversedSort
  ComboBox:SetPanelInfo(CommonDropDownListData)
end

function UMG_PetWareHouseFree_C:EliminateFreePetNum(_PetData)
  local PetData = _PetData
  local PetList = {}
  if PetData then
    for i, PetInfo in ipairs(PetData) do
      local isExchange = PetInfo.pet_status_flags and PetInfo.pet_status_flags & ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
      local isTaskLock = PetInfo.pet_status_flags and PetInfo.pet_status_flags & ProtoEnum.PetStatusFlag.TASK_FORCE_LOCK > 0
      if not isExchange and not isTaskLock then
        table.insert(PetList, PetInfo)
      end
    end
  end
  return #PetList
end

function UMG_PetWareHouseFree_C:UpdateInfo(NotClearFreeList)
  if not NotClearFreeList then
    table.clear(self.FreeList)
    self.FreeList = {}
  end
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local petData = self:EliminateFreePet(petInfoList)
  self.TalentList1 = {}
  self.TalentList2 = {}
  self.TalentList3 = {}
  self.TalentList4 = {}
  self.PetNumLimit = _G.DataConfigManager:GetPetGlobalConfig("pet_depot_number_max").num
  self.PetNum = #petData
  self.FreeText:SetText(LuaText.store_release_quantity_tips .. self.PetNum)
  local MainTeamNum = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetNum()
  local TemporarilyStoreBackpackNum = _G.DataModelMgr.PlayerDataModel:GetTemporarilyStoreBackpackPetNum()
  local PetWareHouse = self:EliminatePetWareHouseNum(petInfoList.pet_data)
  self.UpperLimit:InitNum(PetWareHouse - MainTeamNum - TemporarilyStoreBackpackNum, self.PetNumLimit, "\228\187\147\229\186\147\231\178\190\231\129\181")
  for i = 1, #petData do
    if not BattleUtils.GetBit(petData[i].pet_status_flags, 1) then
      local starLevel = PetUtils.GetBreakThroughStarsList(petData[i])
      local StarNum = 0
      for k = 1, #starLevel do
        if 1 == starLevel[k].IsShow then
          StarNum = StarNum + 1
        end
      end
      for j = 1, 4 do
        if petData[i].talent_rank == j then
          local IsInTeam, teamInfo = PetUtils.GetIsInPvpOrPveTeamByGid(petData[i].gid)
          local petInfo = {
            starLevel = StarNum,
            petData = petData[i],
            ListIndex = j,
            InitSelect = false,
            IsSelectFree = self:GetIsInFreeList(petData[i].gid),
            IsInTeam = IsInTeam
          }
          table.insert(self["TalentList" .. j], petInfo)
        end
      end
    end
  end
  if #self.TalentList1 > 0 or #self.TalentList2 > 0 or #self.TalentList3 > 0 or #self.TalentList4 > 0 then
    self.Switcher_123:SetActiveWidgetIndex(0)
  else
    self.Switcher_123:SetActiveWidgetIndex(1)
  end
  self.selectPetData = nil
  self:RefreshFilterAndSortList(self.data.chooseTypeList1)
end

function UMG_PetWareHouseFree_C:RefreshFilterAndSortList(TypeChooseList)
  for i = 1, 4 do
    self["TalentList" .. i] = self:FilterInfo(TypeChooseList, self["TalentList" .. i])
  end
  local List = {}
  local SelectListIndex, SelectItemIndex
  local findSel = false
  for i = 1, 4 do
    if #self["TalentList" .. i] <= 0 then
    else
      local PetList = self:SortInfo(self.SortIndex, self["TalentList" .. i])
      local petItemList = self:GetInitUiList(PetList, i)
      for j = 1, #petItemList do
        if self.RefreshSelectGid and not findSel then
          local petList = petItemList[j].petList
          for index, pet in ipairs(petList) do
            if pet.petData and pet.petData.gid == self.RefreshSelectGid then
              SelectListIndex = #List + 1
              SelectItemIndex = index
              petItemList[j].selectIndex = index
              findSel = true
              break
            end
          end
        end
        table.insert(List, petItemList[j])
      end
    end
  end
  self.PetList:ClearSelection()
  self.PetList:InitList(List)
  if #self.TalentList1 > 0 or #self.TalentList2 > 0 or #self.TalentList3 > 0 or #self.TalentList4 > 0 then
    self.PetList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ScreenCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher:SetActiveWidgetIndex(2)
  else
    self.PetList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ScreenCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(1)
  end
  if SelectListIndex then
    self.PetList:SelectItemByIndex(SelectListIndex - 1)
  end
end

function UMG_PetWareHouseFree_C:GetInitUiList(_PetList, TalentIndex)
  local PetList = {}
  local PetTotalNum = #_PetList
  if _PetList and PetTotalNum > 0 then
    local IterNum = math.ceil(PetTotalNum / 7.0)
    local Num = 1
    for j = 1, IterNum do
      if PetTotalNum >= Num + 6 then
        local PetListItem = {}
        for i = Num, Num + 6 do
          table.insert(PetListItem, _PetList[i])
        end
        Num = Num + 7
        table.insert(PetList, {
          petList = PetListItem,
          Pos = j,
          talentIndex = TalentIndex,
          parent = self
        })
      else
        local PetListItem = {}
        for i = Num, PetTotalNum do
          table.insert(PetListItem, _PetList[i])
        end
        table.insert(PetList, {
          petList = PetListItem,
          Pos = j,
          talentIndex = TalentIndex,
          parent = self
        })
      end
    end
  end
  return PetList
end

local function ReversedSortAndOtherProperty(a, b)
  local A_Collect = a.petData.partner_mark and a.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE
  local B_Collect = b.petData.partner_mark and b.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE
  if A_Collect and not B_Collect then
    return false
  end
  if not A_Collect and B_Collect then
    return true
  end
  if a.petData.partner_mark == b.petData.partner_mark then
    local a_grow_times = a.petData.grow_times or 0
    local b_grow_times = b.petData.grow_times or 0
    if a_grow_times == b_grow_times then
      if a.petData.level == b.petData.level then
        return a.petData.base_conf_id < b.petData.base_conf_id
      else
        return a.petData.level > b.petData.level
      end
    else
      return a_grow_times > b_grow_times
    end
  else
    return a.petData.partner_mark < b.petData.partner_mark
  end
end

local function SortAndOtherProperty(a, b)
  local A_Collect = a.petData.partner_mark and a.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE
  local B_Collect = b.petData.partner_mark and b.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE
  if A_Collect and not B_Collect then
    return false
  end
  if not A_Collect and B_Collect then
    return true
  end
  if a.petData.partner_mark == b.petData.partner_mark then
    local a_grow_times = a.petData.grow_times or 0
    local b_grow_times = b.petData.grow_times or 0
    if a_grow_times == b_grow_times then
      if a.petData.level == b.petData.level then
        return a.petData.base_conf_id < b.petData.base_conf_id
      else
        return a.petData.level < b.petData.level
      end
    else
      return a_grow_times < b_grow_times
    end
  else
    return a.petData.partner_mark < b.petData.partner_mark
  end
end

function UMG_PetWareHouseFree_C:SortInfo(SortType, SortList)
  local PetList = SortList
  local SortIndex = SortType
  for i = 1, #PetList do
    PetList[i].IconListSortInfo = PetList[i][SortIndex]
  end
  if not self.IsReversedSort then
    table.sort(PetList, ReversedSortAndOtherProperty)
  else
    table.sort(PetList, SortAndOtherProperty)
  end
  return PetList
end

function UMG_PetWareHouseFree_C:HasGid(gid, table)
  if not table then
    return false
  end
  local num = #table
  for i = 1, num do
    if table[i].petData.gid == gid then
      return true
    end
  end
  return false
end

function UMG_PetWareHouseFree_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_PetWareHouseFree_C:FilterInfo(TypeChooseList, PetList)
  local PetInfoList = PetList
  local DepartmentFilter = {}
  local DepartList = {}
  if TypeChooseList.DepartmentFilter then
    for i, v in pairs(TypeChooseList.DepartmentFilter) do
      local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
      table.insert(DepartmentFilter, enum)
    end
  end
  if #DepartmentFilter > 0 then
    for i = 1, #PetInfoList do
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetInfoList[i].petData.base_conf_id)
      for k = 1, #petBaseConf.unit_type do
        for j = 1, #DepartmentFilter do
          if petBaseConf.unit_type[k] == DepartmentFilter[j] or PetInfoList[i].IsSelectFree then
            if not self:HasGid(PetInfoList[i].petData.gid, DepartList) then
              table.insert(DepartList, PetInfoList[i])
            end
            break
          end
        end
      end
    end
  else
    DepartList = PetInfoList
  end
  local TalentFilter = {}
  local TalentList = {}
  for i, v in pairs(TypeChooseList.TalentFilter) do
    local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
    table.insert(TalentFilter, enum)
  end
  if #TalentFilter > 0 then
    for i = 1, #DepartList do
      for j = 1, #TalentFilter do
        if DepartList[i].petData.talent_rank == TalentFilter[j] or DepartList[i].IsSelectFree then
          table.insert(TalentList, DepartList[i])
          break
        end
      end
    end
  else
    TalentList = DepartList
  end
  local NaturePositiveEffectFilter = {}
  local NaturePositiveEffectList = {}
  for i, v in pairs(TypeChooseList.NaturePositiveEffectFilter) do
    local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
    table.insert(NaturePositiveEffectFilter, enum)
  end
  if #NaturePositiveEffectFilter > 0 then
    for i = 1, #TalentList do
      local NaturePositive = TalentList[i].petData.changed_nature_pos_attr_type
      if not NaturePositive or 0 == NaturePositive then
        NaturePositive = _G.DataConfigManager:GetNatureConf(TalentList[i].petData.nature).positive_effect
      else
        NaturePositive = self:GetChangeAttrReqEnum(NaturePositive)
      end
      for j = 1, #NaturePositiveEffectFilter do
        if NaturePositive == NaturePositiveEffectFilter[j] or TalentList[i].IsSelectFree then
          table.insert(NaturePositiveEffectList, TalentList[i])
          break
        end
      end
    end
  else
    NaturePositiveEffectList = TalentList
  end
  local AttributeFilter = {}
  local AttributeList = {}
  for i, v in pairs(TypeChooseList.AttributeFilter) do
    local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
    table.insert(AttributeFilter, enum)
  end
  if #AttributeFilter > 0 then
    for i = 1, #NaturePositiveEffectList do
      for j = 1, #AttributeFilter do
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_HPMAX and NaturePositiveEffectList[i].petData.attribute_info.hp.talent and NaturePositiveEffectList[i].petData.attribute_info.hp.talent > 0 or NaturePositiveEffectList[i].IsSelectFree then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_PHYATK and NaturePositiveEffectList[i].petData.attribute_info.attack.talent and NaturePositiveEffectList[i].petData.attribute_info.attack.talent > 0 or NaturePositiveEffectList[i].IsSelectFree then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEATK and NaturePositiveEffectList[i].petData.attribute_info.special_attack.talent and NaturePositiveEffectList[i].petData.attribute_info.special_attack.talent > 0 or NaturePositiveEffectList[i].IsSelectFree then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_PHYDEF and NaturePositiveEffectList[i].petData.attribute_info.defense.talent and NaturePositiveEffectList[i].petData.attribute_info.defense.talent > 0 or NaturePositiveEffectList[i].IsSelectFree then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEDEF and NaturePositiveEffectList[i].petData.attribute_info.special_defense.talent and NaturePositiveEffectList[i].petData.attribute_info.special_defense.talent > 0 or NaturePositiveEffectList[i].IsSelectFree then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEED and NaturePositiveEffectList[i].petData.attribute_info.speed.talent and NaturePositiveEffectList[i].petData.attribute_info.speed.talent > 0 or NaturePositiveEffectList[i].IsSelectFree then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
      end
    end
  else
    AttributeList = NaturePositiveEffectList
  end
  local PartnerMarkerFilter = {}
  local PartnerMarkerList = {}
  if TypeChooseList.PartnerMarkerFilter then
    for i, v in pairs(TypeChooseList.PartnerMarkerFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(PartnerMarkerFilter, enum)
      end
    end
  end
  if #PartnerMarkerFilter > 0 then
    for i = 1, #AttributeList do
      if AttributeList[i].petData then
        for j = 1, #PartnerMarkerFilter do
          if AttributeList[i].petData.partner_mark == PartnerMarkerFilter[j] or AttributeList[i].IsSelectFree then
            table.insert(PartnerMarkerList, AttributeList[i])
            break
          end
        end
      end
    end
  else
    PartnerMarkerList = AttributeList
  end
  local GetTimeFilter = {}
  local GetTimeList = {}
  if TypeChooseList.GetTimeFilter then
    for _, v in pairs(TypeChooseList.GetTimeFilter or {}) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(GetTimeFilter, enum)
      end
    end
  end
  if #GetTimeFilter > 0 then
    for i = 1, #PartnerMarkerList do
      if PartnerMarkerList[i] and PartnerMarkerList[i].petData then
        for j = 1, #GetTimeFilter do
          if PartnerMarkerList[i].petData.add_time then
            local bCheckPass = false
            if GetTimeFilter[j] == _G.Enum.PetCatchTime.PCT_THISWEEK then
              bCheckPass = NRCModuleManager:DoCmd(PetUIModuleCmd.IsPetInCurrentWeek, PartnerMarkerList[i].petData.add_time)
            elseif GetTimeFilter[j] == _G.Enum.PetCatchTime.PCT_TODAY then
              bCheckPass = NRCModuleManager:DoCmd(PetUIModuleCmd.IsPetCaughtToday, PartnerMarkerList[i].petData.add_time)
            end
            if bCheckPass then
              table.insert(GetTimeList, PartnerMarkerList[i])
              break
            end
          end
        end
      end
    end
  else
    GetTimeList = PartnerMarkerList
  end
  if #DepartmentFilter <= 0 and #TalentFilter <= 0 and #NaturePositiveEffectFilter <= 0 and #AttributeFilter <= 0 and #PartnerMarkerFilter <= 0 and #GetTimeFilter <= 0 then
    self.ComboBox.ScreeningBtn:ChangeIconSelectState(1)
  else
    self.ComboBox.ScreeningBtn:ChangeIconSelectState(2)
  end
  return GetTimeList
end

function UMG_PetWareHouseFree_C:SetRightInfo(PetData, ListIndex)
  if not PetData then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_FavoriteButton_C:UpdateInfo")
  self.ListIndex = ListIndex
  self.IconList_1:ScrollToStart()
  if PetData then
    if self.selectPetData and self.selectPetData.gid == PetData.gid then
    else
      self:PlayAnimation(self.Change)
    end
    self.selectPetData = PetData
  else
    if self.selectPetData and self.selectPetData.gid == PetData.gid then
    else
      self:PlayAnimation(self.Change)
    end
    self.selectPetData = PetData
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.selectPetData.base_conf_id)
  self.textPetName:SetText(self.selectPetData.name)
  self:updatePetGender(self.selectPetData.gender)
  self.UMG_PetRate:SetText(self.selectPetData, TipEnum.OpenPetTipsType.PetWareHouse)
  self.textPetLv:SetText(self.selectPetData.level)
  local BreakThroughStarsList = PetUtils.GetBreakThroughStarsList(self.selectPetData)
  self.CatchHardLv:InitGridView(BreakThroughStarsList)
  local commonAttrData = {}
  local commonAttrData1 = {}
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
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(self.selectPetData.blood_id)
  self.UMG_CollectBtn:UpdateInfo(self.selectPetData.partner_mark, true)
  table.insert(commonAttrData, {
    Name = PetBloodConf.blood_name,
    Path = PetBloodConf.icon
  })
  if self.Attr then
    self.Attr:InitGridView(commonAttrData)
  end
  self.CommonPetDetails:InitPetBaseInfo(self.selectPetData, petBaseConf)
  if not self.RefreshSelectGid then
    local num = self.PetList:GetTotalItemNumber()
    for j = 1, num do
      local ListItem = self.PetList:GetItemByIndex(j - 1)
      if ListItem then
        local find = false
        local count = ListItem.GridView:GetItemCount()
        for i = 1, count do
          local _item = ListItem.GridView:GetItemByIndex(i - 1)
          if _item.PetInfo.petData.gid == self.selectPetData.gid then
            find = true
            local isADD, IsInPvpOrPveTeam = self:AddOrRemoveItemFromFreeList(self.selectPetData)
            self.TalentListIndex = ListIndex
            self.ItemIndex = (ListItem.Pos - 1) * 7 + i
            self.CurAddOrRemoveItem = _item
            if not (isADD and IsInPvpOrPveTeam) then
              goto lbl_203
            end
            do break end
            ::lbl_203::
            self:OnUpdateApplyFreeItem(isADD)
            break
          end
        end
        if find then
          break
        end
      end
    end
  end
  self.Switcher:SetActiveWidgetIndex(0)
end

function UMG_PetWareHouseFree_C:OnUpdateApplyFreeItem(isADD)
  if self.TalentListIndex and self.ItemIndex and self.CurAddOrRemoveItem then
    local i = self.TalentListIndex
    local j = self.ItemIndex
    local item = self.CurAddOrRemoveItem
    if isADD then
      if self["TalentList" .. i][j] then
        self["TalentList" .. i][j].IsSelectFree = true
      end
      if item.IsInTeam then
        item.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      item.PetInfo.IsSelectFree = true
      if item.IsInTeam then
        item.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      item.CheckCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      item:PlayAnimation(self.Tick_In)
    else
      if self["TalentList" .. i][j] then
        self["TalentList" .. i][j].IsSelectFree = false
      end
      item.PetInfo.IsSelectFree = false
      if item.IsInTeam then
        item.State:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      item.CheckCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetWareHouseFree_C:AddOrRemoveItemFromFreeList(petData)
  local IsInPvpOrPveTeam = false
  if petData.partner_mark and petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetPetGlobalConfig("collection_cant_release").str)
    return false
  end
  if 0 == #self.FreeList then
    IsInPvpOrPveTeam = self:GetIsInPvpOrPveTeam(petData)
    if not IsInPvpOrPveTeam then
      table.insert(self.FreeList, petData)
      self:UpdateFreeBtnClick()
    end
    return true, IsInPvpOrPveTeam
  end
  for i = 1, #self.FreeList do
    if self.FreeList[i].gid == petData.gid then
      self:UpdateFreeBtnClickByItemData(false, petData, i)
      return false
    end
    if i == #self.FreeList then
      if #self.FreeList < self.FreeLimit then
        IsInPvpOrPveTeam = self:GetIsInPvpOrPveTeam(petData)
        if not IsInPvpOrPveTeam then
          self:UpdateFreeBtnClickByItemData(true, petData)
        end
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\233\128\137\230\139\169\231\178\190\231\129\181\230\149\176\232\190\190\229\136\176\228\184\138\233\153\144")
        return false
      end
      return true, IsInPvpOrPveTeam
    end
  end
end

function UMG_PetWareHouseFree_C:GetIsInPvpOrPveTeam(petData)
  local IsInTeam, teamInfo = PetUtils.GetIsInPvpOrPveTeamByGid(petData.gid)
  if IsInTeam then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetReleaseTips, petData, teamInfo, {
      caller = self,
      callback = self.ApplyFreePvpOrPvePet
    }, true)
    return true
  else
    return false
  end
end

function UMG_PetWareHouseFree_C:ApplyFreePvpOrPvePet()
  self:UpdateFreeBtnClickByItemData(true, self.selectPetData)
  self:OnUpdateApplyFreeItem(true)
end

function UMG_PetWareHouseFree_C:UpdateFreeBtnClick()
  if self.FreeList and #self.FreeList > 0 then
    self.FreeBtn:SetIsEnabled(true)
    self.NRCSwitcher_73:SetActiveWidgetIndex(0)
    self:SetNewBelowList()
    self:UpdateList()
  else
    self.FreeBtn:SetIsEnabled(false)
    self.NRCSwitcher_73:SetActiveWidgetIndex(1)
  end
  self:RefreshFreeNumText()
end

function UMG_PetWareHouseFree_C:AddRewardItemByPetData(petData)
  local AwardList = PetUtils.GetPetFreeAwradList(petData, FreeRewardConf)
  self.PetFreeAward = PetUtils.AddRewardToItemList(AwardList, self.PetFreeAward)
  self:GetNewBaseInfoReward(petData)
end

function UMG_PetWareHouseFree_C:RemoveRewardItemByPetData(petData)
  local AwardList = PetUtils.GetPetFreeAwradList(petData, FreeRewardConf)
  self.PetFreeAward = PetUtils.RemoveRewardToItemList(AwardList, self.PetFreeAward)
  self:GetNewBaseInfoReward(petData, true)
end

function UMG_PetWareHouseFree_C:UpdateFreeBtnClickByItemData(_add, petData, _index)
  if not self.FreeList then
    self.FreeList = {}
  end
  if _add then
    table.insert(self.FreeList, petData)
  else
    table.remove(self.FreeList, _index)
  end
  if self.FreeList and #self.FreeList > 0 then
    self.FreeBtn:SetIsEnabled(true)
    self.NRCSwitcher_73:SetActiveWidgetIndex(0)
    if _add then
      self:AddRewardItemByPetData(petData)
    else
      self:RemoveRewardItemByPetData(petData)
    end
    self:UpdateList()
  else
    self.FreeBtn:SetIsEnabled(false)
    self.NRCSwitcher_73:SetActiveWidgetIndex(1)
  end
  self:RefreshFreeNumText()
end

function UMG_PetWareHouseFree_C:SetNewBelowList()
  local petData = self.FreeList
  table.clear(self.PetFreeAward)
  for i, _petData in ipairs(petData) do
    self:AddRewardItemByPetData(_petData)
  end
end

function UMG_PetWareHouseFree_C:GetNewBaseInfoReward(_PetData, _Remove)
  local itemCfg
  local _petData = _PetData
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(_petData.catch_base_id)
  if petBaseConf then
    local PetGrowLevel, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(_petData)
    local BreakNumberAllConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BREAK_NUMBER_CONF):GetAllDatas()
    if petBaseConf and GrowOrder - 1 >= 1 and GrowOrder - 1 <= #BreakNumberAllConf then
      local breakItemConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BREAK_ITEM_CONF):GetAllDatas()
      local BreakNumberConf = _G.DataConfigManager:GetBreakNumberConf(GrowOrder - 1)
      petBaseConf = _G.DataConfigManager:GetPetbaseConf(_petData.base_conf_id)
      local UnitType = petBaseConf.unit_type
      for z, v in ipairs(UnitType) do
        if UnitType[z] then
          local ConsumeNum = BreakNumberConf.free_type_item_number
          for j, k in ipairs(breakItemConf) do
            if v == k.unit_type and GrowOrder - 1 == k.break_level then
              if #UnitType > 1 then
                ConsumeNum = ConsumeNum // #UnitType
              end
              if ConsumeNum > 0 then
                itemCfg = k.break_type_item > 1 and _G.DataConfigManager:GetBagItemConf(k.break_type_item) or nil
                if _Remove then
                  if self.PetFreeAward and self.PetFreeAward[itemCfg.id] then
                    self.PetFreeAward[itemCfg.id].Count = self.PetFreeAward[itemCfg.id].Count - ConsumeNum
                    if self.PetFreeAward[itemCfg.id].Count <= 0 then
                      self.PetFreeAward[itemCfg.id] = nil
                    end
                  end
                elseif self.PetFreeAward and self.PetFreeAward[itemCfg.id] then
                  self.PetFreeAward[itemCfg.id].Count = self.PetFreeAward[itemCfg.id].Count + ConsumeNum
                else
                  local Rewards = {}
                  Rewards.Count = ConsumeNum
                  Rewards.Id = itemCfg.id
                  Rewards.Type = ""
                  self.PetFreeAward[itemCfg.id] = Rewards
                end
              end
            end
          end
        end
      end
    end
  end
end

function UMG_PetWareHouseFree_C:UpdateList()
  local wardItemInfo = self.PetFreeAward
  local itemInfo = {}
  for i, item in pairs(wardItemInfo) do
    local itemCfg = item.Id > 0 and _G.DataConfigManager:GetBagItemConf(item.Id) or nil
    table.insert(itemInfo, {
      itemCfg = itemCfg,
      itemId = item.Id,
      itemCount = item.Count,
      itemType = item.Type
    })
  end
  
  local function compare(a, b)
    if a.itemCfg.item_quality ~= b.itemCfg.item_quality then
      return a.itemCfg.item_quality > b.itemCfg.item_quality
    else
      return a.itemCfg.sort_id < b.itemCfg.sort_id
    end
  end
  
  table.sort(itemInfo, compare)
  local rewardsTable = {}
  for k, v in ipairs(itemInfo) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = _G.Enum.GoodsType.GT_BAGITEM
    rewards.itemId = v.itemId
    rewards.itemNum = v.itemCount
    rewards.bShowNum = true
    rewards.bShowTip = true
    table.insert(rewardsTable, rewards)
  end
  self.FreeItemList:InitList(rewardsTable)
end

function UMG_PetWareHouseFree_C:RefreshFreeNumText()
  local FreeNum = self.FreeList and #self.FreeList or 0
  local FreeLimit = self.FreeLimit
  self.Text_quantity:SetText(string.format("<span color=\"#ffc65fff\">%d</>", FreeNum) .. "/" .. FreeLimit)
end

function UMG_PetWareHouseFree_C:GetPetEquipSkills(petData)
  local petEquipSkills = {}
  if petData then
    for i, skillData in ipairs(petData.skill.skill_data) do
      if skillData.is_equipped and 1 == skillData.type and skillData.pos > 0 and skillData.pos <= 4 then
        petEquipSkills[skillData.pos] = skillData
      end
    end
  end
  return petEquipSkills
end

function UMG_PetWareHouseFree_C:ShowDescCampPanel(id)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ShowDescCampPanel, id)
end

function UMG_PetWareHouseFree_C:GetPetFeatrueSkillId(baseConf)
  local skillId = baseConf.pet_feature
  if 0 ~= skillId then
    return skillId, false
  else
    local evolution_pet_id = baseConf.evolution_pet_id[1]
    if nil == evolution_pet_id then
      return
    end
    local evoPetbaseCfg = _G.DataConfigManager:GetPetbaseConf(evolution_pet_id)
    if evolution_pet_id then
      skillId = evoPetbaseCfg.pet_feature
      if 0 ~= skillId then
        return skillId, true
      end
    end
  end
  return 0
end

function UMG_PetWareHouseFree_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetWareHouseFree_C:EliminatePetWareHouseNum(_PetData)
  local PetData = _PetData
  local PetList = {}
  if PetData then
    for i, PetInfo in ipairs(PetData) do
      local isExchange = PetInfo.pet_status_flags and PetInfo.pet_status_flags & ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
      if not isExchange and not _G.DataModelMgr.PlayerDataModel:IsInBackpack(PetInfo.gid, nil, true) then
        table.insert(PetList, PetInfo)
      end
    end
  end
  return #PetList
end

function UMG_PetWareHouseFree_C:EliminateFreePet(petInfoList)
  local PetData = petInfoList.pet_data
  local PetList = {}
  local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  if PetData then
    for i, PetInfo in ipairs(PetData) do
      local IsMainTeam = false
      if teamInfo and teamInfo.teams then
        for j, team in ipairs(teamInfo.teams) do
          local petInfo = PetUtils.PetTeamFindPetInfoByIndex(team, PetInfo.gid)
          if petInfo then
            IsMainTeam = true
            break
          end
        end
      end
      local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, PetInfo.gid)
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetInfo.base_conf_id)
      local isInHome = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetPetIsInHome, PetInfo.gid)
      local isInGuard = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetHomePlantGuardPetGid) == PetInfo.gid
      local isExchange = PetInfo.pet_status_flags and PetInfo.pet_status_flags & ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
      if not isExchange and not IsMainTeam and (not petBaseConf.ban_free or 1 ~= petBaseConf.ban_free) and not isTravel and not isInHome and not isInGuard and not IsInBackPack and not PetUtils.CheckPetIsInherited(PetInfo.gid) then
        table.insert(PetList, PetInfo)
      end
    end
  end
  return PetList
end

function UMG_PetWareHouseFree_C:OnBatchSelect()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_FavoriteButton_C:UpdateInfo")
  local num1, num2, num3 = self:GetCanBatchSelectNum()
  self.module:OpenPanel("QuickSelection", num1, num2, num3)
end

function UMG_PetWareHouseFree_C:GetCanBatchSelectNum()
  local num1 = 0
  local num2 = 0
  local num3 = 0
  for i, v in pairs(self.TalentList1) do
    if v.petData.grow_times and v.petData.grow_times >= 1 or v.petData.partner_mark and v.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE or v.IsSelectFree or v.IsInTeam then
    else
      num1 = num1 + 1
    end
  end
  for i, v in pairs(self.TalentList2) do
    if v.petData.grow_times and v.petData.grow_times >= 1 or v.petData.partner_mark and v.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE or v.IsSelectFree or v.IsInTeam then
    else
      num2 = num2 + 1
    end
  end
  for i, v in pairs(self.TalentList3) do
    if v.petData.grow_times and v.petData.grow_times >= 1 or v.petData.partner_mark and v.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE or v.IsSelectFree or v.IsInTeam then
    else
      num3 = num3 + 1
    end
  end
  return num1, num2, num3
end

function UMG_PetWareHouseFree_C:GetChangeAttrReqEnum(attribute)
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

function UMG_PetWareHouseFree_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  if self.Action then
    _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.ShowDialogueOverlay)
    self.Action:EndAction()
  end
  UE4Helper.SetEnableWorldRendering(true)
  if self.data then
    self.data.chooseTypeList1 = {
      DepartmentFilter = {},
      TalentFilter = {},
      NaturePositiveEffectFilter = {},
      AttributeFilter = {}
    }
  end
end

function UMG_PetWareHouseFree_C:SortItemInfo(SortIndex)
  self.SortIndex = SortIndex
  self:UpdateInfo()
  self:UpdateFreeBtnClick()
end

function UMG_PetWareHouseFree_C:OnAddEventListener()
  self:AddButtonListener(self.BatchSelect.btnLevelUp, self.OnBatchSelect)
  self:AddButtonListener(self.FreeBtn.btnLevelUp, self.OnFreeBtn)
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.OnCloseClick)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_FREE_SORT, self.SortItemInfo)
  self:RegisterEvent(self, PetUIModuleEvent.FilterPetSort, self.OnFilterPet)
  self:RegisterEvent(self, PetUIModuleEvent.ApplyBatchSelectFree, self.BatchSelectFree)
  self:RegisterEvent(self, PetUIModuleEvent.PET_FREE_SUCCESS, self.OnPetFreeSuccess)
  self:AddButtonListener(self.BtnRechristen_1, self.OpenPetTips)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.UMG_CollectBtn.Button, self.OnCollectBtn)
  self:RegisterEvent(self, PetUIModuleEvent.UpdatePetCollect, self.UpdateCollect)
end

function UMG_PetWareHouseFree_C:UpdateCollect(partner_mark)
  self.selectPetData.partner_mark = partner_mark
  self.UMG_CollectBtn:UpdateInfo(partner_mark)
  if self.ListIndex then
    local num = self.PetList:GetTotalItemNumber()
    for j = 1, num do
      local ListItem = self.PetList:GetItemByIndex(j - 1)
      if ListItem then
        local find = false
        local count = ListItem.GridView:GetItemCount()
        for i = 1, count do
          local _item = ListItem.GridView:GetItemByIndex(i - 1)
          if _item.PetInfo.petData.gid == self.selectPetData.gid then
            find = true
            local ItemIndex = (ListItem.Pos - 1) * 7 + i
            self["TalentList" .. self.ListIndex][ItemIndex].petData.partner_mark = partner_mark
            _item.PetInfo.petData.partner_mark = partner_mark
            if self.selectPetData.partner_mark and self.selectPetData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
              _item.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.selectPetData.partner_mark))
              _item.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
              _item.CheckCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
              for k = 1, #self.FreeList do
                if self.FreeList[k].gid == self.selectPetData.gid then
                  self:UpdateFreeBtnClickByItemData(false, self.selectPetData, k)
                  break
                end
              end
              break
            end
            _item.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
            break
          end
        end
        if find then
          break
        end
      end
    end
  end
end

function UMG_PetWareHouseFree_C:BatchSelectFree(List)
  for j = 1, 3 do
    for i = 1, #List do
      if j == List[i].TalentIndex then
        for k, v in pairs(self["TalentList" .. j]) do
          if #self.FreeList < self.FreeLimit and not v.IsSelectFree and not v.IsInTeam and (not v.petData.grow_times or not (v.petData.grow_times >= 1)) and (not v.petData.partner_mark or v.petData.partner_mark == ProtoEnum.PetPartnerMarkType.PPMT_NONE) then
            table.insert(self.FreeList, v.petData)
            v.IsSelectFree = true
            local num = self.PetList:GetTotalItemNumber()
            for _ListIndex = 1, num do
              local ListItem = self.PetList:GetItemByIndex(_ListIndex - 1)
              if ListItem and ListItem.UiData and ListItem.UiData.talentIndex == List[i].TalentIndex then
                local count = ListItem.GridView:GetItemCount()
                for _GridViewIndex = 1, count do
                  local item = ListItem.GridView:GetItemByIndex(_GridViewIndex - 1)
                  if not item.IsInTeam and (not item.PetInfo.petData.grow_times or not (item.PetInfo.petData.grow_times >= 1)) and (not item.PetInfo.petData.partner_mark or item.PetInfo.petData.partner_mark == ProtoEnum.PetPartnerMarkType.PPMT_NONE) then
                    item.CheckCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
                    item:PlayAnimation(self.Tick_In)
                  end
                end
              end
            end
          end
        end
        break
      end
    end
  end
  self:UpdateFreeBtnClick()
end

function UMG_PetWareHouseFree_C:GetIsInFreeList(gid)
  if self.FreeList and #self.FreeList > 0 then
    for _, v in pairs(self.FreeList) do
      if v.gid == gid then
        return true
      end
    end
  end
  return false
end

function UMG_PetWareHouseFree_C:OnFilterPet()
  self:UpdateInfo(true)
  self:UpdateFreeBtnClick()
end

function UMG_PetWareHouseFree_C:OnPetFreeSuccess()
  self:UpdateInfo()
  self:UpdateFreeBtnClick()
end

function UMG_PetWareHouseFree_C:OnUpdatePanel()
  if self.selectPetData and self.ListIndex then
    local newPetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.selectPetData.gid)
    if newPetData.talent_rank == self.selectPetData.talent_rank then
      self.selectPetData = newPetData
      self:SetRightInfo(self.selectPetData, self.ListIndex)
      local num = self.PetList:GetTotalItemNumber()
      for _ListIndex = 1, num do
        local ListItem = self.PetList:GetItemByIndex(_ListIndex - 1)
        local find = false
        if ListItem then
          local count = ListItem.GridView:GetItemCount()
          for _GridViewIndex = 1, count do
            local item = ListItem.GridView:GetItemByIndex(_GridViewIndex - 1)
            if item.PetInfo.petData.gid == self.selectPetData.gid then
              find = true
              local ItemIndex = (ListItem.Pos - 1) * 7 + _GridViewIndex
              self["TalentList" .. self.ListIndex][ItemIndex].petData = self.selectPetData
              item.PetInfo.petData = self.selectPetData
              break
            end
          end
          if find then
            break
          end
        end
      end
    else
      self.RefreshSelectGid = self.selectPetData.gid
      self:UpdateInfo(true)
      self:UpdateFreeBtnClick()
    end
  end
end

function UMG_PetWareHouseFree_C:OnCloseClick()
  self:DispatchEvent(PetUIModuleEvent.OnPetWareHouseFreeClose)
  self:DoClose()
end

function UMG_PetWareHouseFree_C:OnFreeBtn()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET_FREE, true)
  if isBan then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401003, "UMG_PetWarehouse_C:OnNRCButton_0ClickPetFree ")
  if self.FreeList and #self.FreeList > 1 then
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetFreePanel, self.FreeList)
  elseif #self.FreeList > 0 then
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenBackpackPetFreePanel, self.FreeList)
  end
end

function UMG_PetWareHouseFree_C:OnReversedSort()
  self.IsReversedSort = not self.IsReversedSort
  if self.IsReversedSort then
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(1, -1))
  else
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(1, 1))
  end
  self:UpdateInfo(true)
  self:UpdateFreeBtnClick()
end

function UMG_PetWareHouseFree_C:OpenSortPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenSortPanel, self.SortIndex, PetUIModuleEnum.OpenSortType.WareHouseFree)
end

function UMG_PetWareHouseFree_C:OpenFilterPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenFilterPanel, PetUIModuleEnum.OpenSortType.WareHouseFree)
end

function UMG_PetWareHouseFree_C:OpenPetTips()
  local petData = self.selectPetData
  local uidata = {petData = petData}
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, uidata, _G.Enum.GoodsType.GT_PET)
end

function UMG_PetWareHouseFree_C:OnBloodPulse()
  local petData = self.selectPetData
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetBloodPulse, petData, PetUIModuleEnum.OpenSortType.WareHouseFree)
end

function UMG_PetWareHouseFree_C:OnCollectBtn()
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetCollectPanel, self.selectPetData.gid, self.selectPetData.partner_mark)
end

return UMG_PetWareHouseFree_C
