local UMG_FoodProcessingPanel_C = _G.NRCPanelBase:Extend("UMG_FoodProcessingPanel_C")

function UMG_FoodProcessingPanel_C:OnConstruct()
  self:RefreshViewFixedShow()
end

function UMG_FoodProcessingPanel_C:OnActive()
  _G.NRCAudioManager:PlaySound2DAuto(40002011, "UMG_FoodProcessingPanel_C:OnActive")
  self:InitData()
  self:RefreshView()
  self:OnAddEventListener()
  if self.curFoodIndex then
    self.GridView1:SelectItemByIndex(self.curFoodIndex - 1)
    self:RefreshRightView()
  end
end

function UMG_FoodProcessingPanel_C:OnDeactive()
end

function UMG_FoodProcessingPanel_C:OnDestruct()
  self:RemoveAllButtonListener()
  self:UnRegisterAllEvent()
end

function UMG_FoodProcessingPanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnBtnCloseClick)
  self:AddButtonListener(self.MakeBtn1.btnLevelUp, self.OnBtnProductionClick)
  self:AddButtonListener(self.Btn1, self.OnBtn1Click)
  self:AddButtonListener(self.Btn2, self.OnBtn2Click)
  self:AddButtonListener(self.Btn3, self.OnBtn3Click)
  self:RegisterEvent(self, _G.HomeIndoorSandbox.Event.OnFoodProcessingSelectFood, self.OnFoodProcessingSelectFood)
end

function UMG_FoodProcessingPanel_C:InitData()
  self.foodInfoList = {}
  self.curFoodIndex = nil
  self.curMaxProductionNum = 0
  self.curProductionNum = 0
  local allFoodProductionInfo = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetAllFoodProductionInfo)
  self.homeLv = 1
  local homeBriefInfo = _G.HomeIndoorSandbox.Server:GetLocalHomeBriefInfo()
  if homeBriefInfo then
    self.homeLv = homeBriefInfo.home_level or 1
  end
  table.sort(allFoodProductionInfo, function(a, b)
    return a.unlockParam < b.unlockParam
  end)
  local lastProcessingFoodId = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetLastProcessingFoodId)
  for i, v in ipairs(allFoodProductionInfo) do
    if v.unlockType == Enum.ExchangeFormulaUnlockType.EFUT_HOME_LEVEL then
      v.isUnLock = self.homeLv >= v.unlockParam
      table.insert(self.foodInfoList, v)
      if lastProcessingFoodId == v.foodItemId then
        self.curFoodIndex = #self.foodInfoList
      end
      if not v.isUnLock then
        break
      end
    end
  end
  if not self.curFoodIndex and #self.foodInfoList > 0 then
    self.curFoodIndex = 1
  end
end

function UMG_FoodProcessingPanel_C:RefreshViewFixedShow()
  self.GrowthText1:SetText(LuaText.plant_processing_food_need_time)
  self.OutputText1:SetText(LuaText.plant_processing_food_award)
  self.OutputText1_1:SetText(LuaText.plant_processing_food_exchange_cost)
  local getItem1 = self:GetItemShowInfo(Enum.VisualItem.VI_FURNITURE_COIN, Enum.GoodsType.GT_VITEM)
  local getItem2 = self:GetItemShowInfo(Enum.VisualItem.VI_HOME_EXP, Enum.GoodsType.GT_VITEM)
  self.Icon_1:SetPath(getItem1.iconPath)
  self.Icon:SetPath(getItem2.iconPath)
  self.MakeBtn1.Title_1:SetText(LuaText.plant_processing_button_text)
  self.MakeBtn1.Title_2:SetText(LuaText.plant_processing_button_text)
  self.MakeBtn2.Title_1:SetText(LuaText.plant_processing_button_text)
  self.MakeBtn2.Title_2:SetText(LuaText.plant_processing_button_text)
  self.MakeBtn2.btnLevelUp:SetIsEnabled(false)
  self.MakeBtn2.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_FoodProcessingPanel_C:RefreshView()
  self.GridView1:InitList(self.foodInfoList)
  if #self.foodInfoList > 0 then
    self.CanvasPanel_64:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasPanel_64:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_FoodProcessingPanel_C:RefreshRightView()
  local foodInfo = self.foodInfoList[self.curFoodIndex]
  local costItem = self:GetCostItemShowInfo(foodInfo.cost_item)
  self.curMaxProductionNum = math.min(foodInfo.exchangeTimeUp, math.floor(costItem.haveNum / costItem.needNum))
  self.curProductionNum = 1
  local targetItem = self:GetItemShowInfo(foodInfo.foodItemId, foodInfo.foodItemType)
  self.Name_1:SetText(targetItem.name)
  self.ItemIcon:SetPath(targetItem.iconPath)
  self.SeedText:SetText(targetItem.haveNum)
  local costTimeStr = self:GetCostTimeStr(foodInfo.homePetFeedConf.need_time * 60)
  self.GrowthTextTime:SetText(costTimeStr)
  self.OutputText_1:SetText(foodInfo.homePetFeedConf.furniture_coin_num)
  self.OutputText:SetText(foodInfo.homePetFeedConf.home_exp_num)
  self:SetProgressBar()
  self:RefreshProductionCostAndGet()
end

function UMG_FoodProcessingPanel_C:RefreshProductionCostAndGet()
  local foodInfo = self.foodInfoList[self.curFoodIndex]
  local productionNum = math.floor(self.AddSubtract_White:GetSliderValue())
  self.OutputText1_4:SetText(LuaText.plant_processing_food_exchange_num .. productionNum)
  local singleCostItem = self:GetCostItemShowInfo(foodInfo.cost_item)
  self.ItemIcon2:SetPath(singleCostItem.iconPath)
  self.OutputText1_2:SetText(singleCostItem.haveNum)
  self.OutputText1_3:SetText("/" .. singleCostItem.needNum * productionNum)
  if singleCostItem.haveNum >= singleCostItem.needNum * productionNum then
    self.OutputText1_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#030303FF"))
  else
    self.OutputText1_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#9F0B0CFF"))
  end
end

function UMG_FoodProcessingPanel_C:SetProgressBar()
  local minValue = 0
  local maxValue = self.curMaxProductionNum > 0 and self.curMaxProductionNum or 1
  local curValue = self.curMaxProductionNum > 0 and self.curProductionNum or 1
  local CommonAddSubtractData = _G.NRCCommonAddSubtractData()
  CommonAddSubtractData.SliderInfo = {num1 = minValue, num2 = maxValue}
  CommonAddSubtractData.ProgressBarInfo = {num1 = minValue, num2 = maxValue}
  CommonAddSubtractData.AddBtnHandler = self.OnBtnAddItemClick
  CommonAddSubtractData.SubtractBtnHandler = self.OnBtnDelItemClick
  CommonAddSubtractData.MaxBtnHandler = self.OnMaxBtnHandler
  CommonAddSubtractData.SliderHandler = self.OnSliderValueChanged
  CommonAddSubtractData.Call = self
  self.AddSubtract_White:SetPanelInfo(CommonAddSubtractData)
  self.AddSubtract_White:SetSliderValue(curValue)
  self.AddSubtract_White:SetProgressBarPercent(curValue > 0 and curValue / self.AddSubtract_White:GetSliderMaxValue() or 0)
  self.curProductionNum = curValue + 1
  self:RefreshProgressBarValue(curValue)
end

function UMG_FoodProcessingPanel_C:RefreshProgressBarValue(curValue)
  if self.curProductionNum == curValue then
    return
  end
  self.curProductionNum = curValue
  self:RefreshProductionCostAndGet()
  self:SetBtnGray(0 == curValue or curValue > self.curMaxProductionNum)
  local maxValue = self.curMaxProductionNum > 0 and self.curMaxProductionNum or 1
  self.AddSubtract_White:SetAddBtnIsEnabledNewStyle(curValue < maxValue)
  self.AddSubtract_White:SetSubtractBtnIsEnabledNewStyle(curValue > 0)
end

function UMG_FoodProcessingPanel_C:SetBtnGray(isGray)
  if isGray then
    self.MakeBtn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MakeBtn2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.MakeBtn1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MakeBtn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_FoodProcessingPanel_C:OnBtnCloseClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_FoodProcessingPanel_C:OnBtnCloseClick")
  self:PlayAnimation(self.Out)
  self.CloseBtn:SetIsEnabled(false)
end

function UMG_FoodProcessingPanel_C:OnBtnProductionClick()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_FoodProcessingPanel_C:OnBtnProductionClick")
  local foodInfo = self.foodInfoList[self.curFoodIndex]
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.SendZoneHomePetFoodCompoundReq, foodInfo.foodItemId, self.curProductionNum, {
    foodInfo.cost_item[1].cost_goods_id[1]
  })
end

function UMG_FoodProcessingPanel_C:OnBtn1Click()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, Enum.VisualItem.VI_FURNITURE_COIN, Enum.GoodsType.GT_VITEM)
end

function UMG_FoodProcessingPanel_C:OnBtn2Click()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, Enum.VisualItem.VI_HOME_EXP, Enum.GoodsType.GT_VITEM)
end

function UMG_FoodProcessingPanel_C:OnBtn3Click()
  local foodInfo = self.foodInfoList[self.curFoodIndex]
  if foodInfo then
    local costItem = foodInfo.cost_item
    if costItem and costItem[1] and costItem[1].cost_goods_id and costItem[1].cost_goods_id[1] then
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, costItem[1].cost_goods_id[1], costItem[1].cost_goods_type)
    end
  end
end

function UMG_FoodProcessingPanel_C:OnFoodProcessingSelectFood(index)
  if self.curFoodIndex == index or index < 0 or index > #self.foodInfoList then
    return
  end
  self.curFoodIndex = index
  self:RefreshRightView()
end

function UMG_FoodProcessingPanel_C:OnBtnAddItemClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_FoodProcessingPanel_C:OnBtnAddItemClick")
  local curValue = math.min(math.max(1, self.curMaxProductionNum), self.curProductionNum + 1)
  self.AddSubtract_White:SetSliderValue(curValue)
  self.AddSubtract_White:SetProgressBarPercent(self.AddSubtract_White:GetSliderValue() > 0 and self.AddSubtract_White:GetSliderValue() / self.AddSubtract_White:GetSliderMaxValue() or 0)
  self:RefreshProgressBarValue(curValue)
end

function UMG_FoodProcessingPanel_C:OnBtnDelItemClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_FoodProcessingPanel_C:OnBtnAddItemClick")
  local curValue = math.max(0, self.curProductionNum - 1)
  self.AddSubtract_White:SetSliderValue(curValue)
  self.AddSubtract_White:SetProgressBarPercent(self.AddSubtract_White:GetSliderValue() > 0 and self.AddSubtract_White:GetSliderValue() / self.AddSubtract_White:GetSliderMaxValue() or 0)
  self:RefreshProgressBarValue(curValue)
end

function UMG_FoodProcessingPanel_C:OnMaxBtnHandler()
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_FoodProcessingPanel_C:OnBtnAddItemClick")
  local curValue = math.max(1, self.curMaxProductionNum)
  self.AddSubtract_White:SetSliderValue(curValue)
  self.AddSubtract_White:SetProgressBarPercent(self.AddSubtract_White:GetSliderValue() > 0 and self.AddSubtract_White:GetSliderValue() / self.AddSubtract_White:GetSliderMaxValue() or 0)
  self:RefreshProgressBarValue(curValue)
end

function UMG_FoodProcessingPanel_C:OnSliderValueChanged()
  local fValue = self.AddSubtract_White:GetSliderValue()
  local iValue = math.floor(fValue + 0.5)
  local iPos = iValue / math.max(1, self.curMaxProductionNum)
  self.AddSubtract_White:SetSliderValue(iValue)
  self.AddSubtract_White:SetProgressBarPercent(iPos)
  self:RefreshProgressBarValue(iValue)
end

function UMG_FoodProcessingPanel_C:GetItemShowInfo(itemId, itemType)
  local itemShowInfo = {}
  if itemType == Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    if bagItemConf then
      itemShowInfo.iconPath = bagItemConf.icon
      itemShowInfo.name = bagItemConf.name
    end
    local Item = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, itemId)
    if Item then
      itemShowInfo.haveNum = Item.num
    else
      itemShowInfo.haveNum = 0
    end
  elseif itemType == Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    if vItemConf then
      itemShowInfo.iconPath = vItemConf.bigIcon
      itemShowInfo.name = vItemConf.displayName
    end
    itemShowInfo.haveNum = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemNumByType, itemType)
  end
  return itemShowInfo
end

function UMG_FoodProcessingPanel_C:GetCostItemShowInfo(costItem)
  local itemShowInfo = {}
  if costItem and costItem[1] then
    if costItem[1].cost_goods_id and costItem[1].cost_goods_id[1] then
      itemShowInfo = self:GetItemShowInfo(costItem[1].cost_goods_id[1], costItem[1].cost_goods_type)
    end
    itemShowInfo.needNum = costItem[1].cost_goods_num
  end
  return itemShowInfo
end

function UMG_FoodProcessingPanel_C:GetCostTimeStr(costTime)
  local day = math.floor(costTime / 86400)
  local hour = math.floor((costTime - day * 86400) / 3600)
  local min = math.floor((costTime - day * 86400 - hour * 3600) / 60)
  local btnText = 0
  if day > 0 then
    btnText = string.format(LuaText.activity_RTS1, day, hour)
  elseif hour > 0 then
    btnText = string.format(LuaText.activity_RTS2, hour, min)
  elseif min > 0 then
    btnText = min .. LuaText.umg_pass_awardmain_5
  else
    btnText = LuaText.activity_RTS3
  end
  return btnText
end

function UMG_FoodProcessingPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  end
end

return UMG_FoodProcessingPanel_C
