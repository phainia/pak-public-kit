local HomeEnum = require("NewRoco/Modules/System/Home/HomeEnum")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local HomeModuleEvent = require("NewRoco.Modules.System.Home.HomeModuleEvent")
local SEED_PLANT_TAB_TOTAL_WIDTH = 540
local UMG_PlantSeedsPanel_C = _G.NRCPanelBase:Extend("UMG_PlantSeedsPanel_C")

function UMG_PlantSeedsPanel_C:OnConstruct()
  self:SetChildViews(self.PopUp)
  self.uiData = {}
  self.PreferSeedItemId = 0
  self.PreferSeedTabLevel = 1
  self:AddButtonListener(self.SynthesisBtn_1.btnLevelUp, self.OnClickEquipButton)
  self:AddButtonListener(self.UnloadBtn.btnLevelUp, self.OnClickUnEquipButton)
end

function UMG_PlantSeedsPanel_C:OnActive(...)
  if _G.GlobalConfig.DebugOpenUI then
    self:InitPopUpData()
    return
  end
  self.bOnActive = true
  local specificSeedItemId, activeCallback, deactiveCallback = ...
  self.activeCallback = activeCallback
  self.deactiveCallback = deactiveCallback
  if self.activeCallback then
    self.activeCallback()
  end
  self:InitPopUpData()
  self:RegisterEvent(self, HomeModuleEvent.OnEquipSeedChange, self.HandleOnEquipSeedChange)
  self.PreferSeedItemId = specificSeedItemId
  self:RefreshUI()
  self.SynthesisBtn_1.Title_1:SetText(LuaText.seed_select_not_equip_btn_name)
  self.UnloadBtn.Title_1:SetText(LuaText.seed_select_equip_btn_name)
  self:LoadAnimation(0)
  self.bOnActive = false
end

function UMG_PlantSeedsPanel_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
    return
  end
  if self.deactiveCallback then
    self.deactiveCallback()
  end
  self.activeCallback = nil
  self.deactiveCallback = nil
  self:UnRegisterAllEvent()
end

function UMG_PlantSeedsPanel_C:OnEnable()
end

function UMG_PlantSeedsPanel_C:OnDisable()
end

function UMG_PlantSeedsPanel_C:ClosePanel()
  self:LoadAnimation(2)
end

function UMG_PlantSeedsPanel_C:InitPopUpData()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = LuaText.seed_pocket_title
  CommonPopUpData.Call = self
  CommonPopUpData.PopUpType = 2
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_PlantSeedsPanel_C:RefreshUI()
  self.MoneyButton:SetInfo(_G.Enum.VisualItem.VI_COIN, _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN))
  if self.uiData == nil then
    return
  end
  local bagItemList = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, ProtoEnum.BagItemType.BI_PLANT_SEED)
  if nil == bagItemList then
    bagItemList = {}
  end
  local equippingSeed, equippingSeedTabLevel = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetEquipSeed)
  local seedItemArray = {}
  for key, bagItem in pairs(bagItemList) do
    table.insert(seedItemArray, {
      Id = bagItem.id,
      num1 = bagItem.num,
      bEquipping = bagItem.id == equippingSeed,
      caller = self,
      callback = self.OnClickSeedItem
    })
  end
  table.sort(seedItemArray, function(a, b)
    local plantGrowConf1 = _G.DataConfigManager:GetPlantGrowConf(a.Id)
    local plantGrowConf2 = _G.DataConfigManager:GetPlantGrowConf(b.Id)
    local sortId1 = math.maxinteger
    local sortId2 = math.maxinteger
    if plantGrowConf1 then
      sortId1 = plantGrowConf1.home_lv
    end
    if plantGrowConf2 then
      sortId2 = plantGrowConf2.home_lv
    end
    if sortId1 ~= sortId2 then
      return sortId1 < sortId2
    else
      return a.Id < b.Id
    end
  end)
  self.SeedList_1:InitList(seedItemArray)
  self.uiData.seedBagItemArray = seedItemArray
  self.PreferSeedTabLevel = equippingSeedTabLevel
  self.uiData.SelectingSeedTabLevel = equippingSeedTabLevel
  if 0 == #seedItemArray then
  else
    if not self.PreferSeedItemId or 0 == self.PreferSeedItemId then
      self.PreferSeedItemId = equippingSeed
    end
    local preferItemIndex = 1
    for idx, seedData in ipairs(seedItemArray) do
      if seedData.Id == self.PreferSeedItemId then
        preferItemIndex = idx
        break
      end
    end
    self.PreferSeedItemId = 0
    self.SeedList_1:SelectItemByIndex(preferItemIndex - 1)
  end
end

function UMG_PlantSeedsPanel_C:RefreshUISpecific(itemId, newSeedTabLevel)
  if not itemId then
    return
  end
  if not self.uiData or not self.uiData.seedBagItemArray then
    return
  end
  local itemData = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, itemId)
  if not itemData then
    return
  end
  local equippingSeed = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetEquipSeed)
  local targetItemWidget
  for i, seedItemData in ipairs(self.uiData.seedBagItemArray) do
    if seedItemData.Id == itemId then
      targetItemWidget = self.SeedList_1:GetItemByIndex(i - 1)
      break
    end
  end
  if not targetItemWidget then
    return
  end
  local newPropertyTable = {}
  newPropertyTable.bEquipping = equippingSeed == itemId
  targetItemWidget:SetProperty(newPropertyTable)
  targetItemWidget:ApplyProperty()
  if self.uiData.SelectingSeedItemId == itemId then
    self.uiData.equippingSeedTabLevel = newSeedTabLevel or 1
    self.PreferSeedTabLevel = newSeedTabLevel or self.PreferSeedTabLevel
    self:UpdateDetailInfo()
  end
end

function UMG_PlantSeedsPanel_C:OnClickSeedItem(seedItemId, bSelected)
  if bSelected then
    self.uiData.SelectingSeedItemId = seedItemId
  else
    self.uiData.SelectingSeedItemId = nil
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_PlantSeedsPanel_C:OnClickSeedItem")
  self:UpdateDetailInfo()
  return self.bOnActive
end

function UMG_PlantSeedsPanel_C:UpdateDetailInfo()
  local selectingSeedItemId = self.uiData.SelectingSeedItemId
  if nil == selectingSeedItemId or selectingSeedItemId <= 0 then
    return
  end
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(selectingSeedItemId)
  if nil == bagItemConf then
    return
  end
  self.SeedText_1:SetText(bagItemConf.type_desc)
  self.SeedTitle_1:SetText(bagItemConf.name)
  self.SeedDescription_1:SetText(bagItemConf.description)
  self.SeedIcon:SetPath(bagItemConf.big_icon)
  self:InitSeedPlantTab()
end

function UMG_PlantSeedsPanel_C:OnClickEquipButton()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PlantSeedsPanel_C:OnClickEquipButton")
  local selectingSeedItemId = self.uiData.SelectingSeedItemId
  local selectingSeedTabLevel = self.uiData.SelectingSeedTabLevel
  if nil == selectingSeedItemId or selectingSeedItemId <= 0 or nil == selectingSeedTabLevel or selectingSeedTabLevel <= 0 then
    return
  end
  if not self.uiData.bEquippingThisSeedAndTab then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.SendSetEquipSeed, selectingSeedItemId, selectingSeedTabLevel)
  end
end

function UMG_PlantSeedsPanel_C:OnClickUnEquipButton()
  _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_PlantSeedsPanel_C:OnClickUnEquipButton")
  local selectingSeedItemId = self.uiData.SelectingSeedItemId
  if nil == selectingSeedItemId or selectingSeedItemId <= 0 then
    return
  end
  if self.uiData.bEquippingThisSeedAndTab then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.SendSetEquipSeed, 0)
  end
end

function UMG_PlantSeedsPanel_C:HandleOnEquipSeedChange(unEquipSeed, equipSeed, bServerDriven, seedTabLevel)
  if unEquipSeed and unEquipSeed > 0 then
    self:RefreshUISpecific(unEquipSeed, nil)
  end
  if equipSeed and equipSeed > 0 then
    self:RefreshUISpecific(equipSeed, seedTabLevel)
  end
  if bServerDriven and equipSeed > 0 and self.PopUp and self.PopUp.OnBtnClose then
    self.PopUp:OnBtnClose()
  end
end

function UMG_PlantSeedsPanel_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(0) then
    local loopAnim = self:GetAnimByIndex(1)
    self:PlayAnimation(loopAnim, 0, 99999)
  elseif Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_PlantSeedsPanel_C:InitSeedPlantTab()
  local selectingSeedItemId = self.uiData.SelectingSeedItemId
  local plantGrowConf = _G.DataConfigManager:GetPlantGrowConf(selectingSeedItemId, true)
  if not (plantGrowConf and plantGrowConf.plant_tab) or not plantGrowConf.plant_grow_grade then
    return
  end
  local selectingSeedTabLevel = self.uiData.SelectingSeedTabLevel
  if not selectingSeedTabLevel or selectingSeedTabLevel <= 0 then
    return
  end
  local tabSelfConfCount = #plantGrowConf.plant_tab
  local tabSeedDataCount = #plantGrowConf.plant_grow_grade
  if tabSelfConfCount ~= tabSeedDataCount or 0 == tabSelfConfCount then
    Log.Error("UMG_PlantSeedsPanel_C:InitSeedPlantTab tab conf error", plantGrowConf.id, tabSelfConfCount, tabSeedDataCount)
    return
  end
  local singleItemWidget = math.floor(SEED_PLANT_TAB_TOTAL_WIDTH / tabSelfConfCount)
  self.TabList1:SetCustomSize(singleItemWidget, math.floor(self.TabList1:GetCustomItemHeight()))
  self.TabList1.m_colCount = tabSelfConfCount
  local itemDataArray = {}
  for i = 1, tabSelfConfCount do
    table.insert(itemDataArray, {
      tabConfId = plantGrowConf.plant_tab[i],
      index = i,
      callbackCaller = self,
      callbackFunc = self.OnClickSeedTabLevel
    })
  end
  self.TabList1:InitGridView(itemDataArray)
  local preferSeedTabLevel = 1
  if self.PreferSeedTabLevel and self.PreferSeedTabLevel > 0 and tabSelfConfCount >= self.PreferSeedTabLevel then
    preferSeedTabLevel = self.PreferSeedTabLevel
  end
  self.TabList1:SelectItemByIndex(preferSeedTabLevel - 1)
end

function UMG_PlantSeedsPanel_C:OnClickSeedTabLevel(listIndex, newSeedTabLevel)
  if not listIndex or not newSeedTabLevel then
    return
  end
  self.uiData.SelectingSeedTabLevel = newSeedTabLevel
  self.PreferSeedTabLevel = newSeedTabLevel
  self:UpdateDetailTabLevelInfo()
end

function UMG_PlantSeedsPanel_C:UpdateDetailTabLevelInfo()
  local selectingSeedItemId = self.uiData.SelectingSeedItemId
  local selectingSeedTabLevel = self.uiData.SelectingSeedTabLevel
  if not (nil ~= selectingSeedItemId and not (selectingSeedItemId <= 0) and selectingSeedTabLevel) or selectingSeedTabLevel <= 0 then
    return
  end
  local plantGrowConf = _G.DataConfigManager:GetPlantGrowConf(selectingSeedItemId)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(selectingSeedItemId)
  if nil == plantGrowConf or nil == bagItemConf then
    return
  end
  local plantGrowGrade = plantGrowConf.plant_grow_grade and plantGrowConf.plant_grow_grade[selectingSeedTabLevel]
  if not plantGrowGrade then
    return
  end
  local timeStr, outputStr = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GenerateSeedTipsInfo, selectingSeedItemId, nil, selectingSeedTabLevel)
  self.GrowthTextTime:SetText(timeStr)
  self.OutputText:SetText(outputStr)
  local vItemConf = _G.DataConfigManager:GetVisualItemConf(plantGrowGrade.plant_vitem_type or _G.Enum.VisualItem.VI_COIN)
  if vItemConf then
    self.NRCImage_5:SetPath(vItemConf.iconPath)
  end
  self.OutputText1_2:SetText(plantGrowGrade.plant_vitem_value or 0)
  local equippingSeed, equippingSeedTabLevel = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetEquipSeed)
  self.uiData.bEquippingThisSeedAndTab = selectingSeedItemId == equippingSeed and selectingSeedTabLevel == equippingSeedTabLevel
  if self.uiData.bEquippingThisSeedAndTab then
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  end
end

return UMG_PlantSeedsPanel_C
