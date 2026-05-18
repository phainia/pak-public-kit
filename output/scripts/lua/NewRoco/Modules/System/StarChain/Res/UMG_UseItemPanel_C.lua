local StarChainModuleEvent = require("NewRoco.Modules.System.StarChain.StarChainModuleEvent")
local UMG_UseItemPanel_C = _G.NRCPanelBase:Extend("UMG_UseItemPanel_C")

function UMG_UseItemPanel_C:OnConstruct()
  self.bgProxy = _G.NRCModuleManager:DoCmd(TUIModuleCmd.PushBlackBackgroundWidgets, {
    self.NRCImage_125,
    self.NRCImage_58
  })
  self:SetChildViews(self.PopUp)
end

function UMG_UseItemPanel_C:OnDestruct()
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.PopBlackBackgroundWidgets, self.bgProxy)
end

function UMG_UseItemPanel_C:OnActive(Item)
  self.Item = Item
  self.selectNum = 1
  self.BagItemConf = _G.DataConfigManager:GetBagItemConf(Item.ItemId)
  self:SetCommonPopUpInfo(self.PopUp, self.BagItemConf.name)
  self.PopUp:ShowOrHideBtnLeft(false)
  self.PopUp:ShowOrHideBtnRight(false)
  self.HintText_1:SetText(LuaText.star_buytext_starstone_confirm)
  self.Text_Describe:SetText(self.BagItemConf.description)
  local MaxConf = _G.DataConfigManager:GetRoleGlobalConfig("starstone_use_limit").num
  local Max = MaxConf > Item.ItemNum and Item.ItemNum or MaxConf
  self.BuildTimeText:SetText(self.selectNum)
  local SliderInfo = {num1 = 1, num2 = Max}
  local ProgressBarInfo = {num1 = 1, num2 = Max}
  self:SetCommonAddSubtractInfo(self.SliderPanel, SliderInfo, ProgressBarInfo)
  self.SliderPanel:SetSliderValue(1 + self.selectNum / Max * (Max - 1))
  self.SliderPanel:SetProgressBarPercent(self.selectNum / Max)
  local MaxValue = self.SliderPanel:GetSliderMaxValue()
  local MinValue = self.SliderPanel:GetSliderMinValue()
  if MinValue >= self.selectNum then
    self.SliderPanel:SetSubtractBtnIsEnabledNewStyle(false)
  end
  if MaxValue <= self.selectNum then
    self.SliderPanel:SetAddBtnIsEnabledNewStyle(false)
  end
  self.Icon1:OnItemUpdate(Item)
  self:PlayAnimation(self:GetAnimByIndex(0))
  self:OnAddEventListener()
end

function UMG_UseItemPanel_C:OnDeactive()
end

function UMG_UseItemPanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnCloseBtn)
  self:AddButtonListener(self.Btn_Cancel.btnLevelUp, self.OnCloseBtn)
  self:AddButtonListener(self.Btn_Confirm.btnLevelUp, self.OnConfirmBtn)
  self:AddButtonListener(self.Button1, self.OnItemClick)
  self:RegisterEvent(self, StarChainModuleEvent.PurchaseSucceed, self.OnPurchaseSucceed)
end

function UMG_UseItemPanel_C:OnConfirmBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnOK")
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local StarItem = _G.DataConfigManager:GetRoleGlobalConfig("star_item")
  local ExchangeConf = _G.DataConfigManager:GetExchangeConf(StarItem.numList[1])
  _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.SendExchangeReq, StarItem.numList[1], self.selectNum, 1, localPlayer.serverData.base.actor_id, ExchangeConf.cost_item[1].cost_goods_id)
end

function UMG_UseItemPanel_C:OnPurchaseSucceed()
  self:PlayAnimation(self:GetAnimByIndex(2))
end

function UMG_UseItemPanel_C:OnItemClick()
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.Item.ItemId, self.Item.type)
end

function UMG_UseItemPanel_C:OnBtnAddPressed()
  self:PlayAnimation(self.Add_Press)
  self.IsAddClick = true
end

function UMG_UseItemPanel_C:OnBtnAddReleased()
  if self.IsAddClick then
    self:PlayAnimation(self.Add_Up)
    self:OnBtnAddItemClick()
  end
end

function UMG_UseItemPanel_C:OnBtnDelPressed()
  self:PlayAnimation(self.Reduce_Press)
  self.IsDelClick = true
end

function UMG_UseItemPanel_C:OnBtnDelReleased()
  if self.IsDelClick then
    self:PlayAnimation(self.Reduce_Up)
    self:OnBtnDelItemClick()
  end
end

function UMG_UseItemPanel_C:OnBtnAddItemClick()
  self:ChangeBuildTimes(true)
end

function UMG_UseItemPanel_C:OnBtnDelItemClick()
  self:ChangeBuildTimes(false)
end

function UMG_UseItemPanel_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(0) then
    self:PlayAnimation(self:GetAnimByIndex(1))
  elseif anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_UseItemPanel_C:ChangeBuildTimes(_isAddItem)
  local value = self.selectNum
  local MaxValue = self.SliderPanel:GetSliderMaxValue()
  if _isAddItem then
    if value >= MaxValue then
      return
    end
    _G.NRCAudioManager:PlaySound2DAuto(41401008, "UMG_Bag_BXTips_C:OnBtnDelItemClick")
    value = value + 1
    self.SliderPanel:SetSubtractBtnIsEnabledNewStyle(true)
    if MaxValue <= value then
      self.SliderPanel:SetAddBtnIsEnabledNewStyle(false)
    end
  else
    local MinValue = self.SliderPanel:GetSliderMinValue()
    if value <= MinValue then
      return
    end
    _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_Bag_BXTips_C:OnBtnAddItemClick")
    value = value - 1
    self.SliderPanel:SetAddBtnIsEnabledNewStyle(true)
    if MinValue >= value then
      self.SliderPanel:SetSubtractBtnIsEnabledNewStyle(false)
    end
  end
  self.SliderPanel:SetProgressBarPercent(value / MaxValue)
  self.SliderPanel:SetSliderValue(1 + value / MaxValue * (MaxValue - 1))
  self.BuildTimeText:SetText(value)
  self.selectNum = value
end

function UMG_UseItemPanel_C:SetCommonPopUpInfo(PopUp, TitleText)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_UseItemPanel_C:SetCommonAddSubtractInfo(AddSubtract, SliderInfo, ProgressBarInfo, MultipleAddBtnText, MultipleSubtractBtnText, SelectNum)
  local CommonAddSubtractData = _G.NRCCommonAddSubtractData()
  if MultipleAddBtnText then
    CommonAddSubtractData.MultipleAddBtnText = MultipleAddBtnText
  end
  if MultipleSubtractBtnText then
    CommonAddSubtractData.MultipleSubtractBtnText = MultipleSubtractBtnText
  end
  CommonAddSubtractData.SliderInfo = SliderInfo
  CommonAddSubtractData.ProgressBarInfo = ProgressBarInfo
  CommonAddSubtractData.AddBtnHandler = self.OnBtnAddItemClick
  CommonAddSubtractData.SubtractBtnHandler = self.OnBtnDelItemClick
  CommonAddSubtractData.SliderHandler = self.OnSliderChanged
  CommonAddSubtractData.SelectNum = SelectNum
  CommonAddSubtractData.Call = self
  AddSubtract:SetPanelInfo(CommonAddSubtractData)
end

function UMG_UseItemPanel_C:OnCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  self:PlayAnimation(self:GetAnimByIndex(2))
end

function UMG_UseItemPanel_C:OnSliderChanged()
  local value = self.SliderPanel:GetSliderValue()
  local MaxValue = self.SliderPanel:GetSliderMaxValue()
  local MinValue = self.SliderPanel:GetSliderMinValue()
  value = math.floor(value + 0.5)
  self.SliderPanel:SetProgressBarPercent(value / MaxValue)
  if value > tonumber(self.BuildTimeText:GetText()) then
    _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_Bag_BXTips_C:OnBtnAddItemClick")
  end
  if value < tonumber(self.BuildTimeText:GetText()) then
    _G.NRCAudioManager:PlaySound2DAuto(41401008, "UMG_Bag_BXTips_C:OnBtnAddItemClick")
  end
  if MinValue >= value then
    self.SliderPanel:SetSubtractBtnIsEnabledNewStyle(false)
  else
    self.SliderPanel:SetSubtractBtnIsEnabledNewStyle(true)
  end
  if MaxValue <= value then
    self.SliderPanel:SetAddBtnIsEnabledNewStyle(false)
  else
    self.SliderPanel:SetAddBtnIsEnabledNewStyle(true)
  end
  self.SliderPanel:SetSliderValue(1 + value / MaxValue * (MaxValue - 1))
  self.BuildTimeText:SetText(value)
  self.selectNum = value
end

return UMG_UseItemPanel_C
