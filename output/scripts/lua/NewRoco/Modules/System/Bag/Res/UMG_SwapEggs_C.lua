local UMG_SwapEggs_C = _G.NRCPanelBase:Extend("UMG_SwapEggs_C")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local CommonBtnEnum = require("NewRoco.Modules.System.CommonBtn.CommonBtnEnum")

function UMG_SwapEggs_C:OnConstruct()
  _G.DataModelMgr.PlayerDataModel:AddPanelMusic(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_BAG)
  local StateGroup = _G.DataModelMgr.PlayerDataModel:GetStateGroupByApplyEnum(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_BAG)
  if StateGroup then
    _G.NRCModeManager:DoCmd(MusicCollectionModuleCmd.MusicUPanelPause)
    _G.NRCAudioManager:BatchSetState(StateGroup)
  end
  _G.NRCEventCenter:RegisterEvent("UMG_SwapEggs_C", self, FriendModuleEvent.NotifyPickEggResult, self.OnNotifyPickEggResult)
  _G.NRCEventCenter:RegisterEvent("UMG_SwapEggs_C", self, FriendModuleEvent.NotifyExchangeEggResult, self.OnNotifyExchangeEggResult)
  _G.NRCEventCenter:RegisterEvent("UMG_SwapEggs_C", self, FriendModuleEvent.ResZonePickEggResult, self.OnResZonePickEggResult)
  _G.NRCEventCenter:RegisterEvent("UMG_SwapEggs_C", self, BagModuleEvent.UpdateSort, self.UpdateSort)
  _G.NRCEventCenter:RegisterEvent("UMG_SwapEggs_C", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  self:RegisterEvent(self, BagModuleEvent.SetChooseItemInfo, self.SetItemInfo)
  self:RegisterEvent(self, BagModuleEvent.SetSortType, self.SortItemByEvent)
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.inputComponent:SetInputEnable(self, false)
  self:SetCommonTitle()
  self.NRCText:SetText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_choosing").msg)
  self.NRCText_58:SetText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_chosen").msg)
  self.FirstSelectItem = true
  self.bIsScreening = false
end

function UMG_SwapEggs_C:OnDestruct()
  local StateGroup = _G.DataModelMgr.PlayerDataModel:GetStateGroupByApplyEnum(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_BAG)
  if StateGroup then
    _G.NRCModeManager:DoCmd(MusicCollectionModuleCmd.MusicUPanelPlay)
  end
  _G.DataModelMgr.PlayerDataModel:RemovePanelMusic(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_BAG)
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.NotifyPickEggResult, self.OnNotifyPickEggResult)
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.NotifyExchangeEggResult, self.OnNotifyExchangeEggResult)
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.ResZonePickEggResult, self.OnResZonePickEggResult)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.UpdateSort, self.UpdateSort)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
end

function UMG_SwapEggs_C:OnActive()
  self:OnAddEventListener()
  self.ModuleData = self.module:GetData("BagModuleData")
  self.ModuleData:SetCurItemType(Enum.ItemLableType.ILT_PET_EGG)
  self.SelectState = false
  local SortList = self.ModuleData:GetSortTypesByItemType(Enum.ItemLableType.ILT_PET_EGG)
  self.ModuleData:SetCurSortList(SortList)
  local SortList = self:GetSortList()
  local DropDownListInfo = {}
  for i = 1, #SortList do
    table.insert(DropDownListInfo, {
      ComType = CommonBtnEnum.ComboBoxType.SwapEggs,
      name = SortList[i].text,
      sortList = SortList,
      isHideRedDot = true
    })
  end
  local comboBoxText, selectIndex
  if self.ModuleData.SortIndex == _G.Enum.Sequence.SEQUENCE_DEFAULT then
    comboBoxText = SortList[1].text
    selectIndex = 1
  elseif self.ModuleData.SortIndex == _G.Enum.Sequence.SEQUENCE_QUALITY_UP or self.ModuleData.SortIndex == _G.Enum.Sequence.SEQUENCE_QUALITY_DOWN or self.ModuleData.SortIndex == _G.Enum.Sequence.SEQUENCE_QUALITY then
    comboBoxText = SortList[2].text
    selectIndex = 2
  end
  self:SetCommonComboBoxInfo(self.ComboBox, DropDownListInfo, selectIndex, comboBoxText)
  self.CloseBtn.NRCSwitcher_1:SetActiveWidgetIndex(1)
  self.BagIcon1:PlayDefauleSelecteAnim()
  self.NRCText:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRCText_58:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.MiddleBtn3:SetBtnText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_choose_btn").msg)
  self:PlayAnimation(self.open)
  self:SetMoneyItemInfo()
  _G.NRCAudioManager:PlaySound2DAuto(40002001, "UMG_SwapEggs_C:OnActive")
end

function UMG_SwapEggs_C:OnDeactive()
  UE4.UNRCTUIStatics.SetEnableUIOnlyRendering(false)
end

function UMG_SwapEggs_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.MiddleBtn3.btnLevelUp, self.OnBtnMiddle3Clicked)
end

function UMG_SwapEggs_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  if self.titleConf then
    self.Title1:Set_MainTitle(self.titleConf.title)
    self.Title1:SetBg(self.titleConf.head_icon)
    self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
  end
end

function UMG_SwapEggs_C:SetCommonComboBoxInfo(ComboBox, DropDownListInfo, DropDownListIndex, DropDownListText, ComboBoxText, ComboBoxIcon)
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

function UMG_SwapEggs_C:OnDisconnect()
  self:DoClose()
  local LocalPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  LocalPlayer.inputComponent:SetInputEnable(self, true)
end

function UMG_SwapEggs_C:OnAnimationFinished(Animation)
  if Animation == self.open then
  elseif Animation == self.close then
    self:DoClose()
    _G.NRCModeManager:DoCmd(FriendModuleCmd.OnNotifySwapEggsUIClosed)
    local LocalPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    LocalPlayer.inputComponent:SetInputEnable(self, true)
  end
end

function UMG_SwapEggs_C:GetSortList()
  local SortList = self.ModuleData:GetSortTypesByItemType(Enum.ItemLableType.ILT_PET_EGG)
  local List = {}
  for i = 1, #SortList do
    local SortInfo = {}
    local SortID = SortList[i]
    local Name = ""
    local bagItemSequenceConf = _G.DataConfigManager:GetBagItemSequence(SortID + 1)
    if bagItemSequenceConf then
      Name = bagItemSequenceConf.sequence_desc
    end
    SortInfo.text = Name
    SortInfo.sequence = SortID
    table.insert(List, SortInfo)
  end
  return List
end

function UMG_SwapEggs_C:OnClickSortBtn()
  if self.SelectState then
    return
  end
  local SortList = self.ModuleData:GetSortTypesByItemType(Enum.ItemLableType.ILT_PET_EGG)
  local List = {}
  for i = 1, #SortList do
    local SortInfo = {}
    local SortID = SortList[i]
    local Name = _G.DataConfigManager:GetBagItemSequence(SortID + 1).sequence_desc
    SortInfo.text = Name
    SortInfo.sequence = SortID
    table.insert(List, SortInfo)
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenBagSortPanel, List, self.ModuleData.SortIndex)
end

function UMG_SwapEggs_C:OnClickSequenceBtn()
  if self.SelectState then
    return
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.ReversalBagSort)
  if self.ModuleData.IsReversalSort then
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
  self:DelaySeconds(0.1, self.SortItem, self, Enum.ItemLableType.ILT_PET_EGG, self.ModuleData.SortIndex, SelectIndex)
end

function UMG_SwapEggs_C:OnBtnMiddle3Clicked()
  if not self.EggGid then
    return
  end
  local Module = _G.NRCModuleManager:GetModule("FriendModule")
  if self.SelectState then
    _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_SwapEggs_C:OnBtnMiddle3Clicked")
    Module:ReqZonePickEggReq(0)
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_SwapEggs_C:OnBtnMiddle3Clicked")
    Module:ReqZonePickEggReq(self.EggGid)
  end
end

function UMG_SwapEggs_C:OnCloseButtonClicked()
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    return
  end
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Dialog = DialogContext()
  Dialog:SetTitle(_G.DataConfigManager:GetLocalizationConf("petegg_trade_interrupt_tips_title").msg):SetContent(_G.DataConfigManager:GetLocalizationConf("petegg_trade_interrupt_tips").msg):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetClickAnywhereClose(true):SetCloseOnCancel(true):SetCallback(self, self.CancelSwapEggs)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Dialog)
end

function UMG_SwapEggs_C:CancelSwapEggs(IsOK)
  if not IsOK then
    return
  end
  local Module = _G.NRCModuleManager:GetModule("FriendModule")
  Module:ReqZonePickEggReq(-1)
  self:PlayAnimation(self.close)
end

function UMG_SwapEggs_C:OnNotifyPickEggResult(Result)
  if Result == ProtoEnum.ZoneScenePickEggResultNotify.Result.FINISH then
    self.NRCText_58:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif Result == ProtoEnum.ZoneScenePickEggResultNotify.Result.CANCEL then
    self.NRCText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText_58:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif Result == ProtoEnum.ZoneScenePickEggResultNotify.Result.EXIT then
    self:PlayAnimation(self.close)
  end
end

function UMG_SwapEggs_C:OnNotifyExchangeEggResult(Success)
  self:PlayAnimation(self.close)
end

function UMG_SwapEggs_C:OnResZonePickEggResult(Success)
  if not Success then
    return
  end
  self.SelectState = not self.SelectState
  if self.SelectState then
    self.MiddleBtn3:SetBtnText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_choose_cancel_btn").msg)
  else
    self.MiddleBtn3:SetBtnText(_G.DataConfigManager:GetLocalizationConf("petegg_trade_choose_btn").msg)
  end
  self:DispatchEvent(BagModuleEvent.NotifySwapEggsChanged, self.SelectState, self.EggGid)
end

function UMG_SwapEggs_C:SetMoneyItemInfo()
  local CoinNum = self.ModuleData:GetvItemNum(_G.Enum.VisualItem.VI_COIN)
  local DiamondNum = self.ModuleData:GetvItemNum(_G.Enum.VisualItem.VI_DIAMOND)
  local MoneyDatas = {
    {
      moneyType = _G.Enum.VisualItem.VI_COIN,
      sum = CoinNum
    },
    {
      moneyType = _G.Enum.VisualItem.VI_DIAMOND,
      sum = DiamondNum
    }
  }
  self.MoneyBtn:InitGridView(MoneyDatas)
end

function UMG_SwapEggs_C:SetItemInfo(ItemID, ItemGID)
  if self.SelectState then
    return
  end
  if self.FirstSelectItem then
    self.FirstSelectItem = false
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_SwapEggs_C:SetItemInfo")
  end
  local ItemInfo = _G.DataConfigManager:GetBagItemConf(ItemID)
  if not ItemInfo then
    return
  end
  self.EggGid = ItemGID
  local ItemData = self.ModuleData:GetCurSelectedItemData()
  local EggData = ItemData.egg_data
  local isHaveBook, name, desc = _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdCheckItemInHandbook, ItemInfo.id)
  self.NRCImage_101:SetPath(ItemInfo.big_icon)
  if isHaveBook then
    self.ItemName:SetText(name)
    self.ItemDesc:InitText(desc)
  else
    self.ItemName:SetText(ItemInfo.name)
    self.ItemDesc:InitText(ItemInfo.description)
  end
  self.ItemProperty:SetText(ItemInfo.type_desc)
  self:PlayAnimation(self.Change_Icon)
  self:RandomPlayAnimation()
  local FindTimeInfo = {
    name = LuaText.umg_bag_1,
    type = 2,
    des = os.date("%Y-%m-%d", ItemData.update_time)
  }
  local HeightInfo = {
    name = LuaText.umg_bag_2,
    type = 0,
    des = string.format(LuaText.umg_bag_3, EggData.height * 0.01)
  }
  local WeightInfo = {
    name = LuaText.umg_bag_4,
    type = 1,
    des = string.format(LuaText.umg_bag_5, EggData.weight * 0.001)
  }
  local InfoList = {
    HeightInfo,
    WeightInfo,
    FindTimeInfo
  }
  self.EggItem1:OnShowItem(WeightInfo)
  self.EggItem2:OnShowItem(HeightInfo)
  self.EggItem3:OnShowItem(FindTimeInfo)
end

function UMG_SwapEggs_C:UpdateSort(Index, Data)
  _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.OnSequenceSelected, Index, Data)
end

function UMG_SwapEggs_C:SortItemByEvent(ItemType, SortType)
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
  self:DelaySeconds(0.1, self.SortItem, self, ItemType, SortType, SelectIndex)
end

function UMG_SwapEggs_C:SortItem(ItemType, SortType, SelectIndex)
  self.SortList = self.ModuleData:SortItemListByLableType(ItemType, SortType)
  self.NRCScrollView_Eggs:Clear()
  for i = #self.SortList, 1, -1 do
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.SortList[i].id)
    if BagItemConf then
      local Conf = _G.DataConfigManager:GetPetEggConf(BagItemConf.item_behavior[1].ratio[1])
      if Conf and Conf.precious_egg_type and Conf.precious_egg_type ~= _G.Enum.PreciousEggType.PET_NONE then
        table.remove(self.SortList, i)
      end
    end
  end
  if -1 == SelectIndex then
    self.ModuleData:SetFirstOpenPanelId(-1)
  end
  if #self.SortList > 0 then
    self.HasItemSwitcher:SetActiveWidgetIndex(0)
    self.BGSwitcher:SetActiveWidgetIndex(0)
    local SelectItem = self.ModuleData:GetCurSelectedItemData()
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
  self:ChangeSortText(ItemType)
  self:DispatchEvent(BagModuleEvent.NotifySwapEggsChanged, self.SelectState, self.EggGid)
end

function UMG_SwapEggs_C:ChangeSortText(ItemType)
  local SequenceList = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.BAG_ITEM_SEQUENCE):GetAllDatas()
  local SortText = ""
  local SortList = self.ModuleData:GetSortTypesByItemType(ItemType)
  local SortSelectIndex = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetTableSortSelectIndex, ItemType)
  local SortIndex = SortList[SortSelectIndex]
  for i, Conf in pairs(SequenceList) do
    if Conf.sequence == SortIndex then
      SortText = Conf.sequence_desc
      break
    end
  end
  self.ComboBox:SetComboText(SortText)
end

function UMG_SwapEggs_C:FindUseItemIndex(SelectItem)
  for i, Item in ipairs(self.SortList) do
    if Item.id == SelectItem.id then
      return i - 1
    end
  end
end

function UMG_SwapEggs_C:RandomPlayAnimation()
  local index = math.random(1, 4)
  local aimName = string.format("star%d", index)
  self:PlayAnimation(self[aimName])
end

return UMG_SwapEggs_C
