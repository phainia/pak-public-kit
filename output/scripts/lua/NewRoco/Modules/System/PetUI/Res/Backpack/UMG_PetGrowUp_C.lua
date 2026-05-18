local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_PetGrowUp_C = _G.NRCViewBase:Extend("UMG_PetGrowUp_C")
local EnumCantInspireReasonType = {
  None = 0,
  NotMaxLevel = 1,
  NotEnoughMoney = 2,
  NotEnoughItem = 3
}
local EnumPetGrowUpListItemStyleIndex = {
  Style1 = 0,
  Style2 = 1,
  Style3 = 2
}

function UMG_PetGrowUp_C:OnConstruct()
  self.uiData = {
    CatchHardLv = {},
    ItemList = {},
    PetPropertyInfo = {},
    needMoney = 0,
    ResidueGrowCount = 0
  }
  self.GrowUpType = PetUIModuleEnum.PetGrowUpType.None
  self.UMG_Btn:SetBtnText(LuaText.umg_petgrowup_1)
  self.UMG_Btn1:SetBtnText(LuaText.umg_petgrowup_1)
  self.UMG_Btn1:SetShowLockIcon(false)
  self:OnAddEventListener()
end

function UMG_PetGrowUp_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_Btn.btnLevelUp, self.OnbtnEvolutionClick)
  self:AddButtonListener(self.Character, self.OnClickCharacter)
  self:AddButtonListener(self.NRCButton_82, self.OnClickCharacter)
  self:AddButtonListener(self.btnClose.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.SubtractBtn.btnLevelUp, self.OnSubtractBtn)
  self:AddButtonListener(self.AddBtn.btnLevelUp, self.OnAddBtn)
  self:AddButtonListener(self.MaximumBtn.btnLevelUp, self.OnMaximumBtn)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_COMMON_TIP_CLOSE, self.OnEventCommonTipClose)
  self:RegisterEvent(self, PetUIModuleEvent.ResetIsInEvolution, self.OnEventResetIsInEvolution)
  self:RegisterEvent(self, PetUIModuleEvent.OnGrowUp, self.OnEvolution)
  self:RegisterEvent(self, PetUIModuleEvent.BagItemChange, self.OnBagItemChange)
  self.NRCButton_82.OnPressed:Add(self, self.OnPersonalityBtnPressed)
  self.NRCButton_82.OnReleased:Add(self, self.OnPersonalityBtnReleased)
end

function UMG_PetGrowUp_C:OnDestruct()
end

function UMG_PetGrowUp_C:OnActive()
  self.IsInEvolution = false
end

function UMG_PetGrowUp_C:OnDeactive()
end

function UMG_PetGrowUp_C:OnPanelStateChange(_isShow, bPlayAnim)
  Log.Debug("UMG_PetLevelUp_C:OnSubPanelStateChange:", _isShow)
  self:UpdateGrowUpType()
  self:StopAllAnimations()
  if _isShow then
    if self.uiData and self.uiData.petData then
      self.DetailsSwitcher:SetActiveWidgetIndex(0)
      self:InitializeData()
      if not bPlayAnim and not self:IsAnimationPlaying(self.Change) then
        self:PlayAnimation(self.Change, 0, 1, 0, 1.5)
      else
        self:IsPlayAnima()
      end
      self:UpdatePanelInfo()
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ShowRightPanelShareBtn, false)
    else
      self:SetEmpty()
    end
  else
    self:DispatchEvent(PetUIModuleEvent.CloseGrowUpSwitchCloseBtn)
    self:PlayAnimation(self.Out)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ShowRightPanelShareBtn, true)
  end
end

function UMG_PetGrowUp_C:SetEmpty()
  self.DetailsSwitcher:SetActiveWidgetIndex(1)
  self.NRCText_Empty:SetText(LuaText.Select_Null_Pet_Detail)
end

function UMG_PetGrowUp_C:IsPlayAnima()
  self.Index = self.Switcher:GetActiveWidgetIndex()
end

function UMG_PetGrowUp_C:updatePetInfo(_data, _petBaseConf)
  self.uiData = _data
  if _data then
    self.uiData.CatchHardLv = {}
    self.uiData.having = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/pet_evo_icon_having_png.pet_evo_icon_having_png'"
    self.uiData.petBaseConf = _petBaseConf
  else
  end
end

function UMG_PetGrowUp_C:InitializeData()
  self.uiData.needMoney = 0
  self.uiData.ItemList = {}
  self.uiData.PetPropertyInfo = {}
  self.Index = nil
  self.IsGrowUp = true
  self.uiData.Property = {}
  self.uiData.ResidueGrowCount = 0
end

function UMG_PetGrowUp_C:UpdatePanelInfo()
  self:SetPanelBaseInfo()
  self:updatePetNature(self.uiData.petData.nature)
  self:UpdateCurMoney()
  self:SetStarsList()
end

function UMG_PetGrowUp_C:SetPanelBaseInfo()
  if self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToGrowUp then
    if self.Index and 0 == self.Index then
      self:PlayAnimation(self.Change)
    end
    self.IsGrowUp = true
    self.Switcher:SetActiveWidgetIndex(1)
    self.UMG_Btn:SetBtnText(LuaText.umg_petgrowup_1)
    self.UMG_Btn1:SetBtnText(LuaText.umg_petgrowup_1)
  elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToBreakThrough then
    if self.Index and 1 == self.Index then
      self:PlayAnimation(self.Change)
    end
    self.IsGrowUp = false
    self.Switcher:SetActiveWidgetIndex(0)
    self.UMG_Btn:SetBtnText(LuaText.umg_petgrowup_1)
    self.UMG_Btn1:SetBtnText(LuaText.umg_petgrowup_1)
  elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    if self.Index and 1 == self.Index then
      self:PlayAnimation(self.Change)
    end
    self.IsGrowUp = false
    self.Switcher:SetActiveWidgetIndex(2)
    self.UMG_Btn:SetBtnText(LuaText.inspire_text_6)
    self.UMG_Btn1:SetBtnText(LuaText.inspire_text_6)
    self.BtnRechristen_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:UpdatePetTypeIcon()
    self:SetInspirePropertyListInfo()
  end
  self.CurGrowTitle:SetText(LuaText.pet_effort_desc_4)
  self.CurGrowLevel:SetText(self.uiData.petData.grow_times or 0)
  self.AddLevelTitle:SetText(LuaText.pet_effort_desc_5)
  self.Quantity:SetText(1)
  self:SetListIconInfo(tonumber(self.Quantity:GetText()) or 1)
  self:UpdateBtnInfo(self:GetGrowCount())
end

function UMG_PetGrowUp_C:UpdatePetTypeIcon()
  if self.uiData and self.uiData.petData and self.uiData.petData.base_conf_id then
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.petData.base_conf_id)
    if PetBaseConf then
      local UnitType = PetBaseConf.unit_type
      local TypeList = {}
      for i, Type in ipairs(UnitType or {}) do
        table.insert(TypeList, Type)
      end
      self.Attr1:InitGridView(TypeList)
    end
  end
end

function UMG_PetGrowUp_C:UpdateGrowUpType()
  if not self.uiData then
    Log.Error("UMG_PetGrowUp_C:UpdateGrowUpType self.uiData == nil")
    return
  end
  if not self.uiData.petData then
    Log.Error("UMG_PetGrowUp_C:UpdateGrowUpType self.uiData.petData == nil")
    return
  end
  self.GrowUpType = PetUtils.GetPetGrowUpType(self.uiData.petData)
end

function UMG_PetGrowUp_C:updatePetNature(_nature)
  if not self.uiData.petData then
    Log.Error("self.uiData.petData == nil")
    return
  end
  local petNatureConf = _G.DataConfigManager:GetNatureConf(_nature)
  if petNatureConf then
    self.textPetNature:SetText(petNatureConf.name or "")
  end
  if 0 ~= self.uiData.petData.changed_nature_neg_attr_type or 0 ~= self.uiData.petData.changed_nature_pos_attr_type then
    self.NRCImage_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_lailang_png.img_lailang_png'")
  else
    self.NRCImage_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_character_png.img_character_png'")
  end
end

function UMG_PetGrowUp_C:OnBagItemChange()
  if self.Visibility == UE4.ESlateVisibility.Visible then
    self:SetListIconInfo(tonumber(self.Quantity:GetText()) or 1)
  end
end

function UMG_PetGrowUp_C:OnClickCharacter()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetBaseInfo_C:OnBtnBtnRechristenClick")
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.OpendblockerTips, self.uiData, TipEnum.OpenPetTipsType.PetMainPanel)
end

function UMG_PetGrowUp_C:OnPersonalityBtnPressed()
  self:StopAnimation(self.Btn_Press)
  self:StopAnimation(self.Btn_Up)
  self:PlayAnimation(self.Btn_Press)
end

function UMG_PetGrowUp_C:OnPersonalityBtnReleased()
  self:StopAnimation(self.Btn_Press)
  self:StopAnimation(self.Btn_Up)
  self:PlayAnimation(self.Btn_Up)
end

function UMG_PetGrowUp_C:OnEventCommonTipClose()
  if self.uiData then
    if not self.uiData.ItemList then
      local petData = self.uiData.petData
      self.uiData.ItemList = PetUtils.GetPetGrowNeedItems(petData)
    end
    self.ListIcon:InitGridView(self.uiData.ItemList)
  end
end

function UMG_PetGrowUp_C:OnEventResetIsInEvolution()
  self.IsInEvolution = false
end

function UMG_PetGrowUp_C:SetProPertyListInfo()
  if not self.uiData.petData then
    Log.Error("self.uiData.petData == nil")
    return
  end
  local petData = self.uiData.petData
  local petNatureConf = _G.DataConfigManager:GetNatureConf(petData.nature)
  local ResidueGrowCount, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.uiData.petData)
  local PetBeforeProperty = (petNatureConf.positive_effect_proportion + petNatureConf.positive_effect_grow * (GrowOrder - 1)) // 100
  local PetLaterProperty = (petNatureConf.positive_effect_proportion + petNatureConf.positive_effect_grow * GrowOrder) // 100
  local PetProperty = {}
  local positive_effect
  if petData.changed_nature_pos_attr_type and 0 ~= petData.changed_nature_pos_attr_type then
    positive_effect = self:GetChangeAttrReqEnum(petData.changed_nature_pos_attr_type)
  else
    positive_effect = petNatureConf.positive_effect
  end
  local SpecialSkillIndex = self:GetSpecialSkillIndex(positive_effect)
  local PetAddAttribute = _G.DataConfigManager:GetAttributeConf(SpecialSkillIndex)
  if not PetAddAttribute then
    Log.Error("AttributeConf \230\156\137\233\151\174\233\162\152 id\228\184\186%d", SpecialSkillIndex)
    return
  end
  if 1 == PetAddAttribute.is_percent_attr then
    PetBeforeProperty = string.format("%d%s", PetBeforeProperty, "%")
    PetLaterProperty = string.format("%d%s", PetLaterProperty, "%")
  else
  end
  self.NRC_NoChange_2:SetText(PetAddAttribute.attribute_name)
  self.NRC_NoChange:SetText(PetBeforeProperty)
  self.NRC_Change:SetText(PetLaterProperty)
  self.NRCIcon:SetPath(PetAddAttribute.attribute_icon)
  self.uiData.Property.attribute_name = PetAddAttribute.attribute_name
  self.uiData.Property.attribute_icon = PetAddAttribute.attribute_icon
  self.uiData.Property.PetBeforeProperty = PetBeforeProperty
  self.uiData.Property.PetLaterProperty = PetLaterProperty
  local attribute_info = petData.attribute_info
  Log.Dump(attribute_info, 6, "UMG_PetGrowUp_C:SetProPertyListInfo")
  if 0 ~= attribute_info.hp.talent then
    PetAddAttribute = _G.DataConfigManager:GetAttributeConf(Enum.AttributeType.AT_HPMAX)
    table.insert(PetProperty, {
      PetAddAttribute = PetAddAttribute,
      name = LuaText.umg_petgrowup_3,
      PetBeforeProperty = attribute_info.hp.talent,
      PetLaterProperty = attribute_info.hp.talent + (attribute_info.hp.talent_add_value or 0),
      IsShow = false,
      type = Enum.AttributeType.AT_HPMAX,
      IsShowAddIcon = true
    })
  end
  if 0 ~= attribute_info.attack.talent then
    PetAddAttribute = _G.DataConfigManager:GetAttributeConf(Enum.AttributeType.AT_PHYATK)
    table.insert(PetProperty, {
      PetAddAttribute = PetAddAttribute,
      name = LuaText.umg_petgrowup_4,
      PetBeforeProperty = attribute_info.attack.talent,
      PetLaterProperty = attribute_info.attack.talent + (attribute_info.attack.talent_add_value or 0),
      IsShow = false,
      type = Enum.AttributeType.AT_PHYATK,
      IsShowAddIcon = true
    })
  end
  if 0 ~= attribute_info.special_attack.talent then
    PetAddAttribute = _G.DataConfigManager:GetAttributeConf(Enum.AttributeType.AT_SPEATK)
    table.insert(PetProperty, {
      PetAddAttribute = PetAddAttribute,
      name = LuaText.umg_petgrowup_5,
      PetBeforeProperty = attribute_info.special_attack.talent,
      PetLaterProperty = attribute_info.special_attack.talent + (attribute_info.special_attack.talent_add_value or 0),
      IsShow = false,
      type = Enum.AttributeType.AT_SPEATK,
      IsShowAddIcon = true
    })
  end
  if 0 ~= attribute_info.defense.talent then
    PetAddAttribute = _G.DataConfigManager:GetAttributeConf(Enum.AttributeType.AT_PHYDEF)
    table.insert(PetProperty, {
      PetAddAttribute = PetAddAttribute,
      name = LuaText.umg_petgrowup_6,
      PetBeforeProperty = attribute_info.defense.talent,
      PetLaterProperty = attribute_info.defense.talent + (attribute_info.defense.talent_add_value or 0),
      IsShow = false,
      type = Enum.AttributeType.AT_PHYDEF,
      IsShowAddIcon = true
    })
  end
  if 0 ~= attribute_info.special_defense.talent then
    PetAddAttribute = _G.DataConfigManager:GetAttributeConf(Enum.AttributeType.AT_SPEDEF)
    table.insert(PetProperty, {
      PetAddAttribute = PetAddAttribute,
      name = LuaText.umg_petgrowup_7,
      PetBeforeProperty = attribute_info.special_defense.talent,
      PetLaterProperty = attribute_info.special_defense.talent + (attribute_info.special_defense.talent_add_value or 0),
      IsShow = false,
      type = Enum.AttributeType.AT_SPEDEF,
      IsShowAddIcon = true
    })
  end
  if 0 ~= attribute_info.speed.talent then
    PetAddAttribute = _G.DataConfigManager:GetAttributeConf(Enum.AttributeType.AT_SPEED)
    table.insert(PetProperty, {
      PetAddAttribute = PetAddAttribute,
      name = LuaText.umg_petgrowup_8,
      PetBeforeProperty = attribute_info.speed.talent,
      PetLaterProperty = attribute_info.speed.talent + (attribute_info.speed.talent_add_value or 0),
      IsShow = false,
      type = Enum.AttributeType.AT_SPEED,
      IsShowAddIcon = true
    })
  end
  self.uiData.PetPropertyInfo = PetProperty
end

function UMG_PetGrowUp_C:GetChangeAttrReqEnum(attribute)
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

function UMG_PetGrowUp_C:SetClass(_PetProperty)
  local IndividualCount = #_PetProperty
  local Text
  if IndividualCount then
    Text = string.format(LuaText.umg_petgrowup_10, IndividualCount)
  end
  if Text then
    self.Individual_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text:SetText(Text)
  else
    self.Individual_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetGrowUp_C:SetListIconInfo(ChangeNum)
  if self.uiData == nil then
    Log.Error("UMG_PetGrowUp_C:SetListIconInfo self.uiData == nil")
    return
  end
  if nil == self.uiData.petData then
    Log.Error("UMG_PetGrowUp_C:SetListIconInfo self.uiData.petData == nil")
    return
  end
  local LevelIsEnoug = false
  local petData = self.uiData.petData
  self.uiData.ItemList = {}
  self.uiData.needMoney = 0
  if self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToGrowUp then
    local GrowUpCount = tonumber(self.Quantity:GetText())
    local grow_times = petData.grow_times or 0
    if grow_times then
      for i = 1, GrowUpCount do
        local GrowLevelConf = _G.DataConfigManager:GetGrowLevelConf(grow_times + i)
        self:SetGrowItemList(GrowLevelConf)
        self:SetGrowPropertyList(GrowLevelConf)
      end
    end
    self.NRCSwitcher_46:SetActiveWidgetIndex(0)
    self:UpdateMoneyInfo(self.uiData.needMoney)
    local GrowCount = (self.uiData.petData and self.uiData.petData.grow_times or 0) + ChangeNum
    LevelIsEnoug = self:LevelIsEnough(GrowCount)
    self.ListIcon_1:InitGridView(self.uiData.ItemList)
    self.List_1:InitGridView(self.uiData.PetPropertyInfo)
  elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToBreakThrough then
    local ResidueGrowCount, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(petData)
    local BreakNumberAllConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BREAK_NUMBER_CONF):GetAllDatas()
    if GrowOrder >= 1 and GrowOrder <= #BreakNumberAllConf then
      local BreakNumberConf = _G.DataConfigManager:GetBreakNumberConf(GrowOrder)
      self.uiData.needMoney = BreakNumberConf.currency_number
      self:UpdateMoneyInfo(self.uiData.needMoney)
      if petData.level < BreakNumberConf.require_level then
        self.NRCSwitcher_46:SetActiveWidgetIndex(1)
        local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("umg_petgrow_4")
        local Text = string.format(LocalizationConf.msg, BreakNumberConf.require_level)
        self.UMG_Btn1:SetTitleTextAndIcon(nil, nil, nil, nil, Text)
        self.UMG_Btn1:SetClickAble(false)
        self.UMG_Btn1:SetTitleTextColor("c7494a")
      else
        self.NRCSwitcher_46:SetActiveWidgetIndex(0)
      end
      self:SetProPertyListInfo()
      self.uiData.ItemList = PetUtils.GetPetGrowNeedItems(petData)
      self.ListIcon:InitGridView(self.uiData.ItemList)
      self.List:InitGridView(self.uiData.PetPropertyInfo)
    end
  elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    self.uiData.ItemList, self.uiData.needMoney = PetUtils.GetPetInspireNeedItems(petData)
    self:UpdateMoneyInfo(self.uiData.needMoney)
    self.ListIcon_2:InitGridView(self.uiData.ItemList)
    self:UpdateInspireBtn()
  end
  local IsExChangeEnough, ExChangeCount, NeedExChangeCount, DiffItem = self:ExChangeMaterialsIsEnough()
  local ExChangeItemName = _G.DataConfigManager:GetBagItemConf(_G.DataConfigManager:GetPetGlobalConfig("universal_growth_material").num).name
  local pos = self.UMG_Btn.Slot:GetPosition()
  local size = self.UMG_Btn.Slot:GetSize()
  if IsExChangeEnough and NeedExChangeCount > 0 then
    self.NeedOpenExChange = true
    self.DiffItem = DiffItem
    self.NeedExChangeCount = NeedExChangeCount
    pos.x = 313
    pos.y = 8
    size.x = 394
    size.y = 76
    self.UMG_Btn:SetBtnText("<span color=\"#d56c1fff\">\231\162\142\230\153\182</>\232\161\165\229\133\168")
    self:SetBtnState(true)
  else
    pos.x = 374
    pos.y = 8
    size.x = 273
    size.y = 76
    self.DiffItem = {}
    self.NeedExChangeCount = 0
    self.NeedOpenExChange = false
  end
  self:SetBtnState(true)
  if self:materialsIsEnough() and self:moneyIsEnough() and LevelIsEnoug then
    self:SetBtnState(true)
  elseif not (false ~= self:materialsIsEnough() or self.NeedOpenExChange) or not self:moneyIsEnough() then
    self:SetBtnState(false)
  end
end

function UMG_PetGrowUp_C:SetGrowItemList(GrowLevelConf)
  for j, require_item in ipairs(GrowLevelConf.require_item) do
    if require_item.Type == Enum.GoodsType.GT_BAGITEM then
      local IsHasItem = false
      for k, Item in ipairs(self.uiData.ItemList) do
        if require_item.require_item_id == Item.itemId then
          Item.itemNum = Item.itemNum + require_item.require_item_count
          IsHasItem = true
        end
      end
      if not IsHasItem then
        local rewards = _G.NRCCommonItemIconData()
        rewards.itemType = require_item.Type
        rewards.itemId = require_item.require_item_id
        rewards.itemNum = require_item.require_item_count
        rewards.BagNum = PetUtils.getItemCount(require_item.require_item_id)
        rewards.bShowNum = true
        rewards.bShowTip = true
        table.insert(self.uiData.ItemList, rewards)
      end
    elseif require_item.Type == Enum.GoodsType.GT_VITEM then
      self.uiData.needMoney = self.uiData.needMoney + require_item.require_item_count
    end
  end
end

function UMG_PetGrowUp_C:SetGrowPropertyList(GrowLevelConf)
  local petData = self.uiData.petData
  local PetProperty = {}
  for i, attr in ipairs(GrowLevelConf.attr) do
    local IsHasProperty = false
    for j, Property in ipairs(PetProperty) do
      if Property.type == attr.attr_type then
        IsHasProperty = true
        Property.PetLaterProperty = attr.attr_data
      end
    end
    if not IsHasProperty then
      local PetAddAttribute = _G.DataConfigManager:GetAttributeConf(attr.attr_type)
      local PetBeforeProperty = 0
      if attr.attr_type == Enum.AttributeType.AT_HPMAX then
        PetBeforeProperty = petData.attribute_info.hp.effort_add
      elseif attr.attr_type == Enum.AttributeType.AT_PHYATK then
        PetBeforeProperty = petData.attribute_info.attack.effort_add
      elseif attr.attr_type == Enum.AttributeType.AT_SPEATK then
        PetBeforeProperty = petData.attribute_info.special_attack.effort_add
      elseif attr.attr_type == Enum.AttributeType.AT_PHYDEF then
        PetBeforeProperty = petData.attribute_info.defense.effort_add
      elseif attr.attr_type == Enum.AttributeType.AT_SPEDEF then
        PetBeforeProperty = petData.attribute_info.special_defense.effort_add
      elseif attr.attr_type == Enum.AttributeType.AT_SPEED then
        PetBeforeProperty = petData.attribute_info.speed.effort_add
      end
      table.insert(PetProperty, {
        PetAddAttribute = PetAddAttribute,
        name = string.format(LuaText.petutils_8, attr.attr_name),
        PetBeforeProperty = PetBeforeProperty,
        PetLaterProperty = attr.attr_data,
        IsShow = false,
        type = attr.attr_type,
        IsShowAddIcon = false
      })
    end
  end
  self.uiData.PetPropertyInfo = PetProperty
end

function UMG_PetGrowUp_C:SetInspirePropertyListInfo()
  if self.uiData and self.uiData.petData then
    self.ListIcon_2:Clear()
    local PetData = self.uiData.petData
    local InspireLevelAllConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.INSPIRE_LEVEL_CONF):GetAllDatas()
    local CurInspireLevel = 0
    if PetData.inspire_lv then
      CurInspireLevel = PetData.inspire_lv
    end
    local NextInspireLevel = CurInspireLevel + 1
    if NextInspireLevel > #InspireLevelAllConf then
      return
    end
    local InspirePropertyList = {}
    local PetProperty = {}
    local CurInspireLevelConf = InspireLevelAllConf[CurInspireLevel]
    local CurGrowLevel = 0
    if nil == CurInspireLevelConf then
      CurInspireLevelConf = {
        growLevel = CurGrowLevel,
        type_enhance_add = 0,
        attr = {
          [1] = {
            attr_type = _G.Enum.AttributeType.AT_TYPE_SHARPEN,
            attr_data = 0
          },
          [2] = {
            attr_type = _G.Enum.AttributeType.AT_TYPE_BLUNT,
            attr_data = 0
          }
        }
      }
    end
    local NextInspireLevelConf = InspireLevelAllConf[NextInspireLevel]
    if nil == CurInspireLevelConf or nil == NextInspireLevelConf then
      return
    end
    local PetBaseConf = DataConfigManager:GetPetbaseConf(PetData.base_conf_id)
    if PetBaseConf then
      local UnitType = PetBaseConf.unit_type
      local TypeNum = #UnitType
      local Add = NextInspireLevelConf.type_enhance_data[TypeNum]
      for i, Type in pairs(UnitType or {}) do
        local TypeDamageUpText = ""
        if Type then
          local TypeDic = _G.DataConfigManager:GetTypeDictionary(Type)
          if TypeDic then
            TypeDamageUpText = string.format(LuaText.inspire_text_2, TypeDic.short_name)
            local PetAddAttributeType = PetUtils.GetEnhanceAttributeTypeByUnitType(Type)
            local PetBeforeProperty = PetUtils.GetAttributeValueByAttributeType(PetData, PetAddAttributeType)
            local PetLaterProperty = PetBeforeProperty + Add
            local PetAddAttributeConf = _G.DataConfigManager:GetAttributeConf(PetAddAttributeType)
            PetProperty = self:CreatePetInspirePropertyItem(EnumPetGrowUpListItemStyleIndex.Style3, TypeDamageUpText, PetAddAttributeConf, math.modf(PetBeforeProperty / 100), math.modf(PetLaterProperty / 100), true, false, false, false, false)
            table.insert(InspirePropertyList, PetProperty)
          end
        end
      end
    end
    local TypePolarizationText = LuaText.inspire_text_3
    local PetAddAttributeConf = _G.DataConfigManager:GetAttributeConf(NextInspireLevelConf.attr[1].attr_type)
    local BeforeValue = 0
    if CurInspireLevelConf.attr[1].attr_data and 0 ~= CurInspireLevelConf.attr[1].attr_data then
      BeforeValue = CurInspireLevelConf.attr[1].attr_data / 100
      BeforeValue = math.modf(BeforeValue)
    end
    local LaterValue = 0
    if NextInspireLevelConf.attr[1].attr_data and 0 ~= NextInspireLevelConf.attr[1].attr_data then
      LaterValue = NextInspireLevelConf.attr[1].attr_data / 100
      LaterValue = math.modf(LaterValue)
    end
    PetProperty = self:CreatePetInspirePropertyItem(EnumPetGrowUpListItemStyleIndex.Style3, TypePolarizationText, PetAddAttributeConf, BeforeValue, LaterValue, true, false, true, false, false)
    table.insert(InspirePropertyList, PetProperty)
    local TypePassivationText = LuaText.inspire_text_4
    PetAddAttributeConf = _G.DataConfigManager:GetAttributeConf(NextInspireLevelConf.attr[2].attr_type)
    BeforeValue = 0
    if CurInspireLevelConf.attr[2].attr_data and 0 ~= CurInspireLevelConf.attr[2].attr_data then
      BeforeValue = CurInspireLevelConf.attr[2].attr_data / 100
      BeforeValue = math.modf(BeforeValue)
    end
    LaterValue = 0
    if NextInspireLevelConf.attr[2].attr_data and 0 ~= NextInspireLevelConf.attr[2].attr_data then
      LaterValue = NextInspireLevelConf.attr[2].attr_data / 100
      LaterValue = math.modf(LaterValue)
    end
    PetProperty = self:CreatePetInspirePropertyItem(EnumPetGrowUpListItemStyleIndex.Style3, TypePassivationText, PetAddAttributeConf, BeforeValue, LaterValue, true, false, true, false, false)
    table.insert(InspirePropertyList, PetProperty)
    if nil ~= NextInspireLevelConf.grow_level and 0 ~= NextInspireLevelConf.grow_level then
      local EffortLevelText = LuaText.inspire_text_5
      PetProperty = self:CreatePetInspirePropertyItem(EnumPetGrowUpListItemStyleIndex.Style3, EffortLevelText, nil, PetData.grow_times, NextInspireLevelConf.grow_level, true, false, true, false, true)
      table.insert(InspirePropertyList, PetProperty)
    end
    self.List_2:InitGridView(InspirePropertyList)
    self.uiData.PetPropertyInfo = InspirePropertyList
  end
end

function UMG_PetGrowUp_C:CreatePetInspirePropertyItem(StyleIndex, Name, PetAddAttribute, PetBeforeProperty, PetLaterProperty, IsShow, IsShowJiahao, IsShowWenhao, IsShowUp, IsEffortLevel)
  local PetPropertyItem = {
    StyleIndex = StyleIndex or EnumPetGrowUpListItemStyleIndex.Style3,
    name = Name,
    PetAddAttribute = PetAddAttribute,
    PetBeforeProperty = PetBeforeProperty,
    PetLaterProperty = PetLaterProperty,
    IsShow = IsShow,
    IsShowAddIcon = IsShowJiahao,
    IsShowWenhao = IsShowWenhao,
    IsShowUp = IsShowUp,
    IsEffortLevel = IsEffortLevel or false
  }
  return PetPropertyItem
end

function UMG_PetGrowUp_C:OnbtnEvolutionClick()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET_GROW, true)
  if isBan then
    return
  end
  if not self.uiData.petData then
    Log.Error("self.uiData.petData == nil")
    return
  end
  if self.IsInEvolution then
    return
  else
    self.IsInEvolution = true
    local MaterialsIsEnough = self:materialsIsEnough()
    if false == MaterialsIsEnough and not self.NeedOpenExChange then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401015, "UMG_PetBaseInfo_C:OnBtnLevelUpClick")
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petgrowup_11)
      self.IsInEvolution = false
      return
    end
    local curMoney = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
    local GrouUpNeedMoney = self.uiData.needMoney or 0
    if curMoney < GrouUpNeedMoney then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401015, "UMG_PetBaseInfo_C:OnBtnLevelUpClick")
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petgrowup_12)
      self.IsInEvolution = false
      return
    end
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_PetBaseInfo_C:OnBtnLevelUpClick")
    if self.NeedOpenExChange then
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenExChangeGrowUpPanel, self.NeedExChangeCount, self.DiffItem)
    elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToGrowUp then
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.PetGrowUp, self.uiData.petData.gid, tonumber(self.Quantity:GetText()), self.uiData.PetPropertyInfo)
    elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToBreakThrough then
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.PetBreakThrough, self.uiData.petData, self.uiData.PetPropertyInfo, self.uiData.Property)
    elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToInspire then
      local bCanInspire, CantInspireReasonType = self:CheckCanInspire()
      if bCanInspire then
        _G.NRCModeManager:DoCmd(PetUIModuleCmd.PetInspire, self.uiData.petData.gid, self.uiData.petData, self.uiData.PetPropertyInfo, self.uiData.Property)
      end
    end
  end
end

function UMG_PetGrowUp_C:moneyIsEnough()
  local curMoney = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
  local GrouUpNeedMoney = self.uiData.needMoney or 0
  return curMoney >= GrouUpNeedMoney
end

function UMG_PetGrowUp_C:LevelIsEnough(GrowCount)
  local GrowLevelConfList = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GROW_LEVEL_CONF):GetAllDatas()
  if GrowCount > #GrowLevelConfList then
    Log.Debug("\230\136\144\233\149\191\230\172\161\230\149\176\232\182\133\232\191\135\230\156\128\229\164\167\230\172\161\230\149\176,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return false
  end
  local GrowLevelConf = _G.DataConfigManager:GetGrowLevelConf(GrowCount)
  if GrowLevelConf then
    if self.uiData.petData.level >= GrowLevelConf.require_pet_level then
      self:SetBtnState(true)
      return true
    else
      self:SetBtnState(false)
      local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("umg_petgrow_4")
      local Text = string.format(LocalizationConf.msg, GrowLevelConf.require_pet_level)
      self.UMG_Btn1:SetTitleTextAndIcon(nil, nil, nil, nil, Text)
      self.UMG_Btn1:SetTitleTextColor("c7494a")
      self.UMG_Btn1:SetClickAble(false)
      self.NRCSwitcher_46:SetActiveWidgetIndex(1)
      return false
    end
  end
  return false
end

function UMG_PetGrowUp_C:AddAndMaximumBtnIsEnough(GrowCount)
  if not self.uiData.petData then
    Log.Error("self.uiData.petData == nil")
    return
  end
  local GrowLevelConfList = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GROW_LEVEL_CONF):GetAllDatas()
  if GrowCount > #GrowLevelConfList then
    Log.Debug("\230\136\144\233\149\191\230\172\161\230\149\176\232\182\133\232\191\135\230\156\128\229\164\167\230\172\161\230\149\176,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return false
  end
  local GrowLevelConf = _G.DataConfigManager:GetGrowLevelConf(GrowCount)
  if GrowLevelConf then
    if self.uiData.petData.level < GrowLevelConf.require_pet_level then
      return false
    else
      return true
    end
  end
end

function UMG_PetGrowUp_C:OnEvolution(IsInEvolution)
  if not self.uiData.petData then
    Log.Error("self.uiData.petData == nil")
    return
  end
  self.IsInEvolution = IsInEvolution
  if IsInEvolution then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.PetBreakThrough, self.uiData.petData, self.uiData.PetPropertyInfo, self.uiData.Property)
  end
end

function UMG_PetGrowUp_C:UpdateCatchHardLv()
  local CatchHardLv = self.uiData.CatchHardLv
  for i, v in ipairs(CatchHardLv) do
    if 0 == v.IsShow then
      v.IsShow = 1
      break
    end
  end
end

function UMG_PetGrowUp_C:UpdateCurMoney()
  local costItemId = _G.DataConfigManager:GetPetGlobalConfig("universal_growth_material").num
  local num2 = NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, costItemId)
  if nil == num2 then
    num2 = 0
  else
    num2 = num2.num
  end
  local ResidueGrowCount, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.uiData.petData)
  local num1 = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
  local MoneyList = {
    {
      moneyType = _G.Enum.VisualItem.VI_COIN,
      sum = num1
    }
  }
  if ResidueGrowCount <= 0 and self.GrowUpType ~= PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    table.insert(MoneyList, {moneyType = costItemId, sum = num2})
  end
  self.MoneyBtn:InitGridView(MoneyList)
end

function UMG_PetGrowUp_C:SetStarsList()
  if self.uiData == nil then
    Log.Error("UMG_PetGrowUp_C:SetStarsList self.uiData == nil")
    return
  end
  if nil == self.uiData.petData then
    Log.Error("UMG_PetGrowUp_C:SetStarsList self.uiData.petData == nil")
    return
  end
  if self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToGrowUp then
    self:SetGrowStarsList()
    self.CatchHardLv_1:Clear()
    self.CatchHardLv_1:InitGridView(self.uiData.CatchHardLv)
  elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToBreakThrough then
    self:SetBreakThroughStarsList()
    self.CatchHardLv:Clear()
    self.CatchHardLv:InitGridView(self.uiData.CatchHardLv)
  elseif self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    self:SetInspireStarsList()
    self.CatchHardLv_2:Clear()
    self.CatchHardLv_2:InitGridView(self.uiData.CatchHardLv)
  end
end

function UMG_PetGrowUp_C:SetGrowStarsList()
  local petData = self.uiData.petData
  local GrowStarsList = PetUtils.GetGrowStarsList(self.uiData.petData, tonumber(self.Quantity:GetText()))
  for _, v in ipairs(GrowStarsList) do
    v.ShowAnim = true
  end
  self.uiData.CatchHardLv = GrowStarsList
end

function UMG_PetGrowUp_C:SetBreakThroughStarsList()
  local GrowStarsList = PetUtils.GetBreakThroughStarsList(self.uiData.petData, true)
  for _, v in ipairs(GrowStarsList) do
    v.ShowAnim = true
  end
  self.uiData.CatchHardLv = GrowStarsList
end

function UMG_PetGrowUp_C:SetInspireStarsList()
  local InspireStarsList = PetUtils.GetInspireStarsList(self.uiData.petData)
  for _, v in ipairs(InspireStarsList) do
    v.ShowAnim = true
  end
  self.uiData.CatchHardLv = InspireStarsList
end

function UMG_PetGrowUp_C:ShowCanGrowUp(_BreakNumberConf)
  local BreakNumberConf = _BreakNumberConf
  local heroLv = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel() or 0
  Log.Debug(heroLv, "UMG_PetGrowUp_C:ShowCanGrowUp")
  if heroLv >= BreakNumberConf.level_number then
    self.NRCSwitcher_46:SetActiveWidgetIndex(0)
  else
    local Text = string.format("%s%d", LuaText.umg_petgrowup_13, BreakNumberConf.level_number)
    self.NRCSwitcher_46:SetActiveWidgetIndex(1)
    self.UMG_Btn1:SetTitleTextAndIcon(nil, nil, nil, nil, Text)
    self.UMG_Btn1:SetClickAble(false)
    self.UMG_Btn1:SetTitleTextColor("c7494a")
  end
end

function UMG_PetGrowUp_C:CheckCanInspire()
  local bCanInspire = false
  local CantInspireReasonType = EnumCantInspireReasonType.None
  local IsMaxLevel = PetUtils.CheckPetIsMaxLevel(self.uiData.petData)
  if IsMaxLevel then
    bCanInspire = true
  else
    bCanInspire = false
    CantInspireReasonType = EnumCantInspireReasonType.NotMaxLevel
    return bCanInspire, CantInspireReasonType
  end
  if self.uiData.ItemList ~= nil then
    for i, v in pairs(self.uiData.ItemList) do
      if v.BagNum < v.itemNum then
        bCanInspire = false
        CantInspireReasonType = EnumCantInspireReasonType.NotEnoughItem
        return bCanInspire, CantInspireReasonType
      end
    end
  end
  if nil ~= self.needMoney then
    local CurHaveMoney = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
    if CurHaveMoney < self.needMoney then
      bCanInspire = false
      CantInspireReasonType = EnumCantInspireReasonType.NotEnoughMoney
      return bCanInspire, CantInspireReasonType
    end
  end
  return bCanInspire, CantInspireReasonType
end

function UMG_PetGrowUp_C:UpdateInspireBtn()
  local bCanInspire = self:CheckCanInspire()
  if bCanInspire then
    self.NRCSwitcher_46:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_46:SetActiveWidgetIndex(1)
  end
end

function UMG_PetGrowUp_C:GetSpecialSkillIndex(break_attribute_type)
  local attribute = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ATTRIBUTE_CONF):GetAllDatas()
  for i, v in pairs(attribute) do
    if break_attribute_type == v.attribute then
      return i
    end
  end
end

function UMG_PetGrowUp_C:materialsIsEnough()
  local MaterialsIsEnough = true
  local Items = self.uiData.ItemList
  for i, v in ipairs(Items) do
    if v.BagNum < v.itemNum then
      MaterialsIsEnough = false
    end
  end
  return MaterialsIsEnough
end

function UMG_PetGrowUp_C:ExChangeMaterialsIsEnough()
  local Items = self.uiData.ItemList
  local MaterialsIsEnough = true
  local ExChangeCount = PetUtils.getItemCount(_G.DataConfigManager:GetPetGlobalConfig("universal_growth_material").num)
  local NeedExChangeCount = 0
  local DiffItem = {}
  for i, v in ipairs(Items) do
    if v.BagNum < v.itemNum then
      local Diff = v.itemNum - v.BagNum
      if v.ExChangeItemId and v.ExChangeRatio then
        NeedExChangeCount = Diff * v.ExChangeRatio + NeedExChangeCount
        local itemCfg = _G.DataConfigManager:GetBagItemConf(v.itemId)
        table.insert(DiffItem, {
          itemCfg = itemCfg,
          itemCount = Diff,
          itemType = v.itemType,
          itemId = v.itemId,
          itemNum = Diff,
          bShowNum = true,
          bShowTip = true
        })
      else
        MaterialsIsEnough = false
      end
    end
  end
  if MaterialsIsEnough and ExChangeCount < NeedExChangeCount then
    MaterialsIsEnough = false
  end
  return MaterialsIsEnough, ExChangeCount, NeedExChangeCount, DiffItem
end

function UMG_PetGrowUp_C:getItemCount(_itemId)
  local itemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, _itemId)
  if itemData then
    return itemData.num or 0
  end
  return 0
end

function UMG_PetGrowUp_C:UpdateMoneyInfo(_needMoney)
  local costItemId = _G.DataConfigManager:GetPetGlobalConfig("universal_growth_material").num
  local num2 = NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, costItemId)
  if nil == num2 then
    num2 = 0
  else
    num2 = num2.num
  end
  local num1 = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
  local ResidueGrowCount, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.uiData.petData)
  local MoneyList = {
    {
      moneyType = _G.Enum.VisualItem.VI_COIN,
      sum = num1
    }
  }
  if ResidueGrowCount <= 0 and self.GrowUpType ~= PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    table.insert(MoneyList, {moneyType = costItemId, sum = num2})
  end
  self.MoneyBtn:InitGridView(MoneyList)
  local ColorString = ""
  if _needMoney > num1 then
    ColorString = "AF3D3EFF"
  else
    ColorString = "F4EEE1FF"
  end
  local vItemsConf = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_COIN)
  self.UMG_Btn:SetTitleTextAndIcon(vItemsConf.bigIcon, _needMoney)
  self.UMG_Btn:SetQuantityTextColor(ColorString)
  self.UMG_Btn1:SetTitleTextAndIcon(vItemsConf.bigIcon, _needMoney)
  self.UMG_Btn1:SetQuantityTextColor(ColorString)
end

function UMG_PetGrowUp_C:OnCloseBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002016, "UMG_PetGrowUp_C:OnCloseBtnClick")
  self:DispatchEvent(PetUIModuleEvent.RightPanelHideSubPanel)
  self:DispatchEvent(PetUIModuleEvent.RightPanelShowSubPanel, 1)
end

function UMG_PetGrowUp_C:OnSubtractBtn()
  local AddGrowNum = tonumber(self.Quantity:GetText())
  AddGrowNum = AddGrowNum - 1
  if AddGrowNum < 1 then
    self:UpdateBtnInfo()
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401008, "UMG_PetGrowUp_C:OnSubtractBtn1")
  self.Quantity:SetText(AddGrowNum)
  self:SetStarsList()
  self:SetListIconInfo(AddGrowNum)
  self:UpdateBtnInfo()
end

function UMG_PetGrowUp_C:OnAddBtn()
  local AddGrowNum = tonumber(self.Quantity:GetText())
  AddGrowNum = AddGrowNum + 1
  local ResidueGrowCount, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.uiData.petData)
  if AddGrowNum > ResidueGrowCount then
    self:UpdateBtnInfo()
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_PetGrowUp_C:OnAddBtn")
  self.Quantity:SetText(AddGrowNum)
  self:SetStarsList()
  self:SetListIconInfo(AddGrowNum)
  self:UpdateBtnInfo()
end

function UMG_PetGrowUp_C:OnMaximumBtn()
  _G.NRCAudioManager:PlaySound2DAuto(1220002011, "UMG_PetGrowUp_C:OnMaximumBtn")
  local canMaxUpCnt = 0
  local ResidueGrowCount, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.uiData.petData)
  for tempUpCnt = 1, ResidueGrowCount do
    local canUp = self:CheckCanGrowUp(tempUpCnt)
    if not canUp then
      break
    end
    canMaxUpCnt = canMaxUpCnt + 1
  end
  if canMaxUpCnt > 0 then
    self.Quantity:SetText(canMaxUpCnt)
    self:SetListIconInfo(canMaxUpCnt)
    self:SetStarsList()
    self:UpdateBtnInfo()
  else
    self.MaximumBtn:SetIsEnabled(false)
  end
end

function UMG_PetGrowUp_C:CheckCanGrowUp(goalLevel)
  if self.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    return false
  end
  local tempNeedItemList = {}
  local tempNeedMoneyNum = 0
  local LevelIsEnough = false
  local grow_times = self.uiData.petData.grow_times or 0
  if grow_times then
    for i = 1, goalLevel do
      local GrowLevelConf = _G.DataConfigManager:GetGrowLevelConf(grow_times + i)
      if GrowLevelConf then
        for j, require_item in ipairs(GrowLevelConf.require_item) do
          if require_item.Type == Enum.GoodsType.GT_BAGITEM then
            local isHasItem = false
            for k, Item in ipairs(tempNeedItemList) do
              if require_item.require_item_id == Item.itemId then
                Item.itemNum = Item.itemNum + require_item.require_item_count
                isHasItem = true
              end
            end
            if not isHasItem then
              local needItem = _G.NRCCommonItemIconData()
              needItem.itemType = require_item.Type
              needItem.itemId = require_item.require_item_id
              needItem.itemNum = require_item.require_item_count
              needItem.BagNum = PetUtils.getItemCount(require_item.require_item_id)
              table.insert(tempNeedItemList, needItem)
            end
          elseif require_item.Type == Enum.GoodsType.GT_VITEM then
            tempNeedMoneyNum = tempNeedMoneyNum + require_item.require_item_count
          end
        end
      end
    end
    local GrowLevelConfList = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GROW_LEVEL_CONF):GetAllDatas()
    if grow_times + goalLevel > #GrowLevelConfList then
      Log.Debug("\230\136\144\233\149\191\230\172\161\230\149\176\232\182\133\232\191\135\230\156\128\229\164\167\230\172\161\230\149\176,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
      return
    end
    local GrowLevelConf = _G.DataConfigManager:GetGrowLevelConf(grow_times + goalLevel)
    if GrowLevelConf and self.uiData.petData.level >= GrowLevelConf.require_pet_level then
      LevelIsEnough = true
    end
  end
  local num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
  local itemInsufficient = false
  for k, Item in ipairs(tempNeedItemList) do
    if Item.itemNum > Item.BagNum then
      itemInsufficient = true
      break
    end
  end
  if tempNeedMoneyNum > num or itemInsufficient or not LevelIsEnough then
    return false
  else
    return true
  end
end

function UMG_PetGrowUp_C:UpdateBtnInfo()
  local ResidueGrowCount, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.uiData.petData)
  local curSelectLv = tonumber(self.Quantity:GetText())
  if ResidueGrowCount <= curSelectLv or not self:AddAndMaximumBtnIsEnough(self:GetGrowCount()) then
    self:UpdateAddBtn(true)
  else
    self:UpdateAddBtn(false)
  end
  if curSelectLv <= 1 then
    self:UpdateSubtractBtn(true)
  else
    self:UpdateSubtractBtn(false)
  end
  local canUp = self:CheckCanGrowUp(curSelectLv + 1)
  if canUp and ResidueGrowCount > curSelectLv and self:AddAndMaximumBtnIsEnough(self:GetGrowCount()) then
    self:UpdateMaximumBtn(true)
  else
    self:UpdateMaximumBtn(false)
  end
end

function UMG_PetGrowUp_C:UpdateAddBtn(CanUse)
  if CanUse then
    local PlusSign = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_PlusSign3_png.img_PlusSign3_png'"
    self.AddBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.AddBtn:SetPath(PlusSign, PlusSign, PlusSign)
  else
    local PlusSign = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_PlusSign1_png.img_PlusSign1_png'"
    self.AddBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.AddBtn:SetPath(PlusSign, PlusSign, PlusSign)
  end
end

function UMG_PetGrowUp_C:UpdateSubtractBtn(CanUse)
  if CanUse then
    local Subtract = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Subtract3_png.img_Subtract3_png'"
    self.SubtractBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.SubtractBtn:SetPath(Subtract, Subtract, Subtract)
  else
    local Subtract = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Subtract1_png.img_Subtract1_png'"
    self.SubtractBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SubtractBtn:SetPath(Subtract, Subtract, Subtract)
  end
end

function UMG_PetGrowUp_C:UpdateMaximumBtn(CanUse)
  if CanUse then
    local Maxinum = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Maximum1_png.img_Maximum1_png'"
    self.MaximumBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.MaximumBtn:SetPath(Maxinum, Maxinum, Maxinum)
  else
    local Maxinum = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Maximum3_png.img_Maximum3_png'"
    self.MaximumBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.MaximumBtn:SetPath(Maxinum, Maxinum, Maxinum)
  end
end

function UMG_PetGrowUp_C:SetBtnState(CanUse)
  if CanUse then
    self.UMG_Btn.BG:SetIsEnabled(true)
    self.UMG_Btn.btnLevelUp:SetIsEnabled(true)
  else
    self.UMG_Btn.BG:SetIsEnabled(false)
    self.UMG_Btn.btnLevelUp:SetIsEnabled(false)
  end
end

function UMG_PetGrowUp_C:GetGrowCount()
  return (self.uiData.petData and self.uiData.petData.grow_times or 0) + (tonumber(self.Quantity:GetText()) or 1) + 1
end

return UMG_PetGrowUp_C
