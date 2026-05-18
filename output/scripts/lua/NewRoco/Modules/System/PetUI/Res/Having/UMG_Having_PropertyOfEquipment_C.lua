local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Having_PropertyOfEquipment_C = _G.NRCViewBase:Extend("UMG_Having_PropertyOfEquipment_C")

function UMG_Having_PropertyOfEquipment_C:OnConstruct()
  self.FiIterQuality = nil
  self.isNullHaving = true
  self.CurrentPanelIndex = 3
  self.OldSubPanelIndex = {}
  self.hideEquip = NRCModuleManager:DoCmd(PetUIModuleCmd.GetEquipProssession)
  self:SetSwich(self.hideEquip)
  self:SetSwich1(self.hideEquip)
  self:BtnInit()
  self:OnAddEventListener()
end

function UMG_Having_PropertyOfEquipment_C:OnDestruct()
  self:CancelDelay()
end

function UMG_Having_PropertyOfEquipment_C:OnActive(_PanelInfo)
  local PanelInfo = _PanelInfo
  if PanelInfo.IsOpen == true and _PanelInfo.OldSubPanelIndex ~= self.CurrentPanelIndex then
    table.insert(self.OldSubPanelIndex, PanelInfo.OldSubPanelIndex)
  end
  self.FiIterQuality = nil
  if true == PanelInfo.IsFiIterHaving then
    self:FiIterInfo(PanelInfo)
  else
    self:UIInfo()
  end
end

function UMG_Having_PropertyOfEquipment_C:OnHavingChange(_data)
  self.uiData = _data
  self:OnUpdate()
end

function UMG_Having_PropertyOfEquipment_C:OnDeactive()
  self:CancelDelay()
end

function UMG_Having_PropertyOfEquipment_C:OnAddEventListener()
  self:AddButtonListener(self.BtnSwich, self.OnClickBtnSwich)
  self:AddButtonListener(self.BtnSwich_1, self.OnClickBtnSwich1)
  self:AddButtonListener(self.btnUseItem.btnLevelUp, self.OnBtnUseItemClick)
  self:AddButtonListener(self.btnRemoveItem.btnLevelUp, self.OnBtnRemoveItemClick)
  self:AddButtonListener(self.btnAssembly.btnLevelUp, self.OnBtnUseItemClick)
  self:AddButtonListener(self.btnToUnload.btnLevelUp, self.OnBtnRemoveItemClick)
  self:AddButtonListener(self.backBtn.btnClose, self.OnClickDescend)
  self:AddButtonListener(self.btnUpgrade.btnLevelUp, self.OnClickUpgradeBtn)
  self:AddButtonListener(self.btnOk.btnLevelUp, self.SelectResonanceItem)
  self:RegisterEvent(self, PetUIModuleEvent.PlayerDataUpdate, self.OnPlayerDataUpdate)
  self:RegisterEvent(self, PetUIModuleEvent.BagItemChange, self.OnBagInfoChange)
end

function UMG_Having_PropertyOfEquipment_C:OnSelectback(select, selectData)
  if false == select then
    return
  end
  self.uiData.selectData = selectData
  self:SetBasicInfo()
end

function UMG_Having_PropertyOfEquipment_C:SetBasicInfo()
  local selectData = self.uiData.selectData
  if selectData and selectData.bagItem.conf_id then
    if selectData.bagItem.stage == nil or 0 == selectData.bagItem.stage then
      self.Resonance:SetVisibility(UE4.ESlateVisibility.Hidden)
    else
      self.Resonance:SetVisibility(UE4.ESlateVisibility.Visible)
      local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("Pet_carryon_resonance_string")
      local Text = string.format("%s%s", LocalizationConf.msg, selectData.bagItem.stage)
      self.Resonance:SetText(Text)
    end
    self.NameTxt:SetText(selectData.bagItemConf.name)
    if selectData.bagItem.level and selectData.bagItem.level >= 1 then
      local Text = string.format("%d%s", selectData.bagItem.level, LuaText.umg_having_propertyofequipment_1)
      self.Name:SetText(Text)
      if selectData.FiIterQuality then
        self.State:SetActiveWidgetIndex(2)
      else
        self.State:SetActiveWidgetIndex(0)
      end
      if nil ~= selectData.petData and selectData.petData.gid == selectData.curPetData.gid then
        self.btnRemoveItem:SetVisibility(UE4.ESlateVisibility.Visible)
        self.btnUseItem:SetVisibility(UE4.ESlateVisibility.Hidden)
      else
        self.btnRemoveItem:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.btnUseItem:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    else
      self.Name:SetText(LuaText.umg_having_propertyofequipment_2)
      if selectData.FiIterQuality then
        self.State:SetActiveWidgetIndex(2)
      else
        self.State:SetActiveWidgetIndex(0)
      end
      if nil ~= selectData.petData and selectData.petData.gid == selectData.curPetData.gid then
        self.btnRemoveItem:SetVisibility(UE4.ESlateVisibility.Visible)
        self.btnUseItem:SetVisibility(UE4.ESlateVisibility.Hidden)
      else
        self.btnRemoveItem:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.btnUseItem:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
    self:SetPropertyList()
  end
end

function UMG_Having_PropertyOfEquipment_C:FiIterInfo(_PanelInfo)
  self.uiData.SelectHavingInfo = _PanelInfo
  local ResonanceHavingconfid = self.uiData.SelectHavingInfo.data.possessionItem.conf_id
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(ResonanceHavingconfid)
  local num
  if bagItemConf.item_quality <= 3 then
    num = _G.DataConfigManager:GetPetGlobalConfig("resonance_item_id_blue").num
  elseif 4 == bagItemConf.item_quality then
    num = _G.DataConfigManager:GetPetGlobalConfig("resonance_item_id_purple").num
  elseif 5 == bagItemConf.item_quality then
    num = _G.DataConfigManager:GetPetGlobalConfig("resonance_item_id_orange").num
  end
  self:SetFiIterQuality(num)
  self:UIInfo()
end

function UMG_Having_PropertyOfEquipment_C:UIInfo()
  local data = self.uiData
  if self.uiData.possessionItem.conf_id == nil then
    if nil ~= self.FiIterQuality then
      self.NRCText_all_3:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.NRCText_all_4:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.NRCText_all_5:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif 1 == data.pos then
      self.NRCText_all_3:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCText_all_4:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.NRCText_all_5:SetVisibility(UE4.ESlateVisibility.Hidden)
    else
      self.NRCText_all_3:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.NRCText_all_4:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCText_all_5:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  elseif nil ~= self.FiIterQuality then
    self.NRCText_all:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_all_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_all_2:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif 1 == data.pos then
    self.NRCText_all:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText_all_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_all_2:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.NRCText_all:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_all_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText_all_2:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self:UpdateHavingList()
end

function UMG_Having_PropertyOfEquipment_C:OnBagInfoChange()
  if self.Visibility == UE4.ESlateVisibility.Visible then
    self:UIInfo()
  end
end

function UMG_Having_PropertyOfEquipment_C:OnPlayerDataUpdate()
  if self.Visibility == UE4.ESlateVisibility.Visible then
    self:UIInfo()
  end
end

function UMG_Having_PropertyOfEquipment_C:OnUpdate()
  if self.Visibility == UE4.ESlateVisibility.Visible then
    self:UIInfo()
  end
end

function UMG_Having_PropertyOfEquipment_C:UpdateHavingList()
  local hideEquip = self.hideEquip
  local bagDatas = self:GetAllBagData()
  if self.uiData.possessionItem.conf_id == nil then
    self.isNullHaving = true
    self.State1:SetActiveWidgetIndex(1)
    bagDatas = self:ItemSort(bagDatas)
    if false == hideEquip then
      local datas = self:GetAllCarryonsInfo()
      datas = self:ItemSort(datas)
      for i = 1, #bagDatas do
        table.insert(datas, bagDatas[i])
      end
      self:InitGridView1(datas)
      local defIndex = self:GetDefIndex(datas)
      self.List1_1:SelectItemByIndex(defIndex)
    else
      self:InitGridView1(bagDatas)
      self.List1_1:SelectItemByIndex(0)
    end
  else
    self.isNullHaving = false
    self.State1:SetActiveWidgetIndex(0)
    bagDatas = self:ItemSort(bagDatas)
    if false == hideEquip then
      local datas = self:GetAllCarryonsInfo()
      datas = self:ItemSort(datas)
      for i = 1, #bagDatas do
        table.insert(datas, bagDatas[i])
      end
      self:InitGridView(datas)
      local defIndex = self:GetDefIndex(datas)
      self.List1:SelectItemByIndex(defIndex)
    else
      self:InitGridView(bagDatas)
      self.List1:SelectItemByIndex(0)
    end
  end
end

function UMG_Having_PropertyOfEquipment_C:UpdateHavingList2()
  local hideEquip = self.hideEquip
  local bagDatas = self:GetAllBagData()
  if self.isNullHaving == true then
    bagDatas = self:ItemSort(bagDatas)
    if false == hideEquip then
      local datas = self:GetAllCarryonsInfo()
      datas = self:ItemSort(datas)
      for i = 1, #bagDatas do
        table.insert(datas, bagDatas[i])
      end
      self:InitGridView1(datas)
    else
      self:InitGridView1(bagDatas)
    end
  else
    bagDatas = self:ItemSort(bagDatas)
    if false == hideEquip then
      local datas = self:GetAllCarryonsInfo()
      datas = self:ItemSort(datas)
      for i = 1, #bagDatas do
        table.insert(datas, bagDatas[i])
      end
      self:InitGridView(datas)
      local defIndex = self:GetDefIndex(datas)
      self.List1:SelectItemByIndex(defIndex)
    else
      self:InitGridView(bagDatas)
      self.List1:SelectItemByIndex(0)
    end
  end
end

function UMG_Having_PropertyOfEquipment_C:InitGridView(datas)
  if 0 == #datas then
    self:TitleInfoClear(false)
  else
    self:TitleInfoClear(true)
  end
  if #datas < 8 then
    for i = #datas, 7 do
      table.insert(datas, {IsNullSlot = true})
    end
  end
  self.List1:InitGridView(datas)
end

function UMG_Having_PropertyOfEquipment_C:InitGridView1(datas)
  if 0 == #datas then
    self:TitleInfoClear(false)
  else
    self:TitleInfoClear(true)
  end
  if #datas < 8 then
    for i = #datas, 7 do
      table.insert(datas, {IsNullSlot = true})
    end
  end
  self.List1_1:InitGridView(datas)
end

function UMG_Having_PropertyOfEquipment_C:TitleInfoClear(_IsEnable)
  if _IsEnable then
    self.On:SetVisibility(UE4.ESlateVisibility.Visible)
    self.List:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.On:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.List:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.State:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Having_PropertyOfEquipment_C:GetAllBagData()
  local batItemList = {}
  self:GetGetBagItemArrayByType(batItemList, _G.ProtoEnum.BagItemType.BI_ITEM)
  self:GetGetBagItemArrayByType(batItemList, _G.ProtoEnum.BagItemType.BI_MATERIAL)
  self:GetGetBagItemArrayByType(batItemList, _G.ProtoEnum.BagItemType.BI_CARRYON)
  return batItemList
end

function UMG_Having_PropertyOfEquipment_C:GetDefIndex(datas)
  for i = 1, #datas do
    if datas[i].select == true then
      return i - 1
    end
  end
  return 0
end

function UMG_Having_PropertyOfEquipment_C:GetGetBagItemArrayByType(batItemList, itemtype)
  local maxquality = 100
  if self.uiData.pos > 1 then
    local conf = _G.DataConfigManager:GetPetGlobalConfig("pet_equip_limit_quality")
    maxquality = conf.num
  end
  local items = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, itemtype)
  for i = 1, #items do
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(items[i].id)
    if maxquality >= bagItemConf.item_quality then
      local CarryonConf = _G.DataConfigManager:GetPetCarryonItem(items[i].id, true)
      if self.FiIterQuality == nil then
        if nil ~= CarryonConf then
          self:FiIterBagItem(batItemList, items[i], bagItemConf, CarryonConf)
        end
      elseif nil ~= CarryonConf then
        local PetDataInfo = self.uiData.SelectHavingInfo.data
        if PetDataInfo.possessionItem.gid ~= items[i].gid and PetDataInfo.possessionItem.conf_id == items[i].id or self.FiIterQuality == items[i].id then
          self:FiIterBagItem(batItemList, items[i], bagItemConf, CarryonConf)
        end
      end
    end
  end
end

function UMG_Having_PropertyOfEquipment_C:FiIterBagItem(batItemList, items, bagItemConf, CarryonConf)
  local item = {}
  item.callbackCaller = self
  item.callbackFunc = self.OnSelectback
  items.conf_id = items.id
  item.bagItem = items
  item.bagItemConf = bagItemConf
  item.carrconf = CarryonConf
  item.FiIterQuality = self.FiIterQuality
  table.insert(batItemList, item)
end

function UMG_Having_PropertyOfEquipment_C:ItemSort(itemList)
  table.sort(itemList, function(a, b)
    if a.bagItemConf.item_quality == b.bagItemConf.item_quality then
      if a.carrconf and b.carrconf and a.carrconf.can_cost ~= b.carrconf.can_cost then
        return a.carrconf.can_cost < b.carrconf.can_cost
      end
      return a.bagItemConf.id < b.bagItemConf.id
    else
      return a.bagItemConf.item_quality > b.bagItemConf.item_quality
    end
  end)
  return itemList
end

function UMG_Having_PropertyOfEquipment_C:GetAllCarryonsInfo()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  if battlePetList then
    local maxquality = 100
    if self.uiData.pos > 1 then
      local conf = _G.DataConfigManager:GetPetGlobalConfig("pet_equip_limit_quality")
      maxquality = conf.num
    end
    local equipBagItemData = {}
    for i, petData in pairs(battlePetList.pet_data) do
      local num = #petData.possession.item
      if num > 0 then
        for j = 1, num do
          local possessItem = petData.possession.item[j]
          if possessItem.conf_id ~= nil and possessItem.conf_id > 0 then
            if nil == self.FiIterQuality then
              self:GetAllCarryons(possessItem, maxquality, petData, j, equipBagItemData)
            else
              local PetDataInfo = self.uiData.SelectHavingInfo.data
              local gidInfo
              if PetDataInfo.SelectDataPetData then
                gidInfo = PetDataInfo.SelectDataPetData.gid
              else
                gidInfo = PetDataInfo.petData.gid
              end
              if possessItem.conf_id == PetDataInfo.possessionItem.conf_id and petData.gid ~= gidInfo then
                self:GetAllCarryons(possessItem, maxquality, petData, j, equipBagItemData)
              end
            end
          end
        end
      end
    end
    return equipBagItemData
  end
end

function UMG_Having_PropertyOfEquipment_C:GetAllCarryons(possessItem, maxquality, petData, j, equipBagItemData)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(possessItem.conf_id)
  if maxquality >= bagItemConf.item_quality then
    local item = {}
    item.callbackCaller = self
    item.callbackFunc = self.OnSelectback
    item.petData = petData
    item.curPetData = self.uiData.petData
    item.pos = j
    local _bagItem = {}
    _bagItem.conf_id = possessItem.conf_id
    _bagItem.stage = possessItem.stage
    _bagItem.level = possessItem.level
    item.bagItem = _bagItem
    item.bagItemConf = bagItemConf
    item.FiIterQuality = self.FiIterQuality
    if self.uiData.petData.gid == petData.gid and self.uiData.pos == j then
      item.select = true
    end
    local CarryonConf = _G.DataConfigManager:GetPetCarryonItem(_bagItem.id, true)
    item.carrconf = CarryonConf
    table.insert(equipBagItemData, item)
  end
end

function UMG_Having_PropertyOfEquipment_C:SetSwich(flag)
  if true == flag then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1223, "UMG_HavingFitTogether_C:BtnSwichClick2")
    self.NRCSwitcher_p:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_p:SetActiveWidgetIndex(0)
  end
end

function UMG_Having_PropertyOfEquipment_C:SetSwich1(flag)
  if true == flag then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1223, "UMG_HavingFitTogether_C:BtnSwichClick2")
    self.NRCSwitcher_p_1:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_p_1:SetActiveWidgetIndex(0)
  end
end

function UMG_Having_PropertyOfEquipment_C:SetPropertyList()
  local data = self.uiData.selectData
  local List = {}
  local HavingProperty = PetUtils.GetHavingPropertyByPossession(data.bagItem)
  local HavingSkillProperty = PetUtils.GetHavingSkillPropertyByPossession(data.bagItem)
  if nil == HavingProperty then
    table.insert(List, HavingSkillProperty)
  else
    table.insert(HavingProperty, HavingSkillProperty)
    List = HavingProperty
  end
  self.List:InitGridView(List)
end

function UMG_Having_PropertyOfEquipment_C:OnBtnUseItemClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_HavingFitTogether_C:OnBtnUseItemClick")
  if self.uiData.selectData.petData then
    self:UseTips(self.OKCallBack, LuaText.Pet_Carryon_Change_Tips)
  else
    self:OnUse()
  end
end

function UMG_Having_PropertyOfEquipment_C:OnUse()
  local pos = self.uiData.pos - 1
  local bagItemConfGid = self.uiData.selectData.bagItem.gid
  local bagItemConfid = self.uiData.selectData.bagItem.id
  local removedPetGid, removedPos
  if self.uiData.selectData.petData then
    removedPetGid = self.uiData.selectData.petData.gid
    removedPos = self.uiData.selectData.pos - 1
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.EquipPossesion, self.uiData.petData.gid, bagItemConfGid, bagItemConfid, pos, removedPetGid, removedPos)
  self.uiData.Refresh = true
end

function UMG_Having_PropertyOfEquipment_C:UseTips(CallBack, TipsContent)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  Log.Debug("UMG_HavingFitTogether_C:UseTips")
  local dialogContext = DialogContext()
  dialogContext:SetContent(TipsContent):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetCallback(self, CallBack)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
end

function UMG_Having_PropertyOfEquipment_C:SetFiIterQuality(_data)
  self.FiIterQuality = _data
end

function UMG_Having_PropertyOfEquipment_C:OKCallBack(_ok)
  if _ok then
    self:OnUse()
  end
end

function UMG_Having_PropertyOfEquipment_C:OnBtnRemoveItemClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_HavingFitTogether_C:OnBtnRemoveItemClick")
  local pos = self.uiData.selectData.pos - 1
  NRCModuleManager:DoCmd(PetUIModuleCmd.RemovePossession, self.uiData.selectData.petData.gid, pos)
  self.uiData.Refresh = true
end

function UMG_Having_PropertyOfEquipment_C:OnClickDescend()
  local possessionItem = self.uiData.possessionItem
  if nil ~= possessionItem and nil ~= possessionItem.conf_id or self.FiIterQuality then
    if #self.OldSubPanelIndex > 0 then
      local PanelIndex = table.remove(self.OldSubPanelIndex, #self.OldSubPanelIndex)
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.uiData, PanelIndex, false, false)
    end
  else
    table.clear(self.OldSubPanelIndex)
    local IsEquipHavingAward = PetUtils.PetIsEquipmentHaving(self.uiData.petData)
    if false == IsEquipHavingAward then
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.uiData, 6, false, false)
    else
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.uiData, 1, false, false)
    end
  end
  self:SetFiIterQuality(nil)
end

function UMG_Having_PropertyOfEquipment_C:OnClickUpgradeBtn()
  local data = self.uiData
  local HavingInfo = {}
  HavingInfo.bagItemConf = data.selectData.bagItemConf
  HavingInfo.possessionItem = data.selectData.bagItem
  HavingInfo.pos = data.pos
  HavingInfo.petData = self.uiData.petData
  HavingInfo.SelectDataPetData = self.uiData.selectData.petData
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, HavingInfo, 2, true, true)
end

function UMG_Having_PropertyOfEquipment_C:SelectResonanceItem()
  if #self.OldSubPanelIndex > 0 then
    local selectData = self.uiData.selectData
    local TipsContent
    if selectData.bagItem.level and selectData.bagItem.level > 1 then
      TipsContent = LuaText.Pet_carryon_resonance_hasbeen_upgraded
      if selectData.petData then
        self:UseTips(self.RemoveAndSelectResonanceItem, TipsContent)
      else
        self:UseTips(self.ResonanceItem, TipsContent)
      end
    elseif selectData.petData then
      TipsContent = LuaText.Pet_Carryon_Change_Tips
      self:UseTips(self.RemoveAndSelectResonanceItem, TipsContent)
    elseif selectData.bagItem.stage and selectData.bagItem.stage > 1 then
      TipsContent = string.format(LuaText.Pet_carryon_resonance_hasbeen_resonanced, selectData.bagItem.stage)
      self:UseTips(self.ResonanceItem, TipsContent)
    else
      self:ResonanceItem(true)
    end
  end
end

function UMG_Having_PropertyOfEquipment_C:RemoveAndSelectResonanceItem(_ok)
  if _ok then
    self:OnBtnRemoveItemClick()
    self:DelaySeconds(0.1, function()
      self:ResonanceItem(_ok)
    end)
  end
end

function UMG_Having_PropertyOfEquipment_C:ResonanceItem(_ok)
  if _ok then
    self:SetFiIterQuality(nil)
    local PanelIndex = table.remove(self.OldSubPanelIndex, #self.OldSubPanelIndex)
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.uiData, PanelIndex, false, false, true)
  end
end

function UMG_Having_PropertyOfEquipment_C:OnClickBtnSwich()
  if self.hideEquip == true then
    self.hideEquip = false
  else
    self.hideEquip = true
    self:PlayAnimation(self.OpenYinc)
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.SetEquipProssession, self.hideEquip)
  self:UpdateHavingList2()
  self:SetSwich(self.hideEquip)
  self:SetSwich1(self.hideEquip)
end

function UMG_Having_PropertyOfEquipment_C:OnClickBtnSwich1()
  if self.hideEquip == true then
    self.hideEquip = false
  else
    self.hideEquip = true
    self:PlayAnimation(self.OpenYinc)
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.SetEquipProssession, self.hideEquip)
  self:UpdateHavingList2()
  self:SetSwich1(self.hideEquip)
  self:SetSwich(self.hideEquip)
end

function UMG_Having_PropertyOfEquipment_C:BtnInit()
  self.btnUseItem:SetBtnText(LuaText.umg_having_propertyofequipment_3)
  self.btnRemoveItem:SetBtnText(LuaText.umg_having_propertyofequipment_4)
  self.btnAssembly:SetBtnText(LuaText.umg_having_propertyofequipment_5)
  self.btnToUnload:SetBtnText(LuaText.umg_having_propertyofequipment_6)
  self.btnUpgrade:SetBtnText(LuaText.umg_having_propertyofequipment_7)
  self.btnOk:SetBtnText(LuaText.umg_having_propertyofequipment_8)
end

return UMG_Having_PropertyOfEquipment_C
