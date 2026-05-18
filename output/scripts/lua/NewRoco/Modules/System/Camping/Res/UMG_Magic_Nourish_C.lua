local UMG_Magic_Nourish_C = _G.NRCPanelBase:Extend("UMG_Magic_Nourish_C")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MAX_COLUMN = 2

function UMG_Magic_Nourish_C:OnConstruct()
  self.uiData = {}
  local insufficientText = _G.DataConfigManager:GetLocalizationConf("Camp_Exchange_cailiaobuzu")
  self.uiData.insufficientText = insufficientText and insufficientText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176"
  self:PlayAnimation(self.open)
  self.Nourish_Button_Effect:PlayAnimation(self.Nourish_Button_Effect.open)
  self.Nourish_Button_Effect.UMG_Magic_Nourish_ButtonRing:PlayAnimation(self.Nourish_Button_Effect.UMG_Magic_Nourish_ButtonRing.loop, 0, 0)
end

function UMG_Magic_Nourish_C:OnDestruct()
  self:OnRemoveEventListener()
  self:CancelDelay()
end

function UMG_Magic_Nourish_C:OnActive(_param)
  self.param = _param
  self:OnAddEventListener()
  self:RefreshPanel()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1296, "UMG_Magic_Nourish_C:OnConstruct")
end

function UMG_Magic_Nourish_C:OnDeactive()
end

function UMG_Magic_Nourish_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.Btn_Details, self.OnDetailsBtnClick)
  self:AddButtonListener(self.Btn_Upgrade, self.OnUpgradeBtnClick)
  self:AddButtonListener(self.Btn_ShellCoin, self.OnCostItem1Click)
  self:AddButtonListener(self.Btn_Drill, self.OnCostItem2Click)
  NRCEventCenter:RegisterEvent("UMG_Magic_Nourish_C", self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:RegisterEvent("UMG_Magic_Nourish_C", self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
  if self.param.campfire then
    self.param.campfire.sceneCharacter:AddEventListener(self, NPCModuleEvent.NPC_LEVEL_UP, self.OnLevelUp)
  end
end

function UMG_Magic_Nourish_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:RemoveButtonListener(self.Btn_Details, self.OnDetailsBtnClick)
  self:RemoveButtonListener(self.Btn_Upgrade, self.OnUpgradeBtnClick)
  self:RemoveButtonListener(self.Btn_ShellCoin, self.OnCostItem1Click)
  self:RemoveButtonListener(self.Btn_Drill, self.OnCostItem2Click)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
  if self.param.campfire then
    self.param.campfire.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.NPC_LEVEL_UP, self.OnLevelUp)
  end
end

function UMG_Magic_Nourish_C:OnAnimationFinished(anim)
  if anim == self.close then
    if self.isRealClosed then
      if self.param.action then
        self.param.action:EndAction()
      end
      self:DoClose()
    else
      self:PlayUpgradeBtnClose()
    end
  elseif anim == self.open then
    self:PlayUpgradeBtnRingAnimation()
  end
end

function UMG_Magic_Nourish_C:OnCloseBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_Magic_Nourish_C:OnCloseBtnClick")
  if self:IsAnimationPlaying(self.close) or self:IsAnimationPlaying(self.open) then
    return
  end
  self.isRealClosed = true
  self:PlayAnimation(self.close)
  self:PlayUpgradeBtnClose()
end

function UMG_Magic_Nourish_C:OnDetailsBtnClick()
  Log.Debug("UMG_Magic_Nourish_C:OnDetailsBtnClick")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1301, "UMG_Magic_Nourish_C:OnDetailsBtnClick")
end

function UMG_Magic_Nourish_C:OnUpgradeBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1297, "UMG_Magic_Nourish_C:OnUpgradeBtnClick")
  if self.isUpgradeReq == true then
    return
  end
  if not self.isItemEnough then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, self.uiData.insufficientText)
    return
  end
  self.isUpgradeReq = true
end

function UMG_Magic_Nourish_C:OnLevelUpRsp(rsp)
  Log.Debug("UMG_Magic_Nourish_C:OnLevelUpRsp", rsp.ret_info.ret_code)
  if 0 ~= rsp.ret_info.ret_code then
    self.isUpgradeReq = false
    local error = _G.DataConfigManager:GetLocalizationConf("Camp_Levelup_error").msg
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, error)
  end
end

function UMG_Magic_Nourish_C:OnLevelUp()
  Log.Debug("UMG_Magic_Nourish_C:OnLevelUp")
  self:PlayLevelUpAnim()
end

function UMG_Magic_Nourish_C:SetButtonEnabled(enabled)
  self.CloseBtn.btnClose:SetIsEnabled(enabled)
  self.Btn_Details:SetIsEnabled(enabled)
  self.Btn_ShellCoin:SetIsEnabled(enabled)
  self.Btn_Drill:SetIsEnabled(enabled)
  if enabled then
    self.List:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.List:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_Magic_Nourish_C:PlayLevelUpAnim()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1298, "UMG_Magic_Nourish_C:OnUpgradeBtnClick")
  self:SetButtonEnabled(false)
  local lv = self.param.campfire.sceneCharacter.serverData.base.lv
  Log.Error("Level Up \229\183\178\231\187\143\229\186\159\229\188\131\229\149\166!!!!")
  self:PlayAnimation(self.close)
end

function UMG_Magic_Nourish_C:PlayLevelUpEffectBegin()
  self.Upgrade_Dynamic_Effect:PlayAnimation(self.Upgrade_Dynamic_Effect.open)
  self:RefreshPanel()
end

function UMG_Magic_Nourish_C:PlayLevelUpEffectEnd()
  self.Upgrade_Dynamic_Effect:PlayAnimation(self.Upgrade_Dynamic_Effect.close)
end

function UMG_Magic_Nourish_C:PlayUpgradeBtnClose()
  self.Nourish_Button_Effect:PlayAnimation(self.Nourish_Button_Effect.close)
end

function UMG_Magic_Nourish_C:LevelUpAnimComplete()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1302, "UMG_Magic_Nourish_C:OnUpgradeBtnClick")
  self:SetButtonEnabled(true)
  self:PlayAnimation(self.open)
  self.Nourish_Button_Effect:PlayAnimation(self.Nourish_Button_Effect.open)
  self.isUpgradeReq = false
end

function UMG_Magic_Nourish_C:HidePanel(bHide)
  self.Place_Info_SubPanel:SetVisibility(bHide and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
  self.State:SetVisibility(bHide and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
  self.CloseBtn:SetVisibility(bHide and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
end

function UMG_Magic_Nourish_C:OnBagChange()
  self:UpdateCostItems()
end

function UMG_Magic_Nourish_C:OnCostItem1Click()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_CampingTemplate_C:OnItemSelected")
  if self.cost_item then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.cost_item[1].cost_item_id, self.cost_item[1].cost_item_type, false)
  end
end

function UMG_Magic_Nourish_C:OnCostItem2Click()
  if self.cost_item then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.cost_item[2].cost_item_id, self.cost_item[2].cost_item_type, false)
  end
end

function UMG_Magic_Nourish_C:RefreshPanel()
  self.CampingId = self.param.campfire.sceneCharacter.serverData.npc_base.npc_content_cfg_id
  self.CampingLv = self.param.campfire.sceneCharacter.serverData.base.lv
  local maxLv, campingLvCfg = self:GetCampingMaxLvAndCfg(self.CampingId)
  self.MaxLv = maxLv
  self.CampingLvCfg = campingLvCfg
  if maxLv <= self.CampingLv then
    self.State:SetActiveWidgetByWidgetName("Abundant")
  else
    self.State:SetActiveWidgetByWidgetName("upgrade")
    self:UpdateUpgradePanel()
  end
  self.Tree:SetPath(self.module:GetCampingIconPathByLv(self.CampingLv))
  self.Camping_Title:SetText(self.CampingLvCfg.name)
  local placeName = _G.DataConfigManager:GetAreaFuncConf(self.CampingLvCfg.area_id).name
  self.Place_Names:SetText(placeName)
  local fmtStr = _G.DataConfigManager:GetLocalizationConf("Camp_Level_Max_Desc").msg
  self.Place_Names_1:SetText(string.format(fmtStr, placeName))
  self:UpdateCostItems()
end

function UMG_Magic_Nourish_C:GetCampingMaxLvAndCfg(campingId)
  local maxLv = 1
  local campingLvTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.CAMP_LEVELUP_CONF)
  local campLvCfgs = campingLvTable:GetAllDatas()
  for k, v in ipairs(campLvCfgs) do
    if v.content_id == campingId and maxLv < v.level then
      maxLv = v.level
    end
  end
  local campingCfg = _G.DataConfigManager:GetCampConf(campingId)
  return maxLv, campingCfg
end

function UMG_Magic_Nourish_C:GetPetbaseListData()
  local petbaseList = {}
  local petRefreshConfs = self.module:GetPetRefreshConfsByCampingIdAndLevel(self.CampingId, self.CampingLv + 1)
  for _, refreshCfg in ipairs(petRefreshConfs) do
    local npcCfg = _G.DataConfigManager:GetNpcConf(refreshCfg.cfg.npc_id)
    local petbase_id = npcCfg.traverse_data_param[1]
    if nil == petbase_id then
      Log.Error(refreshCfg.cfg.npc_id)
    end
    local petbaseCfg = _G.DataConfigManager:GetPetbaseConf(petbase_id)
    table.insert(petbaseList, petbaseCfg)
  end
  return petbaseList
end

function UMG_Magic_Nourish_C:UpdateUpgradePanel()
  self:UpdatePetList()
end

function UMG_Magic_Nourish_C:UpdatePetList()
  local petbaseList = self:GetPetbaseListData()
  local petListMap = {}
  local maxStage = 1
  for _, petbase in ipairs(petbaseList) do
    petListMap[petbase.id] = {cfg = petbase, isProcessed = false}
    if maxStage < petbase.stage then
      maxStage = petbase.stage
    end
  end
  local petListData = {}
  for stage = 1, maxStage do
    for _, petbase in ipairs(petbaseList) do
      if petbase.stage == stage and petListMap[petbase.id].isProcessed == false then
        petListMap[petbase.id].isProcessed = true
        local petSubList = {}
        local petData = {cfg = petbase, hasLink = false}
        table.insert(petSubList, petData)
        local curPet = petData
        while #curPet.cfg.evolution_pet_id > 0 and petListMap[curPet.cfg.evolution_pet_id[1]] and false == petListMap[curPet.cfg.evolution_pet_id[1]].isProcessed do
          local evolutionId = curPet.cfg.evolution_pet_id[1]
          petListMap[evolutionId].isProcessed = true
          curPet.hasLink = true
          local nextPetData = {
            cfg = petListMap[evolutionId].cfg,
            hasLink = false
          }
          table.insert(petSubList, nextPetData)
          curPet = nextPetData
        end
        table.insert(petListData, petSubList)
      end
    end
  end
  local petShowData = {}
  local curColIndex = 1
  local curRowData = {}
  for _, petList in ipairs(petListData) do
    for _, pet in ipairs(petList) do
      curRowData[#curRowData + 1] = pet
    end
    if 1 == #petListData then
      table.insert(petShowData, curRowData)
      break
    end
    if curColIndex == MAX_COLUMN then
      table.insert(petShowData, curRowData)
      curRowData = {}
      curColIndex = 1
    else
      curColIndex = curColIndex + 1
    end
  end
  self.List:InitList(petShowData)
end

function UMG_Magic_Nourish_C:GetCostByCampIdAndNextLv(campId, nextLv)
  local campingLvTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.CAMP_LEVELUP_CONF)
  local campLvCfgs = campingLvTable:GetAllDatas()
  for k, v in ipairs(campLvCfgs) do
    if v.content_id == campId and v.level == nextLv then
      return v.levelup_cost_item_type, v.levelup_cost_item_id, v.levelup_cost_item_num
    end
  end
end

function UMG_Magic_Nourish_C:UpdateCostItems()
  local nextLv = self.CampingLv + 1
  local cost_item
  local costItemType, costItemId, costItemNum = self:GetCostByCampIdAndNextLv(self.CampingId, nextLv)
  self.isItemEnough = true
  if costItemType and costItemId then
    cost_item = {}
    cost_item[1] = {
      cost_item_id = costItemId,
      cost_item_type = costItemType,
      cost_item_num = costItemNum
    }
  end
  if cost_item and cost_item[1] then
    self.ShellCoin:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetupCostItems(cost_item[1], self.Item_Icon, self.Item_Num, self.Item_num1)
  else
    self.ShellCoin:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if cost_item and cost_item[2] then
    self.Drill:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetupCostItems(cost_item[2], self.Item_Icon2, self.Item_Num2, self.Item_num3)
  else
    self.Drill:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.cost_item = cost_item
  self.Btn_Upgrade:SetVisibility(self.isItemEnough and UE4.ESlateVisibility.visible or UE4.ESlateVisibility.Hidden)
  self:PlayUpgradeBtnRingAnimation()
end

function UMG_Magic_Nourish_C:SetupCostItems(cost_item, item_icon, item_num_text, item_num_text1)
  local cost_item_id = cost_item.cost_item_id
  local cost_item_type = cost_item.cost_item_type
  local cost_item_num = cost_item.cost_item_num
  local quality = 1
  if cost_item_type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(cost_item_id)
    if bagItemConf then
      item_icon:SetPath(bagItemConf.icon)
      quality = bagItemConf.item_quality
    end
  elseif cost_item_type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_STAR)
    if nil ~= vItemConf then
      item_icon:SetPath(vItemConf.bigIcon)
    end
  end
  local itemCount = self:GetItemCount(cost_item_id, cost_item_type)
  item_num_text:SetText(self:GetFormatNumText(itemCount, cost_item_num, quality))
  item_num_text1:SetText(string.format("%d/%d", itemCount, cost_item_num))
  if cost_item_num > itemCount then
    self.isItemEnough = false
  end
end

function UMG_Magic_Nourish_C:GetItemCount(_itemId, _itemType)
  if _itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local itemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, _itemId)
    if itemData then
      return itemData.num or 0
    end
    return 0
  elseif _itemType == _G.Enum.GoodsType.GT_VITEM then
    local VItemNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(16)
    return VItemNum
  end
  return 0
end

function UMG_Magic_Nourish_C:PlayUpgradeBtnRingAnimation()
end

function UMG_Magic_Nourish_C:GetFormatNumText(itemNum, itemNeedNum, quality)
  local itemText = ""
  if itemNeedNum then
    local redStr = "color=\"#ff494b\""
    local colorStr = self:GetQualityColorText(quality)
    local whiteStr = string.format("color=\"%s\"", colorStr)
    local fontStr = "font=\"/Game/NewRoco/Font/huakanglangman_Font\""
    local fmtStr = "<span size=\"16\" %s %s>%d</><span size=\"16\" %s %s>/%d</>"
    if itemNum < itemNeedNum then
      itemText = string.format(fmtStr, redStr, fontStr, itemNum, whiteStr, fontStr, itemNeedNum)
    else
      itemText = string.format(fmtStr, whiteStr, fontStr, itemNum, whiteStr, fontStr, itemNeedNum)
    end
  else
    itemText = tostring(itemNum)
  end
  return itemText
end

function UMG_Magic_Nourish_C:GetQualityColorText(quality)
  if 0 == quality then
    return "#ff0000"
  elseif 1 == quality then
    return "#ffffff"
  elseif 2 == quality then
    return "#96db71"
  elseif 3 == quality then
    return "#43adef"
  elseif 4 == quality then
    return "#c67fcc"
  elseif 5 == quality then
    return "#e6c142"
  end
end

return UMG_Magic_Nourish_C
