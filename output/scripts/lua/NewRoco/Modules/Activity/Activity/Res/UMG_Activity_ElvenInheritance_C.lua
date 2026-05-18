local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_ElvenInheritance_C = Base:Extend("UMG_Activity_ElvenInheritance_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local NRCPanelDynamicData = require("Core.NRCPanel.NRCPanelDynamicData")
local ElvenInheritanceItemOpType = {RefreshData = 1}

function UMG_Activity_ElvenInheritance_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = Enum.ActivityType.ATP_PET_INHERITANCE
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.Image_Bg
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_ElvenInheritance_C:OnConstruct()
  Base.OnConstruct(self)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshPetInheritancePartItemData, self.OnRefreshPetInheritancePartItemData)
  local activityInst = self.activityInst
  if activityInst then
    local partIds = activityInst:GetPartIds()
    if #partIds > 0 then
      self.List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      ActivityUtils.AdjustCtrlAutoSize(self.List, #partIds < 4)
      self.List:InitList(ActivityUtils.CreateActivityItemBaseDataForList(self, partIds))
    else
      self.List:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Activity_ElvenInheritance_C:OnDestruct()
  Base.OnDestruct(self)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshPetInheritancePartItemData)
end

function UMG_Activity_ElvenInheritance_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  if firstLoad then
    self.activityInst:UpdatePartItemProgress()
  end
end

function UMG_Activity_ElvenInheritance_C:GetItemIndexByPartId(_partId)
  local itemIndex = self.List:GetIndexByData(_partId, function(_data, _valueInList)
    return _valueInList and _valueInList.customData == _data
  end)
  return itemIndex
end

function UMG_Activity_ElvenInheritance_C:OnRefreshPetInheritancePartItemData(_activityInst, _partItemData)
  if _partItemData and _activityInst and _activityInst == self.activityInst then
    local itemIndex = self:GetItemIndexByPartId(_partItemData.partId)
    self.List:OpItemByIndex(itemIndex, ElvenInheritanceItemOpType.RefreshData)
  end
end

function UMG_Activity_ElvenInheritance_C:OnItemSelected(_itemInst, _index, _partId, _bSelected)
  if self.inOpenSearchButtonPanel then
    return
  end
  local activityInst = self.activityInst
  if _bSelected and activityInst then
    local itemData = activityInst:GetPartItemData(_partId)
    if itemData and itemData.curProgress >= itemData.maxProgress then
      _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenReplacePetPanel, activityInst, _partId)
    end
  end
end

function UMG_Activity_ElvenInheritance_C:OnItemUpdate(_itemInst, _index, _partId)
  if _itemInst then
    _itemInst:SetupRedPoint(418, {
      self.activityInst:GetActivityId()
    })
  end
  self:OnItemRefreshView(_itemInst, _index, _partId)
end

function UMG_Activity_ElvenInheritance_C:OnItemRefreshView(_itemInst, _index, _partId)
  local activityInst = self.activityInst
  local itemData = activityInst and activityInst:GetPartItemData(_partId)
  if _itemInst and itemData then
    _itemInst:SetTitle(_G.LuaText.INHERITANCE_1)
    _itemInst:SetDescribe(string.format(_G.LuaText.INHERITANCE_2, itemData.maxProgress))
    _itemInst:SetProgress(itemData.curProgress, itemData.maxProgress)
    local petBriefInfo = itemData.selectedPetData
    if petBriefInfo then
      _itemInst:SetButtonState(2, _G.LuaText.INHERITANCE_5)
      _itemInst:SetPetIcon(petBriefInfo.base_conf_id, petBriefInfo.mutation_type, petBriefInfo.glass_info)
      _itemInst:PlayRewardAvailableAnimation()
    else
      _itemInst:SetPetIcon(nil)
      if itemData.curProgress < itemData.maxProgress then
        _itemInst:SetButtonState(0, _G.LuaText.INHERITANCE_3)
        _itemInst:PlayRewardUnAvailableAnimation()
      else
        _itemInst:SetButtonState(1, _G.LuaText.INHERITANCE_4)
        _itemInst:PlayRewardAvailableAnimation()
      end
    end
  end
end

function UMG_Activity_ElvenInheritance_C:OnItemOp(_itemInst, _index, _partId, _opType)
  if _itemInst and _opType == ElvenInheritanceItemOpType.RefreshData then
    self:OnItemRefreshView(_itemInst, _index, _partId)
  end
end

function UMG_Activity_ElvenInheritance_C:OnClickSearchButton(_itemInst, _index, _partId)
  _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_Activity_ElvenInheritance_C:OnClickSearchButton")
  local activityInst = self.activityInst
  if activityInst then
    local itemData = activityInst:GetPartItemData(_partId)
    local petBriefInfo = itemData and itemData.selectedPetData
    if petBriefInfo then
      local panelDynamicData = NRCPanelDynamicData()
      panelDynamicData:SetOpenCallback(self, self.OnSearchButtonPanelOpenOrClosed, true)
      panelDynamicData:SetCloseCallback(self, self.OnSearchButtonPanelOpenOrClosed, false)
      local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petBriefInfo.gid)
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetOpenPanelPetData, petData, 1, false)
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetEnterPetPanelType, PetUIModuleEnum.EnterType.PetInheritance)
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetOpenPetAttribute, true)
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPanelPetMain, {subPanelIndex = 4}, nil, nil, nil, panelDynamicData)
    end
  end
end

function UMG_Activity_ElvenInheritance_C:OnSearchButtonPanelOpenOrClosed(isOpen)
  self.inOpenSearchButtonPanel = isOpen
end

return UMG_Activity_ElvenInheritance_C
