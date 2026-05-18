local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local JsonUtils = require("Common.JsonUtils")
local UMG_PetWarehouseMain_C = _G.NRCPanelBase:Extend("UMG_PetWarehouseMain_C")
local PetWarehouseMainUiData

function UMG_PetWarehouseMain_C:OnConstruct()
  self.firstSelectItem = true
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetDistrictMapGuideRecordEnable, true, "UMG_PetWarehouseMain_C")
end

function UMG_PetWarehouseMain_C:OnActive()
  self.uiData = {}
  self.petInfoList = nil
  self.curPetData = nil
  self.OldSelectPet = nil
  self.curPetListSelectIndex = 0
  self.currentSelectPet = nil
  self.IsSelectCurrentPet = false
  self.IsFreeSuccess = false
  self.IsOnClickTypeBtn = false
  self.IsSetSortListInfo = true
  self.SortIndex = self.module.PetWareHouseSort
  self.IsbMultipleChoice = false
  self.IsReversedSort = false
  self.bIsScreening = false
  self.FreeList = {}
  self.IsUpdateNewPetState = false
  self.IsSelectFirst = false
  self.data = self.module:GetData("PetUIModuleData")
  self.ShowTeamIndex = false
  local showTeam = JsonUtils.LoadSaved("ShowTeamRecord", {})
  if showTeam[1] then
    self.ShowTeamIndex = not self.ShowTeamIndex
    local Index = self.ShowTeamIndex and 1 or 0
    self.CheckSwitcher:SetActiveWidgetIndex(Index)
  end
  self:OnAddEventListener()
  self:SetCommonTitle()
  self.icon = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_zhankai_png.img_zhankai_png'"
  self.FirstEnter = true
  self:GetPetInfoList()
  self:FirstEnterWareHouseMain()
  self.TipPanelVisible = false
  self.FilterListInfo = {}
  self:SetCommonComboBoxInfo(self.ComboBox)
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
  self.CheckSwitcher:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetIsShowPetNotUnlockSkill, false)
  self.ShadeImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetWarehouseMain_C:SetCommonComboBoxInfo(ComboBox, ComboBoxText, ComboBoxIcon)
  local CommonDropDownListData = _G.NRCCommonDropDownListData()
  if ComboBoxText then
    CommonDropDownListData.DropDownListText = ComboBoxText
  end
  if ComboBoxIcon then
    CommonDropDownListData.DropDownListIcon = ComboBoxIcon
  end
  CommonDropDownListData.Call = self
  CommonDropDownListData.Btn_LeftHandler = self.OpenFilterPanelBtnClick
  CommonDropDownListData.Btn_MidHandler = self.OpenSortPanelBtnClick
  CommonDropDownListData.Btn_RightHandler = self.OnReversedSort
  ComboBox:SetPanelInfo(CommonDropDownListData)
end

function UMG_PetWarehouseMain_C:SetNameInfo(petData)
  local petDataInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petData.gid)
  if not petDataInfo then
    return
  end
  local commonAttrData = {}
  local commonAttrData1 = {}
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.BaseConfId)
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
  local BreakThroughStarsList = PetUtils.GetBreakThroughStarsList(petDataInfo)
  self.CatchHardLv:InitGridView(BreakThroughStarsList)
  self.textPetName:SetText(petDataInfo.name)
end

function UMG_PetWarehouseMain_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_PetWarehouseMain_C:GetPetInfoList()
  self.petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local petData = self:EliminateFreePet(self.petInfoList.pet_data)
  local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local PvPteamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.petInfoList, Enum.PlayerTeamType.PTT_PVP_BATTLE_1)
  local PetInfoList = {}
  local index = 1
  for _, petinfo in ipairs(petData) do
    local StarList, StarNum = PetUtils.GetResidueGrowCountAndGrowOrder(petinfo)
    if StarNum then
      StarNum = StarNum - 1
    else
      StarNum = 0
    end
    if not BattleUtils.GetBit(petinfo.pet_status_flags, 1) then
      local IsTeams = false
      local IsPvPTeam = false
      local IsInBackPack
      local BackPackIndex = 0
      local pos = 0
      local TeamPos = 0
      if teamInfo and teamInfo.teams then
        for j, team in ipairs(teamInfo.teams) do
          local petInfo, petInfoIndex = PetUtils.PetTeamFindPetInfoByIndex(team, petinfo.gid)
          if petInfo then
            pos = petInfoIndex + j * 10
            TeamPos = j
            IsTeams = true
          end
        end
      end
      if not self.ShowTeamIndex and IsTeams then
      else
        if PvPteamInfo and PvPteamInfo.teams then
          for j, team in ipairs(PvPteamInfo.teams) do
            local petInfo = PetUtils.PetTeamFindPetInfoByIndex(team, petinfo.gid)
            if petInfo then
              IsPvPTeam = true
            end
          end
        end
        if IsInBackPack then
          pos = BackPackIndex
        end
        if petinfo.base_conf_id then
          local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petinfo.base_conf_id)
          if petBaseConf then
            local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
            local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, petinfo.gid)
            local isInHome = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetPetIsInHome, petinfo.gid)
            local isInGuard = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePlantGuardPetGid) == petinfo.gid
            table.insert(PetInfoList, {
              petinfo.level,
              gid = petinfo.gid,
              PetIcon = modelConf,
              IsOpenTeam = false,
              pet_status_flags = petinfo.pet_status_flags or 0,
              BaseConfId = petinfo.base_conf_id,
              CanChangeTeam = petinfo.enable_change,
              CanChangeTeamSort = petinfo.enable_change and 1 or 0,
              starLevel = StarNum,
              IsInBackPack = IsInBackPack,
              TeamPos = TeamPos,
              energy = petinfo.energy,
              IsTeams = IsTeams,
              IsPvPTeam = IsPvPTeam,
              IsTravel = isTravel,
              IsInHome = isInHome,
              IsInGuard = isInGuard,
              pos = pos,
              gender = petinfo.gender,
              ball_id = petinfo.ball_id,
              PetBaseInfo = petinfo
            })
            PetInfoList[#PetInfoList].SortNum = self:GetSortNum(PetInfoList[#PetInfoList])
          end
        end
        for j = 2, 11 do
          local PetBasicProperty
          if 1 == j then
            PetBasicProperty = petinfo.level
          elseif 2 == j then
            PetBasicProperty = petinfo.add_time
          elseif j <= 8 then
            PetBasicProperty = PetUtils.GetPetAdditionalByType(petinfo, j - 2) or 0
          elseif 9 == j then
            PetBasicProperty = petinfo.talent_rank
          elseif 10 == j then
            if petinfo.partner_mark and petinfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
              PetBasicProperty = petinfo.partner_mark
            else
              PetBasicProperty = -1
            end
          elseif 11 == j then
            if petinfo.grow_times then
              PetBasicProperty = petinfo.grow_times
            else
              PetBasicProperty = 0
            end
          end
          if PetBasicProperty then
            table.insert(PetInfoList[index], PetBasicProperty)
          end
        end
        index = index + 1
      end
    end
  end
  self.petInfoList.petHeadInfo = PetInfoList
  self.PetNumLimit = _G.DataConfigManager:GetPetGlobalConfig("pet_depot_number_max").num
  self.PetNum = #PetInfoList
end

function UMG_PetWarehouseMain_C:UpdateResonanceList()
  local teamInfo = {}
  local petInfos = {}
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  for i, pet_data in ipairs(battlePetList) do
    table.insert(petInfos, PetUtils.PetInfoCreate(pet_data.gid))
  end
  teamInfo.pet_infos = petInfos
  local activedResonances = PetUtils.GetPetTeamActivedResonances(teamInfo)
  if not activedResonances or #activedResonances <= 0 then
    self.ResonanceList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ResonanceList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetWarehouseMain_C:EliminateFreePet(_PetData)
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
  return PetList
end

function UMG_PetWarehouseMain_C:OnPetFreeSuccess()
  self.IsSetSortListInfo = false
  self.IsFreeSuccess = true
  self.IsSelectCurrentPet = true
  self:PlayAnimation(self.Batch_UnSelect)
  self.IsbMultipleChoice = false
  self.Btn_Cultivate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Btn_Exchange:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.Btn_In)
  self:SetFreeNum()
  self:FreeSelectPetIndex(self.uiData.PetSortInfo)
  self:GetPetInfoList()
  self.IsFreeSuccess = false
end

function UMG_PetWarehouseMain_C:FreeSelectPetIndex(_PetDataList)
  local FreeList = self.FreeList
  local PetDataList = _PetDataList
  if #FreeList > 1 then
    for i, v in pairs(FreeList) do
      for j, petData in ipairs(PetDataList) do
        if petData.PetData and v == petData.PetData.gid and j < self.curPetListSelectIndex then
          self.curPetListSelectIndex = j
        end
      end
    end
  end
end

function UMG_PetWarehouseMain_C:UpdateTipsInfo(petData)
  self.module:UpDatePetConfirmPanel(petData.PetData)
end

function UMG_PetWarehouseMain_C:OnDestruct()
  JsonUtils.DumpSaved("ShowTeamRecord", {
    self.ShowTeamIndex
  })
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.HideOrShowPets, true)
  _G.NRCModuleManager:DoCmd(CampingModuleCmd.SetIsCultivatePet, false)
  self.data.chooseTypeList = {
    DepartmentFilter = {},
    TalentFilter = {},
    NaturePositiveEffectFilter = {},
    AttributeFilter = {}
  }
  self:OnRemoveEventListener()
  GlobalConfig.OpenMainPanelFromDebugBtn = 0
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetDistrictMapGuideRecordEnable, false, "UMG_PetWarehouseMain_C")
end

function UMG_PetWarehouseMain_C:UpdatePetInfo(petInfoList, petHeadInfo)
  self.uiData.PetInfoList = petInfoList
  self.uiData.petHeadInfo = petHeadInfo
  self.uiData.PetSortInfo = nil
  self:SetPetList()
end

function UMG_PetWarehouseMain_C:OnCheckedState()
  self.ShowTeamIndex = not self.ShowTeamIndex
  local Index = self.ShowTeamIndex and 1 or 0
  self.CheckSwitcher:SetActiveWidgetIndex(Index)
  self:OnUpdatePetWareHouseInfo()
end

function UMG_PetWarehouseMain_C:OnAddEventListener()
  self:AddButtonListener(self.CheckButton, self.OnCheckedState)
  self:AddButtonListener(self.CloseBtn_1.btnClose, self.OnCloseBtnClicked)
  self:AddButtonListener(self.Btn_Details, self.OnShowTipBtnClicked)
  self:AddButtonListener(self.Btn_Cultivate.btnLevelUp, self.OnBtnSkillClicked)
  self:AddButtonListener(self.Btn_Exchange.btnLevelUp, self.OpenExChangeMainPetPanelBtnClick)
  self:AddButtonListener(self.DepartBtn, self.OpenPetTips)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.BatchSelect.btnLevelUp, self.OnFreeBtnClick)
  self:AddButtonListener(self.Btn_ShutDown, self.ResetDescText)
  self.BloodPulse.OnPressed:Add(self, self.OnBloodPulsePressed)
  self.BloodPulse.OnReleased:Add(self, self.OnBloodPulseReleased)
  self.DepartBtn.OnPressed:Add(self, self.OnDepartBtnPressed)
  self.DepartBtn.OnReleased:Add(self, self.OnDepartBtnReleased)
  self:RegisterEvent(self, PetUIModuleEvent.ExChangeMainPetPanel, self.OpenExChangeMainPetPanelBtnClick)
  self:RegisterEvent(self, PetUIModuleEvent.CultivatePet, self.OnBtnCultivateClicked)
  self:RegisterEvent(self, PetUIModuleEvent.ChangeChooseHousePet, self.OnScrollPetItemSelected)
  self:RegisterEvent(self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
  self:RegisterEvent(self, PetUIModuleEvent.RemovePetNew, self.OnRemovePetNew)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_SORT, self.SortItemInfo)
  self:RegisterEvent(self, PetUIModuleEvent.SetWarehousePetSortIndex, self.SetPetSortIndex)
  self:RegisterEvent(self, PetUIModuleEvent.PET_FREE_SUCCESS, self.OnPetFreeSuccess)
  self:RegisterEvent(self, PetUIModuleEvent.UpdatePetCollect, self.UpdateCollect)
  self:RegisterEvent(self, PetUIModuleEvent.EQUIP_SKILL_SUCCESS, self.OnEquippedSuccess)
  self:RegisterEvent(self, PetUIModuleEvent.OnPetWareHouseFreeClose, self.OnUpdatePetWareHouseInfo)
  self:RegisterEvent(self, PetUIModuleEvent.OnPetWareHouseUpdate, self.OnUpdatePetWareHouseInfo)
  self:RegisterEvent(self, PetUIModuleEvent.OnSendPetSuccess, self.OnSendPetSuccess)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.RELOGIN_UPDATE_PET, self.OnUpdatePetWareHouseInfo)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.PET_FLAG_CHANGE, self.OnPetFreeSuccess)
  _G.NRCEventCenter:RegisterEvent("UMG_PetWarehouseMain_C", self, PetUIModuleEvent.OpenChangePetConfirm, self.OnShowTipBtnClicked)
  _G.NRCEventCenter:RegisterEvent("UMG_PetWarehouseMain_C", self, PetUIModuleEvent.OnBagSKillTipsPanelShowChange, self.OnBagSKillTipsPanelShowChange)
end

function UMG_PetWarehouseMain_C:OnEquippedSuccess(_changes)
  for i, changItem in ipairs(_changes) do
    if changItem.type == _G.ProtoEnum.GoodsType.GT_PET then
      local petData = changItem.pet_data
      if self.curPetData.gid == petData.gid then
        self.curPetData = petData
        for j = 1, #self.petInfoList.petHeadInfo do
          if self.petInfoList.petHeadInfo[j].PetBaseInfo.gid == petData.gid then
            self.petInfoList.petHeadInfo[j].PetBaseInfo.gid = petData.gid
            break
          end
        end
      end
    end
  end
  local itemcount = self.GridView1:GetTotalItemNumber()
  for i = 1, itemcount do
    self.GridView1:OpItemByIndex(i, {
      type = 4,
      curPetData = self.curPetData
    })
  end
end

function UMG_PetWarehouseMain_C:UpdateCollect(partner_mark)
  if self.curPetData and partner_mark == self.curPetData.partner_mark then
    return
  end
  self.curPetData.partner_mark = partner_mark
  local itemcount = self.GridView1:GetTotalItemNumber()
  for i = 1, itemcount do
    self.GridView1:OpItemByIndex(i, {
      type = 1,
      curPetData = self.curPetData
    })
  end
  for i = 1, #self.petInfoList.petHeadInfo do
    if self.petInfoList.petHeadInfo[i].PetBaseInfo.gid == self.curPetData.gid then
      self.petInfoList.petHeadInfo[i].PetBaseInfo.partner_mark = self.curPetData.partner_mark
      if self.curPetData.partner_mark and self.curPetData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
        self.petInfoList.petHeadInfo[i][10] = self.curPetData.partner_mark
        break
      end
      self.petInfoList.petHeadInfo[i][10] = -1
      break
    end
  end
  if self.SortIndex == Enum.PetSequenceDefault.SEQUENCE_COLLECTION_DOWN then
    self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
  end
end

function UMG_PetWarehouseMain_C:OnFreeBtnClick()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET_FREE, true)
  if isBan then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_FavoriteButton_C:UpdateInfo")
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetFreeMainPanel)
end

function UMG_PetWarehouseMain_C:ResetDescText()
end

function UMG_PetWarehouseMain_C:OnBloodPulsePressed()
  self:StopAnimation(self.Press_1)
  self:StopAnimation(self.Up_1)
  self:PlayAnimation(self.Press_1)
end

function UMG_PetWarehouseMain_C:OnBloodPulseReleased()
  self:StopAnimation(self.Press_1)
  self:StopAnimation(self.Up_1)
  self:PlayAnimation(self.Up_1)
end

function UMG_PetWarehouseMain_C:OnDepartBtnPressed()
  self:StopAnimation(self.Press_2)
  self:StopAnimation(self.Up_2)
  self:PlayAnimation(self.Press_2)
end

function UMG_PetWarehouseMain_C:OnDepartBtnReleased()
  self:StopAnimation(self.Press_2)
  self:StopAnimation(self.Up_2)
  self:PlayAnimation(self.Up_2)
end

function UMG_PetWarehouseMain_C:OpenPetTips()
  if self.curPetData then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curPetData.gid)
    local uidata = {petData = petData}
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, uidata, _G.Enum.GoodsType.GT_PET)
  else
    Log.Error("UMG_PetWarehouseMain_C curPetData is nil")
  end
end

function UMG_PetWarehouseMain_C:OnBloodPulse()
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curPetData.gid)
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetBloodPulse, petData, TipEnum.OpenPetTipsType.PetWareHouse)
end

function UMG_PetWarehouseMain_C:OnRemoveEventListener()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.RELOGIN_UPDATE_PET, self.OnUpdatePetWareHouseInfo)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.PET_FLAG_CHANGE, self.OnPetFreeSuccess)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.OpenChangePetConfirm, self.OnShowTipBtnClicked)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.OnBagSKillTipsPanelShowChange, self.OnBagSKillTipsPanelShowChange)
end

function UMG_PetWarehouseMain_C:OnUpdatePetWareHouseInfo()
  self.IsSelectCurrentPet = true
  self.IsSetSortListInfo = false
  self.FreeList = {}
  self:SetFreeNum()
  self:GetPetInfoList()
end

function UMG_PetWarehouseMain_C:OnCloseBtnClicked()
  self.ShadeImage:SetVisibility(UE4.ESlateVisibility.Visible)
  self:CloseAllTipsPanel()
  _G.NRCAudioManager:PlaySound2DAuto(1008, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:PlayAnimation(self.close)
end

function UMG_PetWarehouseMain_C:OnShowTipBtnClicked()
  if self.data.bPetWarehouseTipBtnEnable then
    self:SetTipPanelVisible(true, false)
    _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
    _G.NRCModuleManager:DoCmd(CampingModuleCmd.OpenPetWarehouseTips, true)
  end
end

function UMG_PetWarehouseMain_C:OpenSortPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:PlayAnimation(self.SelectButton_Press)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenSortPanel, self.SortIndex, PetUIModuleEnum.OpenSortType.WareHouse)
end

function UMG_PetWarehouseMain_C:OpenExChangeMainPetPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  if self.currentSelectPet then
    local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, self.currentSelectPet.PetData.PetBaseInfo.gid)
    if isTravel then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehousemain_8)
      return
    end
    local isInHome = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetPetIsInHome, self.currentSelectPet.PetData.PetBaseInfo.gid)
    local isInGuard = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetHomePlantGuardPetGid) == self.currentSelectPet.PetData.PetBaseInfo.gid
    if isInGuard or isInHome then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.pet_in_home_cannot_in_team)
      return
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenExChangeMainPetPanel, self.currentSelectPet.PetData.PetBaseInfo.gid)
  end
end

function UMG_PetWarehouseMain_C:OpenFilterPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenFilterPanel, PetUIModuleEnum.OpenSortType.WareHouse)
end

function UMG_PetWarehouseMain_C:OnBtnSkillClicked()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET_EQUIP_SKILL, true)
  if isBan then
    return
  end
  if self.data.bPetWarehouseTipBtnEnable then
    self:SetTipPanelVisible(true, true)
    _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
    _G.NRCModuleManager:DoCmd(CampingModuleCmd.OpenPetWarehouseTips, true)
  end
end

function UMG_PetWarehouseMain_C:OnBtnCultivateClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  _G.NRCModuleManager:DoCmd(CampingModuleCmd.SetIsCultivatePet, true)
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curPetData.gid)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, false)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetOpenPanelPetDataRedPoint)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1014, "UMG_LobbyMain_C:OnBtnPetHeadClick")
  NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPetAttribute, true)
  NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {
    subPanelIndex = 4,
    callback = self.OnUMGLoadFinished
  })
end

function UMG_PetWarehouseMain_C:SetTipPanelVisible(bVisible, SkillPanel)
  local NeedBtn = not self.IsbMultipleChoice
  if bVisible and self.curPetData then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curPetData.gid)
    local MainTeamNum = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetNum()
    local TemporarilyStoreBackpackNum = _G.DataModelMgr.PlayerDataModel:GetTemporarilyStoreBackpackPetNum()
    self.module:ShowChangePetConfirmPanel(petData, bVisible, NeedBtn, self.PetNum - MainTeamNum - TemporarilyStoreBackpackNum, self.PetNumLimit, SkillPanel)
  else
    self.module:ShowChangePetConfirmPanel(nil, bVisible, NeedBtn)
  end
end

function UMG_PetWarehouseMain_C:SetFreeNum()
  local freenum = #self.FreeList
end

function UMG_PetWarehouseMain_C:SetPetList()
  self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
  if self.IsSetSortListInfo == true then
    self:SetSortListInfo()
  end
  self.IsSetSortListInfo = true
end

function UMG_PetWarehouseMain_C:SetPetSortIndex(_index)
  self.SortIndex = _index
end

function UMG_PetWarehouseMain_C:ClearPetListItemSelectState()
  local itemcount = self.GridView1:GetTotalItemNumber()
  for i = 1, itemcount do
    self.GridView1:OpItemByIndex(i, {
      type = 2,
      curPetData = self.curPetData
    })
  end
end

function UMG_PetWarehouseMain_C:SetSortListInfo()
end

function UMG_PetWarehouseMain_C:SortItemInfo(_index)
  self.IsSelectCurrentPet = true
  self.FreeList = {}
  self:SetFreeNum()
  self.SortIndex = _index
  self.module.PetWareHouseSort = _index
  self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
end

function UMG_PetWarehouseMain_C:SortItem(_petinfo, sortType)
  local cfgTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PET_BAG_SEQUENCE)
  local cfgDatas = cfgTable:GetAllDatas()
  self.DefaultSort = {}
  for i, v in pairs(cfgDatas) do
    if sortType == v.sequence_default then
      self.ComboBox:SetComboText(v.sequence_desc)
    end
  end
  local sortlist = self:SortItemList(_petinfo, sortType)
  self.uiData.PetSortInfo = sortlist
  if self.uiData.PetSortInfo then
    self:RefreshPetListByChooseType(self.data.chooseTypeList, true)
  end
end

function UMG_PetWarehouseMain_C:FirstEnterWareHouseMain()
  local IsSelect = false
  if self.IsbMultipleChoice == false then
    local firstPetGid = _G.NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
    local PetTeam = DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
    local TeamIndex = PetTeam.main_team_idx or 0
    if 0 == firstPetGid or -1 == firstPetGid then
      local team = PetTeam.teams[TeamIndex + 1]
      if team and team.pet_infos and team.pet_infos[1] then
        firstPetGid = team.pet_infos[1].pet_gid
      end
    end
    IsSelect = self:SelectPetIndex(firstPetGid)
    if not IsSelect then
      local team = PetTeam.teams[TeamIndex + 1]
      if team and team.pet_infos and team.pet_infos[1] then
        firstPetGid = team and team.pet_infos and team.pet_infos[1].pet_gid
      else
        Log.Error("\229\174\160\231\137\169\230\149\176\230\141\174\230\156\137\233\151\174\233\162\152", table.tostring(PetTeam))
      end
      self:SelectPetIndex(firstPetGid)
    end
  end
end

function UMG_PetWarehouseMain_C:SelectPetIndex(firstPetGid)
  local sortlist = self.uiData.PetSortInfo
  if sortlist then
    for i = 1, #sortlist do
      if sortlist[i].PetData and sortlist[i].PetData.gid == firstPetGid then
        self.uiData.PetSortInfo[i].IsFist = true
        self.GridView1:SelectItemByIndex(i - 1)
        self:SetNameInfo(sortlist[i].PetData)
        self.currentSelectPet = sortlist[i]
        self.curPetData = sortlist[i].PetData
        return true
      end
    end
  end
  return false
end

function UMG_PetWarehouseMain_C:OnReversedSort()
  self.FreeList = {}
  self:SetFreeNum()
  self.IsSelectCurrentPet = true
  self.IsReversedSort = not self.IsReversedSort
  if self.IsReversedSort then
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(1, -1))
  else
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(1, 1))
  end
  local PetReversedSort = self.uiData.PetSortInfo
  local temporaryList = {}
  for i = 1, #PetReversedSort do
    if true == PetReversedSort[i].IsHasPet then
      table.insert(temporaryList, PetReversedSort[i])
    end
    PetReversedSort[i].IsFree = false
  end
  if true == self.IsReversedSort then
    temporaryList = self:PetListSort(false, temporaryList)
  else
    temporaryList = self:PetListSort(true, temporaryList)
  end
  self.uiData.PetSortInfo = temporaryList
  self:RefreshPetListByChooseType(self.data.chooseTypeList)
end

function UMG_PetWarehouseMain_C:OnFightBtnClick()
end

function UMG_PetWarehouseMain_C:OnFilterPet(TypeChooseList)
  self.FreeList = {}
  self:SetFreeNum()
  local sortInfo = self.uiData.PetSortInfo
  for i = 1, #sortInfo do
    sortInfo[i].IsFree = false
  end
  self:RefreshPetListByChooseType(TypeChooseList)
end

function UMG_PetWarehouseMain_C:OnClickTypeBtn(TypeChooseList)
  self.IsSetSortListInfo = false
  self.IsOnClickTypeBtn = true
  self.IsSelectCurrentPet = true
  self.FreeList = {}
  self.IsbMultipleChoice = false
  self:SetFreeNum()
  self:GetPetInfoList()
  self.IsOnClickTypeBtn = false
end

function UMG_PetWarehouseMain_C:HasGid(gid, table)
  if not table then
    return false
  end
  local num = #table
  for i = 1, num do
    if table[i].PetData.gid == gid then
      return true
    end
  end
  return false
end

function UMG_PetWarehouseMain_C:RefreshPetListByChooseType(TypeChooseList, bIsFirstOpen)
  local DepartmentFilter = {}
  local DepartList = {}
  if TypeChooseList.DepartmentFilter then
    for i, v in pairs(TypeChooseList.DepartmentFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(DepartmentFilter, enum)
      end
    end
  end
  if #DepartmentFilter > 0 then
    for i = 1, #self.uiData.PetSortInfo do
      if self.uiData.PetSortInfo[i].PetData then
        if self.uiData.PetSortInfo[i].PetData.IsTeams then
          table.insert(DepartList, self.uiData.PetSortInfo[i])
        else
          local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.PetSortInfo[i].PetData.BaseConfId)
          for k = 1, #petBaseConf.unit_type do
            for j = 1, #DepartmentFilter do
              if petBaseConf.unit_type[k] == DepartmentFilter[j] then
                if not self:HasGid(self.uiData.PetSortInfo[i].PetData.gid, DepartList) then
                  table.insert(DepartList, self.uiData.PetSortInfo[i])
                end
                break
              end
            end
          end
        end
      end
    end
  else
    DepartList = self.uiData.PetSortInfo
  end
  local TalentFilter = {}
  local TalentList = {}
  if TypeChooseList.TalentFilter then
    for i, v in pairs(TypeChooseList.TalentFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(TalentFilter, enum)
      end
    end
  end
  if #TalentFilter > 0 then
    for i = 1, #DepartList do
      if DepartList[i].PetData then
        if DepartList[i].PetData.IsTeams then
          table.insert(TalentList, DepartList[i])
        else
          for j = 1, #TalentFilter do
            if DepartList[i].PetData.PetBaseInfo.talent_rank == TalentFilter[j] then
              table.insert(TalentList, DepartList[i])
              break
            end
          end
        end
      end
    end
  else
    TalentList = DepartList
  end
  local NaturePositiveEffectFilter = {}
  local NaturePositiveEffectList = {}
  if TypeChooseList.NaturePositiveEffectFilter then
    for i, v in pairs(TypeChooseList.NaturePositiveEffectFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(NaturePositiveEffectFilter, enum)
      end
    end
  end
  if #NaturePositiveEffectFilter > 0 then
    for i = 1, #TalentList do
      if TalentList[i].PetData then
        if TalentList[i].PetData.IsTeams then
          table.insert(NaturePositiveEffectList, TalentList[i])
        else
          local NaturePositive = TalentList[i].PetData.PetBaseInfo.changed_nature_pos_attr_type
          if not NaturePositive or 0 == NaturePositive then
            NaturePositive = _G.DataConfigManager:GetNatureConf(TalentList[i].PetData.PetBaseInfo.nature).positive_effect
          else
            NaturePositive = self:GetChangeAttrReqEnum(NaturePositive)
          end
          for j = 1, #NaturePositiveEffectFilter do
            if NaturePositive == NaturePositiveEffectFilter[j] then
              table.insert(NaturePositiveEffectList, TalentList[i])
              break
            end
          end
        end
      end
    end
  else
    NaturePositiveEffectList = TalentList
  end
  local AttributeFilter = {}
  local AttributeList = {}
  if TypeChooseList.AttributeFilter then
    for i, v in pairs(TypeChooseList.AttributeFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(AttributeFilter, enum)
      end
    end
  end
  if #AttributeFilter > 0 then
    for i = 1, #NaturePositiveEffectList do
      if NaturePositiveEffectList[i].PetData then
        if NaturePositiveEffectList[i].PetData.IsTeams then
          table.insert(AttributeList, NaturePositiveEffectList[i])
        else
          for j = 1, #AttributeFilter do
            if AttributeFilter[j] == _G.Enum.AttributeType.AT_HPMAX and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.hp.talent and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.hp.talent > 0 then
              table.insert(AttributeList, NaturePositiveEffectList[i])
              break
            end
            if AttributeFilter[j] == _G.Enum.AttributeType.AT_PHYATK and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.attack.talent and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.attack.talent > 0 then
              table.insert(AttributeList, NaturePositiveEffectList[i])
              break
            end
            if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEATK and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.special_attack.talent and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.special_attack.talent > 0 then
              table.insert(AttributeList, NaturePositiveEffectList[i])
              break
            end
            if AttributeFilter[j] == _G.Enum.AttributeType.AT_PHYDEF and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.defense.talent and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.defense.talent > 0 then
              table.insert(AttributeList, NaturePositiveEffectList[i])
              break
            end
            if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEDEF and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.special_defense.talent and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.special_defense.talent > 0 then
              table.insert(AttributeList, NaturePositiveEffectList[i])
              break
            end
            if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEED and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.speed.talent and NaturePositiveEffectList[i].PetData.PetBaseInfo.attribute_info.speed.talent > 0 then
              table.insert(AttributeList, NaturePositiveEffectList[i])
              break
            end
          end
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
      if AttributeList[i].PetData then
        if AttributeList[i].PetData.IsTeams then
          table.insert(PartnerMarkerList, AttributeList[i])
        else
          for j = 1, #PartnerMarkerFilter do
            if AttributeList[i].PetData.PetBaseInfo.partner_mark == PartnerMarkerFilter[j] then
              table.insert(PartnerMarkerList, AttributeList[i])
              break
            end
          end
        end
      end
    end
  else
    PartnerMarkerList = AttributeList
  end
  local SpecialityFilter = {}
  local SpecialityList = {}
  if TypeChooseList.SpecialityFilter then
    for i, v in pairs(TypeChooseList.SpecialityFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = v.data.filter_enum_value
        table.insert(SpecialityFilter, enum)
      end
    end
  end
  if #SpecialityFilter > 0 then
    for i = 1, #PartnerMarkerList do
      if PartnerMarkerList[i].PetData then
        if PartnerMarkerList[i].PetData.IsTeams then
          table.insert(SpecialityList, PartnerMarkerList[i])
        else
          for j = 1, #SpecialityFilter do
            if PartnerMarkerList[i].PetData.PetBaseInfo.speciality_id then
              local petTalentConf = _G.DataConfigManager:GetPetTalentConf(PartnerMarkerList[i].PetData.PetBaseInfo.speciality_id)
              if petTalentConf and petTalentConf.filter_enum_value == SpecialityFilter[j] then
                table.insert(SpecialityList, PartnerMarkerList[i])
                break
              end
            end
          end
        end
      end
    end
  else
    SpecialityList = PartnerMarkerList
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
    for i = 1, #SpecialityList do
      if SpecialityList[i] and SpecialityList[i].PetData then
        if SpecialityList[i].PetData.IsTeams then
          table.insert(GetTimeList, SpecialityList[i])
        else
          for j = 1, #GetTimeFilter do
            if SpecialityList[i].PetData.PetBaseInfo and SpecialityList[i].PetData.PetBaseInfo.add_time then
              local bCheckPass = false
              if GetTimeFilter[j] == _G.Enum.PetCatchTime.PCT_THISWEEK then
                bCheckPass = NRCModuleManager:DoCmd(PetUIModuleCmd.IsPetInCurrentWeek, SpecialityList[i].PetData.PetBaseInfo.add_time)
              elseif GetTimeFilter[j] == _G.Enum.PetCatchTime.PCT_TODAY then
                bCheckPass = NRCModuleManager:DoCmd(PetUIModuleCmd.IsPetCaughtToday, SpecialityList[i].PetData.PetBaseInfo.add_time)
              end
              if bCheckPass then
                table.insert(GetTimeList, SpecialityList[i])
                break
              end
            end
          end
        end
      end
    end
  else
    GetTimeList = SpecialityList
  end
  if #DepartmentFilter <= 0 and #TalentFilter <= 0 and #NaturePositiveEffectFilter <= 0 and #AttributeFilter <= 0 and #PartnerMarkerFilter <= 0 and #SpecialityFilter <= 0 and #GetTimeFilter <= 0 then
    if not bIsFirstOpen and self.bIsScreening then
      self.bIsScreening = false
      self.ComboBox.ScreeningBtn:ChangeIconSelectState()
    end
  elseif not self.bIsScreening then
    self.bIsScreening = true
    self.ComboBox.ScreeningBtn:ChangeIconSelectState()
  end
  self:UpdateCurrentSelectPet(GetTimeList)
  self.GridView1.bShowAll = false
  if #GetTimeList > 0 then
    self.GridView1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_Cultivate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_Exchange:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.EmptyState:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Details:SetVisibility(UE4.ESlateVisibility.Visible)
    self.HorizontalBox_42:SetVisibility(UE4.ESlateVisibility.Visible)
    self.textPetName:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CatchHardLv:SetVisibility(UE4.ESlateVisibility.Visible)
    self.GridView1:InitList(GetTimeList)
    if false == self.IsbMultipleChoice then
      if self.FirstEnter then
        local firstPetGid = _G.NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
        local PetTeam = DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
        local TeamIndex = PetTeam.main_team_idx or 0
        if 0 == firstPetGid or -1 == firstPetGid then
          local team = PetTeam.teams[TeamIndex + 1]
          if team and team.pet_infos and team.pet_infos[1] then
            firstPetGid = team.pet_infos[1].pet_gid
          end
        end
        local sortlist = self.uiData.PetSortInfo
        local find = false
        for i = 1, #sortlist do
          if sortlist[i].PetData and sortlist[i].PetData.gid == firstPetGid then
            find = true
            self.GridView1:SelectItemByIndex(i - 1)
          end
        end
        if not find then
          self.GridView1:SelectItemByIndex(0)
        end
        self.FirstEnter = false
      else
        if self.oldIndex then
          local itemCount = self.GridView1:GetTotalItemNumber()
          if itemCount >= self.oldIndex and self.oldIndex > 0 then
            self.curPetListSelectIndex = self.oldIndex
          elseif itemCount > 0 and itemCount <= self.oldIndex and self.oldIndex - 2 >= 0 then
            self.curPetListSelectIndex = self.oldIndex - 1
          end
          self.currentSelectPet = GetTimeList[self.curPetListSelectIndex]
          self.oldIndex = nil
        else
          local IsFind = self:UpdateSelectPetIndex(GetTimeList, self.currentSelectPet)
          if not IsFind then
            self.curPetListSelectIndex = 1
            self.currentSelectPet = GetTimeList[self.curPetListSelectIndex]
          end
        end
        self.GridView1:OpItemByIndex(self.curPetListSelectIndex, {
          type = 3,
          curPetData = self.curPetData
        })
        self.GridView1:SelectItemByIndex(self.curPetListSelectIndex - 1)
        self.IsSelectCurrentPet = false
      end
    end
  else
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.HideOrShowPets, false)
    if self.PetNum > 0 then
      self.NRCText_74:SetText(LuaText.warehouse_filter_no_pet)
    else
      if self.IsFreeSuccess then
        local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
        if teamInfo and teamInfo.teams then
          for j, team in ipairs(teamInfo.teams) do
            if team.pet_infos and team.pet_infos[1] and team.pet_infos[1].pet_gid then
              local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(team.pet_infos[1].pet_gid)
              _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.OnPetWarehouseChangePet, petData.base_conf_id, petData.gid, false)
              break
            end
          end
        end
      end
      self.NRCText_74:SetText(LuaText.warehouse_no_pet)
    end
    self:SetTipPanelVisible(false, false)
    self.EmptyState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_Details:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.GridView1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Cultivate:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HorizontalBox_42:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.textPetName:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CatchHardLv:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetWarehouseMain_C:GetChangeAttrReqEnum(attribute)
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

function UMG_PetWarehouseMain_C:UpdateCurrentSelectPet(_PetList)
  local PetList = _PetList
  if self.IsFreeSuccess == true then
    if PetList[self.curPetListSelectIndex] and PetList[self.curPetListSelectIndex].PetData then
      self.currentSelectPet = PetList[self.curPetListSelectIndex]
    else
      local Index = self:LastPetData(PetList)
      if PetList[Index] and PetList[Index].PetData then
        self.currentSelectPet = PetList[Index]
      else
        self.currentSelectPet = self.uiData.PetSortInfo[1]
        self:OnScrollPetItemSelected(self.currentSelectPet, 1)
      end
    end
  end
end

function UMG_PetWarehouseMain_C:LastPetData(_PetDataList)
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

function UMG_PetWarehouseMain_C:UpdateSelectPetIndex(_PetList, _currentSelectPet)
  local PetList = _PetList
  for i, Pet in ipairs(PetList) do
    if Pet.PetData and _currentSelectPet and Pet.PetData.gid == _currentSelectPet.PetData.gid then
      self.curPetListSelectIndex = i
      return true
    end
  end
  return false
end

function UMG_PetWarehouseMain_C:OnNRCButton_0Click()
  local TeamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.uiData.PetInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local PVPTeamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.uiData.PetInfoList, Enum.PlayerTeamType.PTT_PVP_BATTLE_1)
  local curPetInfo = self:GetPetInfo()
  for i, petInfo in ipairs(curPetInfo) do
    local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, petInfo.gid)
    if isTravel then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehousemain_5)
      return
    end
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_conf_id)
    if petBaseConf.ban_free and 1 == petBaseConf.ban_free then
      local text = _G.DataConfigManager:GetLocalizationConf("magic_change_dimo").msg
      local text1 = string.format(text, petBaseConf.name)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, text1)
      return
    end
    local IsTeamPet = self:IsTeamPetS(petInfo, TeamInfo)
    local IsPvPTeamPet = self:IsTeamPetS(petInfo, PVPTeamInfo)
    if false == IsTeamPet then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehousemain_6)
      return
    end
    if false == IsPvPTeamPet then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehousemain_6)
      return
    end
  end
  if #self.FreeList < 1 then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehousemain_7)
    return
  end
  if #curPetInfo > 1 then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002005, "UMG_PetWarehouse_C:OnNRCButton_0ClickPetFree ")
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetFreePanel, curPetInfo)
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002005, "UMG_PetWarehouse_C:OnNRCButton_0ClickPetFree ")
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenBackpackPetFreePanel, curPetInfo)
  end
end

function UMG_PetWarehouseMain_C:OnNRCButton()
  if self.IsbMultipleChoice == false then
    self.IsbMultipleChoice = true
    self:setBatchType(self.IsbMultipleChoice)
    self:RefreshPetListByChooseType(self.data.chooseTypeList)
    self.firstSelectItem = true
    self.FreeList = {}
    self:SetFreeNum()
    self.NRCButton_0:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimation(self.Batch_Select)
    self:PlayAnimation(self.Btn_Out)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(40007001, "UMG_PetWarehouse_C:OnNRCButtonB")
  else
    self:PlayAnimation(self.Batch_UnSelect)
    self.IsbMultipleChoice = false
    for i, v in ipairs(self.uiData.PetSortInfo) do
      if v.IsFree then
        v.IsFree = false
      end
    end
    self:setBatchType(self.IsbMultipleChoice)
    self:RefreshPetListByChooseType(self.data.chooseTypeList)
    self.firstSelectItem = true
    self.GridView1:SelectItemByIndex(self.curPetListSelectIndex - 1)
    self:PlayAnimation(self.Btn_In)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(40007001, "UMG_PetWarehouse_C:OnNRCButtonB")
  end
  self.module:SetChangePetConfirmPanelBtnVisit(not self.IsbMultipleChoice)
end

function UMG_PetWarehouseMain_C:SortItemList(petList, SortType)
  local sortIndex = SortType
  if sortIndex >= Enum.PetSequenceDefault.SEQUENCE_TALENT_DOWN then
    sortIndex = sortIndex - 1
  end
  return self:SortPetInfo(petList, sortIndex)
end

function UMG_PetWarehouseMain_C:SortPetInfo(petList, sortIndex)
  local petInfo = {}
  for i, v in ipairs(petList) do
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(v.BaseConfId)
    if sortIndex > 2 then
      local attribute = _G.DataConfigManager:GetAttributeConf(sortIndex - 2)
      table.insert(petInfo, {
        IconListInfo = v[1],
        PetData = v,
        IsHasPet = true,
        Icon = attribute.attribute_icon,
        parent = self,
        IsFree = false,
        IsbMultipleChoice = self.IsbMultipleChoice,
        banFree = petBaseConf.ban_free,
        IconListSortInfo = v[sortIndex]
      })
    else
      table.insert(petInfo, {
        IconListInfo = v[1],
        PetData = v,
        IsHasPet = true,
        parent = self,
        IsFree = false,
        IsbMultipleChoice = self.IsbMultipleChoice,
        banFree = petBaseConf.ban_free,
        IconListSortInfo = v[sortIndex]
      })
    end
  end
  local curTeamPetList = {}
  local teamPet = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  for k, v in ipairs(petInfo) do
    for i = 1, #teamPet do
      if v.PetData.gid == teamPet[i].gid then
        table.insert(curTeamPetList, v)
        break
      end
    end
  end
  if self.IsReversedSort then
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(1, -1))
  else
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(1, 1))
  end
  if true == self.IsReversedSort then
    petInfo = self:PetListSort(false, petInfo)
  else
    petInfo = self:PetListSort(true, petInfo)
  end
  return petInfo
end

local function AscendingSortNotOtherProperty(a, b)
  local Min = a.IconListSortInfo
  local Max = b.IconListSortInfo
  if a.PetData.IsTeams then
    if a.PetData.IsTeams then
      Min = math.maxinteger - 10000 - a.PetData.pos
    else
      Min = math.maxinteger - 100000 - a.PetData.pos
    end
  elseif a.PetData.IsInBackPack then
    Min = math.maxinteger - 1000000 - a.PetData.pos
  end
  if b.PetData.IsTeams then
    if b.PetData.IsTeams then
      Max = math.maxinteger - 10000 - b.PetData.pos
    else
      Max = math.maxinteger - 100000 - b.PetData.pos
    end
  elseif b.PetData.IsInBackPack then
    Max = math.maxinteger - 1000000 - b.PetData.pos
  end
  if Min == Max then
    return a.PetData.BaseConfId > b.PetData.BaseConfId
  else
    return Min > Max
  end
end

local function AscendingSortAndOtherProperty(a, b)
  if not a.IconListSortInfo then
  end
  if not b.IconListSortInfo then
  end
  local Min = a.IconListSortInfo
  local Max = b.IconListSortInfo
  if a.PetData.IsTeams then
    if a.PetData.IsTeams then
      Min = math.maxinteger - 10000 - a.PetData.pos
    else
      Min = math.maxinteger - 100000 - a.PetData.pos
    end
  elseif a.PetData.IsInBackPack then
    Min = math.maxinteger - 1000000 - a.PetData.pos
  end
  if b.PetData.IsTeams then
    if b.PetData.IsTeams then
      Max = math.maxinteger - 10000 - b.PetData.pos
    else
      Max = math.maxinteger - 100000 - b.PetData.pos
    end
  elseif b.PetData.IsInBackPack then
    Max = math.maxinteger - 1000000 - b.PetData.pos
  end
  if Min == Max then
    if a.PetData.PetBaseInfo.level == b.PetData.PetBaseInfo.level then
      if a.PetData.starLevel == b.PetData.starLevel then
        if a.PetData.BaseConfId == b.PetData.BaseConfId then
          return (a.PetData.PetBaseInfo.add_time or 0) > (b.PetData.PetBaseInfo.add_time or 0)
        else
          return a.PetData.BaseConfId > b.PetData.BaseConfId
        end
      else
        return a.PetData.starLevel > b.PetData.starLevel
      end
    else
      return a.PetData.PetBaseInfo.level > b.PetData.PetBaseInfo.level
    end
  else
    return Min > Max
  end
end

local function SortNotOtherProperty(a, b)
  if a.IconListSortInfo and b.IconListSortInfo then
    local Min = a.IconListSortInfo
    local Max = b.IconListSortInfo
    if a.PetData.IsTeams then
      if a.PetData.IsTeams then
        Min = a.PetData.pos - (math.maxinteger - 10000)
      else
        Min = a.PetData.pos - (math.maxinteger - 100000)
      end
    elseif a.PetData.IsInBackPack then
      Min = a.PetData.pos - (math.maxinteger - 1000000)
    end
    if b.PetData.IsTeams then
      if b.PetData.IsTeams then
        Max = b.PetData.pos - (math.maxinteger - 10000)
      else
        Max = b.PetData.pos - (math.maxinteger - 100000)
      end
    elseif b.PetData.IsInBackPack then
      Max = b.PetData.pos - (math.maxinteger - 1000000)
    end
    if Min == Max then
      return a.PetData.BaseConfId < b.PetData.BaseConfId
    else
      return Min < Max
    end
  end
end

local function SortAndOtherProperty(a, b)
  if a.IconListSortInfo and b.IconListSortInfo then
    local Min = a.IconListSortInfo
    local Max = b.IconListSortInfo
    if a.PetData.IsTeams then
      if a.PetData.IsTeams then
        Min = a.PetData.pos - (math.maxinteger - 10000)
      else
        Min = a.PetData.pos - (math.maxinteger - 100000)
      end
    elseif a.PetData.IsInBackPack then
      Min = a.PetData.pos - (math.maxinteger - 1000000)
    end
    if b.PetData.IsTeams then
      if b.PetData.IsTeams then
        Max = b.PetData.pos - (math.maxinteger - 10000)
      else
        Max = b.PetData.pos - (math.maxinteger - 100000)
      end
    elseif b.PetData.IsInBackPack then
      Max = b.PetData.pos - (math.maxinteger - 1000000)
    end
    if Min == Max then
      if a.PetData.PetBaseInfo.level == b.PetData.PetBaseInfo.level then
        if a.PetData.starLevel == b.PetData.starLevel then
          if a.PetData.BaseConfId == b.PetData.BaseConfId then
            return (a.PetData.PetBaseInfo.add_time or 0) < (b.PetData.PetBaseInfo.add_time or 0)
          else
            return a.PetData.BaseConfId < b.PetData.BaseConfId
          end
        else
          return a.PetData.starLevel < b.PetData.starLevel
        end
      else
        return a.PetData.PetBaseInfo.level < b.PetData.PetBaseInfo.level
      end
    else
      return Min < Max
    end
  end
end

function UMG_PetWarehouseMain_C:PetListSort(_IsAscendingOrder, _PetList)
  local IsAscendingOrder = _IsAscendingOrder
  local newPetList = {}
  if nil == _PetList then
    _PetList = {}
  end
  newPetList = _PetList
  if newPetList[1] and newPetList[1].PetData.IsOpenTeam == false then
    if IsAscendingOrder then
      if self.SortIndex == Enum.PetSequenceDefault.SEQUENCE_CATCH_DOWN then
        table.sort(newPetList, AscendingSortNotOtherProperty)
      else
        table.sort(newPetList, AscendingSortAndOtherProperty)
      end
    elseif self.SortIndex == Enum.PetSequenceDefault.SEQUENCE_CATCH_DOWN then
      table.sort(newPetList, SortNotOtherProperty)
    else
      table.sort(newPetList, SortAndOtherProperty)
    end
  elseif IsAscendingOrder then
    table.sort(newPetList, function(a, b)
      if a.PetData.CanChangeTeamSort > b.PetData.CanChangeTeamSort then
        return a.PetData.CanChangeTeamSort > b.PetData.CanChangeTeamSort
      elseif a.PetData.CanChangeTeamSort == b.PetData.CanChangeTeamSort and a.IconListSortInfo > b.IconListSortInfo then
        return a.IconListSortInfo > b.IconListSortInfo
      elseif a.PetData.CanChangeTeamSort == b.PetData.CanChangeTeamSort and a.IconListSortInfo == b.IconListSortInfo and a.PetData.BaseConfId > b.PetData.BaseConfId then
        return a.PetData.BaseConfId > b.PetData.BaseConfId
      end
    end)
  else
    table.sort(newPetList, function(a, b)
      if a.PetData.CanChangeTeamSort > b.PetData.CanChangeTeamSort then
        return a.PetData.CanChangeTeamSort > b.PetData.CanChangeTeamSort
      elseif a.PetData.CanChangeTeamSort == b.PetData.CanChangeTeamSort and a.IconListSortInfo < b.IconListSortInfo then
        return a.IconListSortInfo < b.IconListSortInfo
      elseif a.PetData.CanChangeTeamSort == b.PetData.CanChangeTeamSort and a.IconListSortInfo == b.IconListSortInfo and a.PetData.BaseConfId < b.PetData.BaseConfId then
        return a.PetData.BaseConfId < b.PetData.BaseConfId
      end
    end)
  end
  table.stableSort(newPetList, function(a, b)
    local sortNum1 = 0
    local sortNum2 = 0
    if a.PetData and a.PetData.SortNum then
      sortNum1 = a.PetData.SortNum
    end
    if b.PetData and b.PetData.SortNum then
      sortNum2 = b.PetData.SortNum
    end
    return sortNum1 < sortNum2
  end)
  return newPetList
end

function UMG_PetWarehouseMain_C:GetSortNum(petData)
  if petData.IsInHome then
    return math.maxinteger
  elseif petData.IsInGuard then
    return math.maxinteger - 1
  elseif petData.IsTravel then
    return math.maxinteger - 2
  else
    return 0
  end
end

function UMG_PetWarehouseMain_C:SetIsNewPet(_PetInfo)
  local petinfo = _PetInfo
  for i, v in ipairs(petinfo) do
    if v.PetData then
      v.PetData.pet_status_flags = 0
    end
  end
end

function UMG_PetWarehouseMain_C:setBatchType(_IsbMultipleChoice)
  local PetSortInfo = self.uiData.PetSortInfo
  if PetSortInfo then
    local IsbMultipleChoice = _IsbMultipleChoice
    for i, v in ipairs(PetSortInfo) do
      v.IsbMultipleChoice = IsbMultipleChoice
    end
  end
end

function UMG_PetWarehouseMain_C:GetdataInfo(petInfo)
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

function UMG_PetWarehouseMain_C:IsTeamPetS(_curPetInfo, _TeamInfo)
  local curPetInfo = _curPetInfo
  if _TeamInfo then
    local teamInfos = _TeamInfo.teams
    for i, team in ipairs(teamInfos) do
      local petInfo = PetUtils.PetTeamFindPetInfoByIndex(team, curPetInfo.gid)
      if petInfo then
        return false
      end
    end
  end
  return true
end

function UMG_PetWarehouseMain_C:IsTeamPVPPetS(_curPetInfo, _TeamInfo)
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

function UMG_PetWarehouseMain_C:OnScrollPetItemSelected(item, index, needAudio)
  if needAudio then
    if self.firstSelectItem then
      self.firstSelectItem = false
    else
      _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_Friend_Report_C:OnActive")
    end
  end
  if not item or not item.PetData then
    return
  end
  self.curPetListSelectIndex = index
  self.currentSelectPet = item
  if self.IsbMultipleChoice == true then
    if table.contains(self.FreeList, item.PetData.gid) then
      for i, v in ipairs(self.FreeList) do
        if v == item.PetData.gid then
          table.remove(self.FreeList, i)
        end
      end
    elseif not item.PetData.IsPvPTeam then
      table.insert(self.FreeList, item.PetData.gid)
    end
  else
    self.FreeList = {}
    table.insert(self.FreeList, item.PetData.gid)
  end
  self:SetFreeNum()
  if self.OnPetItemClick then
    self:OnPetItemClick(index)
  end
  if item.PetData then
    if self.OldSelectPet == nil or self.OldSelectPet.PetData.gid ~= item.PetData.gid or self.OldSelectPet.PetData.BaseConfId ~= item.PetData.BaseConfId then
      _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.OnPetWarehouseChangePet, item.PetData.BaseConfId, item.PetData.gid)
      self.curPetData = item.PetData
      self.OldSelectPet = item
    else
      _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.HideOrShowPets, true)
    end
    self.module:UpDatePetConfirmPanel(item.PetData)
    self:SetNameInfo(item.PetData)
  else
    self:UpdateTipsInfo(item)
  end
end

function UMG_PetWarehouseMain_C:OnRemovePetNew(item)
  local PetSortInfo = self.uiData.PetSortInfo
  if PetSortInfo then
    for i, v in ipairs(PetSortInfo) do
      if v.PetData and v.PetData.gid == item.PetData.gid then
        v.PetData.pet_status_flags = 0
      end
    end
  end
  _G.DataModelMgr.PlayerDataModel:SetPetNewState(item.PetData)
end

function UMG_PetWarehouseMain_C:OnPetItemClick(_index)
end

function UMG_PetWarehouseMain_C:SetTeamInfo(_gid, _OnClick)
end

function UMG_PetWarehouseMain_C:GetPetInfo()
  local index = self.FreeList
  local gidData = {}
  local petData = self.uiData.PetInfoList.pet_data
  if not petData or not index then
    return {}
  end
  for i, v in pairs(index) do
    for j, _petData in ipairs(petData) do
      if v == _petData.gid then
        table.insert(gidData, _petData)
      end
    end
  end
  return gidData
end

function UMG_PetWarehouseMain_C:OnAnimationFinished(anim)
  if anim == self.close then
    self:CloseAllTipsPanel()
    if self.data.NPCActionOpenPetWarehouse ~= nil then
      Log.Debug("self.data.NPCActionOpenPetWarehouse:EndAction()")
      self.data.NPCActionOpenPetWarehouse:EndAction()
    end
    self:DoClose()
  elseif anim == self.open then
    _G.DataModelMgr.PlayerDataModel:TryGetPetInfo()
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  elseif anim == self.Btn_In then
  elseif anim == self.Btn_Out then
    self.Btn_Cultivate:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetWarehouseMain_C:OnDeactive()
end

function UMG_PetWarehouseMain_C:SetPetItemClickAble(clickable)
  self.GridView1:SetItemClickAble(clickable)
end

function UMG_PetWarehouseMain_C:OnBagSKillTipsPanelShowChange(bShow)
  if bShow then
    self.NRCImage_76:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCImage_76:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetWarehouseMain_C:CloseAllTipsPanel()
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.PetWarehouseReadyToClose)
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_ClosePetTips)
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.ClosePeculiarityTips)
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.PetUICloseblockerTips)
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.CloseTipsStrongPoint)
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.CloseTipsPanel)
end

function UMG_PetWarehouseMain_C:OnSendPetSuccess()
  self.oldIndex = self.GridView1:GetSelectedIndex()
  self:GetPetInfoList()
end

return UMG_PetWarehouseMain_C
