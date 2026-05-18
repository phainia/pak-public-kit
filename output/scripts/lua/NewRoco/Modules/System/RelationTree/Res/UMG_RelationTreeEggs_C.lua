local UMG_RelationTreeEggs_C = _G.NRCPanelBase:Extend("UMG_RelationTreeEggs_C")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local RelationTreeEvent = require("NewRoco.Modules.System.RelationTree.RelationTreeEvent")
local CommonBtnEnum = require("NewRoco.Modules.System.CommonBtn.CommonBtnEnum")

function UMG_RelationTreeEggs_C:OnConstruct()
  self:OnAddEventListener()
  self.Cost = 0
  local allInteractionTreeConfs = self.module:GetAllInteractiontreeConfs()
  for _, conf in pairs(allInteractionTreeConfs) do
    if conf and conf.InteractionTreeTypeDefault == _G.Enum.InteractiontreeTypeDefault.ITTD_CIFU then
      self.Cost = conf.cost or 0
      break
    end
  end
  _G.DataModelMgr.PlayerDataModel:AddPanelMusic(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_BAG)
  local StateGroup = _G.DataModelMgr.PlayerDataModel:GetStateGroupByApplyEnum(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_BAG)
  if StateGroup then
    _G.NRCModeManager:DoCmd(MusicCollectionModuleCmd.MusicUPanelPause)
    _G.NRCAudioManager:BatchSetState(StateGroup)
  end
  self.FirstSelectItem = true
end

function UMG_RelationTreeEggs_C:OnDestruct()
  self.NRCScrollView_Eggs:ClearSelection()
  if self.BagModuleData then
    self.BagModuleData:SetCurSelectedItemData(nil)
  end
  local StateGroup = _G.DataModelMgr.PlayerDataModel:GetStateGroupByApplyEnum(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_BAG)
  if StateGroup then
    _G.NRCModeManager:DoCmd(MusicCollectionModuleCmd.MusicUPanelPlay)
  end
  _G.DataModelMgr.PlayerDataModel:RemovePanelMusic(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_BAG)
  _G.NRCModuleManager:GetModule("BagModule"):UnRegisterEvent(self, BagModuleEvent.SetChooseItemInfo, self.SetItemInfo)
  _G.NRCModuleManager:GetModule("BagModule"):UnRegisterEvent(self, BagModuleEvent.SetSortType, self.SortItemByEvent)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.UpdateSort, self.UpdateSort)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  _G.NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.UNLOCK_RELATION_SHIP_NODE_REQ, self.OnCloseButtonClicked)
end

function UMG_RelationTreeEggs_C:OnActive(panelData)
  self.PanelData = panelData
  self.BagModuleData = _G.NRCModuleManager:GetModule("BagModule"):GetData("BagModuleData")
  local SortList = self:GetSortList()
  local DropDownListInfo = {}
  for i = 1, #SortList do
    table.insert(DropDownListInfo, {
      ComType = CommonBtnEnum.ComboBoxType.RelationEggs,
      name = SortList[i].text,
      sortList = SortList,
      isHideRedDot = true
    })
  end
  local comboBoxText = SortList[1].text
  local selectIndex = 1
  self:SetCommonComboBoxInfo(self.ComboBox, DropDownListInfo, selectIndex, comboBoxText)
  self.CloseBtn.NRCSwitcher_1:SetActiveWidgetIndex(1)
  self.BagIcon1:PlayDefauleSelecteAnim()
  self.BagIcon1:PlayLoopAnim()
  self.MiddleBtn3:SetBtnText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_choose_btn").msg)
  self:UpdatePanel(self.PanelData)
  self.isFirstSelectItem = true
  self.HasItemSwitcher:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.BG2:SetVisibility(UE4.ESlateVisibility.Hidden)
  _G.NRCAudioManager:PlaySound2DAuto(40002001, "UMG_RelationTreeEggs_C:OnActive")
end

function UMG_RelationTreeEggs_C:OnDeactive()
  UE4.UNRCTUIStatics.SetEnableUIOnlyRendering(false)
end

function UMG_RelationTreeEggs_C:UpdatePanel(panelData)
  self:SetMoneyItemInfo(panelData.panelType)
  if panelData.panelType == panelData.EggPanelType.Bless then
    local cost = self.Cost
    local path = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_BRAVE_STAR).iconPath
    self.MiddleBtn3:SetTitleTextAndIcon(path, cost)
    self.ParticularsBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif panelData.panelType == panelData.EggPanelType.Presentation then
    self.Title1:SetBg("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_bagtitle_png.img_bagtitle_png'")
    self.Title1:Set_MainTitle(LuaText.RLTT_Giftegg_text_bag)
    self.Title1:SetSubtitle(LuaText.RLTT_Giftegg_text_title)
    self.MiddleBtn3:SetTitleTextAndIcon()
    self.MiddleBtn3.Title:SetText(LuaText.bagitem_bp_gift_card_button01)
    self.ParticularsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_RelationTreeEggs_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_SwapEggs_C", self, BagModuleEvent.UpdateSort, self.UpdateSort)
  _G.NRCModuleManager:GetModule("BagModule"):RegisterEvent(self, BagModuleEvent.SetChooseItemInfo, self.SetItemInfo)
  _G.NRCModuleManager:GetModule("BagModule"):RegisterEvent(self, BagModuleEvent.SetSortType, self.SortItemByEvent)
  _G.NRCEventCenter:RegisterEvent(self.name, self, RelationTreeEvent.UNLOCK_RELATION_SHIP_NODE_REQ, self.OnCloseButtonClicked)
  _G.NRCEventCenter:RegisterEvent("UMG_RelationTreeEggs_C", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.MiddleBtn3.btnLevelUp, self.OnBtnMiddle3Clicked)
  self:AddButtonListener(self.ParticularsBtn.btnLevelUp, self.OnBtnParticularsClicked)
end

function UMG_RelationTreeEggs_C:SetCommonComboBoxInfo(ComboBox, DropDownListInfo, DropDownListIndex, DropDownListText, ComboBoxText, ComboBoxIcon)
  local CommonDropDownListData = _G.NRCCommonDropDownListData()
  if DropDownListInfo then
    CommonDropDownListData.DropDownListInfo = DropDownListInfo
  end
  CommonDropDownListData.ComType = CommonBtnEnum.ComboBoxType.Bag
  if DropDownListIndex then
    CommonDropDownListData.DropDownListIndex = DropDownListIndex
  end
  if DropDownListText then
    CommonDropDownListData.DropDownListText = DropDownListText
  end
  if ComboBoxText then
    CommonDropDownListData.DropDownListText = ComboBoxText
  end
  if ComboBoxIcon then
    CommonDropDownListData.DropDownListIcon = ComboBoxIcon
  end
  CommonDropDownListData.Call = self
  CommonDropDownListData.Btn_RightHandler = self.OnClickSequenceBtn
  ComboBox:SetPanelInfo(CommonDropDownListData)
end

function UMG_RelationTreeEggs_C:OnDisconnect()
  self:DoClose()
end

function UMG_RelationTreeEggs_C:OnAnimationFinished(Animation)
  if Animation == self.open then
  elseif Animation == self.close then
    self:DoClose()
  end
end

function UMG_RelationTreeEggs_C:OnPcClose()
  self:OnCloseButtonClicked()
end

function UMG_RelationTreeEggs_C:GetSortList()
  local SortList = self.BagModuleData:GetSortTypesByItemType(Enum.ItemLableType.ILT_PET_EGG)
  if self.sequenceList == nil then
    self.sequenceList = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.BAG_ITEM_SEQUENCE):GetAllDatas()
  end
  local List = {}
  for i = 1, #SortList do
    local SortInfo = {}
    local SortID = SortList[i]
    for _, v in pairs(self.sequenceList) do
      if v.sequence == SortID then
        local name = v.sequence_desc
        SortInfo.text = name
        SortInfo.sequence = SortID
        break
      end
    end
    table.insert(List, SortInfo)
  end
  return List
end

function UMG_RelationTreeEggs_C:OnClickSortBtn()
  if self.SelectState then
    return
  end
  local SortList = self.BagModuleData:GetSortTypesByItemType(Enum.ItemLableType.ILT_PET_EGG)
  local List = {}
  for i = 1, #SortList do
    local SortInfo = {}
    local SortID = SortList[i]
    local Name = _G.DataConfigManager:GetBagItemSequence(SortID + 1).sequence_desc
    SortInfo.text = Name
    SortInfo.sequence = SortID
    table.insert(List, SortInfo)
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenBagSortPanel, List, self.BagModuleData.SortIndex)
end

function UMG_RelationTreeEggs_C:OnClickSequenceBtn()
  if self.SelectState then
    return
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.ReversalBagSort, _G.Enum.ItemLableType.ILT_PET_EGG)
  if self.BagModuleData:GetTabSortIsReversalSort(_G.Enum.ItemLableType.ILT_PET_EGG) then
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(-1, 1))
  else
    self.ComboBox.SortingBtn:SetRenderScale(UE4.FVector2D(-1, -1))
  end
  local SelectIndex = -1
  if self.EggGid then
    for i = 1, #self.SortList do
      if self.SortList[i].gid == self.EggGid then
        SelectIndex = i - 1
      end
    end
  end
  if -1 ~= SelectIndex then
    local Item = self.NRCScrollView_Eggs:GetItemByIndex(SelectIndex)
    if Item then
      Item:OnItemSelected(false)
    end
  end
  self:DelaySeconds(0.1, self.SortItem, self, Enum.ItemLableType.ILT_PET_EGG, self.BagModuleData.SortIndex, SelectIndex)
end

function UMG_RelationTreeEggs_C:OnBtnMiddle3Clicked()
  if not self.EggGid or not self.PanelData then
    return
  end
  if self.PanelData.panelType == self.PanelData.EggPanelType.Bless then
    local argData = self.PanelData.argData
    local data = {
      targetUin = argData.targetUin,
      petId = argData.petId,
      petNpcId = argData.petNpcId,
      eggGid = self.EggGid,
      bagitemId = self.ItemID
    }
    local text = string.format(LuaText.interactiontree_cifu_req_check, argData.targetName)
    local PopupData = {
      isEgg = true,
      UnLockText = text,
      CostNum = self.Cost,
      Data = data,
      IsLocal = argData.isLocal
    }
    _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.OpenUnlockInvitationPopup, PopupData)
  elseif self.PanelData.panelType == self.PanelData.EggPanelType.Presentation then
    local argData = self.PanelData.argData
    local text = string.format(LuaText.RLTT_Giftegg_text_give_check, argData.targetName)
    local PopupData = {
      targetUin = argData.targetUin,
      actionId = argData.actionId,
      petEggId = self.ItemID,
      eggGid = self.EggGid,
      text = text
    }
    _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.OpenComplimentaryPetEggs, PopupData)
  end
end

function UMG_RelationTreeEggs_C:OnBtnParticularsClicked()
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local name = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_BRAVE_STAR).displayName
  local des = string.format(LuaText.interactiontree_cifu_inf, name)
  Context:SetTitle(LuaText.interactiontree_cifu_tip_title):SetContent(des):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true):SetCloseOnOK(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_RelationTreeEggs_C:OnCloseButtonClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_RelationTreeEggs_C:OnCloseButtonClicked")
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    return
  end
  self:PlayAnimation(self.close)
end

function UMG_RelationTreeEggs_C:SetMoneyItemInfo(panelType)
  local CoinNum = self.BagModuleData:GetvItemNum(_G.Enum.VisualItem.VI_DIAMOND) or 0
  local DiamondNum = self.BagModuleData:GetvItemNum(_G.Enum.VisualItem.VI_BRAVE_STAR) or 0
  local MoneyDatas = {
    {
      moneyType = _G.Enum.VisualItem.VI_DIAMOND,
      sum = CoinNum
    },
    {
      moneyType = _G.Enum.VisualItem.VI_BRAVE_STAR,
      sum = DiamondNum
    }
  }
  if panelType == self.PanelData.EggPanelType.Bless then
    self.MoneyBtn:InitGridView({
      MoneyDatas[2]
    })
  elseif panelType == self.PanelData.EggPanelType.Presentation then
    self.MoneyBtn:InitGridView({
      MoneyDatas[1]
    })
  end
end

function UMG_RelationTreeEggs_C:SetHiddenMoney(isHidden)
  if isHidden then
    self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ParticularsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ParticularsBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_RelationTreeEggs_C:SetItemInfo(ItemID, ItemGID)
  if self.SelectState then
    return
  end
  if self.FirstSelectItem then
    self.FirstSelectItem = false
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_RelationTreeEggs_C:SetItemInfo")
  else
    _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_RelationTreeEggs_C:SetItemInfo")
  end
  local ItemInfo = _G.DataConfigManager:GetBagItemConf(ItemID)
  if not ItemInfo then
    return
  end
  self.ItemID = ItemID
  self.EggGid = ItemGID
  local ItemData = self.BagModuleData:GetCurSelectedItemData()
  local EggData = ItemData.egg_data
  self.ItemID = ItemID
  local isHaveBook, name, desc = _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdCheckItemInHandbook, ItemInfo.id)
  self.PetEggIcon:SetEggIcon(EggData, ItemInfo.big_icon)
  if isHaveBook then
    self.ItemName:SetText(name)
    self.ItemDesc:InitText(desc)
  else
    self.ItemName:SetText(ItemInfo.name)
    self.ItemDesc:InitText(ItemInfo.description)
  end
  self.PetEggTypeIconItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.PetEggTypeIconItem:SetItemIcon(ItemGID)
  self.ItemProperty:SetText(ItemInfo.type_desc)
  if false == self.isFirstSelectItem then
    self:PlayAnimation(self.Change_Icon)
  end
  self:RandomPlayAnimation()
  if self.PanelData and self.PanelData.panelType == self.PanelData.EggPanelType.Presentation then
    local FindTimeInfo = {
      name = LuaText.umg_bag_1,
      type = 2,
      des = os.date("%Y-%m-%d", ItemData.update_time)
    }
    local HeightInfo = {
      name = LuaText.umg_bag_2,
      type = 0,
      des = EggData.height * 0.01
    }
    local WeightInfo = {
      name = LuaText.umg_bag_4,
      type = 1,
      des = EggData.weight * 0.001
    }
    self.EggItem1:OnShowItem(HeightInfo)
    self.EggItem2:OnShowItem(WeightInfo)
    self.EggItem3:OnShowItem(FindTimeInfo)
    self.EggItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.EggItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_RelationTreeEggs_C:UpdateSort(Index, Data)
  self:SortItemByEvent(Index)
end

function UMG_RelationTreeEggs_C:SortItemByEvent(idx)
  local SortList = self:GetSortList()
  local SortType = SortList[idx].sequence
  local SelectIndex = -1
  if self.EggGid then
    for i = 1, #self.SortList do
      if self.SortList[i].gid == self.EggGid then
        SelectIndex = i - 1
      end
    end
  end
  if -1 ~= SelectIndex then
    local Item = self.NRCScrollView_Eggs:GetItemByIndex(SelectIndex)
    if Item then
      Item:OnItemSelected(false)
    end
  end
  self:DelaySeconds(0.1, self.SortItem, self, _G.Enum.ItemLableType.ILT_PET_EGG, SortType, SelectIndex)
end

function UMG_RelationTreeEggs_C:SortItem(ItemType, SortType, SelectIndex)
  local eggList = self.BagModuleData:SortItemListByLableType(ItemType, SortType)
  self.SortList = {}
  if self.PanelData.panelType == self.PanelData.EggPanelType.Bless then
    local curFristId = self.PanelData.argData.petbaseId
    local repeatDic = {}
    local curBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PanelData.argData.petbaseId)
    if curBaseConf and curBaseConf.pet_evolution_id and #curBaseConf.pet_evolution_id > 0 then
      local petEvoConf = _G.DataConfigManager:GetPetEvolutionConf(curBaseConf.pet_evolution_id[1])
      if petEvoConf and petEvoConf.evolution_chain and #petEvoConf.evolution_chain > 0 then
        for _, v in pairs(petEvoConf.evolution_chain) do
          if 1 == v.stage then
            curFristId = v.petbase_id
            break
          end
        end
      end
    end
    local items = eggList
    if items and #items > 0 then
      for i, bagItem in pairs(items) do
        if bagItem and bagItem.conf and bagItem.egg_data then
          local eggId = bagItem.conf.item_behavior[1].ratio[1]
          local eggConf = _G.DataConfigManager:GetPetEggConf(eggId)
          if eggConf and eggConf.pet_id then
            local petConf = _G.DataConfigManager:GetPetConf(eggConf.pet_id)
            if petConf and petConf.base_id then
              local eggEvoFirstBaseIds = _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.GetPetEvoGroupFirstBaseIds, petConf.base_id)
              for _, eggEvoBaseId in pairs(eggEvoFirstBaseIds) do
                if eggEvoBaseId == curFristId then
                  local ConfIsPrecious = eggConf and eggConf.precious_egg_type and eggConf.precious_egg_type ~= _G.Enum.PreciousEggType.PET_NONE or false
                  local DataIsPrecious = bagItem.egg_data.precious_egg_type and bagItem.egg_data.precious_egg_type ~= _G.Enum.PreciousEggType.PET_NONE or false
                  if false == ConfIsPrecious and false == DataIsPrecious and repeatDic[bagItem.gid] == nil then
                    repeatDic[bagItem.gid] = true
                    table.insert(self.SortList, bagItem)
                  end
                end
              end
            end
          end
        end
      end
    end
  elseif eggList and #eggList > 0 then
    for _, eggItem in pairs(eggList) do
      if eggItem.egg_data and eggItem.egg_data.precious_egg_type ~= nil then
        if _G.NRCModeManager:DoCmd(PetUIModuleCmd.GetEggIsCanGiveAwayByEggType, eggItem.egg_data.precious_egg_type) then
          table.insert(self.SortList, eggItem)
        end
      else
        local eggConf = _G.DataConfigManager:GetPetEggConf(eggItem.egg_data.conf_id)
        if eggConf and eggConf.precious_egg_type and _G.NRCModeManager:DoCmd(PetUIModuleCmd.GetEggIsCanGiveAwayByEggType, eggConf.precious_egg_type) then
          table.insert(self.SortList, eggItem)
        end
      end
    end
  end
  self.NRCScrollView_Eggs:Clear()
  if -1 == SelectIndex then
    self.BagModuleData:SetFirstOpenPanelId(-1)
  end
  if #self.SortList > 0 then
    self.HasItemSwitcher:SetActiveWidgetIndex(0)
    self.BGSwitcher:SetActiveWidgetIndex(0)
    local SelectItem = self.BagModuleData:GetCurSelectedItemData()
    self.NRCScrollView_Eggs:InitList(self.SortList)
    local FindItemIndex
    if SelectItem and SelectItem.id then
      FindItemIndex = self:FindUseItemIndex(SelectItem)
    end
    if FindItemIndex then
      self.NRCScrollView_Eggs:SelectItemByIndex(FindItemIndex)
    elseif -1 == SelectIndex then
      self.NRCScrollView_Eggs:SelectItemByIndex(0)
    else
      self.NRCScrollView_Eggs:SelectItemByIndex(SelectIndex)
    end
  else
    self.HasItemSwitcher:SetActiveWidgetIndex(1)
    self.BGSwitcher:SetActiveWidgetIndex(1)
  end
  if self.isFirstSelectItem then
    self.isFirstSelectItem = false
    self:PlayAnimation(self.open)
    self.HasItemSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BG2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_RelationTreeEggs_C:FindUseItemIndex(SelectItem)
  for i, Item in ipairs(self.SortList) do
    if Item.gid == SelectItem.gid then
      return i - 1
    end
  end
end

function UMG_RelationTreeEggs_C:RandomPlayAnimation()
  local index = math.random(1, 4)
  local aimName = string.format("star%d", index)
  self:PlayAnimation(self[aimName])
end

function UMG_RelationTreeEggs_C:OnTouchEnded(_MyGeometry, _InTouchEvent)
  if self.ComboBox.bShowList then
    self.ComboBox:SetPopupVisible(false)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

return UMG_RelationTreeEggs_C
