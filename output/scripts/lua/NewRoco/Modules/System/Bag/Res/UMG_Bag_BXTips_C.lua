local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local InstanceModuleEvent = require("NewRoco.Modules.Core.Instance.InstanceModuleEvent")
local UMG_Bag_BXTips_C = _G.NRCPanelBase:Extend("UMG_Bag_BXTips_C")

function UMG_Bag_BXTips_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
  self:OnAddEventListener()
end

function UMG_Bag_BXTips_C:OnActive(_SelectItem)
  if _G.GlobalConfig.DebugOpenUI then
    self:SetCommonPopUpInfo()
    return
  end
  self.SelectItem = _SelectItem
  self.SelectListItemIndex = nil
  self.SelectListItemCount = nil
  self.IsBegin = nil
  self:InitPanel()
  self:SetItemList()
  self:SetCommonPopUpInfo()
  self:LoadAnimation(0)
end

function UMG_Bag_BXTips_C:InitPanel()
  if not self.SelectItem then
    Log.Error("\233\128\137\228\184\173\231\154\132\231\137\169\229\147\129\230\149\176\230\141\174\228\184\186\231\169\186,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return
  end
  local SelectItem = self.SelectItem
  local maxValue = SelectItem.num
  self.Digital:SetText(0)
  self.Digital_1:SetText(maxValue)
  self.Slider_95:SetMinValue(0)
  self.Slider_95:SetStepSize(1)
  self.Slider_95:SetMaxValue(maxValue)
  local tipsStr = _G.DataConfigManager:GetLocalizationConf("Present_Box_Count").msg
  self.BXTipsText:SetText(tipsStr)
  self.BuildTimeText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.BuildTimeText:SetText("0")
  local allTextStr = _G.DataConfigManager:GetLocalizationConf("Present_Item_Choice_Tip").msg
  self.AllText:SetText(allTextStr)
  self.PopUp2:SetBtnRightEnableStateNew(false)
  self.progress:SetPercent(0)
  if 0 == maxValue then
    self.Slider_95:SetLocked(true)
    self.Slider_95:SetValue(0)
  else
    self.Slider_95:SetLocked(false)
    self.Slider_95:SetValue(0)
  end
  self:SelectChange(false)
  self:SetupAddOrDecBtnState()
end

function UMG_Bag_BXTips_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if self.SelectItem then
    local bagConf = _G.DataConfigManager:GetBagItemConf(self.SelectItem.id)
    if bagConf then
      local titleIconPath = bagConf.icon
      CommonPopUpData.TitleIcon = titleIconPath
      CommonPopUpData.TitleText = bagConf.name
    end
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnClose
  CommonPopUpData.Btn_RightHandler = self.OnOK
  CommonPopUpData.ClosePanelHandler = self.OnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_Bag_BXTips_C:SelectChange(_IsSelect, SelectListItem, index)
  if _IsSelect then
    self.SelectListItemIndex = index
    self.SelectListItemCount = SelectListItem.Count
    self.SelectItemName = _G.DataConfigManager:GetBagItemConf(SelectListItem.Id).name
    self.CanvasPanel_115:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BuildTimeText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local SelectItem = math.floor(self.Slider_95:GetValue())
    local SelectItemNum = SelectItem * self.SelectListItemCount
    self.BuildTimeText:SetText(SelectItem)
    local tipsTestStr = _G.DataConfigManager:GetLocalizationConf("Present_Box_Count").msg
    self.BXTipsText:SetText(tipsTestStr)
    local itemName = self.SelectItemName
    local desStr = _G.DataConfigManager:GetLocalizationConf("Present_Reward_Count").msg
    local numDes = string.format(desStr, itemName, SelectItemNum)
    self.AllText:SetText(numDes)
    self.Slider_95:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Slider_95:SetValue(0)
    self:ChangeBuildTimes(true)
  else
    self.Slider_95:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Slider_95:SetValue(0)
  end
end

function UMG_Bag_BXTips_C:SetItemList()
  local SelectItem = self.SelectItem
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(SelectItem.id)
  local Id = BagItemConf.item_behavior[1] and BagItemConf.item_behavior[1].ratio[1]
  local BXItemId = _G.DataConfigManager:GetTreasureItemConf(Id)
  local choose_item = BXItemId.choose_item_group
  self.GridView:InitGridView(choose_item)
  if choose_item and #choose_item > 0 then
    for i, _ in ipairs(choose_item) do
      local Item = self.GridView:GetItemByIndex(i - 1)
      Item:SetParent(self)
    end
  end
end

function UMG_Bag_BXTips_C:OnDeactive()
end

function UMG_Bag_BXTips_C:OnAddEventListener()
  self.Add.OnPressed:Add(self, self.OnBtnAddPressed)
  self.Add.OnReleased:Add(self, self.OnBtnAddReleased)
  self.Reduce.OnPressed:Add(self, self.OnBtnDelPressed)
  self.Reduce.OnReleased:Add(self, self.OnBtnDelReleased)
  self:AddDelegateListener(self.Slider_95.OnValueChanged, self.OnSliderValueChanged)
  self:AddDelegateListener(self.Slider_95.OnMouseCaptureBegin, self.OnMouseCaptureBegin)
  self:AddDelegateListener(self.Slider_95.OnMouseCaptureEnd, self.OnMouseCaptureEnd)
end

function UMG_Bag_BXTips_C:OnMouseCaptureBegin()
  self.IsBegin = true
end

function UMG_Bag_BXTips_C:OnMouseCaptureEnd()
  self.IsBegin = false
  self:SetValue()
end

function UMG_Bag_BXTips_C:OnBtnAddPressed()
  self:StopAnimation(self.Add_press)
  self:StopAnimation(self.Add_up)
  self:PlayAnimation(self.Add_press)
  self.IsAddClick = true
end

function UMG_Bag_BXTips_C:OnBtnAddReleased()
  self:StopAnimation(self.Add_press)
  self:StopAnimation(self.Add_up)
  self:PlayAnimation(self.Add_up)
  if self.IsAddClick then
    self:OnBtnAddItemClick()
  end
end

function UMG_Bag_BXTips_C:OnBtnDelPressed()
  self:StopAnimation(self.Reduce_press)
  self:StopAnimation(self.Reduce_up)
  self:PlayAnimation(self.Reduce_press)
  self.IsDelClick = true
end

function UMG_Bag_BXTips_C:OnBtnDelReleased()
  self:StopAnimation(self.Reduce_press)
  self:StopAnimation(self.Reduce_up)
  self:PlayAnimation(self.Reduce_up)
  if self.IsDelClick then
    self:OnBtnDelItemClick()
  end
end

function UMG_Bag_BXTips_C:OnSliderValueChanged(value)
  if 0 == self.SelectItem.num then
    self.Slider_95:SetValue(0)
    self.progress:SetPercent(0)
    return
  end
  local progressValue = value / self.SelectItem.num
  self.progress:SetPercent(progressValue)
  self:SetValue()
  self:SetupAddOrDecBtnState()
end

function UMG_Bag_BXTips_C:SetValue()
  local itemNum = math.floor(self.Slider_95:GetValue() + 0.5)
  if itemNum > tonumber(self.BuildTimeText:GetText()) then
    _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_Bag_BXTips_C:OnBtnAddItemClick")
  end
  if itemNum < tonumber(self.BuildTimeText:GetText()) then
    _G.NRCAudioManager:PlaySound2DAuto(41401008, "UMG_Bag_BXTips_C:OnBtnAddItemClick")
  end
  local showItemNum = itemNum * self.SelectListItemCount
  self.BuildTimeText:SetText(itemNum)
  local desStr = _G.DataConfigManager:GetLocalizationConf("Present_Reward_Count").msg
  local numDes = string.format(desStr, self.SelectItemName, showItemNum)
  self.AllText:SetText(numDes)
  if showItemNum > 0 then
    self.PopUp2:SetBtnRightEnableStateNew(true)
  else
    self.PopUp2:SetBtnRightEnableStateNew(false)
  end
  local Value = self.Slider_95:GetValue()
  if not self.IsBegin and math.type(itemNum) == "integer" and itemNum ~= Value then
    self.Slider_95:SetValue(itemNum)
    local progressValue = itemNum / self.SelectItem.num
    self.progress:SetPercent(progressValue)
  end
end

function UMG_Bag_BXTips_C:ChangeBuildTimes(_isAddItem)
  local curValue = self.Slider_95:GetValue()
  local minValue = self.Slider_95.MinValue
  local maxValue = self.Slider_95.MaxValue
  if self.SelectListItemCount == nil then
    local tipsStr = _G.DataConfigManager:GetLocalizationConf("Present_Item_Choice_Warning").msg
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
    return
  end
  if _isAddItem then
    curValue = curValue + 1
    if maxValue >= curValue then
      _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_Bag_BXTips_C:OnBtnAddItemClick")
    end
  else
    curValue = curValue - 1
    if minValue <= curValue then
      _G.NRCAudioManager:PlaySound2DAuto(41401008, "UMG_Bag_BXTips_C:OnBtnDelItemClick")
    end
  end
  curValue = math.clamp(curValue, minValue, maxValue)
  self.Slider_95:SetValue(curValue)
  local itemNum = math.floor(curValue)
  self.BuildTimeText:SetText(itemNum)
  local showItemNum = itemNum * self.SelectListItemCount
  local desStr = _G.DataConfigManager:GetLocalizationConf("Present_Reward_Count").msg
  local numDes = string.format(desStr, self.SelectItemName, showItemNum)
  self.AllText:SetText(numDes)
  if showItemNum > 0 then
    self.PopUp2:SetBtnRightEnableStateNew(true)
  else
    self.PopUp2:SetBtnRightEnableStateNew(false)
  end
  self.progress:SetPercent(itemNum / self.SelectItem.num)
  self:SetupAddOrDecBtnState()
end

function UMG_Bag_BXTips_C:SetupAddOrDecBtnState()
  if 0 == self.SelectItem.num then
    self.Add:SetIsEnabled(false)
    self.Reduce:SetIsEnabled(false)
  else
  end
end

function UMG_Bag_BXTips_C:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  self:LoadAnimation(2)
end

function UMG_Bag_BXTips_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    if self.UseItem then
      self.UseItem = false
      if self.SelectListItemIndex - 1 < 0 then
        self:LogError("SelectListItemIndex \228\184\141\229\143\175\228\187\165\229\176\143\228\186\1420!,\232\175\183\229\135\186\231\142\176\230\173\164\233\151\174\233\162\152\230\151\182\230\181\139\232\175\149\229\144\140\229\173\166\232\174\176\229\189\149\228\184\128\228\184\139\229\164\141\231\142\176\230\181\129\231\168\139\229\143\141\233\166\136\231\187\153v_mllmli")
      else
        local num = math.floor(self.Slider_95:GetValue())
        _G.NRCModuleManager:DoCmd(BagModuleCmd.UseBagItem, self.SelectItem.gid, self.SelectItem.id, num, self.SelectListItemIndex - 1)
      end
    end
    self:DoClose()
  end
end

function UMG_Bag_BXTips_C:OnOK()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnOK")
  local num = math.floor(self.Slider_95:GetValue())
  if self.SelectListItemIndex and num > 0 then
    Log.Debug(self.SelectItem.gid, num, self.SelectListItemIndex, "UMG_Bag_BXTips_C:OnOK")
    self.UseItem = true
    self:LoadAnimation(2)
  elseif not self.SelectListItemIndex then
    local tipsStr = _G.DataConfigManager:GetLocalizationConf("Present_Item_Choice_Warning").msg
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
  else
    local tipsStr = _G.DataConfigManager:GetLocalizationConf("umg_bag_popup_4").msg
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
  end
end

function UMG_Bag_BXTips_C:GetItemOk()
end

function UMG_Bag_BXTips_C:OnBtnAddItemClick()
  self:ChangeBuildTimes(true)
end

function UMG_Bag_BXTips_C:OnBtnDelItemClick()
  self:ChangeBuildTimes(false)
end

return UMG_Bag_BXTips_C
