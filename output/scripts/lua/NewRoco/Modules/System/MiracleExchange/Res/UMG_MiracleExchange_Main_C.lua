local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_MiracleExchange_Main_C = _G.NRCPanelBase:Extend("UMG_MiracleExchange_Main_C")
local SceneEnum = require("NewRoco.Modules.Core.Scene.Common.SceneEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local MiracleExchangeModuleEvent = require("NewRoco.Modules.System.MiracleExchange.MiracleExchangeModuleEvent")

function UMG_MiracleExchange_Main_C:OnConstruct()
  self.data = self.module:GetData("MiracleExchangeModuleData")
  self.SortIndex = _G.Enum.PetSequenceDefault.SEQUENCE_LEVEL_DOWN
  self.uiData = {}
  self.PetSortInfo = nil
  self.TipPanelVisible = false
  self.IsReversedSort = false
  self.IsSetSortListInfo = true
  self.IsOnClickTypeBtn = false
  self.IsSelectCurrentPet = false
  self.currentSelectPet = nil
  self.curPetListSelectIndex = 0
  self:OnAddEventListener()
  self.Btn_choose:SetBtnText(LuaText.umg_miracleexchange_main_1)
  self.PetTips.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local showTitle = _G.DataConfigManager:GetLocalizationConf("magic_change_mainui_title").msg
  self.Title_1:SetText(showTitle)
end

function UMG_MiracleExchange_Main_C:OnActive(param)
  self.npcAction = param
  self:PlayAnimation(self.open)
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:GetPetInfoList()
  Log.Dump(self.uiData.PetSortInfo, 6, "UMG_MiracleExchange_Main_C:OnActive(param)")
  for i = 1, #self.uiData.PetSortInfo do
    if not self.uiData.PetSortInfo[i].IsHasPet or self.uiData.PetSortInfo[i].PetData.IsMainTeam or self.uiData.PetSortInfo[i].PetData.IsTeams then
    else
      self.GridView1:SelectItemByIndex(i - 1)
      self.Attribute:SetVisibility(UE4.ESlateVisibility.Visible)
      self.BtnCanvas:SetVisibility(UE4.ESlateVisibility.Visible)
      break
    end
    if i == #self.uiData.PetSortInfo then
      self.Attribute:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.BtnCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_MiracleExchange_Main_C:OnDeactive()
end

function UMG_MiracleExchange_Main_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClicked)
  self:AddButtonListener(self.ShowTipBtn, self.OnShowTipBtnClicked)
  self:AddButtonListener(self.Btn_choose.btnLevelUp, self.OnChooseBtnClicked)
end

function UMG_MiracleExchange_Main_C:OnCloseBtnClicked(bSuccess)
  self.isExchangeSuccess = bSuccess
  self:PlayAnimation(self.close)
end

function UMG_MiracleExchange_Main_C:OnShowTipBtnClicked()
  self.TipPanelVisible = not self.TipPanelVisible
  self:SetTipPanelVisible(self.TipPanelVisible)
end

function UMG_MiracleExchange_Main_C:OnChooseBtnClicked()
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.data.MiracleExchangeMainSelectPetGid)
  if petData then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    if petBaseConf and petBaseConf.ban_free and 1 == petBaseConf.ban_free then
      local text = _G.DataConfigManager:GetLocalizationConf("magic_change_dimo").msg
      local text1 = string.format(text, petBaseConf.name)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, text1)
      return
    end
    local exchangeTable = {
      data = {petData},
      type = SceneEnum.MiracleExchangeType.RECEIVE,
      npcId = self.npcAction.Owner.owner.serverData.base.actor_id
    }
    local ballId = 100002
    local info = self.npcAction.Owner.owner.serverData.miracle_change_info
    if info and info.ball_cfg_id > 0 then
      ballId = info.ball_cfg_id
    else
      Log.Warning("UMG_MiracleExchange_Main_C: ball_cfg_id == 0")
    end
    exchangeTable.ballId = self.npcAction.Owner.owner.serverData.miracle_change_info.ball_cfg_id
    exchangeTable.npcAction = self.npcAction
    self.module:OnCmdOpenMiracleExchange(exchangeTable)
  else
    Log.Error("\229\174\160\231\137\169\230\149\176\230\141\174\230\178\161\230\156\137\230\137\190\229\136\176")
  end
end

function UMG_MiracleExchange_Main_C:SelectItem(petgid, item, index)
  if not petgid then
    return
  end
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petgid)
  self.currentSelectPet = item
  self.curPetListSelectIndex = index
  local petConfId = petData.base_conf_id
  self:ChangePetModel(petData, petConfId)
  self.PetTips:SetPetInfo(petData, nil)
  self:SetNameInfo(petgid)
end

function UMG_MiracleExchange_Main_C:SetTipPanelVisible(bVisible)
  if bVisible then
    self.PetTips:ShowInPetWarehouse()
    self.PetTips:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.PetTips:Hide(true, false)
  end
end

function UMG_MiracleExchange_Main_C:GetTypeChooseNum()
end

function UMG_MiracleExchange_Main_C:UpdatePetInfoList()
end

function UMG_MiracleExchange_Main_C:GetPetInfoList()
  local AllPetInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local PetList = self:EliminateFreePet(AllPetInfo.pet_data)
  local PetTeamInfo = PetUtils.PlayerPetInfoGetTeamInfo(AllPetInfo, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local PetInfoList = {}
  local index = 1
  for _, petinfo in ipairs(PetList) do
    if not BattleUtils.GetBit(petinfo.pet_status_flags, 1) then
      local IsTeams = false
      local IsMainTeam = false
      local pos = 0
      if PetTeamInfo.teams then
        for j, team in ipairs(PetTeamInfo.teams) do
          local petInfo, petInfoIndex = PetUtils.PetTeamFindPetInfoByIndex(team, petinfo.gid)
          if petInfo then
            if j == PetTeamInfo.main_team_idx + 1 then
              IsMainTeam = true
              pos = petInfoIndex
            end
            IsTeams = true
          end
        end
      end
      if petinfo.base_conf_id then
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petinfo.base_conf_id)
        if petBaseConf then
          local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
          table.insert(PetInfoList, {
            petinfo.level,
            gid = petinfo.gid,
            PetIcon = modelConf,
            IsOpenTeam = false,
            pet_status_flags = petinfo.pet_status_flags or 0,
            BaseConfId = petinfo.base_conf_id,
            CanChangeTeam = petinfo.enable_change,
            CanChangeTeamSort = petinfo.enable_change and 1 or 0,
            energy = petinfo.energy,
            IsTeams = IsTeams,
            IsMainTeam = IsMainTeam,
            pos = pos,
            gender = petinfo.gender,
            ball_id = petinfo.ball_id
          })
        end
      end
      for j = 2, 8 do
        local PetBasicProperty
        if 1 == j then
          PetBasicProperty = petinfo.additional_attr.addi_attr[j]
        elseif 2 == j then
          local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petinfo.base_conf_id)
          PetBasicProperty = petBaseConf.quality
        else
          PetBasicProperty = petinfo.additional_attr.addi_attr[j - 1]
        end
        if PetBasicProperty then
          table.insert(PetInfoList[index], PetBasicProperty)
        end
      end
      index = index + 1
    end
  end
  self:UpdatePetInfo(AllPetInfo, PetInfoList)
end

function UMG_MiracleExchange_Main_C:EliminateFreePet(_PetData)
  local PetData = _PetData
  local PetList = {}
  for i, PetInfo in ipairs(PetData) do
    local isExchange = PetInfo.pet_status_flags and PetInfo.pet_status_flags & ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
    if not isExchange then
      table.insert(PetList, PetInfo)
    end
  end
  return PetList
end

function UMG_MiracleExchange_Main_C:UpdatePetInfo(petInfoList, petHeadInfo)
  self.uiData.PetInfoList = petInfoList
  self.uiData.petHeadInfo = petHeadInfo
  self.uiData.PetSortInfo = nil
  self:SetPetList()
end

function UMG_MiracleExchange_Main_C:SetPetList()
  self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
  if self.IsSetSortListInfo == true then
    self:SetSortListInfo()
  end
  self.IsSetSortListInfo = true
end

function UMG_MiracleExchange_Main_C:SortItemList(petList, SortType)
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

function UMG_MiracleExchange_Main_C:SortPetInfo(petList, sortIndex)
  local petInfoList = {}
  for i, v in ipairs(petList) do
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(v.BaseConfId)
    if sortIndex > 1 then
      local attribute = _G.DataConfigManager:GetAttributeConf(sortIndex - 1)
      table.insert(petInfoList, {
        IconListInfo = v[1],
        PetData = v,
        IsHasPet = true,
        Icon = attribute.attribute_icon,
        BaseConfId = v.BaseConfId,
        IsFree = false,
        IsbMultipleChoice = self.IsbMultipleChoice,
        banFree = petBaseConf.ban_free,
        IconListSortInfo = v[sortIndex + 1]
      })
    else
      table.insert(petInfoList, {
        IconListInfo = v[1],
        PetData = v,
        IsHasPet = true,
        BaseConfId = v.BaseConfId,
        IsFree = false,
        IsbMultipleChoice = self.IsbMultipleChoice,
        banFree = petBaseConf.ban_free,
        IconListSortInfo = v[sortIndex]
      })
    end
  end
  local curTeamPetList = {}
  local teamPet = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  for k, v in ipairs(petInfoList) do
    for i = 1, #teamPet do
      if v.PetData.gid == teamPet[i].gid then
        table.insert(curTeamPetList, v)
        break
      end
    end
  end
  Log.Dump(petInfoList[1].PetData.IsOpenTeam, 6, "UMG_MiracleExchange_Main_C:SortPetInfo")
  self:PetListSort(true, petInfoList)
  self:SetPetNum(petInfoList)
  return petInfoList
end

function UMG_MiracleExchange_Main_C:PetListSort(_IsAscendingOrder, _PetList)
  if _IsAscendingOrder then
    table.sort(_PetList, function(a, b)
      local Min = a.IconListSortInfo
      local Max = b.IconListSortInfo
      if a.PetData.IsMainTeam == true then
        Min = 10000 - a.PetData.pos
      end
      if b.PetData.IsMainTeam == true then
        Max = 10000 - b.PetData.pos
      end
      if Min == Max then
        return a.PetData.BaseConfId > b.PetData.BaseConfId
      else
        return Min > Max
      end
    end)
  else
    table.sort(_PetList, function(a, b)
      if a.IconListSortInfo and b.IconListSortInfo then
        local Min = a.IconListSortInfo
        local Max = b.IconListSortInfo
        if a.PetData.IsMainTeam == true then
          Min = a.PetData.pos - 1000
        end
        if b.PetData.IsMainTeam == true then
          Max = b.PetData.pos - 1000
        end
        if Min == Max then
          return a.PetData.BaseConfId < b.PetData.BaseConfId
        else
          return Min < Max
        end
      end
    end)
  end
end

function UMG_MiracleExchange_Main_C:SetPetNum(_petInfoList)
  local petInfoList = _petInfoList
  local length = #petInfoList
  if length < 24 then
    for i = length + 1, 24 do
      table.insert(petInfoList, {IsHasPet = false})
    end
  else
    local remainder = length % 6
    if remainder > 0 then
      for i = remainder + 1, 6 do
        table.insert(petInfoList, {IsHasPet = false})
      end
    end
  end
  return petInfoList
end

function UMG_MiracleExchange_Main_C:OnReversedSort(_IsReversedSort)
  self.IsReversedSort = true
  self.IsSelectCurrentPet = true
  self.IsReversedSort = false
  Log.Dump(self.uiData.PetSortInfo, 4, "eeeeeeeeeee")
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
  self.uiData.PetSortInfo = temporaryList
  self:RefreshPetListByChooseType(self.data.chooseTypeList)
end

function UMG_MiracleExchange_Main_C:SortItemInfo(_index)
  local ListVisible = self.DropDownList:GetbListVisible()
  if true == ListVisible then
    self.IsSelectCurrentPet = true
  end
  self.SortIndex = _index
  self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
  if self.IsReversedSort == false then
    self.DropDownList:SetReversedSort()
  end
end

function UMG_MiracleExchange_Main_C:SortItem(_petinfo, sortType)
  local sortlist = self:SortItemList(_petinfo, sortType)
  self.uiData.PetSortInfo = sortlist
  if self.uiData.PetSortInfo then
    self:RefreshPetListByChooseType(self.data.chooseTypeList)
  end
  self.DropDownList:SelectItem(sortType)
end

function UMG_MiracleExchange_Main_C:OnRemovePetNew(item)
  local PetSortInfo = self.uiData.PetSortInfo
  for i, v in ipairs(PetSortInfo) do
    if v.PetData and v.PetData.gid == item.PetData.gid then
      v.PetData.pet_status_flags = 0
    end
  end
  _G.DataModelMgr.PlayerDataModel:SetPetNewState(item.PetData)
end

function UMG_MiracleExchange_Main_C:OnClickTypeBtn(TypeChooseList)
  self.IsSetSortListInfo = false
  self.IsOnClickTypeBtn = true
  self.IsSelectCurrentPet = true
  self.FreeList = {}
  self:GetPetInfoList()
  self.IsOnClickTypeBtn = false
end

function UMG_MiracleExchange_Main_C:RefreshPetListByChooseType(TypeChooseList)
  local typeList = {}
  if #TypeChooseList > 0 then
    for i = 1, #self.uiData.PetSortInfo do
      if self.uiData.PetSortInfo[i].PetData then
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.PetSortInfo[i].PetData.BaseConfId)
        if 1 == #TypeChooseList then
          for k = 1, #petBaseConf.unit_type do
            if petBaseConf.unit_type[k] == TypeChooseList[1] then
              table.insert(typeList, self.uiData.PetSortInfo[i])
            end
          end
        elseif 2 == #TypeChooseList and #petBaseConf.unit_type >= 2 then
          local matchNum = 0
          for k = 1, #petBaseConf.unit_type do
            for j = 1, #TypeChooseList do
              if petBaseConf.unit_type[k] == TypeChooseList[j] then
                matchNum = matchNum + 1
              end
            end
          end
          if 2 == matchNum then
            table.insert(typeList, self.uiData.PetSortInfo[i])
          end
        end
      end
    end
    for i = #typeList + 1, 24 do
      table.insert(typeList, {IsHasPet = false})
    end
  else
    typeList = self.uiData.PetSortInfo
  end
  self.GridView1:InitGridView(typeList)
  if self.IsFreeSuccess or self.IsSelectCurrentPet == true then
    local IsFind = self:UpdateSelectPetIndex(typeList, self.currentSelectPet)
    if true == IsFind then
      self.GridView1:SelectItemByIndex(self.curPetListSelectIndex - 1)
    end
    self.IsSelectCurrentPet = false
  end
end

function UMG_MiracleExchange_Main_C:UpdateSelectPetIndex(_PetList, _currentSelectPet)
  local PetList = _PetList
  for i, Pet in ipairs(PetList) do
    if Pet.PetData and _currentSelectPet and Pet.PetData.gid == _currentSelectPet.PetData.gid then
      self.curPetListSelectIndex = i
      return true
    end
  end
  return false
end

function UMG_MiracleExchange_Main_C:UpdateCurrentSelectPet(_PetList)
  local PetList = _PetList
  if PetList[self.curPetListSelectIndex] and PetList[self.curPetListSelectIndex].PetData then
    self.currentSelectPet = PetList[self.curPetListSelectIndex]
  else
    local Index = self:LastPetData(PetList)
    if PetList[Index] and PetList[Index].PetData then
      self.currentSelectPet = PetList[Index]
    else
      self.currentSelectPet = self.uiData.PetSortInfo[1]
      self:SelectItem(self.currentSelectPet.gid)
    end
  end
end

function UMG_MiracleExchange_Main_C:LastPetData(_PetDataList)
  local PetDataList = _PetDataList
  for i, v in ipairs(PetDataList) do
    if v.PetData == nil then
      if 1 == i then
        return i
      else
        return i - 1
      end
    end
  end
  return #PetDataList
end

function UMG_MiracleExchange_Main_C:SetNameInfo(petgid)
  local petDataInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petgid)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petDataInfo.base_conf_id)
  local petLv = PetUtils.GetCatchHardInfo(petDataInfo)
  local petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
  }
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(petDataInfo.blood_id)
  self.icon_3:SetPath(PetBloodConf.icon)
  self.CatchHardLv:InitGridView(petLv)
  self.NameTxt:SetText(petDataInfo.name)
  self.Resonance:SetText(LuaText.umg_miracleexchange_main_2 .. petDataInfo.level)
  local petType = petBaseConf.unit_type
  for i, TypeIcon in ipairs(petTypeIcons) do
    TypeIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if i <= #petType then
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType[i])
      if typeDic then
        TypeIcon:SetPath(typeDic.type_icon)
        TypeIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_MiracleExchange_Main_C:ChangePetModel(petData, petBaseConfId)
  if petBaseConfId then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseConfId)
    self.PetRTImage:InitPetActor(petBaseConfId, petData)
  end
end

function UMG_MiracleExchange_Main_C:SetSortListInfo()
  local sortIndex = self.SortIndex - 1
  self.DropDownList:OnActive(sortIndex)
end

function UMG_MiracleExchange_Main_C:OnAnimationFinished(anim)
  if anim == self.close then
    if self.npcAction then
      if self.isExchangeSuccess then
        self.npcAction:Finish(true, nil, "T")
      else
        self.npcAction:Finish(false, nil, "F")
      end
    end
    self:DoClose()
  elseif anim == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

return UMG_MiracleExchange_Main_C
