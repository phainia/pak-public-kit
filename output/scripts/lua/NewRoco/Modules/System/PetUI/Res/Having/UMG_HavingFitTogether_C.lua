local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_HavingFitTogether_C = _G.NRCViewBase:Extend("UMG_HavingFitTogether_C")

function UMG_HavingFitTogether_C:OnConstruct()
  self.bagItemGidTopet = {}
  self.hideEquip = NRCModuleManager:DoCmd(PetUIModuleCmd.GetEquipProssession)
  self:SetSwich(self.hideEquip)
  self:OnAddEventListener()
  self:BtnInit()
end

function UMG_HavingFitTogether_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_HavingFitTogether_C:OnDeactive()
end

function UMG_HavingFitTogether_C:OnActive(_param, ...)
end

function UMG_HavingFitTogether_C:SetPanelData(module, panelData)
  self.panelName = panelData.panelName
  self.panelData = panelData
  self.module = module
end

function UMG_HavingFitTogether_C:OnAddEventListener()
  self:AddButtonListener(self.QuestionMarkBtn, self.OnQuestionMarkBtnClick)
  self:AddButtonListener(self.backBtn.btnClose, self.Back)
  self:AddButtonListener(self.BtnSwich, self.BtnSwichClick)
  self:AddButtonListener(self.btnUseItem.btnLevelUp, self.OnBtnUseItemClick)
  self:AddButtonListener(self.btnRemoveItem.btnLevelUp, self.OnBtnRemoveItemClick)
  self:RegisterEvent(self, PetUIModuleEvent.PlayerDataUpdate, self.OnPlayerDataUpdate)
  self:RegisterEvent(self, PetUIModuleEvent.BagItemChange, self.OnBagInfoChange)
end

function UMG_HavingFitTogether_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, PetUIModuleEvent.PlayerDataUpdate)
  self:UnRegisterEvent(self, PetUIModuleEvent.BagItemChange)
end

function UMG_HavingFitTogether_C:OnQuestionMarkBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1060, "UMG_HavingFitTogether_C:OnQuestionMarkBtnClick")
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenSkillTips, {
    skillData = self.skillConf
  })
end

function UMG_HavingFitTogether_C:OnSelectback(select, selectData)
  if false == select then
    return
  end
  self.uiData.selectData = selectData
  if selectData.petData ~= nil and selectData.petData.gid == selectData.curPetData.gid then
    self.btnRemoveItem:SetVisibility(UE4.ESlateVisibility.Visible)
    self.btnUseItem:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.btnRemoveItem:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.btnUseItem:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self:UpdateTitleInfo()
end

function UMG_HavingFitTogether_C:OnBtnUseItemClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_HavingFitTogether_C:OnBtnUseItemClick")
  if self.uiData.selectData.petData then
    self:UseTips()
  else
    self:OnUse()
  end
end

function UMG_HavingFitTogether_C:OnUse()
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

function UMG_HavingFitTogether_C:OnBtnRemoveItemClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_HavingFitTogether_C:OnBtnRemoveItemClick")
  local pos = self.uiData.selectData.pos - 1
  NRCModuleManager:DoCmd(PetUIModuleCmd.RemovePossession, self.uiData.petData.gid, pos)
  self.uiData.Refresh = true
end

function UMG_HavingFitTogether_C:OKCallBack(_ok)
  if _ok then
    self:OnUse()
  end
end

function UMG_HavingFitTogether_C:UseTips()
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  Log.Debug("UMG_HavingFitTogether_C:UseTips")
  local dialogContext = DialogContext()
  dialogContext:SetContent(LuaText.Pet_Carryon_Change_Tips):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetCallback(self, self.OKCallBack)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
end

function UMG_HavingFitTogether_C:Back()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1007, "UMG_HavingFitTogether_C:Back")
  if self.uiData.callbackCaller and self.uiData.callbackFunc then
    tcall(self.uiData.callbackCaller, self.uiData.callbackFunc, 1)
  end
end

function UMG_HavingFitTogether_C:OnEquipPossesionSuccess(data)
end

function UMG_HavingFitTogether_C:UpdatePetInfo(data)
  self.uiData = data
  self:UIInfo()
end

function UMG_HavingFitTogether_C:OnBagInfoChange()
  if self.Visibility == UE4.ESlateVisibility.Visible then
    self:UIInfo()
  end
end

function UMG_HavingFitTogether_C:OnPlayerDataUpdate()
  if self.Visibility == UE4.ESlateVisibility.Visible then
    self:UIInfo()
  end
end

function UMG_HavingFitTogether_C:UIInfo()
  if 1 == self.uiData.pos then
    self.NRCText_all:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText_all_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.NRCText_all:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_all_1:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self:UpdatePetInfoList()
end

function UMG_HavingFitTogether_C:TitleInfoClear()
  self.NRCTextName:SetText("")
  self.DesTxt:SetText("")
  self.UMG_HavingItemTemplate:Clear()
  self.CanvasPanelUse:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.btnUseItem:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.btnRemoveItem:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_HavingFitTogether_C:UpdateTitleInfo()
  if self.uiData.selectData == nil then
    self:TitleInfoClear()
    return
  end
  local data = self.uiData.selectData.bagItem
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(data.conf_id)
  local bagItem = {}
  bagItem.conf_id = data.conf_id
  local titleData = {bagItem = bagItem}
  self.UMG_HavingItemTemplate:OnItemUpdate(titleData)
  self.NRCTextName:SetText(bagItemConf.name)
  local carrconf = _G.DataConfigManager:GetPetCarryonItem(data.conf_id)
  local str
  local haveSkill = false
  self.skillConf = nil
  for i = 1, #carrconf.carryon_effect do
    local item = carrconf.carryon_effect[i]
    if item.sequence_desc == _G.Enum.EquipEffectType.EET_ATTR then
      str = self:ShowInfoAttri(item)
    elseif item.sequence_desc == _G.Enum.EquipEffectType.EET_PASSIVE_SKILL then
      haveSkill = true
      local skillconf = self:ShowInfoSkill(item)
      local skillname = skillconf.name
      self.skillConf = skillconf
      if nil == str then
        str = LuaText.Pet_Carryon_GetSkill_Desc .. skillname
      else
        str = string.format("%s\239\188\140%s%s", str, LuaText.Pet_Carryon_GetSkill_DescEx, skillname)
      end
    end
  end
  self.DesTxt:SetText(str)
  if 1 == carrconf.can_cost then
    self.CanvasPanelUse:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.CanvasPanelUse:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if true == haveSkill then
    self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_HavingFitTogether_C:ShowInfoAttri(carryon_effect)
  if carryon_effect.sequence_desc == _G.Enum.EquipEffectType.EET_ATTR then
    local conf = self:GetAttriConf(carryon_effect.param1)
    if 1 == conf.is_percent_attr then
      local num = self:FormatNum(carryon_effect.param2 / 100)
      return string.format("%s+%s%s", conf.attribute_name, num, "%")
    else
      return string.format("%s+%s", conf.attribute_name, carryon_effect.param2)
    end
  end
  return nil
end

function UMG_HavingFitTogether_C:GetAttriConf(attriType)
  local attritable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ATTRIBUTE_CONF)
  local attriConfs = attritable:GetAllDatas()
  for i, conf in pairs(attriConfs) do
    local index = tonumber(conf.attribute)
    if index == attriType then
      return conf
    end
  end
end

function UMG_HavingFitTogether_C:ShowInfoSkill(carryon_effect)
  if carryon_effect.sequence_desc == _G.Enum.EquipEffectType.EET_PASSIVE_SKILL then
    local conf = _G.DataConfigManager:GetSkillConf(carryon_effect.param1)
    return conf
  end
end

function UMG_HavingFitTogether_C:FormatNum(num)
  if num <= 0 then
    return 0
  else
    local t1, t2 = math.modf(num)
    if t2 > 0 then
      return num
    else
      return t1
    end
  end
end

function UMG_HavingFitTogether_C:UpdatePetInfoList()
  local hideEquip = self.hideEquip
  self.uiData.selectData = nil
  local bagDatas = self:GetAllBagData()
  bagDatas = self:ItemSort(bagDatas)
  if false == hideEquip then
    local datas = self:GetAllCarryonsInfo()
    datas = self:ItemSort(datas)
    for i = 1, #bagDatas do
      table.insert(datas, bagDatas[i])
    end
    self:InitGridView(datas)
    local defIndex = self:GetDefIndex(datas)
    self.GridView1:SelectItemByIndex(defIndex)
  else
    self:InitGridView(bagDatas)
    self.GridView1:SelectItemByIndex(0)
  end
end

function UMG_HavingFitTogether_C:InitGridView(datas)
  self.GridView1:InitGridView(datas)
  if 0 == #datas then
    self:TitleInfoClear()
  end
end

function UMG_HavingFitTogether_C:GetDefIndex(datas)
  for i = 1, #datas do
    if datas[i].select == true then
      return i - 1
    end
  end
  return 0
end

function UMG_HavingFitTogether_C:ItemSort(itemList)
  table.sort(itemList, function(a, b)
    if a.bagItemConf.item_quality == b.bagItemConf.item_quality then
      if a.carrconf.can_cost ~= b.carrconf.can_cost then
        return a.carrconf.can_cost < b.carrconf.can_cost
      end
      return a.bagItemConf.id < b.bagItemConf.id
    else
      return a.bagItemConf.item_quality > b.bagItemConf.item_quality
    end
  end)
  return itemList
end

function UMG_HavingFitTogether_C:GetAllCarryonsInfo()
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
              _bagItem.id = possessItem.conf_id
              item.bagItem = _bagItem
              item.bagItemConf = bagItemConf
              if self.uiData.petgid == petData.gid and self.uiData.pos == j then
                item.select = true
              end
              local CarryonConf = _G.DataConfigManager:GetPetCarryonItem(_bagItem.id, true)
              item.carrconf = CarryonConf
              table.insert(equipBagItemData, item)
            end
          end
        end
      end
    end
    return equipBagItemData
  end
end

function UMG_HavingFitTogether_C:GetAllBagData()
  local batItemList = {}
  self:GetGetBagItemArrayByType(batItemList, _G.ProtoEnum.BagItemType.BI_ITEM)
  self:GetGetBagItemArrayByType(batItemList, _G.ProtoEnum.BagItemType.BI_MATERIAL)
  self:GetGetBagItemArrayByType(batItemList, _G.ProtoEnum.BagItemType.BI_CARRYON)
  return batItemList
end

function UMG_HavingFitTogether_C:GetGetBagItemArrayByType(batItemList, itemtype)
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
      if nil ~= CarryonConf then
        local item = {}
        item.callbackCaller = self
        item.callbackFunc = self.OnSelectback
        items[i].conf_id = items[i].id
        item.bagItem = items[i]
        item.bagItemConf = bagItemConf
        item.carrconf = CarryonConf
        table.insert(batItemList, item)
      end
    end
  end
end

function UMG_HavingFitTogether_C:BtnSwichClick()
  if self.hideEquip == true then
    self.hideEquip = false
  else
    self.hideEquip = true
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.SetEquipProssession, self.hideEquip)
  self:UpdatePetInfoList()
  self:SetSwich(self.hideEquip)
end

function UMG_HavingFitTogether_C:SetSwich(flag)
  if true == flag then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1223, "UMG_HavingFitTogether_C:BtnSwichClick2")
    self.NRCSwitcher_p:SetActiveWidgetIndex(1)
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_HavingFitTogether_C:BtnSwichClick1")
    self.NRCSwitcher_p:SetActiveWidgetIndex(0)
  end
end

function UMG_HavingFitTogether_C:BtnInit()
  self.btnUseItem:SetBtnText(LuaText.umg_havingfittogether_1)
  self.btnRemoveItem:SetBtnText(LuaText.umg_havingfittogether_2)
  self.btnUseItem:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/ui_combtn_shang_png.ui_combtn_shang_png'")
  self.btnRemoveItem:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/ui_combtn_xia_png.ui_combtn_xia_png'")
end

return UMG_HavingFitTogether_C
