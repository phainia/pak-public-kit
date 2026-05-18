local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local natureConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NATURE_CONF):GetAllDatas()
local UMG_ModifyList_C = Base:Extend("UMG_ModifyList_C")

function UMG_ModifyList_C:OnConstruct()
end

function UMG_ModifyList_C:OnDestruct()
end

function UMG_ModifyList_C:OnItemUpdate(_data, datalist, index)
  self.UiData = _data
  self.index = index
  if _data.IsEmpty then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    if _data.openType == PetUIModuleEnum.PetTeamShareReviseType.Talent then
      self.Switcher1:SetActiveWidgetIndex(1)
      self:SetNatureIcon(self.attributeIcon_5, _data.ChangeType)
      self:SetNeedItemIcon()
      if _data.attribute then
        self.attributeIcon_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:SetNatureIcon(self.attributeIcon_4, _data.attribute)
        local numText = "+" .. _data.num
        self.NRCText_3:SetText(numText)
        self.NRCText_6:SetText(numText)
        local attribute = self:GetChangeAttrReqEnum(_data.attribute)
        local attrConf = _G.DataConfigManager:GetAttributeConf(attribute)
        self.Name:SetText(string.format(LuaText.lineup_code_change_individual_tips1, attrConf.attribute_name))
      elseif _data.LevelNum then
        self.attributeIcon_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.NRCText_3:SetText("-")
        local unlock_attribute_quantity = _G.DataConfigManager:GetPetGlobalConfig("unlock_attribute_quantity").num
        self.NRCText_6:SetText(string.format("+" .. (_data.LevelNum + 1) * unlock_attribute_quantity))
        self.Name:SetText(LuaText.lineup_code_create_new_individual)
      end
    end
    if _data.openType == PetUIModuleEnum.PetTeamShareReviseType.Nature then
      self.Switcher1:SetActiveWidgetIndex(0)
      local shareName = self:GetRealNatureName(self.UiData.share_pos_effect, self.UiData.share_neg_effect) or self.UiData.natureName
      local CurName = self:GetRealNatureName(self.UiData.pos_effect, self.UiData.neg_effect) or self.UiData.natureName
      self.NatureNameText:SetText(CurName)
      self.NatureNameText1:SetText(shareName)
      self.Name:SetText(self.UiData.text)
      self:SetNatureIcon(self.attributeIcon_2, self.UiData.share_pos_effect)
      self:SetNatureIcon(self.attributeIcon_3, self.UiData.share_neg_effect)
      self:SetNatureIcon(self.attributeIcon, self.UiData.pos_effect)
      self:SetNatureIcon(self.attributeIcon_1, self.UiData.neg_effect)
      self:SetNeedItemIcon()
    end
    if _data.openType == PetUIModuleEnum.PetTeamShareReviseType.Blood then
      self.Switcher1:SetActiveWidgetIndex(2)
      local unitTable = {}
      local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(self.UiData.nowBloodID)
      table.insert(unitTable, {
        Name = PetBloodConf.blood_name,
        Path = PetBloodConf.icon
      })
      local PetBloodConf2 = _G.DataConfigManager:GetPetBloodConf(self.UiData.tarBloodID)
      table.insert(unitTable, {
        Name = PetBloodConf2.blood_name,
        Path = PetBloodConf2.icon
      })
      self.Name:SetText(LuaText.lineup_code_change_blood)
      self.Common_Attr:InitGridView(unitTable)
      self:RefreshBloodItemList(self.UiData.NeedItemList)
    end
  end
end

function UMG_ModifyList_C:GetRealNatureName(Pos, Neg)
  local ChangedNatureName
  for i, v in ipairs(natureConf) do
    if v.positive_effect == Pos and v.negative_effect == Neg then
      ChangedNatureName = v.name
      break
    end
  end
  return ChangedNatureName
end

function UMG_ModifyList_C:GetChangeAttrReqEnum(attribute)
  if not attribute then
    return nil
  end
  if attribute == Enum.AttributeType.AT_HPMAX_PERCENT then
    return Enum.AttributeType.AT_HPMAX
  elseif attribute == Enum.AttributeType.AT_PHYATK_PERCENT then
    return Enum.AttributeType.AT_PHYATK
  elseif attribute == Enum.AttributeType.AT_SPEATK_PERCENT then
    return Enum.AttributeType.AT_SPEATK
  elseif attribute == Enum.AttributeType.AT_PHYDEF_PERCENT then
    return Enum.AttributeType.AT_PHYDEF
  elseif attribute == Enum.AttributeType.AT_SPEDEF_PERCENT then
    return Enum.AttributeType.AT_SPEDEF
  elseif attribute == Enum.AttributeType.AT_SPEED_PERCENT then
    return Enum.AttributeType.AT_SPEED
  end
end

function UMG_ModifyList_C:SetNatureIcon(icon, attributeCfg)
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

function UMG_ModifyList_C:SetNeedItemIcon()
  local IsEnough = true
  local rewardsTable = {}
  for k, v in ipairs(self.UiData.Items) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = _G.Enum.GoodsType.GT_BAGITEM
    rewards.itemId = v.itemId
    rewards.itemNum = v.num
    rewards.bShowNum = true
    rewards.checkIsEnough = true
    if v.num <= 0 then
      rewards.bShowNum = false
    end
    if not v.IsEnough then
      rewards.isSubNum = true
      self:SetClickable(false)
      IsEnough = false
    end
    rewards.bShowTip = false
    table.insert(rewardsTable, rewards)
  end
  if not IsEnough then
    local ItemSynthesisInfoList = self.UiData.ItemSynthesisInfoList
    if ItemSynthesisInfoList and ItemSynthesisInfoList[1] and (ItemSynthesisInfoList[1].remainExchangeTimes and ItemSynthesisInfoList[1].remainExchangeTimes > 0 or not ItemSynthesisInfoList[1].remainExchangeTimes) then
      rewardsTable = {}
      self:SetClickable(true)
      local costItems = ItemSynthesisInfoList[1].cost_item
      for k, v in ipairs(costItems) do
        local rewards = _G.NRCCommonItemIconData()
        rewards.itemType = v.cost_goods_type
        rewards.itemId = v.cost_goods_id[1]
        rewards.itemNum = v.cost_goods_num
        rewards.bShowNum = true
        rewards.checkIsEnough = true
        if v.cost_goods_type == Enum.GoodsType.GT_BAGITEM then
          local bagItem = NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, v.cost_goods_id[1])
          if bagItem then
            if bagItem.num < v.cost_goods_num then
              self:SetClickable(false)
            end
          else
            self:SetClickable(false)
          end
        elseif v.cost_goods_type == Enum.GoodsType.GT_VITEM then
          local num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(v.cost_goods_id[1])
          if nil == num then
            num = 0
          end
          if num < v.cost_goods_num then
            self:SetClickable(false)
          end
        end
        rewards.bShowTip = false
        table.insert(rewardsTable, rewards)
      end
    end
    self.NRCGridView_114:InitGridView(rewardsTable)
  else
    self.NRCGridView_114:InitGridView(rewardsTable)
  end
end

function UMG_ModifyList_C:RefreshBloodItemList(itemDosageInfoList)
  if itemDosageInfoList then
    self.showItemList = itemDosageInfoList
    local showItemList = {}
    for i, v in ipairs(itemDosageInfoList) do
      local itemIconData = _G.NRCCommonItemIconData()
      itemIconData.itemType = v.itemType or _G.Enum.GoodsType.GT_BAGITEM
      itemIconData.itemId = v.itemId
      itemIconData.BagNum = v.itemNum
      itemIconData.itemNum = v.needNum
      itemIconData.checkIsEnough = true
      itemIconData.bShowNum = true
      itemIconData.bShowTip = false
      table.insert(showItemList, itemIconData)
    end
    self.NRCGridView_114:InitGridView(showItemList)
  end
end

function UMG_ModifyList_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Select_in)
    if self.UiData.openType == PetUIModuleEnum.PetTeamShareReviseType.Talent then
      self.UiData.Panel:SetCurSelectTalentItem(self.UiData.attribute, self.UiData.IsEmpty)
    elseif self.UiData.openType == PetUIModuleEnum.PetTeamShareReviseType.Nature then
      local data = {
        share_pos_effect = self.UiData.share_pos_effect,
        share_neg_effect = self.UiData.share_neg_effect,
        pos_effect = self.UiData.pos_effect,
        neg_effect = self.UiData.neg_effect,
        UseType = self.UiData.UseType
      }
      self.UiData.Panel:SetCurSelectNatureItem(data, self.UiData.IsEmpty)
    elseif self.UiData.openType == PetUIModuleEnum.PetTeamShareReviseType.Blood then
      self.UiData.Panel:SelectBloodChangeIndex(self.index)
      for i = 1, self.Common_Attr:GetItemCount() do
        local item = self.Common_Attr:GetItemByIndex(i - 1)
        item:PlayAnimation(item.Select)
      end
    end
  else
    self:PlayAnimation(self.Select_out)
    if self.UiData.openType == PetUIModuleEnum.PetTeamShareReviseType.Blood then
      for i = 1, self.Common_Attr:GetItemCount() do
        local item = self.Common_Attr:GetItemByIndex(i - 1)
        item:PlayAnimation(item.Select_out)
      end
    end
  end
end

function UMG_ModifyList_C:OnTouchEnded(MyGeometry, InTouchEvent)
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(40007001, "UMG_ModifyList_C:OnItemSelected")
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_ModifyList_C:OnDeactive()
end

return UMG_ModifyList_C
