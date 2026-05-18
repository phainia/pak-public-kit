local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetTotalWarehouse_C = _G.NRCViewBase:Extend("UMG_PetTotalWarehouse_C")

function UMG_PetTotalWarehouse_C:OnConstruct()
  self:SetChildViews(self.PetWarehouse, self.PetFormIntoColumns, self.PetSumUp)
  self.subPanels = {
    self.PetSumUp,
    self.PetFormIntoColumns
  }
  self.curSubPanelIndex = 0
  self.SortIndex = 0
  self:updateSubPanelVisible()
  self:ShowSubPanel(1)
  self.petInfoList = nil
  self.PetWarehouse:setPetInfoMainCtrl(self)
  self.PetFormIntoColumns:setPetInfoMainCtrl(self)
  self.PetSumUp:setPetInfoMainCtrl(self)
  self:OnAddEventListener()
end

function UMG_PetTotalWarehouse_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_PetTotalWarehouse_C:OnActive()
end

function UMG_PetTotalWarehouse_C:SetSortIndex(index)
  self.SortIndex = index
end

function UMG_PetTotalWarehouse_C:GetSortIndex()
  return self.SortIndex
end

function UMG_PetTotalWarehouse_C:OnAddEventListener()
  self:AddButtonListener(self.CloseWareHouseBtn, self.OnCloseButtonClicked)
  self:RegisterEvent(self, PetUIModuleEvent.UpdataPetWarehouseInfo, self.OnUpdataPetWarehouseInfo)
  self:RegisterEvent(self, PetUIModuleEvent.PET_FREE_SUCCESS, self.OnPetFreeSuccess)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.PET_FLAG_CHANGE, self.OnPetFreeSuccess)
end

function UMG_PetTotalWarehouse_C:OnRemoveEventListener()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.PET_FLAG_CHANGE, self.OnPetFreeSuccess)
end

function UMG_PetTotalWarehouse_C:OnCloseButtonClicked()
  self.petInfoMainCtrl:CloseWareHouseUpdate()
end

function UMG_PetTotalWarehouse_C:OnSelectPetChange(_petData)
  self.PetSumUp:OnSelectPetChange(_petData)
end

function UMG_PetTotalWarehouse_C:updateSubPanelVisible()
  for panelIndex, subPanel in pairs(self.subPanels) do
    if subPanel then
      if panelIndex == self.curSubPanelIndex then
        subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        subPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
    end
  end
end

function UMG_PetTotalWarehouse_C:ShowSubPanel(_index, _subIndex)
  if _index > 0 and _index <= #self.subPanels and self.curSubPanelIndex ~= _index then
    self:ChangeSubPanelState(self.curSubPanelIndex, false)
    self.curSubPanelIndex = _index
    self:ChangeSubPanelState(self.curSubPanelIndex, true)
  end
end

function UMG_PetTotalWarehouse_C:CloseTeamPanle()
  self.petInfoList.IsOpenTeam = false
  self:SetPetInfoList()
  self.PetWarehouse:SetOpenTeamBtnState(false)
  self.PetWarehouse:UpdateFightBtn()
  self:ShowSubPanel(1)
  self.CloseWareHouseBtn:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_PetTotalWarehouse_C:OnPetFreeSuccess(_pet_gid)
  self:UpdatePetWareHouseInfo()
end

function UMG_PetTotalWarehouse_C:ShowPetFormlntoColumns(_index)
  local petTeamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  self.petInfoList.IsOpenTeam = true
  self.PetFormIntoColumns:UpdatePetFormInfo(petTeamInfo)
  self:SetIsNewPet()
  self:SetPetInfoList()
  self:ShowSubPanel(_index)
  self.CloseWareHouseBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PetTotalWarehouse_C:OnUpdataPetWarehouseInfo(_PetWareHouseInfo)
  if self.petInfoList then
    local petTeamInfo = PetUtils.PlayerPetInfoGetTeamInfo(_PetWareHouseInfo, Enum.PlayerTeamType.PTT_BIG_WORLD)
    PetUtils.PlayerPetInfoSetTeamInfo(self.petInfoList, petTeamInfo, Enum.PlayerTeamType.PTT_BIG_WORLD)
    self:UpdatePetWareHouseInfo()
  end
end

function UMG_PetTotalWarehouse_C:UpdatePetWareHouseInfo()
  self.petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  self.petInfoList.petHeadInfo = nil
  self.petInfoList.IsOpenTeam = false
  self.curSubPanelIndex = 0
  self:updateSubPanelVisible()
  self:ShowSubPanel(1)
  self:SetPetInfoList()
  self:PanelChanageUpdateInfo()
  self:UpdateChildPanelInfo()
end

function UMG_PetTotalWarehouse_C:UpdateChildPanelInfo()
  self.PetWarehouse:UpdatePetWareHouseInfo()
end

function UMG_PetTotalWarehouse_C:SetPetTeamInfo(team_info)
  PetUtils.PlayerPetInfoSetTeamInfo(self.petInfoList, team_info, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local petTeamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  self:SetPetInfoList()
  self.PetFormIntoColumns:UpdatePetFormInfo(petTeamInfo, true)
end

function UMG_PetTotalWarehouse_C:SetPetInfoList()
  local petDataList = self.petInfoList.pet_data
  local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(self.petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local IsOpenTeam = self.petInfoList.IsOpenTeam
  local SelectTeamIndex = self.PetFormIntoColumns:GetPetFormIndex()
  local PetInfoList = {}
  local index = 1
  for _, petData in ipairs(petDataList) do
    if not BattleUtils.GetBit(petData.pet_status_flags, 1) then
      local IsTeams = false
      local IsMainTeam = false
      local MainTeamIndex = 0
      if teamInfo.teams then
        for j, team in ipairs(teamInfo.teams) do
          local petInfo, petInfoIndex = PetUtils.PetTeamFindPetInfoByIndex(team, petData.gid)
          if petInfo then
            if j == SelectTeamIndex then
              IsMainTeam = true
              MainTeamIndex = petInfoIndex
            end
            IsTeams = true
          end
        end
      end
      if petData.base_conf_id then
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
        if petBaseConf then
          local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
          table.insert(PetInfoList, {
            petData.level,
            gid = petData.gid,
            PetIcon = modelConf,
            IsTeams = IsTeams,
            IsOpenTeam = IsOpenTeam,
            pet_status_flags = petData.pet_status_flags or 0,
            IsMainTeam = IsMainTeam,
            MainTeamIndex = MainTeamIndex,
            BaseConfId = petData.base_conf_id,
            CanChangeTeam = petData.enable_change,
            CanChangeTeamSort = petData.enable_change and 1 or 0,
            energy = petData.energy
          })
        end
      end
      for j = 2, 7 do
        local PetBasicProperty = petData.additional_attr.addi_attr[j]
        if PetBasicProperty then
          table.insert(PetInfoList[index], PetBasicProperty)
        end
      end
      index = index + 1
    end
  end
  self.petInfoList.petHeadInfo = PetInfoList
  self.PetWarehouse:UpdatePetInfo(self.petInfoList, PetInfoList)
end

function UMG_PetTotalWarehouse_C:SetWareHouseTeamInfo(_gid, _OnClick)
  local gid = _gid
  local IsInTeam = false
  local petInfos = {}
  local GidList = {}
  local PetFormIndex = self.PetFormIntoColumns:GetPetFormIndex()
  local team_info = PetUtils.PlayerPetInfoGetTeamInfo(self.petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local team = team_info.teams[PetFormIndex]
  if team then
    if team.pet_infos then
      if #team.pet_infos >= 6 then
        IsInTeam = true
      end
      local petInfo, petInfoIndex = PetUtils.PetTeamFindPetInfoByIndex(team, gid)
      if petInfo then
        if team_info.main_team_idx == PetFormIndex - 1 and #team.pet_infos <= 1 then
          _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_pettotalwarehouse_1)
          return
        end
        IsInTeam = true
        table.insert(GidList, gid)
        table.remove(team.pet_infos, petInfoIndex)
      end
      if false == IsInTeam then
        table.insert(team.pet_infos, PetUtils.PetInfoCreate(gid))
      end
    else
      table.insert(petInfos, PetUtils.PetInfoCreate(gid))
      team.pet_infos = petInfos
    end
  else
    return
  end
  self:SetPetTeamInfo(team_info)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamsInfo, team_info.teams, PetFormIndex - 1)
  _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(PetUIModuleEvent.PET_TEAM_CHANGE, GidList)
end

function UMG_PetTotalWarehouse_C:PanelChanageUpdateInfo()
  self.PetSumUp:PanelChanage()
end

function UMG_PetTotalWarehouse_C:UpdatePetWarehouse(_petTeamInfo)
  PetUtils.PlayerPetInfoSetTeamInfo(self.petInfoList, _petTeamInfo, Enum.PlayerTeamType.PTT_BIG_WORLD)
  self:SetPetInfoList()
end

function UMG_PetTotalWarehouse_C:SetSortListInfo()
  self.UMG_PetDropDownList:OnActive()
end

function UMG_PetTotalWarehouse_C:ChangeSubPanelState(_index, _isShow)
  if _index then
    local subPanel = self.subPanels[_index]
    if subPanel then
      if subPanel.OnPanelStateChange then
        tcall(subPanel, subPanel.OnPanelStateChange, _isShow)
      end
      if _isShow then
        subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_PetTotalWarehouse_C:SetIsNewPet()
  local petinfo = self.petInfoList.pet_data
  for i, v in ipairs(petinfo) do
    v.pet_status_flags = 0
  end
end

function UMG_PetTotalWarehouse_C:OnRemovePetNew(item)
  local petinfo = self.petInfoList.pet_data
  for i, v in ipairs(petinfo) do
    if v.gid == item.PetData.gid then
      v.pet_status_flags = 0
    end
  end
end

function UMG_PetTotalWarehouse_C:setPetInfoMainCtrl(_petInfoMainCtrl)
  self.petInfoMainCtrl = _petInfoMainCtrl
end

function UMG_PetTotalWarehouse_C:OpenPetFormation()
  self.PetWarehouse:OnFightBtnClick()
end

return UMG_PetTotalWarehouse_C
