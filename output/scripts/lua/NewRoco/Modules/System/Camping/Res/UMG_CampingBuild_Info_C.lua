local UMG_CampingBuild_Info_C = _G.NRCViewBase:Extend("UMG_CampingBuild_Info_C")

function UMG_CampingBuild_Info_C:OnConstruct()
  Log.Debug("UMG_CampingBuild_Info_C:OnConstruct")
  self.uiData = {}
  self:OnAddEventListener()
  local buildTimesText = _G.DataConfigManager:GetLocalizationConf("Camp_Exchange_dazaocishu")
  self.uiData.buildTimesText = buildTimesText and buildTimesText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176"
  local insufficientText = _G.DataConfigManager:GetLocalizationConf("Camp_Exchange_cailiaobuzu")
  self.uiData.insufficientText = insufficientText and insufficientText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176"
  self.Title:SetText(_G.DataConfigManager:GetLocalizationConf("Camp_TITLE_dazao").msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  self.Title_1:SetText(_G.DataConfigManager:GetLocalizationConf("Camp_TITLE_dazaoxiao").msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  self.NRCText:SetText(_G.DataConfigManager:GetLocalizationConf("Camp_BTN_dazao").msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  self.UMG_Common_BIconPar:BindToAnimationFinished(self.UMG_Common_BIconPar.close, {
    self,
    self.PlayOpenAnm
  })
end

function UMG_CampingBuild_Info_C:OnDestruct()
  self.uiData = nil
end

function UMG_CampingBuild_Info_C:OnAddEventListener()
  self:AddButtonListener(self.GetRewardsBtn, self.OnBtnBuildItemsClick)
  self:AddButtonListener(self.Add, self.OnBtnAddItemClick)
  self:AddButtonListener(self.ReductionOf, self.OnBtnDelItemClick)
  self:AddDelegateListener(self.Slider_95.OnValueChanged, self.OnSliderValueChanged)
end

function UMG_CampingBuild_Info_C:SetExchangeInfoData(data)
  self.uiData.exchangeData = data
  self:RefreshUI()
  self.UMG_Common_BIconPar:PlayAnimation(self.UMG_Common_BIconPar.close)
end

function UMG_CampingBuild_Info_C:PlayOpenAnm()
  self.UMG_Common_BIconPar:PlayAnimation(self.UMG_Common_BIconPar.open)
end

function UMG_CampingBuild_Info_C:RefreshUI()
  local bagItemId = self.uiData.exchangeData.getItem.get_goods_id
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(bagItemId)
  if bagItemConf then
    self.Icon_1:SetPath(bagItemConf.big_icon)
    self.SubTitle1_1:SetText(bagItemConf.name)
    self.Describe:SetText(bagItemConf.description)
  end
  self:SetupSlier()
  self:SetupBuildNumText()
  self:SetupAddOrDecBtnState()
  self:SetupCostItemList()
end

function UMG_CampingBuild_Info_C:SetupCostItemList()
  local costItems = self.uiData.exchangeData.costItems
  local itemInfos = {}
  for _, v in ipairs(costItems) do
    local itemId = v.cost_goods_id
    local itemNeedNum = v.cost_goods_num
    local itemNum = self:GetItemCount(itemId, v.cost_goods_type)
    local itemType = v.cost_goods_type
    table.insert(itemInfos, {
      itemId = itemId,
      itemNum = itemNum,
      itemNeedNum = itemNeedNum,
      itemType = itemType
    })
  end
  self.uiData.itemInfos = itemInfos
  self.List:InitGridView(itemInfos)
end

function UMG_CampingBuild_Info_C:SetupSlier()
  local exchangeData = self.uiData.exchangeData
  local minValue = math.max(1, exchangeData.exchange_time_lower_limit)
  local maxValue = math.min(exchangeData.canExchangeNum, exchangeData.exchange_time_upper_limit)
  if 0 == maxValue then
    maxValue = 1
  end
  self.Slider_95:SetStepSize(1)
  self.Slider_95:SetMinValue(minValue)
  self.Slider_95:SetMaxValue(maxValue)
  self.Slider_95:SetValue(1)
  self.Digital_1:SetText(maxValue)
  if 0 == exchangeData.canExchangeNum then
    self.SliderPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.SliderPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_CampingBuild_Info_C:GetItemCount(_itemId, _itemType)
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
end

function UMG_CampingBuild_Info_C:IsMaterialEnough(_buildNum)
  if nil == _buildNum then
    _buildNum = 1
  end
  local materialsIsEnough = true
  local items = self.uiData.ItemInfos
  for i, v in ipairs(items) do
    if v.itemCount < v.needCount * _buildNum then
      materialsIsEnough = false
    end
  end
  return materialsIsEnough
end

function UMG_CampingBuild_Info_C:OnBtnBuildItemsClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_CampingBuild_Info_C:OnBtnBuildItemsClick")
  local canExchangeNum = self.uiData.exchangeData.canExchangeNum
  if 0 == canExchangeNum then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.uiData.insufficientText)
    return
  end
  local exchangeId = self.uiData.exchangeData.exchangeId
  local num = math.floor(self.Slider_95:GetValue())
  NRCModuleManager:DoCmd(CampingModuleCmd.SendExchangeReq, exchangeId, num, 0)
end

function UMG_CampingBuild_Info_C:OnBtnAddItemClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1072, "UMG_CampingBuild_Info_C:OnBtnAddItemClick")
  self:ChangeBuildTimes(true)
end

function UMG_CampingBuild_Info_C:OnBtnDelItemClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1072, "UMG_CampingBuild_Info_C:OnBtnDelItemClick")
  self:ChangeBuildTimes(false)
end

function UMG_CampingBuild_Info_C:OnSliderValueChanged()
  Log.Debug("UMG_CampingBuild_Info_C:OnSliderValueChanged")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1072, "UMG_CampingBuild_Info_C:OnBtnDelItemClick")
  self:SetupAddOrDecBtnState()
  self:SetupBuildNumText()
end

function UMG_CampingBuild_Info_C:ChangeBuildTimes(_isAddItem)
  Log.Debug("UMG_CampingBuild_Info_C:ChangeBuildTimes")
  local curValue = self.Slider_95:GetValue()
  local minValue = self.Slider_95.MinValue
  local maxValue = self.Slider_95.MaxValue
  if _isAddItem then
    curValue = curValue + 1
  else
    curValue = curValue - 1
  end
  curValue = math.clamp(curValue, minValue, maxValue)
  self.Slider_95:SetValue(curValue)
  self:SetupAddOrDecBtnState()
  self:SetupBuildNumText()
end

function UMG_CampingBuild_Info_C:SetupAddOrDecBtnState()
  local curValue = self.Slider_95:GetValue()
  local minValue = self.Slider_95.MinValue
  local maxValue = self.Slider_95.MaxValue
  self.Add:SetIsEnabled(curValue ~= maxValue)
  self.ReductionOf:SetIsEnabled(curValue ~= minValue)
end

function UMG_CampingBuild_Info_C:SetupBuildNumText()
  if self.uiData.exchangeData == nil or 0 == self.uiData.exchangeData.canExchangeNum then
    self.Prompt_1:SetText(string.format("%s<span color=\"#ff696b\" size=\"14\" font=\"/Game/NewRoco/Font/huakanglangman_Font\"> %d</>", self.uiData.buildTimesText, 0))
  else
    local curValue = math.floor(self.Slider_95:GetValue())
    self.Prompt_1:SetText(string.format("%s<span color=\"#ffffff\" size=\"14\" font=\"/Game/NewRoco/Font/huakanglangman_Font\"> %d</>", self.uiData.buildTimesText, curValue))
  end
end

return UMG_CampingBuild_Info_C
