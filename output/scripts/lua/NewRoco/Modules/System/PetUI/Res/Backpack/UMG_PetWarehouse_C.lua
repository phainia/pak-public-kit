local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetWarehouse_C = _G.NRCViewBase:Extend("UMG_PetWarehouse_C")

function UMG_PetWarehouse_C:Ctor()
  Log.Debug("UMG_PetRadarInfo_C:Ctor")
end

function UMG_PetWarehouse_C:Initialize(Initializer)
end

function UMG_PetWarehouse_C:OnConstruct()
  self.uiData = {}
  self.curPetListSelectIndex = 0
  self.SortIndex = _G.Enum.PetSequenceDefault.SEQUENCE_LEVEL_DOWN
  self.IsbMultipleChoice = false
  self.IsReversedSort = false
  self.FreeList = {}
  self.IsOpenTeamBtn = false
  self.Box:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:UpdateFightBtn()
  self:OnAddEventListener()
  self.icon = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_zhankai_png.img_zhankai_png'"
  self.UMG_FightBtn:SetPath(self.icon)
  self.UMG_FightBtn:SetBtnText(LuaText.umg_petwarehouse_1)
  Log.Debug("UMG_PetWarehouse_C:OnConstruct")
end

function UMG_PetWarehouse_C:UpdatePetWareHouseInfo()
  self.IsOpenTeamBtn = false
  self:UpdateFightBtn()
  self.IsbMultipleChoice = false
  self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:SetFreeNum()
  self.UMG_PetDropDownList:OnActive(self.SortIndex - 1)
  self.Box:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PetWarehouse_C:OnDestruct()
  self.UMG_PetDropDownList:Destruct()
end

function UMG_PetWarehouse_C:UpdatePetInfo(petInfoList, petHeadInfo)
  self.uiData.PetInfoList = petInfoList
  self.uiData.petHeadInfo = petHeadInfo
  self.uiData.PetSortInfo = nil
  self:SetPetList()
end

function UMG_PetWarehouse_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_FightBtn.btnLevelUp, self.OnFightBtnClick)
  self:AddButtonListener(self.NRCButton_0, self.OnNRCButton_0Click)
  self:AddButtonListener(self.NRCButton, self.OnNRCButton)
  self:RegisterEvent(self, PetUIModuleEvent.ChangeChooseHousePet, self.OnScrollPetItemSelected)
  self:RegisterEvent(self, PetUIModuleEvent.RemovePetNew, self.OnRemovePetNew)
  self:RegisterEvent(self, PetUIModuleEvent.OnClickReversedSort, self.OnReversedSort)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_SORT, self.SortItemInfo)
  self:RegisterEvent(self, PetUIModuleEvent.SetWarehousePetSortIndex, self.SetPetSortIndex)
end

function UMG_PetWarehouse_C:SetFreeNum()
  local freenum = #self.FreeList
  self.NumText:SetText(freenum .. "/30")
end

function UMG_PetWarehouse_C:SetPetList()
  self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
  self:SetSortListInfo()
end

function UMG_PetWarehouse_C:SetPetSortIndex(_index)
  self.SortIndex = _index
end

function UMG_PetWarehouse_C:SetSortListInfo()
  local sortIndex = self.SortIndex - 1
  self.UMG_PetDropDownList:OnActive(sortIndex)
end

function UMG_PetWarehouse_C:SortItemInfo(_index)
  if self:GetVisibility() == UE4.ESlateVisibility.Visible then
    local ListVisible = self.UMG_PetDropDownList:GetbListVisible()
    if true == ListVisible then
      self.FreeList = {}
      self:SetFreeNum()
    end
    self.SortIndex = _index
    self.petInfoMainCtrl:SetSortIndex(_index)
    self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
    if self.IsReversedSort == false then
      self.UMG_PetDropDownList:SetReversedSort()
    end
  end
end

function UMG_PetWarehouse_C:SortItem(_petinfo, sortType)
  local sortlist = self:SortItemList(_petinfo, sortType)
  self.uiData.PetSortInfo = sortlist
  if self.uiData.PetSortInfo then
    self.GridView1:InitGridView(self.uiData.PetSortInfo)
    if self.uiData.PetSortInfo[1].PetData.IsOpenTeam == false and false == self.IsbMultipleChoice then
      self.GridView1:SelectItemByIndex(0)
    end
  end
  self.UMG_PetDropDownList:SelectItem(sortType)
end

function UMG_PetWarehouse_C:OnReversedSort(_IsReversedSort)
  self.IsReversedSort = true
  self.IsReversedSort = false
  local PetReversedSort = self.uiData.PetSortInfo
  local temporaryList = {}
  for i = 1, #PetReversedSort do
    if true == PetReversedSort[i].IsHasPet then
      table.insert(temporaryList, PetReversedSort[i])
    end
  end
  if true == _IsReversedSort then
    self:PetListSort(false, temporaryList)
  else
    self:PetListSort(true, temporaryList)
  end
  temporaryList = self:SetPetNum(temporaryList)
  self.FreeList = {}
  self:SetFreeNum()
  self.uiData.PetSortInfo = temporaryList
  self.GridView1:InitGridView(temporaryList)
  if false == self.uiData.PetSortInfo[1].PetData.IsOpenTeam and false == self.IsbMultipleChoice then
    self.GridView1:SelectItemByIndex(0)
  end
end

function UMG_PetWarehouse_C:OnFightBtnClick()
  if self.petInfoMainCtrl and self.IsbMultipleChoice == false then
    self.petInfoMainCtrl:ShowPetFormlntoColumns(2)
    self.IsOpenTeamBtn = true
    self:UpdateFightBtn()
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(PetUIModuleEvent.PET_TEAM_OPEND, true)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1222, "UMG_PetItemTemplate_C:OnItemSelectedIsFree ")
  end
end

function UMG_PetWarehouse_C:UpdateFightBtn()
  if self.IsOpenTeamBtn then
    self.UMG_FightBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCButton:SetRenderOpacity(0.5)
    self.NRCButton_0:SetRenderOpacity(0.5)
    self.NRCImage_131:SetRenderOpacity(0.5)
    self.TText:SetRenderOpacity(0.5)
  else
    self.NRCButton:SetRenderOpacity(1)
    self.NRCButton_0:SetRenderOpacity(1)
    self.UMG_FightBtn:SetRenderOpacity(1)
    self.NRCImage_131:SetRenderOpacity(1)
    self.TText:SetRenderOpacity(1)
    self.UMG_FightBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_PetWarehouse_C:OnNRCButton_0Click()
  if self.IsOpenTeamBtn then
    return
  end
  local TeamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.uiData.PetInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local curPetInfo = self:GetPetInfo()
  if not curPetInfo then
    return
  end
  for i, petInfo in ipairs(curPetInfo) do
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_conf_id)
    if nil == petBaseConf or petBaseConf.ban_free and 1 == petBaseConf.ban_free then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehouse_2 .. (petBaseConf and petBaseConf.name) .. LuaText.umg_petwarehouse_3)
      return
    end
    local IsTeamPet = self:IsTeamPetS(petInfo, TeamInfo)
    if false == IsTeamPet then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehouse_4)
      return
    end
  end
  if #self.FreeList < 1 then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehouse_5)
    return
  end
  NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OpenMiracleExchange, {data = curPetInfo})
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1221, "UMG_PetWarehouse_C:OnNRCButton_0ClickPetFree ")
end

function UMG_PetWarehouse_C:OnNRCButton()
  if self.IsOpenTeamBtn then
    return
  end
  if self.IsbMultipleChoice == false then
    self.IsbMultipleChoice = true
    self:SetIsNewPet(self.uiData.PetSortInfo)
    self.petInfoMainCtrl:SetIsNewPet()
    self:setBatchType(self.IsbMultipleChoice)
    self.GridView1:InitGridView(self.uiData.PetSortInfo)
    self.FreeList = {}
    self:SetFreeNum()
    self.NRCButton_0:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Box:SetVisibility(UE4.ESlateVisibility.Visible)
    self.UMG_FightBtn:SetRenderOpacity(0.5)
    self.NumText:SetVisibility(UE4.ESlateVisibility.Visible)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1219, "UMG_PetWarehouse_C:OnNRCButtonB")
  else
    self.IsbMultipleChoice = false
    for i, v in ipairs(self.uiData.PetSortInfo) do
      if v.IsFree then
        v.IsFree = false
      end
    end
    self:setBatchType(self.IsbMultipleChoice)
    self.GridView1:InitGridView(self.uiData.PetSortInfo)
    if false == self.uiData.PetSortInfo[1].PetData.IsOpenTeam then
      self.GridView1:SelectItemByIndex(self.curPetListSelectIndex - 1)
    end
    self.Box:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.UMG_FightBtn:SetRenderOpacity(1)
    self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_PetWarehouse_C:OnNRCButtonB")
  end
end

function UMG_PetWarehouse_C:SortItemList(petList, SortType)
  Log.Trace(SortType, "UMG_PetWarehouse_C:SortItemList")
  local sortIndex = SortType
  if SortType == _G.Enum.PetSequenceDefault.SEQUENCE_LEVEL_DOWN then
    return self:SortPetInfo(petList, sortIndex)
  elseif SortType == _G.Enum.PetSequenceDefault.SEQUENCE_CATCH_DOWN then
    return self:SortPetInfo(petList, sortIndex)
  elseif SortType == _G.Enum.PetSequenceDefault.SEQUENCE_HP_DOWN then
    return self:SortPetInfo(petList, sortIndex)
  elseif SortType == _G.Enum.PetSequenceDefault.SEQUENCE_PHYATK_DOWN then
    return self:SortPetInfo(petList, sortIndex)
  elseif SortType == _G.Enum.PetSequenceDefault.SEQUENCE_SPEATK_DOWN then
    return self:SortPetInfo(petList, sortIndex)
  elseif SortType == _G.Enum.PetSequenceDefault.SEQUENCE_PHYDEF_DOWN then
    return self:SortPetInfo(petList, sortIndex)
  elseif SortType == _G.Enum.PetSequenceDefault.SEQUENCE_SPEDEF_DOWN then
    return self:SortPetInfo(petList, sortIndex)
  elseif SortType == _G.Enum.PetSequenceDefault.SEQUENCE_SPEED_DOWN then
    return self:SortPetInfo(petList, sortIndex)
  end
end

function UMG_PetWarehouse_C:SortPetInfo(petList, sortIndex)
  local petInfo = {}
  for i, v in ipairs(petList) do
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(v.BaseConfId)
    if sortIndex > 1 then
      local attribute = _G.DataConfigManager:GetAttributeConf(sortIndex - 1)
      table.insert(petInfo, {
        IconListInfo = v[sortIndex],
        PetData = v,
        IsHasPet = true,
        Icon = attribute.attribute_icon,
        IsFree = false,
        IsbMultipleChoice = self.IsbMultipleChoice,
        banFree = petBaseConf.ban_free,
        IconListSortInfo = v[sortIndex]
      })
    else
      table.insert(petInfo, {
        IconListInfo = v[sortIndex],
        PetData = v,
        IsHasPet = true,
        IsFree = false,
        IsbMultipleChoice = self.IsbMultipleChoice,
        banFree = petBaseConf.ban_free,
        IconListSortInfo = v[sortIndex]
      })
    end
  end
  self:PetListSort(true, petInfo)
  self:SetPetNum(petInfo)
  return petInfo
end

function UMG_PetWarehouse_C:PetListSort(_IsAscendingOrder, _PetList)
  if _PetList[1].PetData.IsOpenTeam == false then
    if _IsAscendingOrder then
      table.sort(_PetList, function(a, b)
        if a.IconListSortInfo == b.IconListSortInfo then
          return a.PetData.BaseConfId > b.PetData.BaseConfId
        else
          return a.IconListSortInfo > b.IconListSortInfo
        end
      end)
    else
      table.sort(_PetList, function(a, b)
        if a.IconListSortInfo and b.IconListSortInfo then
          if a.IconListSortInfo == b.IconListSortInfo then
            return a.PetData.BaseConfId < b.PetData.BaseConfId
          else
            return a.IconListSortInfo < b.IconListSortInfo
          end
        end
      end)
    end
  elseif _IsAscendingOrder then
    table.sort(_PetList, function(a, b)
      if a.PetData.CanChangeTeamSort > b.PetData.CanChangeTeamSort then
        return a.PetData.CanChangeTeamSort > b.PetData.CanChangeTeamSort
      elseif a.PetData.CanChangeTeamSort == b.PetData.CanChangeTeamSort and a.IconListSortInfo > b.IconListSortInfo then
        return a.IconListSortInfo > b.IconListSortInfo
      elseif a.PetData.CanChangeTeamSort == b.PetData.CanChangeTeamSort and a.IconListSortInfo == b.IconListSortInfo and a.PetData.BaseConfId > b.PetData.BaseConfId then
        return a.PetData.BaseConfId > b.PetData.BaseConfId
      end
    end)
  else
    table.sort(_PetList, function(a, b)
      if a.PetData.CanChangeTeamSort > b.PetData.CanChangeTeamSort then
        return a.PetData.CanChangeTeamSort > b.PetData.CanChangeTeamSort
      elseif a.PetData.CanChangeTeamSort == b.PetData.CanChangeTeamSort and a.IconListSortInfo < b.IconListSortInfo then
        return a.IconListSortInfo < b.IconListSortInfo
      elseif a.PetData.CanChangeTeamSort == b.PetData.CanChangeTeamSort and a.IconListSortInfo == b.IconListSortInfo and a.PetData.BaseConfId < b.PetData.BaseConfId then
        return a.PetData.BaseConfId < b.PetData.BaseConfId
      end
    end)
  end
end

function UMG_PetWarehouse_C:SetIsNewPet(_PetInfo)
  local petinfo = _PetInfo
  for i, v in ipairs(petinfo) do
    if v.PetData then
      v.PetData.pet_status_flags = 0
    end
  end
end

function UMG_PetWarehouse_C:setBatchType(_IsbMultipleChoice)
  local PetSortInfo = self.uiData.PetSortInfo
  local IsbMultipleChoice = _IsbMultipleChoice
  for i, v in ipairs(PetSortInfo) do
    v.IsbMultipleChoice = IsbMultipleChoice
  end
end

function UMG_PetWarehouse_C:GetdataInfo(petInfo)
  local CurrentItem = os.date("%Y", os.time())
  for i, v in ipairs(petInfo) do
    local IconListItem = os.date("%Y", v.IconListInfo)
    if CurrentItem == IconListItem then
      v.IconListInfo = os.date("%m.%d", v.IconListInfo)
    else
      v.IconListInfo = os.date("%Y", v.IconListInfo)
    end
  end
  return petInfo
end

function UMG_PetWarehouse_C:SetPetNum(_petInfo)
  local petInfo = _petInfo
  local length = #petInfo
  if length < 24 then
    for i = length + 1, 24 do
      table.insert(petInfo, {IsHasPet = false})
    end
  else
    local remainder = length % 6
    if remainder > 0 then
      for i = remainder + 1, 6 do
        table.insert(petInfo, {IsHasPet = false})
      end
    end
  end
  return petInfo
end

function UMG_PetWarehouse_C:IsTeamPetS(_curPetInfo, _TeamInfo)
  local curPetInfo = _curPetInfo
  local teamInfos = _TeamInfo.teams
  for i, team in ipairs(teamInfos) do
    local petInfo = PetUtils.PetTeamFindPetInfoByIndex(team, curPetInfo.gid)
    if petInfo then
      return false
    end
  end
  return true
end

function UMG_PetWarehouse_C:OnScrollPetItemSelected(item, index)
  local OnClickItem = item
  if OnClickItem.PetData.IsOpenTeam then
    self:SetTeamInfo(OnClickItem.PetData.gid, OnClickItem)
  end
  self.curPetListSelectIndex = index
  if self.IsbMultipleChoice == true then
    if table.contains(self.FreeList, self.curPetListSelectIndex) then
      for i, v in ipairs(self.FreeList) do
        if v == self.curPetListSelectIndex then
          table.remove(self.FreeList, i)
        end
      end
    else
      table.insert(self.FreeList, self.curPetListSelectIndex)
    end
  else
    self.FreeList = {}
    table.insert(self.FreeList, self.curPetListSelectIndex)
  end
  self:SetFreeNum()
  if self.OnPetItemClick then
    self:OnPetItemClick(index)
  end
end

function UMG_PetWarehouse_C:OnRemovePetNew(item)
  local PetSortInfo = self.uiData.PetSortInfo
  for i, v in ipairs(PetSortInfo) do
    if v.PetData and v.PetData.gid == item.PetData.gid then
      v.PetData.pet_status_flags = 0
    end
  end
  self.petInfoMainCtrl:OnRemovePetNew(item)
end

function UMG_PetWarehouse_C:OnPetItemClick(_index)
  local petInfos = self.uiData.PetSortInfo
  if self.petInfoMainCtrl and petInfos then
    local petInfo = petInfos[_index]
    if petInfo and petInfo.IsHasPet then
      local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petInfo.PetData.gid)
      self.petInfoMainCtrl:OnSelectPetChange(petData)
    end
  end
end

function UMG_PetWarehouse_C:SetTeamInfo(_gid, _OnClick)
  self.petInfoMainCtrl:SetWareHouseTeamInfo(_gid, _OnClick)
end

function UMG_PetWarehouse_C:GetPetInfo()
  local index = self.FreeList
  local gidData = {}
  local petData = self.uiData.PetInfoList.pet_data
  if not petData or not index then
    return nil
  end
  for i, v in pairs(index) do
    local gid = self.uiData.PetSortInfo[v].PetData.gid
    for j, _petData in ipairs(petData) do
      if gid == _petData.gid then
        table.insert(gidData, _petData)
      end
    end
  end
  return gidData
end

function UMG_PetWarehouse_C:SetOpenTeamBtnState(_State)
  self.IsOpenTeamBtn = _State
end

function UMG_PetWarehouse_C:setPetInfoMainCtrl(_petInfoMainCtrl)
  self.petInfoMainCtrl = _petInfoMainCtrl
end

function UMG_PetWarehouse_C:OnDeactive()
end

return UMG_PetWarehouse_C
