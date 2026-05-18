local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Activity_Participation_C = _G.NRCPanelBase:Extend("UMG_Activity_Participation_C")

function UMG_Activity_Participation_C:OnConstruct()
  self:SetChildViews(self.PopUp)
end

function UMG_Activity_Participation_C:OnDestruct()
end

function UMG_Activity_Participation_C:OnActive(activityInst)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    self:SetCommonPopUpInfo()
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    return
  end
  self.activityInst = activityInst
  if activityInst then
    self.activityStartTime = self.activityInst:GetActivityStartTime()
    local unit_type = activityInst:GetPetRaiseConf().unit_type
    self.unit_type = unit_type
    self.chooseTypeList = {
      DepartmentFilter = {},
      TalentFilter = {},
      NaturePositiveEffectFilter = {},
      AttributeFilter = {}
    }
    local PetTypeList = {}
    for i = 1, #unit_type do
      local petType = unit_type[i]
      if petType then
        local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
        if typeDic then
          table.insert(PetTypeList, {
            Path = typeDic.tips_base_icon,
            Name = string.format("%s", typeDic.short_name)
          })
        end
      end
    end
    self.Attr:InitGridView(PetTypeList)
    self:UpdateInfo()
  end
  self:OnAddEventListener()
  _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_Activity_Participation_C:OnActive")
  self:LoadAnimation(0)
  self:SetCommonPopUpInfo()
  self:SetComScreenInfo()
end

function UMG_Activity_Participation_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Activity_Participation_C:SetComScreenInfo()
  local ComScreenData = _G.NRCCommonDropDownListData()
  ComScreenData.Btn_LeftHandler = self.OpenFilterPanelBtnClick
  ComScreenData.Call = self
  self.UMG_ComScreen:SetPanelInfo(ComScreenData)
  self.UMG_ComScreen:ShowOrHideComboBox(false)
end

function UMG_Activity_Participation_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
end

function UMG_Activity_Participation_C:UpdateInfo()
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local petData = self:EliminateFreePet(petInfoList)
  self.PetInfoList = {}
  for i = 1, #petData do
    if not BattleUtils.GetBit(petData[i].pet_status_flags, 1) then
      local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, petData[i].gid)
      local IsMainTeam, petIndex = PetUtils.GetIsMainTeamByGid(petData[i].gid)
      local petPos = 0
      if IsMainTeam then
        petPos = petPos + 100000 + (6 - petIndex) * 10000
      end
      if isTravel then
        petPos = petPos - 100000
      end
      if petData[i].grow_times then
        petPos = petPos + petData[i].grow_times * 10
      end
      local petInfo = {
        petPos = petPos,
        petData = petData[i],
        AddTime = petData[i].add_time
      }
      table.insert(self.PetInfoList, petInfo)
    end
  end
  self:RefreshFilterAndSortList(self.chooseTypeList)
end

function UMG_Activity_Participation_C:RefreshFilterAndSortList(TypeChooseList)
  self.PetInfoList = self:FilterInfo(TypeChooseList, self.PetInfoList)
  if #self.PetInfoList <= 0 then
    self.ScrollBox_322:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ScrollBox_322:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local PetList = self:SortInfo(self.PetInfoList)
    local PetIconList = {}
    for _, PetInfo in ipairs(PetList) do
      local PetIconData = {}
      PetIconData.PetData = PetInfo.petData
      PetIconData.bShowTip = true
      PetIconData.bShowTag = true
      table.insert(PetIconList, PetIconData)
    end
    self.SecondLine:InitGridView(PetIconList)
  end
end

local function SortPetInfo(a, b)
  if a.petPos == b.petPos then
    return a.AddTime > b.AddTime
  else
    return a.petPos > b.petPos
  end
end

function UMG_Activity_Participation_C:SortInfo(SortList)
  local PetList = SortList
  table.sort(PetList, SortPetInfo)
  return PetList
end

function UMG_Activity_Participation_C:FilterInfo(TypeChooseList, PetList)
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
          if petBaseConf.unit_type[k] == DepartmentFilter[j] then
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
        if DepartList[i].petData.talent_rank == TalentFilter[j] then
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
        if NaturePositive == NaturePositiveEffectFilter[j] then
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
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_HPMAX and NaturePositiveEffectList[i].petData.attribute_info.hp.talent and NaturePositiveEffectList[i].petData.attribute_info.hp.talent > 0 then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_PHYATK and NaturePositiveEffectList[i].petData.attribute_info.attack.talent and NaturePositiveEffectList[i].petData.attribute_info.attack.talent > 0 then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEATK and NaturePositiveEffectList[i].petData.attribute_info.special_attack.talent and NaturePositiveEffectList[i].petData.attribute_info.special_attack.talent > 0 then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_PHYDEF and NaturePositiveEffectList[i].petData.attribute_info.defense.talent and NaturePositiveEffectList[i].petData.attribute_info.defense.talent > 0 then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEDEF and NaturePositiveEffectList[i].petData.attribute_info.special_defense.talent and NaturePositiveEffectList[i].petData.attribute_info.special_defense.talent > 0 then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
        if AttributeFilter[j] == _G.Enum.AttributeType.AT_SPEED and NaturePositiveEffectList[i].petData.attribute_info.speed.talent and NaturePositiveEffectList[i].petData.attribute_info.speed.talent > 0 then
          table.insert(AttributeList, NaturePositiveEffectList[i])
          break
        end
      end
    end
  else
    AttributeList = NaturePositiveEffectList
  end
  if #DepartmentFilter <= 0 and #TalentFilter <= 0 and #NaturePositiveEffectFilter <= 0 and #AttributeFilter <= 0 then
    self.UMG_ComScreen:SetScreeningBtnIcon(UEPath.Screen_1)
  else
    self.UMG_ComScreen:SetScreeningBtnIcon(UEPath.Screen)
  end
  return AttributeList
end

function UMG_Activity_Participation_C:GetChangeAttrReqEnum(attribute)
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

function UMG_Activity_Participation_C:HasGid(gid, table)
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

function UMG_Activity_Participation_C:EliminateFreePet(petInfoList)
  local PetData = petInfoList.pet_data
  local PetList = {}
  local unit_type_list = self.activityInst:GetPetRaiseConf().unit_type or {}
  if PetData then
    for i, PetInfo in ipairs(PetData) do
      local IsUnit = false
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetInfo.base_conf_id)
      for j, unit_type in pairs(unit_type_list) do
        local petUnitType = petBaseConf.unit_type
        for k, pet_unit_type in pairs(petUnitType) do
          if unit_type == pet_unit_type then
            IsUnit = true
            break
          end
        end
        if IsUnit then
          break
        end
      end
      local isExchange = PetInfo.pet_status_flags and PetInfo.pet_status_flags & ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
      if not isExchange and (not petBaseConf.ban_free or 1 ~= petBaseConf.ban_free) and IsUnit and PetInfo.add_time >= self.activityStartTime then
        table.insert(PetList, PetInfo)
      end
    end
  end
  return PetList
end

function UMG_Activity_Participation_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_Activity_Participation_C", self, PetUIModuleEvent.FilterPet, self.OnFilterPet)
end

function UMG_Activity_Participation_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Activity_Participation_C:OnFilterPet(chooseTypeList)
  self.chooseTypeList = chooseTypeList
  self:UpdateInfo()
end

function UMG_Activity_Participation_C:OpenFilterPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenFilterPanel, PetUIModuleEnum.OpenSortType.NeedModuleCatch, {
    HiddenParam = self.unit_type,
    chooseTypeList = self.chooseTypeList,
    HiddenFilterEnum = {4, 5}
  })
end

function UMG_Activity_Participation_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_Activity_Participation_C:ClosePanel")
  self:LoadAnimation(2)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
end

return UMG_Activity_Participation_C
