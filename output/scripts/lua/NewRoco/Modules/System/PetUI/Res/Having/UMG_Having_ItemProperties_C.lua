local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Having_ItemProperties_C = _G.NRCViewBase:Extend("UMG_Having_ItemProperties_C")

function UMG_Having_ItemProperties_C:OnConstruct()
  self:SetBtnInfo()
  self:OnAddEventListener()
end

function UMG_Having_ItemProperties_C:OnDestruct()
end

function UMG_Having_ItemProperties_C:OnActive(_PanelInfo)
  local PanelInfo = _PanelInfo
  if PanelInfo.IsOpen == true then
    self.OldSubPanelIndex = PanelInfo.OldSubPanelIndex
  end
  self.ConsumeMoney = nil
  self:SetBasicInfo()
end

function UMG_Having_ItemProperties_C:OnHavingChange(_data)
  self.data = _data
end

function UMG_Having_ItemProperties_C:OnAddEventListener()
  self:AddButtonListener(self.Btn.btnLevelUp, self.OnClickUpgradeBtn)
  self:AddButtonListener(self.Btn_2.btnLevelUp, self.OnClickResonanceBtn)
  self:AddButtonListener(self.backBtn.btnClose, self.OnClickDescend)
  self:AddButtonListener(self.Btn_Details.btnLevelUp, self.OnClickResonanceBtn)
  self:RegisterEvent(self, PetUIModuleEvent.HavingUpgradeAndResonanceUpdateEvent, self.HavingUpgradeAndResonanceUpdate)
end

function UMG_Having_ItemProperties_C:HavingUpgradeAndResonanceUpdate(_res_carryon)
  local res_carryon = _res_carryon
  if self.data then
    self.data.possessionItem.conf_id = res_carryon.conf_id
    self.data.possessionItem.level = res_carryon.level
    self.data.possessionItem.stage = res_carryon.stage
  end
  self:SetBasicInfo()
end

function UMG_Having_ItemProperties_C:SetBasicInfo()
  local data = self.data
  if 0 == data.possessionItem.stage then
    self.Resonance:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.Resonance:SetVisibility(UE4.ESlateVisibility.Visible)
    local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("Pet_carryon_resonance_string")
    local Text = string.format("%s%s", LocalizationConf.msg, data.possessionItem.stage)
    self.Resonance:SetText(Text)
  end
  self.NameTxt:SetText(data.bagItemConf.name)
  local Text = string.format("%d%s", data.possessionItem.level, LuaText.umg_having_itemproperties_1)
  self.Name:SetText(Text)
  self:SetPropertyList()
  self:SetItemList()
end

function UMG_Having_ItemProperties_C:SetPropertyList()
  local List = {}
  local data = self.data
  local possessionItem = data.possessionItem
  local CurrentHavingProperty = PetUtils.GetHavingPropertyByPossession(possessionItem)
  local HavingSkillProperty = PetUtils.GetHavingSkillPropertyByPossession(possessionItem)
  local NewHavingProperty = PetUtils.GetHavingPropertyByPossession(possessionItem, 1)
  Log.Dump(possessionItem, 6, "UMG_Having_ItemProperties_C:SetPropertyList")
  if NewHavingProperty and #NewHavingProperty > 0 then
    table.insert(List, {
      name = LuaText.umg_having_itemproperties_2,
      CurrentLevel = possessionItem.level,
      NewLevel = possessionItem.level + 1,
      IsFullLevle = false
    })
    for _, v in ipairs(CurrentHavingProperty) do
      table.insert(List, {
        CurrentAttributeConf = v.AttributeConf,
        bagItemConf = v.bagItemConf,
        CurrentPetCarryonUpgrade = v.PetCarryonUpgrade,
        NewPetCarryonUpgrade = NewHavingProperty[_].PetCarryonUpgrade,
        IsFullLevle = false
      })
    end
    table.insert(List, HavingSkillProperty)
  else
    table.insert(List, {
      name = LuaText.umg_having_itemproperties_2,
      CurrentLevel = possessionItem.level,
      IsFullLevle = true
    })
    for _, v in ipairs(CurrentHavingProperty) do
      table.insert(List, {
        CurrentAttributeConf = v.AttributeConf,
        bagItemConf = v.bagItemConf,
        CurrentPetCarryonUpgrade = v.PetCarryonUpgrade,
        IsFullLevle = true
      })
    end
    table.insert(List, HavingSkillProperty)
  end
  self.List:InitGridView(List)
end

function UMG_Having_ItemProperties_C:SetItemList()
  local ItemList = {}
  local data = self.data
  local level = data.possessionItem.level + 1
  local PetCarryonItem = _G.DataConfigManager:GetPetCarryonItem(data.possessionItem.conf_id)
  local PetCarryonUpgrade = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_CARRYON_UPGRADE):GetAllDatas()
  for i, Upgrade in pairs(PetCarryonUpgrade) do
    if PetCarryonItem.upgrade_cost == Upgrade.sort_id and level == Upgrade.level then
      self.ConsumeMoney = Upgrade.cost_coin
      ItemList = Upgrade.upgrade_cost
    end
  end
  self.GridView1:Clear()
  if #ItemList > 0 then
    self.GridView1:InitGridView(ItemList)
    self.State:SetActiveWidgetIndex(0)
    self.Currency:SetText(self.ConsumeMoney)
    local IsCanUpgrade = self:SetUpgradeBtnState(ItemList)
    local curMoney = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
    if false == IsCanUpgrade or curMoney < self.ConsumeMoney then
      self.Btn:SetIsEnabled(false)
    else
      self.Btn:SetIsEnabled(true)
    end
  else
    self.State:SetActiveWidgetIndex(1)
  end
end

function UMG_Having_ItemProperties_C:OnClickResonanceBtn()
  local data = self.data
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, data, 5, true, false)
end

function UMG_Having_ItemProperties_C:OnClickDescend()
  if self.OldSubPanelIndex then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.data, self.OldSubPanelIndex, false, false)
  end
end

function UMG_Having_ItemProperties_C:OnClickUpgradeBtn()
  local data = self.data
  local PetIsEquipmentHaving
  if data.possessionItem.gid then
    PetIsEquipmentHaving = false
  else
    PetIsEquipmentHaving = true
  end
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.HavingUpgrade, data.petData.gid, data.pos - 1, PetIsEquipmentHaving, data.possessionItem.gid)
end

function UMG_Having_ItemProperties_C:SetUpgradeBtnState(_ItemList)
  local ItemList = _ItemList
  for _, Item in ipairs(ItemList) do
    local ItemCount = self:getItemCount(Item.cost_item)
    if ItemCount < Item.cost_num then
      return false
    end
  end
  return true
end

function UMG_Having_ItemProperties_C:getItemCount(_itemId)
  local itemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, _itemId)
  if itemData then
    return itemData.num or 0
  end
  return 0
end

function UMG_Having_ItemProperties_C:OnDeactive()
end

function UMG_Having_ItemProperties_C:SetBtnInfo()
  self.Btn:SetBtnText(LuaText.umg_having_itemproperties_3)
  self.Btn_2:SetBtnText(LuaText.umg_having_itemproperties_4)
  local Icon = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_gongming1_png.img_gongming1_png'"
  local Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_gongming3_png.img_gongming3_png'"
  local Icon_2 = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_gongming2_png.img_gongming2_png'"
  self.Btn_Details:SetPath(Icon, Icon_1, Icon_2)
end

return UMG_Having_ItemProperties_C
