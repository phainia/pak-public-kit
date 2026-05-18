local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local UMG_NPCShopConfirm_C = _G.NRCPanelBase:Extend("UMG_NPCShopConfirm_C")

function UMG_NPCShopConfirm_C:OnConstruct()
  self.uiData = {}
  _G.NRCAudioManager:PlaySound2DAuto(1251, "UMG_NPCShopConfirm_C:OnConstruct")
  self:ShowBtn(false)
  self:SetChildViews(self.ConfirmTicket)
  self.ticket = nil
  self.CanvasPanelPoint:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_CLOSE, self.CloseNPCShop)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOPCONFIRM_CLOSE, self.CloseNPCShop)
  self.DelayId = _G.DelayManager:DelaySeconds(1.0, function()
    self:ShowBtn(true)
  end)
  self:BtnInit()
end

function UMG_NPCShopConfirm_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  self:UnRegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_CLOSE, self.CloseNPCShop)
end

function UMG_NPCShopConfirm_C:OnActive(_param, _param1, ...)
  NRCModuleManager:GetModule("NPCShopUIModule"):DispatchEvent(NPCShopUIModuleEvent.NPCSHOPCONFIRM_OPEN)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    return
  end
  local shopId
  if _param.shopId then
    shopId = _param.shopId
  elseif _param[1].shopId then
    shopId = _param[1].shopId
  end
  if 101 ~= shopId and 102 ~= shopId then
    self.BuyBtn:SetRenderOpacity(0)
    self.BuyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CancelBtn:SetRenderOpacity(0)
    self.CancelBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BtnClose:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.shopId = shopId
  self.shopType = _G.Enum.ShopType.ST_DEFAULT
  local shopConf = _G.DataConfigManager:GetShopConf(self.shopId, true)
  if shopConf and shopConf.shop_type then
    self.shopType = shopConf.shop_type
  end
  self.bIfNeedAppCloseConfirm = false
  self.ConfirmTicket:OnActive(_param, _param1)
  if self.shopType == _G.Enum.ShopType.ST_FASHION_TAILOR then
    self.ConfirmTicket.Img_Chuo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:OnAddEventListener()
  self:PlayAnimation(self.open)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCShopConfirm_C", self, NRCGlobalEvent.OnApplicationHasReactivated, self.OnAppHasReactivated)
  self:BindInputAction()
end

function UMG_NPCShopConfirm_C:OnDeactive()
  self.bIfNeedAppCloseConfirm = false
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnApplicationHasReactivated, self.OnAppHasReactivated)
  self:UnBindInputAction()
end

function UMG_NPCShopConfirm_C:BindInputAction()
end

function UMG_NPCShopConfirm_C:UnBindInputAction()
end

function UMG_NPCShopConfirm_C:OnPcClose()
  if not self:IsPlayingAnimation() then
    self:OnBtnCloseClick()
  end
end

function UMG_NPCShopConfirm_C:OnAppHasReactivated()
  if self.bIfNeedAppCloseConfirm then
    self.bIfNeedAppCloseConfirm = false
    self.ConfirmTicket:StopAllAnimations()
    self:DoClose()
  end
end

function UMG_NPCShopConfirm_C:SetDatas(List)
  if List and #List > 0 then
    self.ItemList:SetDatas(List)
  else
    self.ItemList:Clear()
  end
end

function UMG_NPCShopConfirm_C:OnAddEventListener()
  self:AddButtonListener(self.CancelBtn.btnLevelUp, self.OnBtnCancelClick)
  self:AddButtonListener(self.BuyBtn.btnLevelUp, self.OnBtnBuyClick)
  self:AddButtonListener(self.BtnClose, self.OnBtnCloseClick)
end

function UMG_NPCShopConfirm_C:OnRemoveEventListener()
end

function UMG_NPCShopConfirm_C:ShowBtn(visible)
  self.CancelBtn.btnLevelUp:SetIsEnabled(visible)
  self.BuyBtn.btnLevelUp:SetIsEnabled(visible)
end

function UMG_NPCShopConfirm_C:CloseNPCShop(shopId)
  self.CanvasPanelBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1252, "UMG_NPCShopConfirm_C:CloseNPCShop")
  self.ConfirmTicket:PlayAnimationClose()
  self.CanvasPanelPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanelBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:ShowBtn(false)
end

function UMG_NPCShopConfirm_C:OnBtnCancelClick()
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    return
  end
  self:ShowBtn(false)
  self.ConfirmTicket:OnBtnCancelClick()
  self:PlayAnimation(self.Cancel)
end

function UMG_NPCShopConfirm_C:OnBtnBuyClick()
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    return
  end
  self:ShowBtn(false)
  self.ConfirmTicket:OnBtnBuyClick()
  self:DoClose()
end

function UMG_NPCShopConfirm_C:OnBtnCloseClick()
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    return
  end
  if self.shopType == _G.Enum.ShopType.ST_FASHION_TAILOR and (self:IsAnimationPlaying(self.open) or self.ConfirmTicket:IsAnimationPlaying(self.ConfirmTicket.Close)) then
    return
  end
  self:ShowBtn(false)
  self.BtnClose:SetIsEnabled(false)
  self:PlayAnimation(self.close)
end

function UMG_NPCShopConfirm_C:GetRealTime()
  local sertime = _G.ZoneServer:GetServerTime()
  local strTime = os.date("%m.%d %H:%M:%S", sertime)
  return strTime
end

function UMG_NPCShopConfirm_C:BtnInit()
  self.BuyBtn:SetBtnText(LuaText.umg_npcshopconfirm_1)
  self.BuyBtn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/ui_combtn_sure_png.ui_combtn_sure_png'")
  self.CancelBtn:SetBtnText(LuaText.umg_npcshopconfirm_2)
  self.CancelBtn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/ui_combtn_cancel_png.ui_combtn_cancel_png'")
end

function UMG_NPCShopConfirm_C:OnAnimationFinished(anim)
  if anim == self.Cancel then
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.ColseBackground)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1253, "UMG_NPCShopConfirm_C:OnAnimationFinished")
    self:ShowBtn(true)
    self:DoClose()
  elseif anim == self.close then
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.ColseBackground)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1253, "UMG_NPCShopConfirm_C:OnAnimationFinished")
    self:ShowBtn(true)
    _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.PlayHappyAnimAfterBuying)
    self:DoClose()
  elseif anim == self.open and self.shopType == _G.Enum.ShopType.ST_FASHION_TAILOR then
    self.ConfirmTicket:PlayAnimationClose()
  end
end

return UMG_NPCShopConfirm_C
