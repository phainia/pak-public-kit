local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Pet_Impression_C = _G.NRCViewBase:Extend("UMG_Pet_Impression_C")

function UMG_Pet_Impression_C:OnConstruct()
  self:SetChildViews(self.Impression_Item_1, self.Impression_Item_2, self.Impression_Item_3, self.Impression_Item_4, self.Impression_Item)
  self.Buttons = {
    self.Impression_Item_1,
    self.Impression_Item_2,
    self.Impression_Item_3,
    self.Impression_Item_4
  }
  self.Impression_Item_1:RegisterGroupButton(1)
  self.Impression_Item_2:RegisterGroupButton(2)
  self.Impression_Item_3:RegisterGroupButton(3)
  self.Impression_Item_4:RegisterGroupButton(4)
  self.isNotCoins = true
  _G.NRCModuleManager:GetModule("PetUIModule"):RegisterEvent(self, PetUIModuleEvent.ImpressionChangeSelect, self.OnSelectChange)
  _G.NRCEventCenter:RegisterEvent("PetUIModule", self, BagModuleEvent.GoodChangeTypeEnum.GT_PET, self.OnPetDataChange)
  self:RegisterEvent(self, PetUIModuleEvent.OnChangePetBagState, self.ChangeBagState)
  self:OnAddEventListener()
end

function UMG_Pet_Impression_C:OnActive()
end

function UMG_Pet_Impression_C:OnPetDataChange(GoodsChangeItem, CmdID)
  self:UpdatePetInfo(GoodsChangeItem.pet_data)
end

function UMG_Pet_Impression_C:ChangeBagState(isOpen)
  if isOpen then
    self:PlayAnimation(self.Zoom_In)
  else
    self:PlayAnimation(self.Zoom_Out)
  end
end

function UMG_Pet_Impression_C:PlayImpressionAnimation()
  self:PlayAnimation(self.In)
end

function UMG_Pet_Impression_C:OnLevelUp()
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenImpressionUnLockPanel)
end

function UMG_Pet_Impression_C:UpdatePetInfo(petInfo, petInfoMainCtrl)
  if nil == petInfo then
    return
  end
  self.petInfoMainCtrl = petInfoMainCtrl
  self.petGid = petInfo.gid
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGid)
  self.petData = petData
  if not petData then
    return
  end
  local num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN)
  local baseId = petData.base_conf_id
  self.PetBaseConf = _G.DataConfigManager:GetPetbaseConf(baseId)
  local group_id = self.PetBaseConf.belong_habit_group
  if 0 == group_id then
    return
  end
  self.HabitConf = self:GetImpressionGroupConf(group_id)
  self:ResettingButtonSelect()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetCurSelectImpressionIndex, 0)
  self:SetButtonsInfo(petData)
  self.selectIndex = petData.habit_level + 1
  if self.selectIndex <= #self.Buttons then
    self.Buttons[self.selectIndex]:ClickItemButton()
  else
    self.Buttons[1]:ClickItemButton()
  end
end

function UMG_Pet_Impression_C:ResettingButtonSelect()
  if self.Buttons then
    for i = 1, #self.Buttons do
      local button = self.Buttons[i]
      button:DefaultItem()
    end
  end
end

function UMG_Pet_Impression_C:GetImpressionGroupConf(group_id)
  local habits = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PET_HABIT_CONF):GetAllDatas()
  local groupConf = {}
  for i, conf in pairs(habits) do
    if conf.group_id == group_id then
      table.insert(groupConf, conf)
    end
  end
  return groupConf
end

function UMG_Pet_Impression_C:SetButtonsInfo(petInfo)
  local dataList = {}
  for i = 1, #self.HabitConf do
    local info = {}
    info.conf = self.HabitConf[i]
    info.level = petInfo.habit_level
    info.gid = self.petData.gid
    table.insert(dataList, info)
  end
  table.sort(dataList, function(a, b)
    return a.conf.group_number < b.conf.group_number
  end)
  for i = 1, #dataList do
    if i <= #self.Buttons then
      self.Buttons[i]:SetInfo(dataList[i])
    end
  end
end

function UMG_Pet_Impression_C:OnSelectChange(index, data)
  if data then
    self:SetInfo(data)
  end
end

function UMG_Pet_Impression_C:SetInfo(data)
  local level = self.petData.habit_level
  local conf = data.conf
  local itemDatas = {}
  local bagItem = self:GetItem(conf.unlock_item_id)
  local item = {}
  self.curData = data
  item.id = conf.unlock_item_id
  item.conf = _G.DataConfigManager:GetBagItemConf(conf.unlock_item_id)
  item.num = 0
  if bagItem then
    item.num = bagItem.num
  end
  item.maxNum = conf.unlock_item_num
  table.insert(itemDatas, item)
  local isLock = level >= data.conf.group_number
  self.Title:SetText(data.conf.group_number)
  self.Title_1:SetText(conf.name)
  self.Title1_4:SetText(conf.desc)
  self.TextBlock_1:SetText(conf.effect_desc)
  self.ListIcon:InitGridView(itemDatas)
  self.needMoney:SetText(conf.unlock_money)
  local bagModuleData = _G.NRCModuleManager:GetModule("BagModule"):GetData("BagModuleData")
  local coin_num = bagModuleData:GetvItemNum(_G.Enum.VisualItem.VI_COIN)
  self.needMoney_1:SetText(coin_num)
  self:ShowLock(isLock)
  self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if level + 1 == data.conf.group_number then
    self.HorizontalBox_59:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Centre:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN)
    if num >= conf.unlock_money and bagItem and bagItem.num >= conf.unlock_item_num then
      self.Switcher:SetActiveWidgetIndex(0)
      self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Switcher:SetActiveWidgetIndex(0)
      if num < conf.unlock_money then
        local numStr = string.format("<span color=\"#AF3D3EFF\" size=\"30\" font=\"/Game/NewRoco/Font/244-ShangShouDunDun_Font\">%d</>", conf.unlock_money)
        self.needMoney:SetText(numStr)
        self.isNotCoins = true
        self.WidgetSwitcher_105:SetActiveWidgetIndex(0)
      else
        self.isNotCoins = false
        self.WidgetSwitcher_105:SetActiveWidgetIndex(1)
      end
    end
  end
  if level + 1 < data.conf.group_number then
    self.Switcher:SetActiveWidgetIndex(2)
    self.HorizontalBox_59:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Centre:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if isLock then
    self.Switcher:SetActiveWidgetIndex(3)
  end
end

function UMG_Pet_Impression_C:GetItem(id)
  local type = _G.DataConfigManager:GetBagItemConf(id).type
  local lst = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, type)
  for i, item in pairs(lst) do
    if item.id == id then
      return item
    end
  end
end

function UMG_Pet_Impression_C:ShowLock(isLock)
  local lock = UE4.ESlateVisibility.Collapsed
  if false == isLock then
    lock = UE4.ESlateVisibility.Visible
  end
  self.TextBlock_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(isLock and "#FBC562FF" or "#908F85FF"))
  self.icon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(isLock and "#FBC562FF" or "#908F85FF"))
  self.Centre:SetVisibility(lock)
  self.NRCImage_9:SetVisibility(lock)
  self.HorizontalBox_59:SetVisibility(lock)
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_Pet_Impression_C:OnDeactive()
  if self.Impression_Item_1 then
    self.Impression_Item_1:OnDeactive()
  end
  if self.Impression_Item_2 then
    self.Impression_Item_2:OnDeactive()
  end
  if self.Impression_Item_3 then
    self.Impression_Item_3:OnDeactive()
  end
  if self.Impression_Item_4 then
    self.Impression_Item_4:OnDeactive()
  end
  if self.Impression_Item_5 then
    self.Impression_Item_5:OnDeactive()
  end
  self:StopAllAnimations()
end

function UMG_Pet_Impression_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Explore.btnLevelUp, self.OnClickBtn)
  self:AddButtonListener(self.NRCButton_62, self.OnClickNotItemBtn)
end

function UMG_Pet_Impression_C:OnClickBtn()
  if self.curData then
    local conf = self.curData.conf
    local bagItem = self:GetItem(conf.unlock_item_id)
    local num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN)
    if num < conf.unlock_money then
      _G.NRCAudioManager:PlaySound2DAuto(41401016, "UMG_PetLeftPanelMenuButton_C:OnTouchEnded")
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.pet_habit_unlock_tips_no_coin)
    elseif bagItem and bagItem.num < conf.unlock_item_num then
      _G.NRCAudioManager:PlaySound2DAuto(41401016, "UMG_PetLeftPanelMenuButton_C:OnTouchEnded")
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.pet_habit_unlock_button_no_item)
    elseif nil == bagItem then
      _G.NRCAudioManager:PlaySound2DAuto(41401016, "UMG_PetLeftPanelMenuButton_C:OnTouchEnded")
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.pet_habit_unlock_button_no_item)
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetLeftPanelMenuButton_C:OnTouchEnded")
      local item = self.Buttons[self.selectIndex]
      item:OnLevelUp()
      self:ShowLock(false)
    end
  end
end

function UMG_Pet_Impression_C:OnClickNotItemBtn()
  if self.isNotCoins then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.pet_habit_unlock_tips_no_coin)
  else
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.pet_habit_unlock_button_no_item)
  end
end

function UMG_Pet_Impression_C:OnDestruct()
  _G.NRCModuleManager:GetModule("PetUIModule"):UnRegisterEvent(self, PetUIModuleEvent.ImpressionChangeSelect, self.OnSelectChange)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.GoodChangeTypeEnum.GT_PET, self.OnPetDataChange)
  self:RegisterEvent(self, PetUIModuleEvent.OnChangePetBagState, self.ChangeBagState)
end

function UMG_Pet_Impression_C:OnAnimationFinished(anim)
  if anim == self.In then
    self:StopAllAnimations()
    self:PlayAnimation(self.Loop, 0, 99999)
  end
end

function UMG_Pet_Impression_C:OnPanelStateChange(_IsShow)
  if _IsShow then
    local isOpenPetBag = self.petInfoMainCtrl:GetPetBagOpenState()
    local isOpenAttr = self.petInfoMainCtrl:GetAttributeOpenState()
    self:StopAllAnimations()
    self:PlayAnimation(self.In)
    if isOpenAttr and isOpenPetBag then
      self:PlayAnimation(self.Zoom_In)
    else
      self:PlayAnimation(self.Zoom_Out)
    end
  else
    self:PlayAnimation(self.Out)
  end
end

function UMG_Pet_Impression_C:OnPlayMinInPanel()
  local isOpenPetBag = self.petInfoMainCtrl:GetPetBagOpenState()
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
  if isOpenPetBag then
    self:PlayAnimation(self.Zoom_In)
  end
end

function UMG_Pet_Impression_C:OnPlayMinOutPanel()
  local isOpenPetBag = self.petInfoMainCtrl:GetPetBagOpenState()
  self:StopAllAnimations()
  if isOpenPetBag then
    self:PlayAnimation(self.Zoom_Out)
  end
  self:PlayAnimation(self.Out)
end

return UMG_Pet_Impression_C
