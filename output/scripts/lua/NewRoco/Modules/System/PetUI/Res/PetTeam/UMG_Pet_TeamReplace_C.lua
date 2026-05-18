local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local ProtoEnum = require("Data.PB.ProtoEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local UMG_Pet_TeamReplace_C = _G.NRCPanelBase:Extend("UMG_Pet_TeamReplace_C")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local PetTeamUtils = require("NewRoco.Modules.System.PetUI.Res.PetTeam.PetTeamUtils")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local PvpBattleFilter = {
  [Enum.PlayerTeamType.PTT_PVP_BATTLE_2] = Enum.SkillDamType.SDT_WATER,
  [Enum.PlayerTeamType.PTT_PVP_BATTLE_3] = Enum.SkillDamType.SDT_INSECT
}
local PetTabType = {
  BagPet = 1,
  TrialPet = 2,
  RandomPet = 3
}
local ExChangeState = {Normal = 0, ExChanging = 1}
UMG_Pet_TeamReplace_C.SwitcherDescribeDataType = {
  None = 0,
  TeamDescription = 1,
  TeamErrorMessage = 2
}
UMG_Pet_TeamReplace_C.TabItemCountToCustomWidth = {
  [2] = 530,
  [3] = 357
}

function UMG_Pet_TeamReplace_C:InitData()
  self.uiData = {}
  self.data = self.module:GetData("PetUIModuleData")
end

function UMG_Pet_TeamReplace_C:OnActive(teamType, selTeamIdx, petGid, slotId, mode, openType)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    return
  end
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.RefreshEditorPetTeamCache, teamType, selTeamIdx)
  self.WarehouseList:InitList({})
  self.PetList:InitGridView({})
  self.Switcher:SetActiveWidgetIndex(2)
  self:OnAddEventListener()
  self.curTeamIdx = selTeamIdx
  self.curPetGid = petGid
  self.curSlotId = slotId
  self.curMode = mode
  self.curTeamType = teamType
  self.openType = openType
  self.curExChangeState = ExChangeState.Normal
  self.descText = {}
  self.skillId = nil
  self.uiData = {}
  self.slotDic = {}
  self.SwitcherDescribeData = {
    type = UMG_Pet_TeamReplace_C.SwitcherDescribeDataType.None
  }
  self.RecyclingCountMap = {}
  self.canInTeamNum = PetTeamUtils.GetCanInPetNum(teamType)
  self.canSelectNum = self.canInTeamNum
  self.data = self.module:GetData("PetUIModuleData")
  self.showLockSkill = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetIsShowPetNotUnlockSkill)
  self:SetCommonTitle()
  self:RefreshShowLockSkillBtn()
  self:InitUI()
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  if selTeamIdx and mode then
    self:RefreshPetEquipSkill()
  end
  self.trialRefreshTime = nil
  if self.curTeamType and self.curTeamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    self.trialRefreshTime = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetTrialPetBriefRefreshTime)
  end
  self.KeyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RandomBonus.RedDot:SetupKey(419)
  self:SetCommonComboBoxInfo(self.ComScreen)
  self:RefreshTeamData()
  self:UpdateRoleMagicInfo()
  self:SetPetTabType(PetTabType.BagPet - 1)
  self:PlayAnimation(self.In)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetInQualifyingState, self.curTeamType and self.curTeamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetIsShowPetNotUnlockSkill, false)
end

function UMG_Pet_TeamReplace_C:OnBtnRenameClick()
  self:ResetDescText()
  local param = {
    teamType = self.curTeamType,
    TeamIdx = self.curTeamIdx,
    teamName = self:GetTeamName()
  }
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenRechristenPanel, param, nil, 2)
end

function UMG_Pet_TeamReplace_C:SetCommonComboBoxInfo(ComboBox, ComboBoxText, ComboBoxIcon)
  local CommonDropDownListData = _G.NRCCommonDropDownListData()
  if ComboBoxText then
    CommonDropDownListData.DropDownListText = ComboBoxText
  end
  if ComboBoxIcon then
    CommonDropDownListData.DropDownListIcon = ComboBoxIcon
  end
  CommonDropDownListData.Call = self
  CommonDropDownListData.Btn_LeftHandler = self.OpenFilterPanelBtnClick
  CommonDropDownListData.Btn_MidHandler = self.OnSortBtnButtonClick
  CommonDropDownListData.Btn_RightHandler = self.OnReversedSort
  ComboBox:SetPanelInfo(CommonDropDownListData)
end

function UMG_Pet_TeamReplace_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Pet_TeamReplace_C:IsTrialPetExpired()
  if self.trialRefreshTime then
    local servetTime = ActivityUtils.GetSvrTimestamp()
    if servetTime > self.trialRefreshTime then
      return true
    end
  end
  return false
end

function UMG_Pet_TeamReplace_C:OnDeactive()
  UE4Helper.SetEnableWorldRendering(nil, nil, "UMG_Pet_TeamReplace")
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.OnCmdTryReshowUmgPVPQualifier)
end

function UMG_Pet_TeamReplace_C:GetCurMode()
  return self.curMode
end

function UMG_Pet_TeamReplace_C:GetCurExChangeState()
  return self.curExChangeState == ExChangeState.Normal
end

function UMG_Pet_TeamReplace_C:GetCurSelPetDataGid()
  return self.curSelPetData and self.curSelPetData.gid or 0
end

function UMG_Pet_TeamReplace_C:GetCurSelectIsInTeam()
  local gid = self:GetCurSelPetDataGid()
  local isInTeam = self:IsInTeam(gid)
  return isInTeam
end

function UMG_Pet_TeamReplace_C:SetPetTabType(type)
  self.Tab:SelectItemByIndex(type)
end

function UMG_Pet_TeamReplace_C:OnPetTeamReplaceTabSelect(tabInfoListIndex)
  tabInfoListIndex = tabInfoListIndex or 1
  local tabInfoList = self.tabInfoList or {}
  local tabInfo = tabInfoList and tabInfoList[tabInfoListIndex]
  local TabType = tabInfo and tabInfo.tabType
  if self:IsTrialPetExpired() then
    local tips = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_trial_pet_character4").str
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tips)
    self:OnCloseButtonClick()
    return
  end
  self.petTabType = TabType
  self:ChangePetTabData(TabType)
end

function UMG_Pet_TeamReplace_C:ChangePetTabData(type)
  if self.curExChangeState == ExChangeState.ExChanging then
    self:OnExchangeBtnClick()
  end
  self:AddPetsToPetList()
  if self.curPetTabType ~= type and self.curSelPetData and not self:IsInTeam(self.curSelPetData.gid) then
    self.curSelPetData = nil
  end
  self.curPetTabType = type
  local prevMode = self.curMode
  local nextMode = prevMode
  if type == PetTabType.BagPet then
    self:RefreshUI(prevMode, nextMode)
  elseif type == PetTabType.TrialPet then
    self:RefreshUI(prevMode, nextMode)
  elseif type == PetTabType.RandomPet then
    self:RefreshUI(prevMode, nextMode)
  end
  self:SwitchUIByPetTabType(type)
end

function UMG_Pet_TeamReplace_C:OnCollectBtn()
  self:ResetDescText()
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetCollectPanel, self.curSelPetData.gid, (self.curSelPetData.PetBaseInfo or {}).partner_mark)
end

function UMG_Pet_TeamReplace_C:OnRecyclingBtn()
  if not self.curSelPetData then
    return
  end
  local curSelPetData = self.curSelPetData
  local tempPetInfos = self:GetCurTempPetInfo()
  self.RecyclingCountMap[curSelPetData.gid] = UE4.UNRCStatics.GetTimestampMicroseconds()
  for index, value in ipairs(tempPetInfos) do
    if value.pet_gid == curSelPetData.gid then
      table.remove(tempPetInfos, index)
      break
    end
  end
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamInfo, tempPetInfos, self.curTeamIdx, self.module.data.OpenTeamType)
end

function UMG_Pet_TeamReplace_C:ResetWareHouseList()
  local itemcount = self.WarehouseList:GetItemCount()
  for i = 1, itemcount do
    local item = self.WarehouseList:GetChildAt(i - 1)
    if item then
    end
  end
end

function UMG_Pet_TeamReplace_C:UpdateCollect(partner_mark)
  if not self.curSelPetData or not self.curSelPetData.PetBaseInfo then
    return
  end
  self.curSelPetData.PetBaseInfo.partner_mark = partner_mark
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  if self.curSelPetData.PetBaseInfo.is_trial_pet or team.is_mirror then
    self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UMG_CollectBtn:UpdateInfo(partner_mark)
  end
  local itemcount = self.WarehouseList:GetItemCount()
  for i = 1, itemcount do
    local item = self.WarehouseList:GetItemByIndex(i - 1)
    if not item.data.PetData then
    elseif item.data.PetData.gid == self.curSelPetData.gid then
      if self.curSelPetData.PetBaseInfo.partner_mark and self.curSelPetData.PetBaseInfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE and not item.data.PetData.IsMainTeam then
        item.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.curSelPetData.PetBaseInfo.partner_mark))
        item.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        item.data.PetData.PetBaseInfo.partner_mark = partner_mark
      else
        item.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
  itemcount = self.PetList:GetItemCount()
  for i = 1, itemcount do
    local item = self.PetList:GetItemByIndex(i - 1)
    if not item.data.PetData then
    elseif item.data.PetData.gid == self.curSelPetData.gid then
      if self.curSelPetData.PetBaseInfo.partner_mark and self.curSelPetData.PetBaseInfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE and not item.data.PetData.IsMainTeam then
        item.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.curSelPetData.PetBaseInfo.partner_mark))
        item.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        item.data.PetData.PetBaseInfo.partner_mark = partner_mark
      else
        item.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
  for i = 1, #self.warehousePetHeadInfo do
    if self.warehousePetHeadInfo[i].PetBaseInfo.gid == self.curSelPetData.gid then
      self.warehousePetHeadInfo[i].PetBaseInfo.partner_mark = self.curSelPetData.PetBaseInfo.partner_mark
      if self.curSelPetData.PetBaseInfo.partner_mark then
        self.warehousePetHeadInfo[i][11] = self.curSelPetData.PetBaseInfo.partner_mar
        break
      end
      self.warehousePetHeadInfo[i][11] = 0
      break
    end
  end
end

function UMG_Pet_TeamReplace_C:OnPetTeamWarehouseItemExChanging(isInTeam, PetData)
  if PetData then
    if isInTeam then
      self.RecyclingBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.RecyclingBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.RecyclingBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Pet_TeamReplace_C:OnPetTeamManagementSelChanged(selectedTeamIdx)
  local prevMode = self.curMode
  local nextMode = prevMode
  if self.curExChangeState == ExChangeState.ExChanging then
    self:OnExchangeBtnClick()
  end
  self:RefreshTeamData()
  self:UpdateRoleMagicInfo()
  self:RefreshUI(prevMode, nextMode)
  if self.uiData.AfterFilterList and self.isEmptyTeam and self.curSelPetData then
    local findGid = false
    for i, petInfo in ipairs(self.uiData.AfterFilterList) do
      if petInfo.PetData and petInfo.PetData.PetBaseInfo and petInfo.PetData.PetBaseInfo.gid == self.curSelPetData.gid then
        findGid = true
        break
      end
    end
    if not findGid and self.curSelPetData.gid then
      self.WarehouseList:SelectItemByIndex(0)
    end
  end
  if self.isEmptyTeam then
    self:SelectFirstPet()
  end
end

function UMG_Pet_TeamReplace_C:OnAddEventListener()
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_SORT, self.SortItemInfo)
  self:RegisterEvent(self, PetUIModuleEvent.SetWarehousePetSortIndex, self.SetPetSortIndex)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationSelected, self.OnPetTeamFastFormationSelected)
  self:RegisterEvent(self, PetUIModuleEvent.TypeChooseChanged, self.OnTypeChooseChanged)
  self:RegisterEvent(self, PetUIModuleEvent.PvpPetTeamEquipPetSkills, self.OnPvpPetTeamEquipPetSkills)
  self:RegisterEvent(self, PetUIModuleEvent.PetEquipSkillFinished, self.OnPetEquipSkillFinished)
  self:RegisterEvent(self, PetUIModuleEvent.UpdatePetCollect, self.UpdateCollect)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemExChanging, self.OnPetTeamWarehouseItemExChanging)
  self:RegisterEvent(self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
  self:RegisterEvent(self, PetUIModuleEvent.PlayerDataUpdate, self.OnPlayerDataUpdate)
  self:RegisterEvent(self, PetUIModuleEvent.OnBalancePetDataForPvpUpdate, self.UpdateSelectPetDataForPvpBalance)
  self:AddButtonListener(self.Btn_ShutDown, self.ResetDescText)
  self:AddButtonListener(self.Btn_ShutDown_1, self.ResetDescText)
  self:AddButtonListener(self.Btn_ShutDown_2, self.ResetDescText)
  self:AddButtonListener(self.Btn_ShutDown_3, self.ResetDescText)
  self:AddButtonListener(self.Btn_ShutDown_4, self.ResetDescText)
  self:AddButtonListener(self.Btn_ShutDown_5, self.ResetDescText)
  self:AddButtonListener(self.ExchangeGrey.btnLevelUp, self.OnBanChangeButtonClick)
  self:AddButtonListener(self.Btn_Cultivate_1.btnLevelUp, self.OnChangeButtonClick)
  self:AddButtonListener(self.RandomBonus.btnLevelUp, self.OnRandomPetBonusButtonClick)
  self:AddButtonListener(self.DeleteBtn.btnLevelUp, self.OnDeleteBtnClick)
  self:AddButtonListener(self.ExchangeBtn.btnLevelUp, self.OnExchangeBtnClick)
  self:AddButtonListener(self.ExchangeBtn_1.btnLevelUp, self.OnExchangeBtnClick)
  self:AddButtonListener(self.Return.btnClose, self.OnClose)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.BtnRechristen_1, self.OpenPetTips)
  self:AddButtonListener(self.UMG_CollectBtn.Button, self.OnCollectBtn)
  self:AddButtonListener(self.RecyclingBtn, self.OnRecyclingBtn)
  self:AddButtonListener(self.changeBtn4.btnLevelUp, self.OnClickSkillsChange)
  self:AddButtonListener(self.PetDetails.btnLevelUp, self.OnBtnCultivateClicked)
  self:AddButtonListener(self.changeBtn5.btnLevelUp, self.SaveSkillChange)
  self:AddButtonListener(self.RenameBtn.btnLevelUp, self.OnBtnRenameClick)
  self:AddButtonListener(self.ViewPet.btnLevelUp, self.OnSelectSkillClick)
  self:AddButtonListener(self.ViewPet_2.btnLevelUp, self.OnSortSkillClick)
  self:AddButtonListener(self.ViewPet_3.btnLevelUp, self.OnShowLockSkillClick)
  self:AddButtonListener(self.ShareBtn.btnLevelUp, self.OnShareClick)
  self:AddButtonListener(self.KeyBtn.btnLevelUp, self.OnImportClick)
  self.Exchange_1.btnLevelUp.OnClicked:Add(self, self.OnBtnOpenMagicBag)
  self.BloodBtn.OnClicked:Add(self, self.OnBtnOpenMagicBag)
  self.BloodBtn_1.OnClicked:Add(self, self.OnBtnOpenMagicBag)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.RefreshCurTeamUI)
  _G.NRCEventCenter:RegisterEvent("UMG_Pet_TeamManagement_C", self, PetUIModuleEvent.PetTeamEquipPetMagicRsp, self.UpdateRoleMagicInfo)
  _G.NRCEventCenter:RegisterEvent("UMG_Pet_TeamReplace_C", self, PetUIModuleEvent.OpenChangePetConfirm, self.OnShowTipBtnClick)
  _G.NRCEventCenter:RegisterEvent("UMG_Pet_TeamReplace_C", self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  _G.NRCEventCenter:RegisterEvent("UMG_PetWarehouseMain_C", self, PetUIModuleEvent.OnBagSKillTipsPanelShowChange, self.OnBagSKillTipsPanelShowChange)
  _G.NRCEventCenter:RegisterEvent("UMG_PetWarehouseMain_C", self, PetUIModuleEvent.RefreshAdjustPetPanel, self.RefreshAdjustPetPanel)
  self:RegisterEvent(self, PetUIModuleEvent.EQUIP_SKILL_SUCCESS, self.OnEquippedSuccess)
  if self.ChangePetSkillsPanel then
    self.ChangePetSkillsPanel.OnLoadPanelCallbackDelegate:Add(self, self.OnChangePetSkillPanelCallback)
  end
end

function UMG_Pet_TeamReplace_C:OnBtnCultivateClicked()
  local petDataInfo = self.curShowPetData.PetBaseInfo
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petDataInfo, 1, false)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetEnterPetPanelType, PetUIModuleEnum.EnterType.PvpPetTeamUmg)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1014, "UMG_LobbyMain_C:OnBtnPetHeadClick")
  local skillMap = self:GetSkillMapByPetGid(self.curShowPetData)
  local teamParam = self:GetTeamParam(self.curShowPetData.gid)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPvpSkillData, skillMap, teamParam)
  NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {subPanelIndex = 4, callback = nil})
end

function UMG_Pet_TeamReplace_C:SaveSkillChange()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    if ChangePetSkillsPanel and ChangePetSkillsPanel.petData and ChangePetSkillsPanel.petData.blood_id ~= Enum.PetBloodType.PBT_NIGHTMARE then
      ChangePetSkillsPanel:OnChangeButtonClick()
    end
    ChangePetSkillsPanel:OnDisable()
  end
  self.IsChangeSkill = false
  self.Switcher:SetActiveWidgetIndex(0)
  self:InitFilterAndSort()
end

function UMG_Pet_TeamReplace_C:OnEquippedSuccess(_changes)
end

function UMG_Pet_TeamReplace_C:OnChangePetSkillPanelCallback()
  self.Switcher:SetActiveWidgetIndex(1)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Pet_TeamReplace_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, PetUIModuleEvent.PET_UI_SORT, self.SortItemInfo)
  self:UnRegisterEvent(self, PetUIModuleEvent.SetWarehousePetSortIndex, self.SetPetSortIndex)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationSelected, self.OnPetTeamFastFormationSelected)
  self:UnRegisterEvent(self, PetUIModuleEvent.TypeChooseChanged, self.OnTypeChooseChanged)
  self:UnRegisterEvent(self, PetUIModuleEvent.PvpPetTeamEquipPetSkills, self.OnPvpPetTeamEquipPetSkills)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetEquipSkillFinished, self.OnPetEquipSkillFinished)
  self:UnRegisterEvent(self, PetUIModuleEvent.UpdatePetCollect, self.UpdateCollect)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemExChanging, self.OnPetTeamWarehouseItemExChanging)
  self:UnRegisterEvent(self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
  self:UnRegisterEvent(self, PetUIModuleEvent.PlayerDataUpdate, self.OnPlayerDataUpdate)
  self:UnRegisterEvent(self, PetUIModuleEvent.OnBalancePetDataForPvpUpdate, self.UpdateSelectPetDataForPvpBalance)
  self:RemoveButtonListener(self.Btn_ShutDown, self.ResetDescText)
  self:RemoveButtonListener(self.Btn_ShutDown_1, self.ResetDescText)
  self:RemoveButtonListener(self.Btn_ShutDown_2, self.ResetDescText)
  self:RemoveButtonListener(self.Btn_ShutDown_3, self.ResetDescText)
  self:RemoveButtonListener(self.Btn_ShutDown_4, self.ResetDescText)
  self:RemoveButtonListener(self.Btn_ShutDown_5, self.ResetDescText)
  self:RemoveButtonListener(self.Btn_Cultivate_1.btnLevelUp, self.OnChangeButtonClick)
  self:RemoveButtonListener(self.DeleteBtn.btnLevelUp, self.OnDeleteBtnClick)
  self:RemoveButtonListener(self.ExchangeBtn.btnLevelUp, self.OnExchangeBtnClick)
  self:RemoveButtonListener(self.ExchangeBtn_1.btnLevelUp, self.OnExchangeBtnClick)
  self:RemoveButtonListener(self.Return.btnClose, self.OnClose)
  self:RemoveButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:RemoveButtonListener(self.BtnRechristen_1, self.OpenPetTips)
  self:RemoveButtonListener(self.UMG_CollectBtn.Button, self.OnCollectBtn)
  self:RemoveButtonListener(self.RecyclingBtn, self.OnRecyclingBtn)
  self:RemoveButtonListener(self.changeBtn4.btnLevelUp, self.OnClickSkillsChange)
  self:RemoveButtonListener(self.RenameBtn.btnLevelUp, self.OnBtnRenameClick)
  self:RemoveButtonListener(self.ViewPet.btnLevelUp, self.OnSelectSkillClick)
  self:RemoveButtonListener(self.ViewPet_2.btnLevelUp, self.OnSortSkillClick)
  self:RemoveButtonListener(self.ViewPet_3.btnLevelUp, self.OnShowLockSkillClick)
  self:RemoveButtonListener(self.ShareBtn.btnLevelUp, self.OnShareClick)
  self:RemoveButtonListener(self.KeyBtn.btnLevelUp, self.OnImportClick)
  self.Exchange_1.btnLevelUp.OnClicked:Remove(self, self.OnBtnOpenMagicBag)
  self.BloodBtn.OnClicked:Remove(self, self.OnBtnOpenMagicBag)
  self.BloodBtn_1.OnClicked:Remove(self, self.OnBtnOpenMagicBag)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.RefreshCurTeamUI)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamEquipPetMagicRsp, self.UpdateRoleMagicInfo)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.OpenChangePetConfirm, self.OnShowTipBtnClick)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.OnBagSKillTipsPanelShowChange, self.OnBagSKillTipsPanelShowChange)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.RefreshAdjustPetPanel, self.RefreshAdjustPetPanel)
  if self.ChangePetSkillsPanel then
    self.ChangePetSkillsPanel.OnLoadPanelCallbackDelegate:Remove(self, self.OnChangePetSkillPanelCallback)
  end
end

function UMG_Pet_TeamReplace_C:RefreshCurTeamUI()
  self.Text_1:SetText(self:GetTeamName())
end

function UMG_Pet_TeamReplace_C:UpdateRoleMagicInfo()
  local hasMagic = false
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  if team.is_mirror then
    self.BloodBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BloodBtn_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Exchange_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BloodBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.BloodBtn_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Exchange_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Exchange:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if team.is_mirror then
    if team.mirror_magic_id and 0 ~= team.mirror_magic_id then
      local BagItemConf = _G.DataConfigManager:GetBagItemConf(team.mirror_magic_id)
      if BagItemConf then
        hasMagic = true
        self.Switcher_1:SetActiveWidgetIndex(0)
        self.Icon:SetPath(BagItemConf.icon)
      end
    end
  elseif team.role_magic_gid and 0 ~= team.role_magic_gid then
    local itemInfo = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByGid, team.role_magic_gid)
    if itemInfo then
      local PlayerMagicConf = _G.DataConfigManager:GetBagItemConf(itemInfo.id)
      if PlayerMagicConf then
        hasMagic = true
        self.Switcher_1:SetActiveWidgetIndex(0)
        self.Icon:SetPath(PlayerMagicConf.icon)
      end
    end
  end
  if not hasMagic then
    self.Switcher_1:SetActiveWidgetIndex(1)
  end
end

function UMG_Pet_TeamReplace_C:QueryPvpBalanceData(petData)
end

function UMG_Pet_TeamReplace_C:UpdateSelectPetDataForPvpBalance(petDataList)
  local nextShowPetData
  local curShowPetData = self.curShowPetData
  if curShowPetData then
    nextShowPetData = {}
    table.copy(curShowPetData, nextShowPetData)
  end
  local PetBaseInfo = nextShowPetData and nextShowPetData.PetBaseInfo
  local currentShowPetGuid = PetBaseInfo and PetBaseInfo.gid
  local needSwitchToPvpBalancePetData = PetUtils.CheckNeedSwitchToPvpBalancePetData(nextShowPetData)
  if needSwitchToPvpBalancePetData then
    local balancePetData = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.CmdGetBalancedPetDataForPvp, currentShowPetGuid)
    if balancePetData and nextShowPetData then
      nextShowPetData.balancedPetBaseInfo = balancePetData
      self:SetRightInfo(nextShowPetData)
    end
  end
end

function UMG_Pet_TeamReplace_C:PreProcessPetDataForPvpBalance(petData)
  local needSwitchToPvpBalancePetData = PetUtils.CheckNeedSwitchToPvpBalancePetData(petData)
  if needSwitchToPvpBalancePetData then
    local petGuid = petData and petData.gid
    local balancePetData = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.CmdGetBalancedPetDataForPvp, petGuid)
    if balancePetData then
      local nextShowPetData = {}
      local curShowPetData = petData
      table.copy(curShowPetData, nextShowPetData)
      nextShowPetData.balancedPetBaseInfo = balancePetData
      petData = nextShowPetData
    else
      local petGuidList = {}
      table.insert(petGuidList, petGuid)
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.CmdQueryBalancedPetDataForPvp, petGuidList)
    end
  end
  return petData
end

function UMG_Pet_TeamReplace_C:OnBtnOpenMagicBag()
  local BagItemS = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PLAYERSKILL)
  if BagItemS and #BagItemS > 0 then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenBloodLineMagic, self.curTeamType, self.curTeamIdx)
  else
    local Conf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_tips1")
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, Conf.str)
  end
  self:ResetDescText()
end

function UMG_Pet_TeamReplace_C:OnPcClose()
  self:OnClose()
end

function UMG_Pet_TeamReplace_C:OnBloodPulse()
  self:ResetDescText()
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPetBloodPulse, self.curShowPetData.PetBaseInfo)
end

function UMG_Pet_TeamReplace_C:OpenPetTips()
  if not self.curShowPetData or not self.curShowPetData.PetBaseInfo then
    Log.Error("\229\174\160\231\137\169\230\149\176\230\141\174\228\184\186\231\169\186,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return
  end
  self:ResetDescText()
  local TipData = {
    petData = self.curShowPetData.PetBaseInfo
  }
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, TipData, _G.Enum.GoodsType.GT_PET)
end

function UMG_Pet_TeamReplace_C:OnPetEquipSkillFinished()
  self:ChangePetTabData(self.petTabType)
end

function UMG_Pet_TeamReplace_C:RefreshPetEquipSkill()
  self.data:ClearPetSkillsData()
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  if team.pet_infos then
    for _, pet in pairs(team.pet_infos) do
      local petId = pet.pet_gid
      local skills = {}
      local equip_infos = pet.equip_infos
      if equip_infos then
        for _, skillInfo in pairs(equip_infos) do
          skills[skillInfo.pos] = skillInfo.id
        end
      else
        skills = nil
      end
      self.data:SetPetSkillsData(petId, skills)
    end
  end
end

function UMG_Pet_TeamReplace_C:OpenFilterPanelBtnClick()
  self:ResetDescText()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenFilterPanel, PetUIModuleEnum.OpenSortType.TeamReplace, self.data.chooseTypeList)
end

function UMG_Pet_TeamReplace_C:OnFilterPet(typeList)
  if self.data then
    self.data.chooseTypeList = typeList
    self:FilterRefreshUI()
  end
end

function UMG_Pet_TeamReplace_C:OnSortBtnButtonClick()
  self:ResetDescText()
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenSortPanel, self.SortIndex, PetUIModuleEnum.OpenSortType.TeamReplace)
end

function UMG_Pet_TeamReplace_C:OnRandomPetBonusButtonClick()
  local currentState = self.randomPetBonusState or {}
  local state = {}
  state.open = true
  state.starCount = currentState.starCount or 0
  state.winNum = currentState.winNum or 0
  state.hitPetNum = currentState.hitPetNum or 0
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetRandomPetBonusPanelState, state)
  if self.RandomBonus.RedDot:IsRed() then
    self.RandomBonus.RedDot:EraseRedPoint()
  end
end

function UMG_Pet_TeamReplace_C:OnConstruct()
  self:SetChildViews(self.CommonPetDetails, self.UMG_PetRate)
end

function UMG_Pet_TeamReplace_C:OnDestruct()
  self:OnRemoveEventListener()
  UE4Helper.SetEnableWorldRendering(nil, nil, "UMG_Pet_TeamReplace")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetInQualifyingState, false)
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:OnDisable()
  end
  if self.data and self.data:GetEnterPetPanelType() == PetUIModuleEnum.EnterType.PvpPetTeamUmg then
    self.data:SetEnterPetPanelType(nil)
  end
end

function UMG_Pet_TeamReplace_C:SetParent(parent)
  self.Parent = parent
end

function UMG_Pet_TeamReplace_C:AsyncLoadSceneOver()
  UE4Helper.SetEnableWorldRendering(false, nil, "UMG_Pet_TeamReplace")
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Pet_TeamReplace_C:InitUI()
  if self.openType == PetUIModuleEnum.OpenTeamReplaceType.PvpQualifier then
    self.UMG_TeamReplaceImage:SetTeamData(self, self.curTeamType)
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_TeamReplaceImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UMG_TeamReplaceImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:InitTeam()
  self:InitWarehouse()
  local tabInfoList = {}
  local tabName = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_trial_pet_character2").str
  local pvp_rank_character18Conf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character18")
  local pvp_rank_character18ConfStr = pvp_rank_character18Conf and pvp_rank_character18Conf.str or ""
  local pvp_rank_trial_pet_character3Conf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_trial_pet_character3")
  local pvp_rank_trial_pet_character3ConfStr = pvp_rank_trial_pet_character3Conf and pvp_rank_trial_pet_character3Conf.str or ""
  local normalPetTabInfo = {}
  normalPetTabInfo.name = tabName
  normalPetTabInfo.tabType = PetTabType.BagPet
  local trialPetTabInfo = {}
  tabName = pvp_rank_trial_pet_character3ConfStr
  trialPetTabInfo.name = tabName
  trialPetTabInfo.tabType = PetTabType.TrialPet
  trialPetTabInfo.redKey = 382
  trialPetTabInfo.isEraseRed = true
  local randomPetTabInfo = {}
  tabName = pvp_rank_character18ConfStr
  randomPetTabInfo.name = tabName
  randomPetTabInfo.tabType = PetTabType.RandomPet
  table.insert(tabInfoList, normalPetTabInfo)
  if self.curTeamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    table.insert(tabInfoList, trialPetTabInfo)
  end
  do
    local curTeamType = self.curTeamType
    local AllowRandomPetTeamTypeMap = BattleConst.AllowRandomPetTeamTypeMap
    local allowRandomPetTeamType = curTeamType and AllowRandomPetTeamTypeMap and AllowRandomPetTeamTypeMap[curTeamType]
    if allowRandomPetTeamType then
      table.insert(tabInfoList, randomPetTabInfo)
    end
  end
  for i, tabInfo in ipairs(tabInfoList) do
    tabInfo.index = i
    tabInfo.OnSelectCallback = self.OnPetTeamReplaceTabSelect
    tabInfo.OnSelectCallbackOwner = self
  end
  local tabInfoCount = #tabInfoList
  if tabInfoCount <= 1 then
    self:PlayAnimation(self.tab1)
  end
  local tabSlot = self.Tab and self.Tab.Slot
  local tabSlotSize = tabSlot and tabSlot:GetSize()
  local tabSlotSizeX = tabSlotSize and tabSlotSize.X or 0
  local tabSlotSizeY = tabSlotSize and tabSlotSize.Y or 0
  local tabItemWidth = tabSlotSizeX
  local tabItemHeight = tabSlotSizeY
  if tabInfoCount >= 1 then
    tabItemWidth = tabSlotSizeX / tabInfoCount
  end
  tabItemWidth = math.round(tabItemWidth)
  tabItemHeight = math.round(tabItemHeight)
  if tabItemWidth > 0 and tabItemHeight > 0 then
    self.Tab:SetCustomSize(tabItemWidth, tabItemHeight)
  end
  self.tabInfoList = tabInfoList
  self.Tab:InitGridView(tabInfoList)
  self.Btn_Cultivate_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/ui_combtn_sure_png.ui_combtn_sure_png'")
  if self.curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
    local Conf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_pet1")
  end
  self:RefreshCommonTitle(self.curTeamType)
  self:RefreshTitle(self.curTeamType)
end

function UMG_Pet_TeamReplace_C:RefreshCommonTitle(teamType)
  local allBattleTypeConf = _G.DataConfigManager:GetAllByName("BATTLE_TYPE_CONF")
  for i, v in pairs(allBattleTypeConf) do
    if v.player_team_type == teamType then
      self.Title1:Set_MainTitle(v.name)
      break
    end
  end
end

function UMG_Pet_TeamReplace_C:RefreshTitle(teamType)
  if teamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_1 or teamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_2 or teamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_3 or teamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4 or teamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_5 then
    self.Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Title:SetText(_G.LuaText.PVP_rank_character2)
  else
    self.Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Pet_TeamReplace_C:SetTipPanelVisible(bVisible)
  if bVisible then
  else
  end
end

function UMG_Pet_TeamReplace_C:InitTeam()
end

function UMG_Pet_TeamReplace_C:InitWarehouse()
  self.SortIndex = _G.Enum.PetSequenceDefault.SEQUENCE_LEVEL_DOWN
  self:SetSortText(self.SortIndex)
end

function UMG_Pet_TeamReplace_C:RefreshTeamFromCmd()
  self:RefreshTeam()
  self:RefreshWarehouse()
  if self.curSelPetData then
    local petinfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curSelPetData.gid, self.is_mirror)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petinfo.base_conf_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      local petData = {
        level = petinfo.level,
        gid = petinfo.gid,
        energy = petinfo.energy,
        petIcon = modelConf,
        base_conf_id = petinfo.base_conf_id,
        PetBaseInfo = petinfo
      }
      self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, petData)
    end
  end
end

function UMG_Pet_TeamReplace_C:AddPetsToPetList()
  local prevTeamPetList = self.teamPetList or {}
  local prevAnyTeamPetIsRandom = self.anyTeamPetIsRandom
  local nextTeamPetList = self.teamPetList
  nextTeamPetList = {}
  local nextAnyTeamPetIsRandom = false
  local petList = {}
  local inTeamGidDic = {}
  for index = self.canInTeamNum + 1, self.canSelectNum do
    if self.slotDic[index] then
      self.teamInfoDic[self.slotDic[index]] = nil
      self.slotDic[index] = nil
    end
  end
  self.trialRefreshTime = nil
  if self.curTeamType and self.curTeamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    self.trialRefreshTime = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetTrialPetBriefRefreshTime)
  end
  for i = 1, self.canInTeamNum do
    local petGid = self.slotDic[i]
    local tempPetData, petInfo
    if petGid then
      local petinfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid, self.is_mirror)
      local petBaseConf = petinfo and _G.DataConfigManager:GetPetbaseConf(petinfo.base_conf_id, true)
      local petTypeInfoType = PetUtils.GetPetTypeInfoType(petinfo)
      if petBaseConf then
        local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
        local t = {
          level = petinfo.level,
          gid = petinfo.gid,
          energy = petinfo.energy,
          petIcon = modelConf,
          base_conf_id = petinfo.base_conf_id,
          PetBaseInfo = petinfo,
          is_trial_pet = petinfo.is_trial_pet,
          refreshTime = self.trialRefreshTime,
          skill = petinfo.skill,
          blood_id = petinfo.blood_id
        }
        tempPetData = t
        petInfo = {
          PetData = t,
          isHasPet = true,
          isPetListItem = true,
          canInTeamNum = self.canInTeamNum
        }
      elseif petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
        local randomPetInfo = petinfo
        local temp = {
          gid = randomPetInfo.gid,
          PetBaseInfo = randomPetInfo,
          type = randomPetInfo.type
        }
        tempPetData = temp
        petInfo = {
          PetData = temp,
          isHasPet = true,
          isPetListItem = true,
          canInTeamNum = self.canInTeamNum
        }
        nextAnyTeamPetIsRandom = true
      end
      inTeamGidDic[petGid] = petGid
    else
      petInfo = {
        isHasPet = false,
        isPetListItem = true,
        canInTeamNum = self.canInTeamNum
      }
    end
    if tempPetData then
      table.insert(nextTeamPetList, tempPetData)
    end
    if petInfo then
      table.insert(petList, petInfo)
    end
  end
  if self.canInTeamNum < 6 then
    for i = self.canInTeamNum + 1, 6 do
      table.insert(petList, {
        isHasPet = false,
        isPetListItem = true,
        isLockUp = true,
        canInTeamNum = self.canInTeamNum
      })
    end
  end
  self.inTeamGidDic = inTeamGidDic
  self.teamPetList = nextTeamPetList
  self.HeadShowPetList = petList
  self:RefreshSwitcherDescribeData()
  self:OnPetTeamListChanged(prevTeamPetList, nextTeamPetList, prevAnyTeamPetIsRandom, nextAnyTeamPetIsRandom)
end

function UMG_Pet_TeamReplace_C:FilterRefreshUI()
  self:ResetDescText()
  self:AddPetsToPetList()
  self.PetList:InitGridView(self.HeadShowPetList)
  self:RefreshWarehouse()
  local petTabType = self.petTabType
  local curMode = self.curMode
  if petTabType ~= PetTabType.RandomPet then
    if curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
      self:SelectFirstPet()
    elseif curMode == PetUIModuleEnum.ModifyPetMode.QuickEdit then
      self:Reselect()
    end
  end
end

function UMG_Pet_TeamReplace_C:GetPetDataByCurPetGid()
  if self.curPetGid then
    for _, petData in ipairs(self.teamPetList) do
      if petData.gid == self.curPetGid then
        return petData
      end
    end
  end
  return nil
end

function UMG_Pet_TeamReplace_C:GetFirstNotCommonEvoPet()
  local teamPetList = self.teamPetList
  local afterFilterList = self.uiData.AfterFilterList
  local tarGetPet
  if afterFilterList and #afterFilterList > 0 then
    self.Switcher:SetActiveWidgetIndex(0)
    local _PetData = self:GetPetDataByCurPetGid()
    if #teamPetList > 0 then
      for _, petData in pairs(teamPetList) do
        if not _PetData or petData.gid ~= _PetData.gid then
          for _, petInfo in pairs(afterFilterList) do
            if petInfo.PetData then
              tarGetPet = petInfo.PetData
              break
            end
          end
          if tarGetPet then
            break
          end
        end
      end
    else
      for _, petInfo in pairs(afterFilterList) do
        tarGetPet = petInfo.PetData
        break
      end
    end
  end
  return tarGetPet
end

function UMG_Pet_TeamReplace_C:RefreshSlotDicData()
  self.teamInfoDic = {}
  self.slotDic = {}
  local teamInfoDic = self.teamInfoDic
  local slotDic = self.slotDic
  local teamPetList = self.teamPetList
  for i = 1, self.canSelectNum do
    if teamPetList[i] then
      slotDic[i] = teamPetList[i].gid
      teamInfoDic[teamPetList[i].gid] = i
    end
  end
end

function UMG_Pet_TeamReplace_C:RefreshSwitcherDescribeData()
  local fantasticSkillValid = self:CheckCurrentTeamFantasticSkillValid()
  if not fantasticSkillValid then
    self.SwitcherDescribeData = {
      type = UMG_Pet_TeamReplace_C.SwitcherDescribeDataType.TeamErrorMessage
    }
  else
    self.SwitcherDescribeData = {
      type = UMG_Pet_TeamReplace_C.SwitcherDescribeDataType.TeamDescription
    }
  end
end

function UMG_Pet_TeamReplace_C:RefreshUI(prevMode, nextMode)
  self.PvpDepartmentFilter = PvpBattleFilter[self.curTeamType]
  self.data.chooseTypeList = {
    DepartmentFilter = {},
    TalentFilter = {},
    NaturePositiveEffectFilter = {},
    AttributeFilter = {}
  }
  self:SwitchUIByMode(nextMode)
  self:RefreshTeam()
  if prevMode == PetUIModuleEnum.ModifyPetMode.SingleEdit and nextMode == PetUIModuleEnum.ModifyPetMode.QuickEdit then
  else
    self:RefreshWarehouse()
  end
  if self.curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit and self.teamPetList then
    self:RefreshSlotDicData()
    if self.curSelPetData then
      self.Switcher:SetActiveWidgetIndex(0)
      self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, self.curSelPetData)
    elseif self.curSlotId then
      local trySelectPet
      if 11 == self.curSlotId then
        if #self.teamPetList > 0 then
          trySelectPet = self.teamPetList[1]
        end
        if not trySelectPet then
          trySelectPet = self:GetFirstNotCommonEvoPet()
        end
      else
        trySelectPet = self:GetFirstNotCommonEvoPet()
      end
      if trySelectPet then
        self.Switcher:SetActiveWidgetIndex(0)
        self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, trySelectPet)
      else
        self.Switcher:SetActiveWidgetIndex(2)
      end
      local petData = self:GetPetDataByCurPetGid()
      self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemLocked, petData, self.teamPetList)
    elseif self.curPetGid then
      self:Reselect()
    end
  elseif self.curMode == PetUIModuleEnum.ModifyPetMode.QuickEdit and self.teamPetList then
    if self.curSelPetData then
      self.Switcher:SetActiveWidgetIndex(0)
      self:SetRightInfo(self.curSelPetData)
    elseif #self.teamPetList > 0 then
      self.Switcher:SetActiveWidgetIndex(0)
      self:SetRightInfo(self.teamPetList[1])
    else
      self.Switcher:SetActiveWidgetIndex(2)
    end
    self:DispatchEvent(PetUIModuleEvent.PetTeamFastFormationChanged, self.teamInfoDic)
  end
end

function UMG_Pet_TeamReplace_C:UpdateExchangeBtn(state)
  if state then
    self.NRCSwitcher_Btn:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_Btn:SetActiveWidgetIndex(1)
    self.ExchangeGrey.HideAnim = true
    self.ExchangeGrey:SetShowLockIcon(false)
  end
end

function UMG_Pet_TeamReplace_C:SwitchUIByMode(mode)
  if nil == mode then
    return
  end
  local prevMode = self.curMode
  self.curMode = mode
  if mode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
    local tipStr = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character16").str
    if self.is_mirror then
      self:UpdateExchangeBtn(false)
    else
      self:UpdateExchangeBtn(true)
    end
    self.Btn_Cultivate_1:SetBtnText(tipStr)
    self.Btn_Cultivate_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_huanxia_png.img_huanxia_png'")
  elseif mode == PetUIModuleEnum.ModifyPetMode.QuickEdit then
    local tipStr = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character17").str
    self:UpdateExchangeBtn(false)
    self.Btn_Cultivate_1:SetBtnText(tipStr)
    self.Btn_Cultivate_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_baicunpeizhi_png.img_baicunpeizhi_png'")
  end
end

function UMG_Pet_TeamReplace_C:SwitchUIByPetTabType(type)
  local randomBonusButtonVisibility = UE4.ESlateVisibility.Visible
  self.RandomBonus:SetVisibility(randomBonusButtonVisibility)
end

function UMG_Pet_TeamReplace_C:RefreshTeamData()
  local prevTeamPetList = self.teamPetList or {}
  local prevAnyTeamPetIsRandom = self.anyTeamPetIsRandom
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  self.is_mirror = team.is_mirror
  self.isEmptyTeam = true
  if team.is_mirror then
    self.NRCText_53:SetText(string.format(LuaText.share_pet_owner_inf_2, team.mirror_friend_name))
  end
  local petList = {}
  local inTeamGidDic = {}
  local nextTeamPetList = {}
  local nextAnyTeamPetIsRandom = false
  for i = 1, self.canInTeamNum do
    local petInfoList = team and team.pet_infos or {}
    local teamPetInfoItem = petInfoList and petInfoList[i]
    local petGid = teamPetInfoItem and teamPetInfoItem.pet_gid
    local teamPetDataItem, petInfoItem
    if petGid then
      local petInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid, team.is_mirror)
      local petTypeInfoType = PetUtils.GetPetTypeInfoType(petInfo)
      if petInfo then
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_conf_id, true)
        if petBaseConf then
          local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
          local t = {
            level = petInfo.level,
            gid = petInfo.gid,
            energy = petInfo.energy,
            petIcon = modelConf,
            gender = petInfo.gender,
            blood_id = petInfo.blood_id,
            base_conf_id = petInfo.base_conf_id,
            PetBaseInfo = petInfo,
            is_trial_pet = petInfo.is_trial_pet,
            skill = petInfo.skill
          }
          teamPetDataItem = t
          petInfoItem = {
            PetData = t,
            isHasPet = true,
            isPetListItem = true,
            canInTeamNum = self.canInTeamNum
          }
        elseif petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
          local randomPetInfo = petInfo
          local temp = {
            gid = randomPetInfo.gid,
            PetBaseInfo = randomPetInfo,
            type = randomPetInfo.type
          }
          teamPetDataItem = temp
          petInfoItem = {
            PetData = temp,
            isHasPet = true,
            isPetListItem = true,
            canInTeamNum = self.canInTeamNum
          }
          nextAnyTeamPetIsRandom = true
        end
        inTeamGidDic[petGid] = petGid
      end
      self.isEmptyTeam = false
    else
      petInfoItem = {
        isHasPet = false,
        isPetListItem = true,
        canInTeamNum = self.canInTeamNum
      }
    end
    if teamPetDataItem then
      table.insert(nextTeamPetList, teamPetDataItem)
    end
    petInfoItem = petInfoItem or {
      isHasPet = false,
      isPetListItem = true,
      canInTeamNum = self.canInTeamNum
    }
    if petInfoItem then
      table.insert(petList, petInfoItem)
    end
  end
  if self.canInTeamNum < 6 then
    for i = self.canInTeamNum + 1, 6 do
      table.insert(petList, {
        isHasPet = false,
        isPetListItem = true,
        isLockUp = true,
        canInTeamNum = self.canInTeamNum
      })
    end
  end
  self.inTeamGidDic = inTeamGidDic
  self.HeadShowPetList = petList
  self.teamPetList = nextTeamPetList
  self.anyTeamPetIsRandom = nextAnyTeamPetIsRandom
  self.Text_1:SetText(self:GetTeamName())
  self:RefreshSlotDicData()
  self:RefreshSwitcherDescribeData()
  self:OnPetTeamListChanged(prevTeamPetList, nextTeamPetList, prevAnyTeamPetIsRandom, nextAnyTeamPetIsRandom)
end

function UMG_Pet_TeamReplace_C:RefreshTeam()
  self.PetList:InitGridView(self.HeadShowPetList)
  if self.SwitcherDescribeData.type == UMG_Pet_TeamReplace_C.SwitcherDescribeDataType.TeamDescription then
    self.NRCSwitcher_Describe:SetActiveWidgetIndex(0)
    self.Text_1:SetText(self:GetTeamName())
  elseif self.SwitcherDescribeData.type == UMG_Pet_TeamReplace_C.SwitcherDescribeDataType.TeamErrorMessage then
    self.NRCSwitcher_Describe:SetActiveWidgetIndex(1)
  end
  local HeadShowPetList = self.HeadShowPetList or {}
  self:AddPetDataInBalanceQueryQueue(HeadShowPetList)
end

function UMG_Pet_TeamReplace_C:GetTeamName()
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  if team.is_mirror then
    self.Btn_Cultivate_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FriendsLineupText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FriendsLineupText:SetText(string.format(LuaText.share_pet_owner_inf_1, team.mirror_friend_name))
    self.RenameBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Btn_Cultivate_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FriendsLineupText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.RenameBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if not team.team_name or team.team_name == "" then
    local teamNameCfg = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_name")
    return string.format(teamNameCfg.str, self.curTeamIdx + 1)
  else
    return team.team_name
  end
end

function UMG_Pet_TeamReplace_C:HasCommonEvolution(petGid)
  if self.teamPetList then
    for _, petData in pairs(self.teamPetList) do
      if PetUtils.IsCommonEvolution(petData.gid, petGid) then
        return true
      end
    end
  end
  return false
end

function UMG_Pet_TeamReplace_C:IsInTeam(gid)
  if self.inTeamGidDic and self.inTeamGidDic[gid] then
    return true
  else
    return false
  end
end

function UMG_Pet_TeamReplace_C:RefreshWarehouse()
  self:SetPetInfoList()
  self:UpdatePetInfo(self.warehousePetHeadInfo)
  self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
end

function UMG_Pet_TeamReplace_C:SetPetInfoList()
  self.petInfoList = {}
  local petData = {}
  if self.petTabType == PetTabType.BagPet then
    petData = _G.DataModelMgr.PlayerDataModel:GetPetData()
  elseif self.petTabType == PetTabType.TrialPet then
    petData = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetTrialPets)
  elseif self.petTabType == PetTabType.RandomPet then
    local option = {
      removeSameBloodPetData = true,
      removeInTeamGid = true,
      inTeamGidDic = self.inTeamGidDic
    }
    petData = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetRandomPets, option)
  end
  self.trialRefreshTime = nil
  if self.curTeamType and self.curTeamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    self.trialRefreshTime = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetTrialPetBriefRefreshTime)
  end
  local petInfoList = {}
  for i, petinfo in ipairs(petData) do
    local isFreePet = self:IsFreePet(petinfo)
    local petInfo
    if not isFreePet and not self:IsInTeam(petinfo.gid) then
      local baseConfId = petinfo and petinfo.base_conf_id
      local petTypeInfoType = PetUtils.GetPetTypeInfoType(petinfo)
      if baseConfId then
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(baseConfId)
        if petBaseConf then
          local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
          local temp = {
            level = petinfo.level,
            gid = petinfo.gid,
            petIcon = modelConf,
            pet_status_flags = petinfo.pet_status_flags or 0,
            base_conf_id = petinfo.base_conf_id,
            CanChangeTeam = petinfo.enable_change,
            CanChangeTeamSort = petinfo.enable_change and 1 or 0,
            energy = petinfo.energy,
            PetBaseInfo = petinfo,
            is_trial_pet = petinfo.is_trial_pet,
            refreshTime = self.trialRefreshTime,
            canInTeamNum = self.canInTeamNum
          }
          for j = 1, 12 do
            local PetBasicProperty
            if 1 == j then
              PetBasicProperty = petinfo.level
            elseif 2 == j then
              PetBasicProperty = petinfo.add_time
            elseif j <= 8 then
              PetBasicProperty = PetUtils.GetPetAdditionalByType(petinfo, j - 2)
            elseif 10 == j then
              PetBasicProperty = petinfo.talent_rank
            elseif 11 == j then
              if petinfo.partner_mark and petinfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
                PetBasicProperty = 100 - petinfo.partner_mark
              else
                PetBasicProperty = 0
              end
            elseif 12 == j then
              if petinfo.grow_times then
                PetBasicProperty = petinfo.grow_times
              else
                PetBasicProperty = 0
              end
            end
            if PetBasicProperty then
              temp[j] = PetBasicProperty
            end
          end
          local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, petinfo.gid)
          petInfo = {
            PetData = temp,
            isHasPet = true,
            IsTravel = isTravel,
            IsFree = false,
            banFree = petBaseConf.ban_free,
            canInTeamNum = self.canInTeamNum
          }
        end
      elseif petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
        local randomPetInfo = petinfo
        local temp = {
          gid = randomPetInfo.gid,
          PetBaseInfo = randomPetInfo,
          type = randomPetInfo.type
        }
        petInfo = {
          PetData = temp,
          isHasPet = true,
          IsTravel = false,
          IsFree = false,
          banFree = false,
          canInTeamNum = self.canInTeamNum
        }
      end
    end
    if petInfo then
      table.insert(petInfoList, petInfo)
    end
  end
  self.warehousePetHeadInfo = petInfoList
end

function UMG_Pet_TeamReplace_C:EliminateFreePet(_PetData)
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

function UMG_Pet_TeamReplace_C:IsFreePet(PetInfo)
  local isExchange = PetInfo.pet_status_flags and PetInfo.pet_status_flags & ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
  if not isExchange then
    return false
  end
  return true
end

function UMG_Pet_TeamReplace_C:UpdatePetInfo(petHeadInfo)
  self.uiData.petHeadInfo = petHeadInfo
  self.uiData.PetSortInfo = nil
  self.uiData.AfterFilterList = nil
end

function UMG_Pet_TeamReplace_C:SetSortListInfo()
  local sortIndex = self.SortIndex - 1
end

function UMG_Pet_TeamReplace_C:GetPetBagSequence(sortId)
  local cfgTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PET_BAG_SEQUENCE)
  local cfgDatas = cfgTable:GetAllDatas()
  for _, val in ipairs(cfgDatas) do
    if sortId == val.sequence_default then
      return val
    end
  end
  return nil
end

function UMG_Pet_TeamReplace_C:SetSortText(sortId)
  local PetBagSequence = self:GetPetBagSequence(sortId)
  self.ComScreen:SetComboText(PetBagSequence.sequence_desc)
end

function UMG_Pet_TeamReplace_C:SortItemInfo(sortId)
  self.SortIndex = sortId
  self:SortItem(self.uiData.petHeadInfo, self.SortIndex)
  self:SetSortText(sortId)
  self:Reselect()
end

function UMG_Pet_TeamReplace_C:SortItem(_petinfo, sortIndex)
  local sortlist = self:PetListSort(true, _petinfo)
  self.uiData.PetSortInfo = sortlist
  if self.uiData.PetSortInfo then
    self:RefreshPetListByChooseType(self.data.chooseTypeListTeamReplace)
    self:SetPetNum(self.uiData.PetSortInfo)
  end
end

function UMG_Pet_TeamReplace_C:SetPetSortIndex(_index)
  self.SortIndex = _index
end

function UMG_Pet_TeamReplace_C:OnTypeChooseChanged(typeList)
  self:RefreshPetListByChooseType(typeList)
  if self.curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
    self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, self.curSelPetData)
  else
    self:DispatchEvent(PetUIModuleEvent.PetTeamFastFormationChanged, self.teamInfoDic)
  end
end

function UMG_Pet_TeamReplace_C:OnPetTeamListChanged(prevTeamPetList, nextTeamPetList, prevAnyTeamPetIsRandom, nextAnyTeamPetIsRandom)
  local teamPetList = nextTeamPetList or {}
  local pureRandomPetCount = 0
  local typeRandomPetCount = 0
  for i, petData in ipairs(teamPetList) do
    local petBaseInfo = petData and petData.PetBaseInfo
    local typeInfoType = PetUtils.GetPetTypeInfoType(petBaseInfo)
    if typeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
      local typeInfo = petBaseInfo and petBaseInfo.type
      local skillDamType = typeInfo and typeInfo.param
      if 0 == skillDamType then
        pureRandomPetCount = pureRandomPetCount + 1
      else
        typeRandomPetCount = typeRandomPetCount + 1
      end
    end
  end
  local randomPetRewordConf = _G.NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.CmdGetRandomPetRewordConf, pureRandomPetCount, typeRandomPetCount)
  local prevRandomPetBonusState = self.randomPetBonusState or {}
  local nextRandomPetBonusState = {}
  nextRandomPetBonusState.starCount = randomPetRewordConf and randomPetRewordConf.star or 0
  nextRandomPetBonusState.winNum = randomPetRewordConf and randomPetRewordConf.win_num or 0
  nextRandomPetBonusState.hitPetNum = randomPetRewordConf and randomPetRewordConf.hit_pet_num or 0
  self.randomPetBonusState = nextRandomPetBonusState
  if not nextAnyTeamPetIsRandom and self.RandomBonus.RedDot:IsRed() then
    self.RandomBonus.RedDot:EraseRedPoint()
  end
end

function UMG_Pet_TeamReplace_C:Reselect()
  if self.curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
    local petData = self:GetPetDataByCurPetGid()
    if self.curSelPetData then
      self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, self.curSelPetData)
    else
      self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, petData)
    end
    self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemLocked, petData, self.teamPetList)
  else
    self:DispatchEvent(PetUIModuleEvent.PetTeamFastFormationRefreshed, self.teamInfoDic)
  end
end

function UMG_Pet_TeamReplace_C:OnClose(isOKClose)
  local flag = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.CheckIsAnyUmgIsOpening)
  if flag then
    return
  end
  if self.IsChangeSkill then
    self.IsChangeSkill = false
    self.Switcher:SetActiveWidgetIndex(0)
    self:InitFilterAndSort()
    local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
    if ChangePetSkillsPanel then
      ChangePetSkillsPanel:OnDisable()
    end
    return
  end
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    return
  end
  if not isOKClose then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1007, " UMG_Pet_TeamReplace_C:OnClose")
  end
  self.teamInfoDic = nil
  self.slotDic = nil
  self.uiData.petHeadInfo = nil
  self.uiData.PetSortInfo = nil
  self.uiData.AfterFilterList = nil
  self.curSelPetData = nil
  self:InitFilterAndSort()
  self.teamPetList = nil
  self.data.chooseTypeList = {
    DepartmentFilter = {},
    TalentFilter = {},
    NaturePositiveEffectFilter = {},
    AttributeFilter = {}
  }
  self:HideTipsIfNeeded()
  self:OnCloseButtonClick()
end

function UMG_Pet_TeamReplace_C:HideTipsIfNeeded()
  if self.TipPanelVisible == true then
    self.TipPanelVisible = false
    self:SetTipPanelVisible(self.TipPanelVisible)
  end
end

function UMG_Pet_TeamReplace_C:OnShowTipBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1211, " UMG_Pet_TeamReplace_C:OnShowTipBtnClick")
  self.TipPanelVisible = not self.TipPanelVisible
  if self.TipPanelVisible == true then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1083, " UMG_Pet_TeamReplace_C:OnShowTipBtnClick")
  end
  self:SetTipPanelVisible(self.TipPanelVisible)
end

function UMG_Pet_TeamReplace_C:OnCultivateClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1014, "UMG_Pet_TeamReplace_C:OnCultivateClick")
  self:HideTipsIfNeeded()
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curSelPetData.gid)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetOpenPanelPetData, petData, 1, false)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPetAttribute, true)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPanelPetMain, {
    subPanelIndex = 4,
    Callback = self.SetPetTeamHid,
    Caller = self
  }, true)
end

function UMG_Pet_TeamReplace_C:SetPetTeamHid()
end

function UMG_Pet_TeamReplace_C:OnAnimFinished(Animation)
  if Animation == self.Out then
    self.data:ClearPetSkillsData()
    self:DelaySeconds(0.01, function()
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.PetTeamSetBtnCloseState, PetUIModuleEnum.PetTeamShowType.Normal)
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.ClosePetTeamReplacePanel)
    end)
  end
end

function UMG_Pet_TeamReplace_C:OnCloseButtonClick()
  if self:IsAnimationPlaying(self.Out) then
    return
  end
  self:PlayAnimation(self.Out)
end

function UMG_Pet_TeamReplace_C:OnExchangeBtnClick()
  if self.curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
    if self.curExChangeState == ExChangeState.Normal then
      self.curExChangeState = ExChangeState.ExChanging
      self.ExchangeBtn:SetBtnText(LuaText.pvp_team_cancel_exchang)
      local isInTeam = self:IsInTeam(self.curSelPetData.gid)
      self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemExChanging, isInTeam, self.curSelPetData)
    else
      self.curExChangeState = ExChangeState.Normal
      self.ExchangeBtn:SetBtnText(LuaText.umg_petbag_1)
      self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemExChanging, nil, nil)
    end
  end
  self:ResetDescText()
end

function UMG_Pet_TeamReplace_C:ApplyDeleteBtnClick()
  self.slotDic = {}
  local slotDic = self.slotDic
  if nil == slotDic then
    slotDic = {}
  end
  local newTeam = {}
  for i = 1, self.canInTeamNum do
    if slotDic[i] then
      table.insert(newTeam, {
        pet_gid = slotDic[i]
      })
    end
  end
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  if nil == team.pet_infos then
    team.pet_infos = {}
  end
  newTeam.magicID = -1
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamInfo, newTeam, self.curTeamIdx, self.module.data.OpenTeamType)
end

function UMG_Pet_TeamReplace_C:OnDeleteBtnClick()
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local teamIndex = self.curTeamIdx and self.curTeamIdx + 1
  local teams = teamInfo and teamInfo.teams
  local team = teams and teamIndex and teams[teamIndex]
  local petInfoList = team and team.pet_infos or {}
  local petInfoListCount = #petInfoList
  if petInfoListCount > 0 then
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local dialogContext = DialogContext()
    dialogContext:SetContent(LuaText.share_pet_delete_team_content):SetTitle(LuaText.share_pet_delete_team_title):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetCloseOnOK(true):SetClickAnywhereClose(true):SetCallbackOkOnly(self, self.ApplyDeleteBtnClick):SetToppingIconType(0)
    NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
  else
    self:ApplyDeleteBtnClick()
  end
  self:ResetDescText()
end

function UMG_Pet_TeamReplace_C:OnBanChangeButtonClick()
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  if team.is_mirror then
    NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.share_pet_change_tip)
  end
end

function UMG_Pet_TeamReplace_C:OnChangeButtonClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_Pet_TeamReplace_C:OnChangeButtonClick")
  if self.curExChangeState == ExChangeState.ExChanging then
    self:OnExchangeBtnClick()
  end
  local prevMode = self.curMode
  local nextMode
  if prevMode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
    nextMode = PetUIModuleEnum.ModifyPetMode.QuickEdit
    self:RefreshTeamData()
    self:RefreshUI(prevMode, nextMode)
  elseif prevMode == PetUIModuleEnum.ModifyPetMode.QuickEdit then
    nextMode = PetUIModuleEnum.ModifyPetMode.SingleEdit
    self:SaveSkillChange()
    local slotDic = self.slotDic
    if nil == slotDic then
      slotDic = {}
    end
    if not PetUtils.CheckPvpTeamValid(slotDic, self.curTeamType) then
      local nameLessCfg = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_same_pet")
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, nameLessCfg.str)
      return
    end
    local newTeam = {}
    for i = 1, self.canInTeamNum do
      if slotDic[i] then
        table.insert(newTeam, {
          pet_gid = slotDic[i]
        })
      end
    end
    local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
    local main_team_idx = teamInfo.main_team_idx
    local team = teamInfo.teams[self.curTeamIdx + 1]
    if nil == team.pet_infos then
      team.pet_infos = {}
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamInfo, newTeam, self.curTeamIdx, self.module.data.OpenTeamType)
  end
  self:SwitchUIByMode(nextMode)
end

function UMG_Pet_TeamReplace_C:ChangePetTeamSuccess(retCode)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.CloseTeamReplacePanel, self.ChangePetTeamSuccess)
  if 0 == retCode then
    self:OnClose(true)
  end
end

function UMG_Pet_TeamReplace_C:GetTeamParam(PetGid)
  local teamParam = {}
  teamParam.TeamType = self.curTeamType
  teamParam.TeamIdx = self.curTeamIdx
  teamParam.PetGid = PetGid
  return teamParam
end

function UMG_Pet_TeamReplace_C:GetPvpTeamPetSkillListByPetGid(PetGid)
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
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

function UMG_Pet_TeamReplace_C:GetSkillMapByPetGid(petData)
  local PetGid = petData.gid
  local skillList = self:GetPetEquipSkills(petData.PetBaseInfo)
  local skillMap = {}
  if skillList then
    for index, skillInfo in pairs(skillList) do
      skillMap[skillInfo.id] = index
    end
  end
  return skillMap
end

function UMG_Pet_TeamReplace_C:OnClickSkillsChange()
  self:ResetDescText()
  self.showLockSkill = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetIsShowPetNotUnlockSkill)
  self:RefreshShowLockSkillBtn()
  if self.curShowPetData then
    self.IsChangeSkill = true
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetEnterPetPanelType, PetUIModuleEnum.EnterType.PvpPetTeamUmg)
    local skillMap = self:GetSkillMapByPetGid(self.curShowPetData)
    local teamParam = self:GetTeamParam(self.curShowPetData.gid)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPvpSkillData, skillMap, teamParam)
    _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
    local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
    local posToIdDic = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetPetEquipSkillMap, self.curSelPetData.PetBaseInfo.gid, PetUIModuleEnum.PetEquipSkillType.PvpTeam)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetAssumptionEquipSkill, self.curSelPetData.PetBaseInfo.gid, posToIdDic)
    if ChangePetSkillsPanel then
      self:InitFilterAndSort()
      ChangePetSkillsPanel:ShowPetSkill()
      self.Switcher:SetActiveWidgetIndex(1)
    else
      self.ChangePetSkillsPanel:LoadPanel(nil, self.curSelPetData.PetBaseInfo)
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
    self:ShowSkillBtnState()
  end
end

function UMG_Pet_TeamReplace_C:ShowSkillBtnState()
  if self.curSelPetData and self.curSelPetData.PetBaseInfo and self.curSelPetData.PetBaseInfo.blood_id == Enum.PetBloodType.PBT_NIGHTMARE then
    self.changeBtn5:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.changeBtn5:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Pet_TeamReplace_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Pet_TeamReplace_C:GetPetEquipSkills(petData)
  if not petData then
    Log.Error("UMG_Pet_TeamReplace_C:GetPetEquipSkills petData is nil")
    return {}
  end
  local petEquipSkills = self:GetPvpTeamPetSkillListByPetGid(petData.gid)
  if petEquipSkills then
    local result = {}
    for _, id in pairs(petEquipSkills) do
      table.insert(result, {id = id})
    end
    return result
  end
  petEquipSkills = self.data:GetPetSkillsData(petData.gid)
  if petEquipSkills then
    local result = {}
    for _, id in pairs(petEquipSkills) do
      table.insert(result, {id = id})
    end
    return self:EquipSkillLegalHandle(petData, result)
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

function UMG_Pet_TeamReplace_C:EquipSkillLegalHandle(petData, equipSkill)
  local function bIsLearned(skillId)
    if petData.skill and petData.skill.skill_data then
      for i, skillData in ipairs(petData.skill.skill_data) do
        if skillData.id == skillId and skillData.is_learned then
          return true
        end
      end
    end
    return false
  end
  
  local petEquipSkills = {}
  for i, v in pairs(equipSkill) do
    if bIsLearned(v.id) then
      table.insert(petEquipSkills, {
        id = v.id
      })
    end
  end
  if #petEquipSkills < 1 and petData.skill and petData.skill.skill_data then
    for i, v in ipairs(petData.skill.skill_data) do
      if v.skill_src == Enum.PetNewSkillSrc.PNSS_PET_BLOOD then
        table.insert(petEquipSkills, {
          id = v.id
        })
        break
      end
    end
  end
  return petEquipSkills
end

function UMG_Pet_TeamReplace_C:InitFeatures(skillId, lock)
  if 0 == skillId or nil == skillId then
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local skillCfg = _G.DataConfigManager:GetSkillConf(skillId)
  if skillCfg then
    if skillCfg.icon then
      self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SkillIconBg:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SkillIcon:SetPath(NRCUtils:FormatConfIconPath(skillCfg.icon, _G.UIIconPath.SkillIconPath))
    else
      self.SkillIconBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.SkillNameTxt:SetText(skillCfg.name)
    local skillDesc = skillCfg.desc
    self.NRCTextDes:SetText(skillDesc)
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Visible)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Pet_TeamReplace_C:ShowDescRightPanel(id)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ShowDescRightPanel, id)
end

function UMG_Pet_TeamReplace_C:OnDescTextClicked(descText)
  local nounInterpretationTipsInfo = {}
  nounInterpretationTipsInfo.text = descText
  _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
end

function UMG_Pet_TeamReplace_C:ResetDescText()
  table.clear(self.descText)
  self.BtnClosePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Btn_ShutDown_5:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Pet_TeamReplace_C:OnPvpPetTeamEquipPetSkills()
  if self.IsChangeSkill then
    self.IsChangeSkill = false
    self.Switcher:SetActiveWidgetIndex(0)
  end
  local PetBaseInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curShowPetData.gid, self.is_mirror)
  UMG_Pet_TeamReplace_C.ReplacePetDataPetBaseInfo(self.curShowPetData, PetBaseInfo)
  self.curSelPetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curShowPetData.gid, self.is_mirror)
  self:SetRightInfo(self.curShowPetData)
end

function UMG_Pet_TeamReplace_C:RefreshAdjustPetPanel()
  local PetBaseInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curShowPetData.gid, self.is_mirror)
  UMG_Pet_TeamReplace_C.ReplacePetDataPetBaseInfo(self.curShowPetData, PetBaseInfo)
  self.curSelPetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curShowPetData.gid, self.is_mirror)
  self:SetRightInfo(self.curShowPetData)
end

function UMG_Pet_TeamReplace_C.ReplacePetDataPetBaseInfo(petData, nextPetBaseInfo)
  local prevPetBaseInfo = petData and petData.PetBaseInfo
  local petGid = petData and petData.gid
  if petData then
    petData.PetBaseInfo = nextPetBaseInfo
    if prevPetBaseInfo ~= nextPetBaseInfo then
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.CmdInvalidateBalancedPetDataForPvp, petGid)
      petData.balancedPetBaseInfo = nil
    end
  end
end

function UMG_Pet_TeamReplace_C:RefreshSkillList()
end

function UMG_Pet_TeamReplace_C:SetRightInfo(PetData, ListIndex)
  if not PetData then
    return
  end
  PetData = self:PreProcessPetDataForPvpBalance(PetData)
  self.curShowPetData = PetData
  self.curSelPetData = PetData
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_FavoriteButton_C:UpdateInfo")
  self.ListIndex = ListIndex
  self.IconList_1:ScrollToStart()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.curSelPetData.base_conf_id, true)
  local commonAttrData = {}
  local commonAttrData1 = {}
  local petData = self.curSelPetData.PetBaseInfo
  local balancedPetData = self.curSelPetData and self.curSelPetData.balancedPetBaseInfo
  if balancedPetData then
    petData = balancedPetData
  end
  if not petData then
    return
  end
  local PetAttrBalanceTipsVisibility = UE4.ESlateVisibility.Collapsed
  local isRandomPet, _ = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdIsRandomPet, petData.gid)
  local balancedPetBaseInfo = self.curSelPetData and self.curSelPetData.balancedPetBaseInfo
  local isPvpBalance = nil ~= balancedPetBaseInfo
  if isPvpBalance then
    PetAttrBalanceTipsVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
  end
  self.PetAttrBalanceTips:SetVisibility(PetAttrBalanceTipsVisibility)
  if isRandomPet then
    self.Switcher:SetActiveWidgetIndex(4)
    return
  end
  self.textPetName:SetText(petData.name)
  self:updatePetGender(petData.gender)
  self.UMG_PetRate:SetText(petData)
  self.textPetLv:SetText(petData.level)
  local PetLevel = PetUtils.GetBreakThroughStarsList(petData)
  self.CatchHardLv:InitGridView(PetLevel)
  local petType = petBaseConf and petBaseConf.unit_type or {}
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
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(petData.blood_id)
  if PetBloodConf then
    if not petData or petData.is_trial_pet then
      self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.UMG_CollectBtn:UpdateInfo(petData.partner_mark, true)
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
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  local MirrorPetData = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetMirrorPetDataByGid, self.curSelPetData.gid)
  if MirrorPetData then
    self.NRCSwitcher_1:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_1:SetActiveWidgetIndex(0)
  end
  if isTrialPet or MirrorPetData then
    self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  local attrList = {}
  local attrInfo = petData.attribute_info
  local positive_effect, negative_effect
  local natureConf = _G.DataConfigManager:GetNatureConf(petData.nature)
  if 0 ~= petData.changed_nature_pos_attr_type then
    positive_effect = self:GetChangeAttrReqEnum(petData.changed_nature_pos_attr_type)
  else
    positive_effect = natureConf.positive_effect
  end
  if 0 ~= petData.changed_nature_neg_attr_type then
    negative_effect = self:GetChangeAttrReqEnum(petData.changed_nature_neg_attr_type)
  else
    negative_effect = natureConf.negative_effect
  end
  table.insert(attrList, {
    attrType = _G.Enum.AttributeType.AT_HPMAX,
    arrowType = _G.Enum.AttributeType.AT_HPMAX_PERCENT,
    addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_HPMAX),
    attrInfo = attrInfo.hp,
    positive_effect = positive_effect,
    negative_effect = negative_effect,
    petConfId = self.curSelPetData.base_conf_id,
    name = LuaText.umg_battle_changepetconfirm_1
  })
  table.insert(attrList, {
    attrType = _G.Enum.AttributeType.AT_PHYDEF,
    arrowType = _G.Enum.AttributeType.AT_PHYDEF_PERCENT,
    addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_PHYDEF),
    attrInfo = attrInfo.defense,
    positive_effect = positive_effect,
    negative_effect = negative_effect,
    petConfId = self.curSelPetData.base_conf_id,
    name = LuaText.umg_battle_changepetconfirm_5
  })
  table.insert(attrList, {
    attrType = _G.Enum.AttributeType.AT_PHYATK,
    arrowType = _G.Enum.AttributeType.AT_PHYATK_PERCENT,
    addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_PHYATK),
    attrInfo = attrInfo.attack,
    positive_effect = positive_effect,
    negative_effect = negative_effect,
    petConfId = self.curSelPetData.base_conf_id,
    name = LuaText.umg_battle_changepetconfirm_3
  })
  table.insert(attrList, {
    attrType = _G.Enum.AttributeType.AT_SPEDEF,
    arrowType = _G.Enum.AttributeType.AT_SPEDEF_PERCENT,
    addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_SPEDEF),
    attrInfo = attrInfo.special_defense,
    positive_effect = positive_effect,
    negative_effect = negative_effect,
    petConfId = self.curSelPetData.base_conf_id,
    name = LuaText.umg_battle_changepetconfirm_6
  })
  table.insert(attrList, {
    attrType = _G.Enum.AttributeType.AT_SPEATK,
    arrowType = _G.Enum.AttributeType.AT_SPEATK_PERCENT,
    addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_SPEATK),
    attrInfo = attrInfo.special_attack,
    positive_effect = positive_effect,
    negative_effect = negative_effect,
    petConfId = self.curSelPetData.base_conf_id,
    name = LuaText.umg_battle_changepetconfirm_4
  })
  table.insert(attrList, {
    attrType = _G.Enum.AttributeType.AT_SPEED,
    arrowType = _G.Enum.AttributeType.AT_SPEED_PERCENT,
    addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_SPEED),
    attrInfo = attrInfo.speed,
    positive_effect = positive_effect,
    negative_effect = negative_effect,
    petConfId = self.curSelPetData.base_conf_id,
    name = LuaText.umg_battle_changepetconfirm_2,
    NoShowline = true
  })
  local petEquipSkillList = self:GetPetEquipSkills(petData)
  self.BtnHandlerList = {}
  self.BtnHandlerList.Call = self
  self.BtnHandlerList.OnTextClickedHandler = self.OnDescTextClicked
  self.BtnHandlerList.OnRestTextHandler = self.ResetDescText
  self.CommonPetDetails:InitPetBaseInfo(petData, petBaseConf, attrList, petEquipSkillList, PetUIModuleEnum.CommonPetDetailsShowType.PvpRank, self.BtnHandlerList)
  self:UpdateChangePetSkills()
  if self.IsChangeSkill then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

function UMG_Pet_TeamReplace_C:InitFilterAndSort()
  self.sortRuleId = 1
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:InitFilterAndSort()
  end
  local path2 = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Screen1_png.img_Screen1_png'"
  self.ViewPet:SetPath(path2, path2, path2)
  self:RefreshShowLockSkillBtn()
end

function UMG_Pet_TeamReplace_C:SetPetData(PetData)
  if PetData and (not self.curSelPetData or self.curSelPetData.base_conf_id ~= PetData.base_conf_id) then
    self:InitFilterAndSort()
  end
  self.curSelPetData = PetData
end

function UMG_Pet_TeamReplace_C:OnPlayerDataUpdate()
  if self.curSelPetData then
    local PetBaseInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curSelPetData.gid, self.is_mirror)
    UMG_Pet_TeamReplace_C.ReplacePetDataPetBaseInfo(self.curSelPetData, PetBaseInfo)
    local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
    if ChangePetSkillsPanel then
      ChangePetSkillsPanel:RefreshUI(self.curSelPetData.PetBaseInfo)
    end
  end
  if self.curSelPetData then
    local PetBaseInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.curShowPetData.gid, self.is_mirror)
    UMG_Pet_TeamReplace_C.ReplacePetDataPetBaseInfo(self.curSelPetData, PetBaseInfo)
  end
  self:UpdatePvpSkillData()
  self:RefreshWarehouse()
end

function UMG_Pet_TeamReplace_C:UpdateChangePetSkills()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    local skillMap = self:GetSkillMapByPetGid(self.curShowPetData)
    local teamParam = self:GetTeamParam(self.curShowPetData.gid)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPvpSkillData, skillMap, teamParam)
    if self.curSelPetData then
      ChangePetSkillsPanel:RefreshUI(self.curSelPetData.PetBaseInfo)
    end
  end
end

function UMG_Pet_TeamReplace_C:GetChangeAttrReqEnum(attribute)
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

function UMG_Pet_TeamReplace_C:OnReversedSort()
  self.IsReversedSort = not self.IsReversedSort
  if self.petTabType == PetTabType.RandomPet then
    return
  end
  local PetReversedSort = self.uiData.PetSortInfo
  local temporaryList = {}
  if PetReversedSort then
    for i = #PetReversedSort, 1, -1 do
      if PetReversedSort[i].isHasPet == true then
        table.insert(temporaryList, PetReversedSort[i])
      end
    end
    temporaryList = self:SetPetNum(temporaryList)
    self.uiData.PetSortInfo = temporaryList
    self:RefreshPetListByChooseType(self.data.chooseTypeListTeamReplace)
    self:Reselect()
  end
end

function UMG_Pet_TeamReplace_C:TryExChangePet(PetData)
  if not self.curSelPetData then
    return
  end
  local isInTeam = self:IsInTeam(self.curSelPetData.gid)
  local tempPetInfos = self:GetCurTempPetInfo()
  if isInTeam then
    if not PetData or PetData.gid == self.curSelPetData.gid then
      return
    end
    local id1, id2
    for index, value in ipairs(tempPetInfos) do
      if value.pet_gid == self.curSelPetData.gid then
        id1 = index
      end
      if value.pet_gid == PetData.gid then
        id2 = index
      end
    end
    if id1 and id2 then
      tempPetInfos[id1], tempPetInfos[id2] = tempPetInfos[id2], tempPetInfos[id1]
    end
  elseif PetData then
    local hasSelectPet = false
    for index, value in ipairs(tempPetInfos) do
      if value.pet_gid == PetData.gid then
        tempPetInfos[index].pet_gid = self.curSelPetData.gid
        tempPetInfos[index].equip_infos = self.data:GetPetEquipInfos(self.curSelPetData.gid)
        hasSelectPet = true
        break
      end
    end
    if not hasSelectPet then
      return true
    end
  else
    table.insert(tempPetInfos, {
      pet_gid = self.curSelPetData.gid,
      equip_infos = self.data:GetPetEquipInfos(self.curSelPetData.gid)
    })
  end
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamInfo, tempPetInfos, self.curTeamIdx, self.module.data.OpenTeamType)
end

function UMG_Pet_TeamReplace_C:OnPetTeamWarehouseItemSelected(PetData)
  if self.curMode == PetUIModuleEnum.ModifyPetMode.QuickEdit or PetData and PetData == self.curSelPetData then
    self:SetRightInfo(PetData)
    return
  end
  if self.curExChangeState == ExChangeState.ExChanging then
    local state = self:TryExChangePet(PetData)
    if not state then
      return
    else
      self:OnExchangeBtnClick()
    end
  end
  if not self.curSelPetData or PetData and self.curSelPetData.base_conf_id ~= PetData.base_conf_id then
    self:InitFilterAndSort()
  end
  self.curSelPetData = PetData
  if PetData then
    self:ResetDescText()
    self:SetRightInfo(PetData)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_Pet_TeamReplace_C:OnPetTeamWarehouseItemSelected")
  else
    self.Switcher:SetActiveWidgetIndex(2)
    self:HideTipsIfNeeded()
  end
end

function UMG_Pet_TeamReplace_C:GetCurTempPetInfo()
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local team = teamInfo.teams[self.curTeamIdx + 1]
  local tempPetInfos = {}
  if team.pet_infos then
    for _, value in pairs(team.pet_infos) do
      local tmp = {
        pet_gid = value.pet_gid
      }
      table.insert(tempPetInfos, tmp)
    end
  end
  return tempPetInfos
end

function UMG_Pet_TeamReplace_C:CheckCurSelectValid(PetData)
  local checkTable = {}
  for i = 1, self.canInTeamNum do
    if self.slotDic[i] then
      table.insert(checkTable, self.slotDic[i])
    end
  end
  table.insert(checkTable, PetData.gid)
  if not PetUtils.CheckPvpTeamValid(checkTable, self.curTeamType) then
    local nameLessCfg = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_same_pet")
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, nameLessCfg.str)
    return false
  end
  return true
end

function UMG_Pet_TeamReplace_C:CheckCurrentTeamFantasticSkillValid()
  if not BattleUtils.IsBanFantasticSkillInRankPvp(self.curTeamType) then
    return true
  end
  local teamPetList = self.teamPetList
  local anySkillIsFantastic = false
  for i, petData in ipairs(teamPetList) do
    local petSkillDataList = self:GetPetEquipSkills(petData)
    local equippedFantasticId = -1
    local skillData = petData and petData.skill and petData.skill.skill_data or {}
    local fantasticId = -1
    if petData.blood_id == _G.Enum.PetBloodType.PBT_FANTASTIC or petData.blood_id == _G.Enum.PetBloodType.PBT_NIGHTMARE then
      fantasticId = PetUtils.GetFantasticSkillInPetSkillDataList(skillData)
    end
    for _, v in ipairs(petSkillDataList) do
      if fantasticId == v.id then
        equippedFantasticId = fantasticId
        break
      end
    end
    if -1 ~= equippedFantasticId then
      anySkillIsFantastic = true
      break
    end
  end
  if anySkillIsFantastic then
    return false
  end
  return true
end

function UMG_Pet_TeamReplace_C:OnPetTeamFastFormationSelected(PetData)
  if nil == PetData then
    return
  end
  self:SetRightInfo(PetData)
  if nil == self.teamInfoDic then
    self.teamInfoDic = {}
  end
  if nil == self.slotDic then
    self.slotDic = {}
  end
  local teamInfoDic = self.teamInfoDic
  local slotDic = self.slotDic
  if nil == teamInfoDic[PetData.gid] then
    if not self:CheckCurSelectValid(PetData) then
      return
    end
    local isFull = true
    for i = 1, self.canInTeamNum do
      if nil == slotDic[i] then
        slotDic[i] = PetData.gid
        teamInfoDic[PetData.gid] = i
        isFull = false
        break
      end
    end
    if isFull then
      local strTips = string.format(LuaText.umg_pet_teamreplace_7, self.canInTeamNum)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, strTips)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1009, "UMG_Pet_TeamReplace_C:OnPetTeamFastFormationSelected isFull")
    else
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1225, "UMG_Pet_TeamReplace_C:OnPetTeamFastFormationSelected")
    end
  else
    local index = teamInfoDic[PetData.gid]
    slotDic[index] = nil
    teamInfoDic[PetData.gid] = nil
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_Pet_TeamReplace_C:OnPetTeamFastFormationSelected")
  end
  self:DispatchEvent(PetUIModuleEvent.PetTeamFastFormationChanged, teamInfoDic)
end

function UMG_Pet_TeamReplace_C:HasGid(gid, table)
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

function UMG_Pet_TeamReplace_C:CheckDepartmentFilter(DepartmentFilter, petInfo)
  if DepartmentFilter and #DepartmentFilter > 0 then
    local PetData = petInfo and petInfo.PetData
    local petBaseConfId = PetData and PetData.base_conf_id
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseConfId, true)
    local unitTypeList = petBaseConf and petBaseConf.unit_type or {}
    for k = 1, #unitTypeList do
      for j = 1, #DepartmentFilter do
        if unitTypeList[k] == DepartmentFilter[j] then
          return true
        end
      end
    end
  end
  return false
end

function UMG_Pet_TeamReplace_C:CheckTalentFilter(TalentFilter, petInfo)
  local PetData = petInfo and petInfo.PetData
  local PetBaseInfo = PetData and PetData.PetBaseInfo
  local talent_rank = PetBaseInfo and PetBaseInfo.talent_rank
  if TalentFilter and #TalentFilter > 0 then
    for i = 1, #TalentFilter do
      if talent_rank == TalentFilter[i] then
        return true
      end
    end
  end
  return false
end

function UMG_Pet_TeamReplace_C:CheckNaturePositiveEffectFilter(NaturePositiveEffectFilter, petInfo)
  if NaturePositiveEffectFilter and #NaturePositiveEffectFilter > 0 then
    local PetData = petInfo and petInfo.PetData
    local PetBaseInfo = PetData and PetData.PetBaseInfo
    local changed_nature_pos_attr_type = PetBaseInfo and PetBaseInfo.changed_nature_pos_attr_type
    local nature = PetBaseInfo and PetBaseInfo.nature
    local NaturePositive = changed_nature_pos_attr_type
    if not NaturePositive or 0 == NaturePositive then
      local natureConf = _G.DataConfigManager:GetNatureConf(nature)
      NaturePositive = natureConf and natureConf.positive_effect
    else
      NaturePositive = self:GetChangeAttrReqEnum(NaturePositive)
    end
    for j = 1, #NaturePositiveEffectFilter do
      if NaturePositive == NaturePositiveEffectFilter[j] then
        return true
      end
    end
  end
  return false
end

function UMG_Pet_TeamReplace_C:CheckAttributeFilter(AttributeFilter, petInfo)
  local PetData = petInfo and petInfo.PetData
  local PetBaseInfo = PetData and PetData.PetBaseInfo
  local attributeInfo = PetBaseInfo and PetBaseInfo.attribute_info
  local hp = attributeInfo and attributeInfo.hp
  local hpTalent = hp and hp.talent
  local attack = attributeInfo and attributeInfo.attack
  local attackTalent = attack and attack.talent
  local specialAttack = attributeInfo and attributeInfo.special_attack
  local specialAttackTalent = specialAttack and specialAttack.talent
  local defense = attributeInfo and attributeInfo.defense
  local defenseTalent = defense and defense.talent
  local specialDefense = attributeInfo and attributeInfo.special_defense
  local specialDefenseTalent = specialDefense and specialDefense.talent
  local speed = attributeInfo and attributeInfo.speed
  local speedTalent = speed and speed.talent
  for j = 1, #AttributeFilter do
    if AttributeFilter[j] == _G.Enum.AttributeType.AT_HPMAX and hpTalent and hpTalent > 0 then
      return true
    end
    if AttributeFilter[j] == _G.Enum.AttributeType.AT_PHYATK and attackTalent and attackTalent > 0 then
      return true
    end
    if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEATK and specialAttackTalent and specialAttackTalent > 0 then
      return true
    end
    if AttributeFilter[j] == _G.Enum.AttributeType.AT_PHYDEF and defenseTalent and defenseTalent > 0 then
      return true
    end
    if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEDEF and specialDefenseTalent and specialDefenseTalent > 0 then
      return true
    end
    if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEED and speedTalent and speedTalent > 0 then
      return true
    end
  end
  return false
end

function UMG_Pet_TeamReplace_C:CheckPartnerMarkerFilter(PartnerMarkerFilter, petInfo)
  local PetData = petInfo and petInfo.PetData
  local PetBaseInfo = PetData and PetData.PetBaseInfo
  local partner_mark = PetBaseInfo and PetBaseInfo.partner_mark
  for j = 1, #PartnerMarkerFilter do
    if partner_mark == PartnerMarkerFilter[j] then
      return true
    end
  end
  return false
end

function UMG_Pet_TeamReplace_C:RefreshPetListByChooseType(TypeChooseList)
  self:ResetDescText()
  if self.petTabType == PetTabType.RandomPet then
    TypeChooseList = {
      DepartmentFilter = {},
      TalentFilter = {},
      NaturePositiveEffectFilter = {},
      AttributeFilter = {},
      PartnerMarkerFilter = {},
      SpecialityFilter = {},
      GetTimeFilter = {}
    }
  end
  local DepartmentFilter = {}
  if self.PvpDepartmentFilter then
    table.insert(DepartmentFilter, self.PvpDepartmentFilter)
  end
  if TypeChooseList.DepartmentFilter then
    for i, v in pairs(TypeChooseList.DepartmentFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(DepartmentFilter, enum)
      end
    end
  end
  local TalentFilter = {}
  if TypeChooseList.TalentFilter then
    for i, v in pairs(TypeChooseList.TalentFilter) do
      local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
      table.insert(TalentFilter, enum)
    end
  end
  local NaturePositiveEffectFilter = {}
  if TypeChooseList.NaturePositiveEffectFilter then
    for i, v in pairs(TypeChooseList.NaturePositiveEffectFilter) do
      local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
      table.insert(NaturePositiveEffectFilter, enum)
    end
  end
  local AttributeFilter = {}
  if TypeChooseList.AttributeFilter then
    for i, v in pairs(TypeChooseList.AttributeFilter) do
      local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
      table.insert(AttributeFilter, enum)
    end
  end
  local PartnerMarkerFilter = {}
  if TypeChooseList.PartnerMarkerFilter then
    for i, v in pairs(TypeChooseList.PartnerMarkerFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(PartnerMarkerFilter, enum)
      end
    end
  end
  local resultList = {}
  local InitState = true
  if #DepartmentFilter > 0 or #TalentFilter > 0 or #NaturePositiveEffectFilter > 0 or #AttributeFilter > 0 or #PartnerMarkerFilter > 0 then
    InitState = false
    self.ComScreen.ScreeningBtn:ChangeIconSelectState(2)
  else
    self.ComScreen.ScreeningBtn:ChangeIconSelectState(1)
  end
  for _, petInfo in pairs(self.uiData.PetSortInfo) do
    if petInfo.PetData then
      local CanInsert = InitState
      if self:CheckDepartmentFilter(DepartmentFilter, petInfo) then
        CanInsert = true
      end
      if not CanInsert and self:CheckTalentFilter(TalentFilter, petInfo) then
        CanInsert = true
      end
      if not CanInsert and self:CheckNaturePositiveEffectFilter(NaturePositiveEffectFilter, petInfo) then
        CanInsert = true
      end
      if not CanInsert and self:CheckAttributeFilter(AttributeFilter, petInfo) then
        CanInsert = true
      end
      if not CanInsert and self:CheckPartnerMarkerFilter(PartnerMarkerFilter, petInfo) then
        CanInsert = true
      end
      if CanInsert then
        table.insert(resultList, petInfo)
      end
    end
  end
  for i, petInfo in ipairs(resultList) do
    petInfo.CallbackOwner = self
    petInfo.OnSpawnCallback = self.OnWarehouseItemSpawn
  end
  self:ResetWareHouseList()
  self.WarehouseList:InitList(resultList)
  self.uiData.AfterFilterList = resultList
end

function UMG_Pet_TeamReplace_C:PetListSort(_IsAscendingOrder, _PetList)
  local newPetList = {}
  local travelPetList = {}
  for i = 1, #_PetList do
    local petInfo = _PetList[i]
    if petInfo.IsTravel then
      table.insert(travelPetList, petInfo)
    else
      table.insert(newPetList, petInfo)
    end
  end
  
  local function cmpFunction(a, b)
    return true
  end
  
  if _IsAscendingOrder then
    function cmpFunction(a, b)
      if self.RecyclingCountMap[a.PetData.gid] and self.RecyclingCountMap[b.PetData.gid] then
        return self.RecyclingCountMap[a.PetData.gid] > self.RecyclingCountMap[b.PetData.gid]
      elseif self.RecyclingCountMap[a.PetData.gid] then
        return true
      elseif self.RecyclingCountMap[b.PetData.gid] then
        return false
      else
        local aIconListSortInfo = a.PetData[self.SortIndex]
        local bIconListSortInfo = b.PetData[self.SortIndex]
        if aIconListSortInfo and bIconListSortInfo then
          if aIconListSortInfo == bIconListSortInfo then
            return aIconListSortInfo > bIconListSortInfo
          else
            return aIconListSortInfo > bIconListSortInfo
          end
        elseif aIconListSortInfo then
          return true
        elseif bIconListSortInfo then
          return false
        else
          return false
        end
      end
    end
  else
    function cmpFunction(a, b)
      if self.RecyclingCountMap[a.PetData.gid] and self.RecyclingCountMap[b.PetData.gid] then
        return self.RecyclingCountMap[a.PetData.gid] > self.RecyclingCountMap[b.PetData.gid]
      elseif self.RecyclingCountMap[a.PetData.gid] then
        return true
      elseif self.RecyclingCountMap[b.PetData.gid] then
        return false
      else
        local aIconListSortInfo = a.PetData[self.SortIndex]
        local bIconListSortInfo = b.PetData[self.SortIndex]
        if aIconListSortInfo and bIconListSortInfo then
          if aIconListSortInfo == bIconListSortInfo then
            return aIconListSortInfo < bIconListSortInfo
          else
            return aIconListSortInfo < bIconListSortInfo
          end
        elseif aIconListSortInfo then
          return false
        elseif bIconListSortInfo then
          return true
        else
          return false
        end
      end
    end
  end
  if self.petTabType == PetTabType.RandomPet then
    function cmpFunction(a, b)
      local petDataA = a and a.PetData
      
      local petDataB = b and b.PetData
      local typeInfoA = petDataA and petDataA.type
      local typeInfoB = petDataB and petDataB.type
      local skillDamTypeA = typeInfoA and typeInfoA.param or 0
      local skillDamTypeB = typeInfoB and typeInfoB.param or 0
      return skillDamTypeA < skillDamTypeB
    end
  end
  table.sort(newPetList, cmpFunction)
  for i = 1, #travelPetList do
    table.insert(newPetList, travelPetList[i])
  end
  return newPetList
end

function UMG_Pet_TeamReplace_C:SetNameInfo(petData)
  local petDataInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petData.gid, self.is_mirror)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  local petLv = PetUtils.GetCatchHardInfo(petDataInfo)
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(petDataInfo.blood_id)
  self.CatchHardLv:InitGridView(petLv)
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
end

function UMG_Pet_TeamReplace_C:SetPetNum(_petInfo)
  local petInfo = _petInfo
  local length = #petInfo
  if length < 100 then
    for i = length + 1, 100 do
      table.insert(petInfo, {isHasPet = false})
    end
  else
    local remainder = length % 6
    if remainder > 0 then
      for i = remainder + 1, 6 do
        table.insert(petInfo, {isHasPet = false})
      end
    end
  end
  return petInfo
end

function UMG_Pet_TeamReplace_C:CloseTipsAndClearSkillListSelection()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.IsHavePetSkillTips)
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:ClearSkillListSelection()
  end
end

function UMG_Pet_TeamReplace_C:OnSelectSkillClick()
  self:CloseTipsAndClearSkillListSelection()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:OpenSkillFilteringPanelByCurShowSkillList()
  end
end

function UMG_Pet_TeamReplace_C:OnSortSkillClick()
  self:CloseTipsAndClearSkillListSelection()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnCmdOpenPetSortPanel, self.sortRuleId, self.skillSortReverse)
end

function UMG_Pet_TeamReplace_C:OnPetSkillFilterRuleChange(filterRule)
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    local path
    if filterRule then
      path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Screen3_png.img_Screen3_png'"
    else
      path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Screen1_png.img_Screen1_png'"
    end
    self.ViewPet:SetPath(path, path, path)
    ChangePetSkillsPanel:OnPetSkillFilterRuleChange(filterRule)
  end
end

function UMG_Pet_TeamReplace_C:OnPetSkillSortRuleChange(id, skillSortReverse)
  self.sortRuleId = id
  self.skillSortReverse = skillSortReverse
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:OnPetSkillSortRuleChange(id, skillSortReverse)
  end
end

function UMG_Pet_TeamReplace_C:OnImportClick()
  self:ResetDescText()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenLoadPetTeamPanel, self.curTeamType, self.curTeamIdx)
end

function UMG_Pet_TeamReplace_C:OnShareClick()
  self:ResetDescText()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_SHARE, true)
  if isBan then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenShareTeamPanel, self.curTeamType, self.curTeamIdx)
end

function UMG_Pet_TeamReplace_C:OnShowLockSkillClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_Pet_TeamReplace_C:OnShowLockSkillClick")
  self:CloseTipsAndClearSkillListSelection()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    self.showLockSkill = not self.showLockSkill
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetIsShowPetNotUnlockSkill, self.showLockSkill)
    self:RefreshShowLockSkillBtn()
    ChangePetSkillsPanel:OnShowLockSkillChange(self.showLockSkill)
  end
end

function UMG_Pet_TeamReplace_C:RefreshShowLockSkillBtn()
  local path, text
  if self.showLockSkill then
    path = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_UnlockVisible_png.img_UnlockVisible_png'"
    text = LuaText.skill_sort_text_2
  else
    path = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_UnlockInvisible_png.img_UnlockInvisible_png'"
    text = LuaText.skill_sort_text_1
  end
  self.ViewPet_3:SetPath(path, path, path)
  self.ViewPet_3:SetText(text)
end

function UMG_Pet_TeamReplace_C:OnBagSKillTipsPanelShowChange(bShow)
  if bShow then
    self.NRCImage_76:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCImage_76:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Pet_TeamReplace_C:UpdatePvpSkillData()
  local curShowPetData = self.curShowPetData
  local gid = self.curShowPetData and self.curShowPetData.gid
  local skillMap = self:GetSkillMapByPetGid(curShowPetData)
  local teamParam = self:GetTeamParam(gid)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPvpSkillData, skillMap, teamParam)
end

function UMG_Pet_TeamReplace_C:AddPetDataInBalanceQueryQueue(petInfoList)
  petInfoList = petInfoList or {}
  local petGuidList = {}
  for i, petInfo in ipairs(petInfoList) do
    local petData = petInfo and petInfo.PetData
    local needSwitchToPvpBalancePetData = PetUtils.CheckNeedSwitchToPvpBalancePetData(petData)
    if needSwitchToPvpBalancePetData then
      local petGuid = petData and petData.gid
      table.insert(petGuidList, petGuid)
    end
  end
  if #petGuidList > 0 then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.CmdQueryBalancedPetDataForPvp, petGuidList)
  end
end

function UMG_Pet_TeamReplace_C:OnWarehouseItemSpawn(petInfo)
  local petInfoList = {}
  table.insert(petInfoList, petInfo)
  self:AddPetDataInBalanceQueryQueue(petInfoList)
end

function UMG_Pet_TeamReplace_C:SelectFirstPet()
  if self.curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit and self.teamPetList then
    local trySelectPet = self:GetFirstNotCommonEvoPet()
    if trySelectPet and self.curSelPetData and trySelectPet.gid == self.curSelPetData.gid then
      return
    end
    if trySelectPet then
      self.Switcher:SetActiveWidgetIndex(0)
      self:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, trySelectPet)
    else
      self.Switcher:SetActiveWidgetIndex(2)
    end
  elseif self.curMode == PetUIModuleEnum.ModifyPetMode.QuickEdit and self.teamPetList then
    local trySelectPet = self:GetFirstNotCommonEvoPet()
    if trySelectPet then
      self.Switcher:SetActiveWidgetIndex(0)
      self:DispatchEvent(PetUIModuleEvent.PetTeamFastFormationSelected, trySelectPet)
    else
      self.Switcher:SetActiveWidgetIndex(2)
    end
  end
end

return UMG_Pet_TeamReplace_C
