local natureConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NATURE_CONF):GetAllDatas()
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_DetailsDifferencesList_C = Base:Extend("UMG_DetailsDifferencesList_C")

function UMG_DetailsDifferencesList_C:OnConstruct()
end

function UMG_DetailsDifferencesList_C:OnDestruct()
end

function UMG_DetailsDifferencesList_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data.UiData
  if #datalist == index then
    self.Line:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Line:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.HeadIcon:SetIconPathAndMaterial(_data.petData.base_conf_id, _data.petData.mutation_type, _data.petData.shine_color_id, _data.petData.glass_type)
  self.PetLevel:SetText(_data.petData.level)
  if _data.type == PetUIModuleEnum.PetTeamShareReviseType.Talent then
    self:SetNeedItemIcon(self.uiData.Items)
    self.Switcher:SetActiveWidgetIndex(1)
    self:SetNatureIcon(self.attributeIcon_5, self.uiData.ChangeType)
    if self.uiData.attribute then
      self.attributeIcon_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:SetNatureIcon(self.attributeIcon_4, self.uiData.attribute)
      local numText = "+" .. self.uiData.num
      self.NRCText_3:SetText(numText)
      self.NRCText_6:SetText(numText)
    elseif self.uiData.LevelNum then
      self.attributeIcon_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NRCText_3:SetText("-")
      local unlock_attribute_quantity = _G.DataConfigManager:GetPetGlobalConfig("unlock_attribute_quantity").num
      self.NRCText_6:SetText(string.format("+" .. (self.uiData.LevelNum + 1) * unlock_attribute_quantity))
    end
  elseif _data.type == PetUIModuleEnum.PetTeamShareReviseType.Nature then
    self:SetNeedItemIcon(self.uiData.Items)
    self.Switcher:SetActiveWidgetIndex(0)
    local CurName = self:GetRealNatureName(self.uiData.pos_effect, self.uiData.neg_effect) or self.uiData.natureName
    local shareName
    if 1 == self.uiData.UseType then
      self:SetNatureIcon(self.attributeIcon_2, self.uiData.pos_effect)
      self:SetNatureIcon(self.attributeIcon_3, self.uiData.share_neg_effect)
      shareName = self:GetRealNatureName(self.uiData.pos_effect, self.uiData.share_neg_effect) or self.uiData.natureName
    end
    if 2 == self.uiData.UseType then
      self:SetNatureIcon(self.attributeIcon_2, self.uiData.share_pos_effect)
      self:SetNatureIcon(self.attributeIcon_3, self.uiData.neg_effect)
      shareName = self:GetRealNatureName(self.uiData.share_pos_effect, self.uiData.neg_effect) or self.uiData.natureName
    end
    if 3 == self.uiData.UseType then
      self:SetNatureIcon(self.attributeIcon_2, self.uiData.share_pos_effect)
      self:SetNatureIcon(self.attributeIcon_3, self.uiData.share_neg_effect)
      shareName = self:GetRealNatureName(self.uiData.share_pos_effect, self.uiData.share_neg_effect) or self.uiData.natureName
    end
    self.NatureNameText:SetText(CurName)
    self.NatureNameText1:SetText(shareName)
    self:SetNatureIcon(self.attributeIcon, self.uiData.pos_effect)
    self:SetNatureIcon(self.attributeIcon_1, self.uiData.neg_effect)
  elseif _data.type == PetUIModuleEnum.PetTeamShareReviseType.Blood then
    self.Switcher:SetActiveWidgetIndex(2)
    local unitTable = {}
    local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(self.uiData.nowBloodID)
    table.insert(unitTable, {
      Name = PetBloodConf.blood_name,
      Path = PetBloodConf.icon
    })
    local PetBloodConf2 = _G.DataConfigManager:GetPetBloodConf(self.uiData.tarBloodID)
    table.insert(unitTable, {
      Name = PetBloodConf2.blood_name,
      Path = PetBloodConf2.icon
    })
    self.Common_Attr1:OnItemUpdate({
      Name = PetBloodConf.blood_name,
      Path = PetBloodConf.icon
    })
    self.Common_Attr2:OnItemUpdate({
      Name = PetBloodConf2.blood_name,
      Path = PetBloodConf2.icon
    })
    self:RefreshItemList(self.uiData.NeedItemList)
  elseif _data.type == PetUIModuleEnum.PetTeamShareReviseType.Skill then
    self.Switcher:SetActiveWidgetIndex(3)
    self.GridView_Skill:InitGridView(self.uiData.skillIDList)
    self:RefreshItemList(self.uiData.NeedItemList)
  end
end

function UMG_DetailsDifferencesList_C:RefreshItemList(itemDosageInfoList)
  if itemDosageInfoList then
    self.showItemList = itemDosageInfoList
    local showItemList = {}
    for i, v in ipairs(itemDosageInfoList) do
      local itemIconData = _G.NRCCommonItemIconData()
      itemIconData.itemType = v.itemType or _G.Enum.GoodsType.GT_BAGITEM
      itemIconData.itemId = v.itemId
      itemIconData.BagNum = v.itemNum
      itemIconData.itemNum = v.needNum
      itemIconData.bShowNum = true
      itemIconData.bShowTip = false
      table.insert(showItemList, itemIconData)
    end
    self.NRCGridView_114:InitGridView(showItemList)
  end
end

function UMG_DetailsDifferencesList_C:GetRealNatureName(Pos, Neg)
  local ChangedNatureName
  for i, v in ipairs(natureConf) do
    if v.positive_effect == Pos and v.negative_effect == Neg then
      ChangedNatureName = v.name
      break
    end
  end
  return ChangedNatureName
end

function UMG_DetailsDifferencesList_C:SetNatureIcon(icon, attributeCfg)
  if attributeCfg == Enum.AttributeType.AT_HPMAX_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_01_png.ui_pet_attribute_01_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_02_png.ui_pet_attribute_02_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_04_png.ui_pet_attribute_04_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_03_png.ui_pet_attribute_03_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_05_png.ui_pet_attribute_05_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_06_png.ui_pet_attribute_06_png'")
  end
end

function UMG_DetailsDifferencesList_C:SetNeedItemIcon(ItemList)
  local rewardsTable = {}
  for k, v in pairs(ItemList) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = _G.Enum.GoodsType.GT_BAGITEM
    rewards.itemId = v.itemId
    rewards.itemNum = v.num
    rewards.bShowNum = true
    rewards.bShowTip = false
    table.insert(rewardsTable, rewards)
  end
  self.NRCGridView_114:InitGridView(rewardsTable)
end

function UMG_DetailsDifferencesList_C:OnItemSelected(_bSelected)
end

function UMG_DetailsDifferencesList_C:OnDeactive()
end

return UMG_DetailsDifferencesList_C
