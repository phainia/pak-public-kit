local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local ShareUIModuleEvent = reload("NewRoco.Modules.System.ShareUI.ShareUIModuleEvent")
local UMG_Level_Team_C = _G.NRCPanelBase:Extend("UMG_Level_Team_C")

function UMG_Level_Team_C:OnConstruct()
  self:SetChildViews(self.CommonPetDetails, self.UMG_PetRate)
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self:OnInit()
end

function UMG_Level_Team_C:OnInit()
  self.TableData = {}
  table.insert(self.TableData, {
    title = LuaText.challenge_text_34
  })
  table.insert(self.TableData, {
    title = LuaText.challenge_text_35
  })
  self:PlayAnimation(self.In)
  self.IsReversalSort = false
  self.curSortId = 1
  self:OnAddEventListener()
  self:CheckShareIsOpen()
  if self.ShareIsOpen then
    _G.NRCModuleManager:DoCmd(_G.ShareUIModuleCmd.CheckRewardStateEntrance, self.shareBaseId)
  end
end

function UMG_Level_Team_C:OnDeactive()
  _G.NRCModeManager:DoCmd(LevelSelectionModuleCmd.OnCmdSetLevelListItemPet, nil)
  _G.NRCModuleManager:GetModule("PetUIModule"):UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.RefreshTeamName)
  self:RemoveButtonListener(self.ShareBtn.btnLevelUp, self.OnShareClick)
  self:RemoveButtonListener(self.KeyBtn.btnLevelUp, self.OnImportClick)
  self:UnRegisterEvent(self, LevelSelectionModuleEvent.OnChangeBattleTab, self.OnChageSelectTab)
  self:UnRegisterEvent(self, LevelSelectionModuleEvent.OnSelectBattleTeam, self.OnChageSelectTeam)
  self:UnRegisterEvent(self, LevelSelectionModuleEvent.OnChangeSelectPet, self.OnChangeSelectPet)
  self:UnRegisterEvent(self, LevelSelectionModuleEvent.OnSaveBattleTeamSucceed, self.OnSaveBattleTeamSucceed)
  self:UnRegisterEvent(self, LevelSelectionModuleEvent.OnUpdateTeamBloodMagic, self.OnUpdateTeamBloodMagic)
  self:UnRegisterEvent(self, LevelSelectionModuleEvent.OnUpdateCurrentPetList, self.OnUpdatePetList)
  _G.NRCEventCenter:UnRegisterEvent(self, LevelSelectionModuleEvent.OnShowPetDataRight, self.SetRightInfo)
  _G.NRCEventCenter:UnRegisterEvent(self, LevelSelectionModuleEvent.OnIsHideArrayRight, self.OnIsHideArrayRight)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.OnFilter, self.OnFilterPets)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.UpdateSort, self.SortPets)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  _G.NRCModuleManager:GetModule("PetUIModule"):UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.RefreshTeamName)
  _G.NRCEventCenter:UnRegisterEvent(self, ShareUIModuleEvent.SHOW_ENTRANCE_REWARD, self.CheckShowShareReward)
  self:CancelShareDelayId()
  self.ShareUIReward:CancelShareDelayId()
end

function UMG_Level_Team_C:OnImportClick()
  if self.curSelectTeam then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenLoadPetTeamPanel, self.curSelectTeam.type, self.curSelectTeam.idx)
  end
end

function UMG_Level_Team_C:OnShareClick()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_SHARE, true)
  if isBan then
    return
  end
  if self.curSelectTeam then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenShareTeamPanel, self.curSelectTeam.type, self.curSelectTeam.idx)
  end
end

function UMG_Level_Team_C:OnActive(panelType)
  self.panelType = panelType
  self.teamType = 1 == self.panelType and _G.Enum.PlayerTeamType.PTT_PVE_NPC_CHALLENGE_FIGHT or _G.Enum.PlayerTeamType.PTT_PVE_BOSS_CHALLENGE_FIGHT
  self:OnOpenPanel()
  local CommonDropDownListData = _G.NRCCommonDropDownListData()
  CommonDropDownListData.Call = self
  CommonDropDownListData.Btn_LeftHandler = self.OnClickScreenBtn
  CommonDropDownListData.Btn_RightHandler = self.OnClickReverse
  CommonDropDownListData.Btn_MidHandler = self.OnClickComboBox
  self.ComScreen:SetPanelInfo(CommonDropDownListData)
end

function UMG_Level_Team_C:OnOpenPanel()
  self.SelectTabAudio = false
  self.curSelectTeam = nil
  self.Tab:InitGridView(self.TableData)
  self.Tab:SelectItemByIndex(0)
end

function UMG_Level_Team_C:OnChageSelectTab(index)
  if self.SelectTabAudio then
    _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Leve_BattleSilhouette_C:OnSelectCameraShotItemEvent")
  else
    self.SelectTabAudio = true
  end
  local idx = index - 1
  self.tableIdx = idx
  self.Btn_Cultivate1:SetVisibility(1 == idx and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  for i = 0, 1 do
    local item = self.Tab:GetItemByIndex(i)
    if idx == i then
      item:OnSelectAnimation()
    else
      item:OnUnSelectAnimation()
    end
  end
  if 1 == idx then
    local teamDatas = _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdGetAllTeamDatas)
    _G.NRCEventCenter:DispatchEvent(LevelSelectionModuleEvent.OnIsHideArrayRight, false)
    self:PlayAnimation(self.Change_tab2)
    self.DefaultTeam:InitList(teamDatas)
    self.DefaultTeam:SelectItemByIndex(0)
    self:OnSwitcherSwitcher(0)
  else
    self:OnSwitcherSwitcher(1)
    self:ShowPetStorehouse()
  end
end

function UMG_Level_Team_C:OnPetTeamManagementSelChanged(selectedTeamIdx)
  if self.curSelectTeam ~= nil then
    self:ShowSelectTeamPetList()
  end
end

function UMG_Level_Team_C:CreateStorehouseData()
  local petList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().pet_data
  return petList
end

function UMG_Level_Team_C:OnChageSelectTeam(teamData, index)
  self.curSelectTeam = teamData
  self.Btn_Redact:SetVisibility(self.curSelectTeam.type == _G.Enum.PlayerTeamType.PTT_BIG_WORLD and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
end

function UMG_Level_Team_C:OnChangeSelectPet(petSelectDic)
  local datas = {}
  for i = 1, 6 do
    local gid = petSelectDic[i]
    table.insert(datas, {pet_gid = gid})
  end
  self.curChangeTeam = datas
  self.PetList:InitGridView(datas)
end

function UMG_Level_Team_C:BuildPetList(teams)
  local datas = {}
  for i = 1, #teams do
    local gid = teams[i].pet_gid
    table.insert(datas, {pet_gid = gid})
  end
  return datas
end

function UMG_Level_Team_C:OnSaveBattleTeamSucceed(isCurTeam)
  if 1 == self.tableIdx then
    self:OnSwitcherSwitcher(0)
    if isCurTeam then
    else
      local teamDatas = _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdGetAllTeamDatas)
      self.DefaultTeam:InitList(teamDatas)
    end
  end
end

function UMG_Level_Team_C:OnUpdateTeamBloodMagic()
  local datas = {}
  local allTeamDatas = _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdGetAllTeamDatas)
  for i = 1, #allTeamDatas do
    local teamData = allTeamDatas[i]
    teamData.isDontPlayAim = true
    table.insert(datas, teamData)
    if teamData.type == self.curSelectTeam.type and teamData.idx == self.curSelectTeam.idx then
      self.curSelectTeam.magicGid = teamData.magicGid
      if teamData.magicGid == nil or 0 == teamData.magicGid then
        self.Switcher:SetActiveWidgetIndex(1)
      else
        self.Switcher:SetActiveWidgetIndex(0)
        local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, teamData.magicGid)
        local bagitemConf = _G.DataConfigManager:GetBagItemConf(bagItemData.id)
        self.Icon:SetPath(bagitemConf.icon)
      end
    end
  end
  self.DefaultTeam:InitList(datas)
end

function UMG_Level_Team_C:OnChangeBattleTeamItem(teamData)
  self:ShowSelectTeamPetList()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdInitCurrentTeamDic, teamData)
  self:OnSwitcherSwitcher(1)
  self:PlayAnimation(self.Team_in)
  local petData = {}
  for i = 1, 6 do
    local data = {}
    if teamData and i <= #teamData.teams then
      data = teamData.teams[i]
    else
      data = {pet_gid = 0}
    end
    table.insert(petData, data)
  end
  self.Text_1:SetText(teamData.title)
  self.PetList:InitGridView(petData)
  if teamData.magicGid == nil or 0 == teamData.magicGid then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, teamData.magicGid)
    local bagitemConf = _G.DataConfigManager:GetBagItemConf(bagItemData.id)
    self.Icon:SetPath(bagitemConf.icon)
    self.Switcher:SetActiveWidgetIndex(0)
  end
  local datas = self:CreateStorehouseData()
  self.WarehouseList:InitGridView(datas)
  self.petInfos = datas
  self.curTeamDatas = datas
  self.curSelectTeam = teamData
  self:DispatchEvent(LevelSelectionModuleEvent.OnOpenTeamCompiler, true)
end

function UMG_Level_Team_C:OnUpdateTeamInfo()
  local teamDatas = self.module.data:CreateDefaultTeamDatas()
  local datas = {}
  for i = 1, #teamDatas do
    local teamData = teamDatas[i]
    teamData.isDontPlayAim = true
    table.insert(datas, teamData)
    if teamData.type == self.curSelectTeam.type and teamData.idx == self.curSelectTeam.idx then
      self.curSelectTeam.magicGid = teamData.magicGid
      self.Text_1:SetText(teamData.title)
      if teamData.magicGid == nil or 0 == teamData.magicGid then
        self.Switcher:SetActiveWidgetIndex(1)
      else
        self.Switcher:SetActiveWidgetIndex(0)
        local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, teamData.magicGid)
        local bagitemConf = _G.DataConfigManager:GetBagItemConf(bagItemData.id)
        self.Icon:SetPath(bagitemConf.icon)
      end
    end
  end
  self.DefaultTeam:InitList(datas)
end

function UMG_Level_Team_C:GetFilterOtherTeamPetDatas(teamType, teamIdx)
  local petAllList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().pet_data
  local allTeamInfos = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().team_infos
  local removeGids = {}
  local datas = {}
  for _, petTeamInfo in pairs(allTeamInfos) do
    if teamType ~= petTeamInfo.team_type then
      for _, petTeam in pairs(petTeamInfo.teams) do
        if petTeam.pet_infos and #petTeam.pet_infos > 0 then
          for _, petInfo in pairs(petTeam.pet_infos) do
            table.insert(removeGids, petInfo.pet_gid)
          end
        end
      end
    else
      for i, petTeam in pairs(petTeamInfo.teams) do
        if i - 1 ~= teamIdx and petTeam.pet_infos and #petTeam.pet_infos > 0 then
          for _, petInfo in pairs(petTeam.pet_infos) do
            table.insert(removeGids, petInfo.pet_gid)
          end
        end
      end
    end
  end
  for i, petData in pairs(petAllList) do
    local isHave = false
    for _, gid in pairs(removeGids) do
      if petData.gid == gid then
        isHave = true
        break
      end
    end
    if not isHave then
      table.insert(datas, petData)
    end
  end
  return datas
end

function UMG_Level_Team_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Redact.btnLevelUp, self.OnClickBtn_Redact)
  self:AddButtonListener(self.BloodBtn, self.OnClickBloodBtn_1)
  self:AddButtonListener(self.Btn_Cultivate1.btnLevelUp, self.OnClickBtn_Cultivate)
  self:AddButtonListener(self.Btn_Adhibition.btnLevelUp, self.OnClickBtn_Adhibition)
  self:AddButtonListener(self.Exchange_1.btnLevelUp, self.OnClickBloodBtn_1)
  self:AddButtonListener(self.rename_btn, self.OnClickReNameBtn)
  self:AddButtonListener(self.BtnRechristen_1, self.OpenPetTips)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.Return.btnClose, self.ClosePetRight)
  self:AddButtonListener(self.changeBtn4.btnLevelUp, self.OnClickSkillsChange)
  self:AddButtonListener(self.ShareBtn.btnLevelUp, self.OnShareClick)
  self:AddButtonListener(self.KeyBtn.btnLevelUp, self.OnImportClick)
  self.ScrollBox.OnUserScrolled:Add(self, self.OnScrollChanged)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnChangeBattleTab, self.OnChageSelectTab)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnSelectBattleTeam, self.OnChageSelectTeam)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnChangeSelectPet, self.OnChangeSelectPet)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnSaveBattleTeamSucceed, self.OnSaveBattleTeamSucceed)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnUpdateTeamBloodMagic, self.OnUpdateTeamBloodMagic)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnChangeBattleTeamItem, self.OnChangeBattleTeamItem)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnUpdateCurrentPetList, self.OnUpdatePetList)
  _G.NRCEventCenter:RegisterEvent("UMG_Level_Team_C", self, BagModuleEvent.OnFilter, self.OnFilterPets)
  _G.NRCEventCenter:RegisterEvent("UMG_Level_Team_C", self, BagModuleEvent.UpdateSort, self.SortPets)
  _G.NRCEventCenter:RegisterEvent("UMG_Level_Team_C", self, LevelSelectionModuleEvent.OnShowPetDataRight, self.SetRightInfo)
  _G.NRCEventCenter:RegisterEvent("UMG_Level_Team_C", self, LevelSelectionModuleEvent.OnIsHideArrayRight, self.OnIsHideArrayRight)
  _G.NRCEventCenter:RegisterEvent("UMG_Level_Team_C", self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  _G.NRCModuleManager:GetModule("PetUIModule"):RegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.RefreshTeamName)
  _G.NRCEventCenter:RegisterEvent(self.name, self, ShareUIModuleEvent.SHOW_ENTRANCE_REWARD, self.CheckShowShareReward)
end

function UMG_Level_Team_C:OnClosePanel()
  if not self:IsAnimationPlaying(self.Out) then
    self:StopAllAnimations()
    self:PlayAnimation(self.Out)
  else
    self:DoClose()
  end
end

function UMG_Level_Team_C:OnAnimationFinished(anim)
  if self.Out == anim then
    self:DoClose()
  elseif self.Right_Out == anim then
    self.CanvasPanel_15:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Level_Team_C:OnSwitcherSwitcher(SwitcherIndex)
  self.NRCSwitcher_1:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Level_Team_C:OnSwitcherNRCSwitcher_27(SwitcherIndex)
  self.NRCSwitcher_27:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Level_Team_C:OnClickBtn_Redact()
  if self.curSelectTeam ~= nil then
    self:ShowSelectTeamPetList()
  end
end

function UMG_Level_Team_C:OnClickBloodBtn_1()
  local items = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, _G.Enum.BagItemType.BI_PLAYERSKILL)
  if items and #items > 0 then
    local gidList = {}
    if self.curChangeTeam == nil then
      self.curChangeTeam = self:BuildPetList(self.curSelectTeam.teams) or {}
    end
    for i = 1, #self.curChangeTeam do
      if 0 ~= self.curChangeTeam[i].pet_gid then
        table.insert(gidList, self.curChangeTeam[i].pet_gid)
      end
    end
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenBloodLineMagic, self.curSelectTeam.type, self.curSelectTeam.idx, gidList)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.challenge_text_10)
  end
end

function UMG_Level_Team_C:OnClickReNameBtn()
  local param = {
    teamType = self.curSelectTeam.type,
    TeamIdx = self.curSelectTeam.idx,
    teamName = self.curSelectTeam.title
  }
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenRechristenPanel, param, nil, 2)
end

function UMG_Level_Team_C:OnClickBtn_Adhibition()
  if self.curSelectTeam ~= nil then
    local newInfo = self:GetTeamDataByType(self.curSelectTeam.type, self.curSelectTeam.idx)
    if newInfo then
      _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSelectTeam, newInfo, self.panelType)
    else
      _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSelectTeam, self.curSelectTeam, self.panelType)
    end
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSetCacheTeamData, nil)
    self:OnClosePanel()
  else
  end
end

function UMG_Level_Team_C:GetTeamDataByType(type, idx)
  local allDataList = _G.NRCModeManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdGetAllTeamDatas)
  for key, teamInfo in pairs(allDataList) do
    if type == teamInfo.type and idx == teamInfo.idx then
      return teamInfo
    end
  end
  return nil
end

function UMG_Level_Team_C:OnClickBloodBtn()
end

function UMG_Level_Team_C:OnClickBtn_Cultivate()
  local team = {}
  team.idx = self.curSelectTeam.idx
  team.type = self.curSelectTeam.type
  team.title = self.curSelectTeam.title
  team.teams = self.curChangeTeam or self:BuildPetList(self.curSelectTeam.teams)
  team.magicGid = self.curSelectTeam.magicGid
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSaveBattleTeam, team)
  self:OnIsHideArrayRight(false)
  _G.NRCEventCenter:DispatchEvent(LevelSelectionModuleEvent.OnIsHideArrayRight, false)
  self:DispatchEvent(LevelSelectionModuleEvent.OnOpenTeamCompiler, false)
end

function UMG_Level_Team_C:OnFilterPets(petInfos, condition)
  self.WarehouseList:InitGridView(petInfos)
  self.curTeamDatas = petInfos
  self:OnUpdatePetList()
  self:SetFilterCondition(condition)
end

function UMG_Level_Team_C:SortPets(sortIndex, sortData)
  self.curSortId = sortIndex
  self:OnUpdatePetList()
end

function UMG_Level_Team_C:OnUpdatePetList()
  local datas
  if 1 == self.curSortId then
    datas = self:SortPetLevel(self.curTeamDatas)
  else
    datas = self:SortPetTime(self.curTeamDatas)
  end
  if self.IsReversalSort then
    datas = self:OnReversePetList(datas)
  end
  self.WarehouseList:InitGridView(datas)
end

function UMG_Level_Team_C:SortPetLevel(datas)
  table.sort(datas, function(a, b)
    if a.level == b.level then
      return a.gid < b.gid
    else
      return a.level > b.level
    end
  end)
  return datas
end

function UMG_Level_Team_C:SortPetTime(datas)
  table.sort(datas, function(a, b)
    if a.add_time == b.add_time then
      return a.gid < b.gid
    else
      return a.add_time > b.add_time
    end
  end)
  return datas
end

function UMG_Level_Team_C:OnReversePetList(datas)
  local function reversal(list)
    local reversedList = {}
    
    for i = #list, 1, -1 do
      table.insert(reversedList, list[i])
    end
    return reversedList
  end
  
  local petList = {}
  petList = reversal(datas)
  return petList
end

function UMG_Level_Team_C:OnClickReverse()
  self.IsReversalSort = not self.IsReversalSort
  self:SetReverse()
  self:OnUpdatePetList()
end

function UMG_Level_Team_C:RefreshTeamName()
  self:OnUpdateTeamInfo()
end

function UMG_Level_Team_C:OnEquipmentOrRemoveBloodEvent()
end

function UMG_Level_Team_C:ShowSelectTeamPetList()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdInitCurrentTeamDic, self.curSelectTeam)
  self:OnSwitcherSwitcher(1)
  self:PlayAnimation(self.Team_in)
  local petData = {}
  for i = 1, 6 do
    local data = {}
    if self.curSelectTeam and i <= #self.curSelectTeam.teams then
      data = self.curSelectTeam.teams[i]
    else
      data = {pet_gid = 0}
    end
    table.insert(petData, data)
  end
  self.Text_1:SetText(self.curSelectTeam.title)
  self.PetList:InitGridView(petData)
  if self.curSelectTeam.magicGid == nil or 0 == self.curSelectTeam.magicGid then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, self.curSelectTeam.magicGid)
    local bagitemConf = _G.DataConfigManager:GetBagItemConf(bagItemData.id)
    self.Icon:SetPath(bagitemConf.icon)
    self.Switcher:SetActiveWidgetIndex(0)
  end
  local datas = self:CreateStorehouseData()
  self.WarehouseList:InitGridView(datas)
  self.petInfos = datas
  self.curTeamDatas = datas
  self:DispatchEvent(LevelSelectionModuleEvent.OnOpenTeamCompiler, true)
end

function UMG_Level_Team_C:ShowPetStorehouse()
  local cacheTeams = _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdGetCacheTeamData)
  local currentTeam
  if nil == cacheTeams then
    if self.panelType == LevelSelectionEnum.BattlePanel.Silhouette then
      currentTeam = self.module.data.curNpcTeamData
    else
      currentTeam = self.module.data.curBossTeamData
    end
  else
    currentTeam = cacheTeams
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSetCacheTeamData, nil)
  end
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdInitCurrentTeamDic, currentTeam, true)
  self:PlayAnimation(self.Change_tab1)
  local storehouseDatas = self:CreateStorehouseData()
  self.WarehouseList:InitGridView(storehouseDatas)
  self.petInfos = storehouseDatas
  self.curTeamDatas = storehouseDatas
end

function UMG_Level_Team_C:OnClickScreenBtn()
  if self.petInfos == nil then
    return
  end
  for i = 1, #self.petInfos do
    local filterData = {}
    filterData.petbase_id = self.petInfos[i].base_conf_id
    filterData.gid = self.petInfos[i].gid
    filterData.gender = self.petInfos[i].gender
    self.petInfos[i].filterData = filterData
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenFilterPanel, self.petInfos, _G.DataConfigManager.ConfigTableId.TRAVEL_FILTER_CONF, self.FilterCondition)
end

function UMG_Level_Team_C:SetFilterCondition(condition)
  if not self.FilterCondition then
    self.FilterCondition = {}
    self.FilterCondition.FilterDepartCondition = {}
    self.FilterCondition.FilterGenderCondition = {}
  end
  if condition and self.FilterCondition then
    local oldCount = #self.FilterCondition.FilterDepartCondition + #self.FilterCondition.FilterGenderCondition
    local newCount = #condition.FilterDepartCondition + #condition.FilterGenderCondition
    if 0 == oldCount and newCount > 0 or oldCount > 0 and 0 == newCount then
      self.ComScreen.ScreeningBtn:ChangeIconSelectState()
    end
    self.FilterCondition = condition
  end
end

function UMG_Level_Team_C:SetReverse()
  if self.IsReversalSort then
    self.ComScreen.SortingBtn:SetRenderScale(UE4.FVector2D(-1, 1))
  else
    self.ComScreen.SortingBtn:SetRenderScale(UE4.FVector2D(-1, -1))
  end
end

function UMG_Level_Team_C:OnClickComboBox()
  local list = {}
  for i = 1, 2 do
    local sortInfo = {}
    local sortId = i
    local name = _G.DataConfigManager:GetTravelSequenceConf(sortId).sequence_desc
    sortInfo.text = name
    sortInfo.sequence = sortId
    table.insert(list, sortInfo)
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenBagSortPanel, list, self.curSortId)
end

function UMG_Level_Team_C:OnIsHideArrayRight(IsHideArrayRight)
  if self.IsHideArrayRight == IsHideArrayRight then
    return
  end
  if IsHideArrayRight then
    self:StopAllAnimations()
    self:PlayAnimation(self.Right_In)
    self.CanvasPanel_15:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:PlayAnimation(self.Right_Out)
  end
  self.IsHideArrayRight = IsHideArrayRight
end

function UMG_Level_Team_C:SetRightInfo(PetData)
  if not PetData then
    return
  end
  self.petData = PetData
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_FavoriteButton_C:UpdateInfo")
  self.IconList_1:ScrollToStart()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetData.base_conf_id)
  local commonAttrData = {}
  local commonAttrData1 = {}
  self.textPetName:SetText(PetData.name)
  self:updatePetGender(PetData.gender)
  self.UMG_PetRate:SetText(PetData)
  self.textPetLv:SetText(PetData.level)
  local PetLevel = PetUtils.GetCatchHardInfo(PetData)
  self.CatchHardLv:InitGridView(PetLevel)
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
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(PetData.blood_id)
  if PetBloodConf then
    if not PetData or PetData.is_trial_pet then
      self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.UMG_CollectBtn:UpdateInfo(PetData.partner_mark, true)
    end
    table.insert(commonAttrData, {
      Name = PetBloodConf.blood_name,
      Path = PetBloodConf.icon
    })
    if self.Attr then
      self.Attr:InitGridView(commonAttrData)
    end
  end
  local isTrialPet, _ = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdIsTrailPet, PetData.gid)
  if isTrialPet then
    self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.CommonPetDetails:InitPetBaseInfo(PetData, petBaseConf)
  self.Switcher:SetActiveWidgetIndex(0)
end

function UMG_Level_Team_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Level_Team_C:GetPetEquipSkills(petData)
  local petEquipSkills = self:GetPvpTeamPetSkillListByPetGid(petData.gid)
  if petEquipSkills then
    local result = {}
    for _, id in pairs(petEquipSkills) do
      table.insert(result, {id = id})
    end
    return result
  end
  local petUIData = _G.NRCModuleManager:GetModule("PetUIModule").data
  petEquipSkills = petUIData:GetPetSkillsData(petData.gid)
  if petEquipSkills then
    local result = {}
    for _, id in pairs(petEquipSkills) do
      table.insert(result, {id = id})
    end
    return result
  end
  petEquipSkills = {}
  if petData.skill and petData.skill.skill_data then
    for i, skillData in ipairs(petData.skill.skill_data) do
      if skillData.is_equipped and 1 == skillData.type and skillData.pos > 0 and skillData.pos <= 4 then
        petEquipSkills[skillData.pos] = skillData
      end
    end
  end
  return petEquipSkills
end

function UMG_Level_Team_C:GetPvpTeamPetSkillListByPetGid(PetGid)
  local teamInfo
  if self.teamType then
    if self.teamType == Enum.PlayerTeamType.PTT_BIG_WORLD then
      teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
    else
      teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(self.teamType)
    end
  else
    teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
  end
  if nil == teamInfo then
    return nil
  end
  local team = teamInfo.teams[1]
  if team and team.pet_infos then
    for _, petInfo in pairs(team.pet_infos) do
      if petInfo.pet_gid == PetGid then
        if petInfo.equip_infos then
          do
            local skillList = {}
            for _, skillInfo in pairs(petInfo.equip_infos) do
              skillList[skillInfo.pos] = skillInfo.id
            end
            return skillList
          end
          break
        end
        do return nil end
        break
      end
    end
  end
  return nil
end

function UMG_Level_Team_C:OpenPetTips()
  local petData = self.petData
  local uidata = {petData = petData}
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, uidata, _G.Enum.GoodsType.GT_PET)
end

function UMG_Level_Team_C:OnBloodPulse()
  local petData = self.petData
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPetBloodPulse, petData, TipEnum.OpenPetTipsType.PetWareHouse)
end

function UMG_Level_Team_C:ClosePetRight()
  self:OnIsHideArrayRight(false)
  _G.NRCEventCenter:DispatchEvent(LevelSelectionModuleEvent.OnIsHideArrayRight, false)
  self.petData = nil
end

function UMG_Level_Team_C:GetSkillMapByPetGid(petData)
  local PetGid = petData.gid
  local skillList = self:GetPetEquipSkills(petData)
  local skillMap = {}
  if skillList then
    for index, skillInfo in pairs(skillList) do
      skillMap[skillInfo.id] = index
    end
  end
  return skillMap
end

function UMG_Level_Team_C:GetTeamParam(PetGid)
  local teamParam = {}
  teamParam.TeamType = self.teamType
  teamParam.TeamIdx = 0
  teamParam.PetGid = PetGid
  return teamParam
end

function UMG_Level_Team_C:OnClickSkillsChange()
  if self.petData then
    local petDataInfo = self.petData
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petDataInfo, 2, true)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetEnterPetPanelType, PetUIModuleEnum.EnterType.PvpPetTeamUmg)
    local skillMap = self:GetSkillMapByPetGid(petDataInfo)
    local teamParam = self:GetTeamParam(petDataInfo.gid)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPvpSkillData, skillMap, teamParam)
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {subPanelIndex = 4, callback = nil})
  end
end

function UMG_Level_Team_C:OnScrollChanged(value)
  if value ~= self.lastValue then
    local item = _G.NRCModeManager:DoCmd(LevelSelectionModuleCmd.OnCmdGetLevelListItemPet)
    if UE.UObject.IsValid(item) then
      item:UnRegister()
    end
  end
  self.lastValue = value
end

function UMG_Level_Team_C:CheckShowShareReward(data)
  if data.shareBaseId == self.shareBaseId and 0 == data.rewardGetState then
    local function cb()
      self.ShareUIReward:Init({
        shareBaseId = data.shareBaseId,
        
        isUpAnim = false
      })
    end
    
    self.shareDelayId = _G.DelayManager:DelayFrames(1, cb, self)
  end
end

function UMG_Level_Team_C:CancelShareDelayId()
  if self.shareDelayId then
    _G.DelayManager:CancelDelayById(self.shareDelayId)
    self.shareDelayId = nil
  end
end

function UMG_Level_Team_C:CheckShareIsOpen()
  self.shareBaseId = _G.Enum.ShareButtonType.SBT_TEAM_SHARE
  self.ShareIsOpen = _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.CheckIsOpen, self.shareBaseId)
  if self.ShareIsOpen then
    self.ShareBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ShareBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Level_Team_C
