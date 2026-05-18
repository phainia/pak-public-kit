local UMG_MagicalStudy_C = _G.NRCPanelBase:Extend("UMG_MagicalStudy_C")

local function _SortStudyItem(a, b)
  local IsMaxA = a.data.origin_value == a.data.target_value and 1 or 0
  local IsMaxB = b.data.origin_value == b.data.target_value and 1 or 0
  if IsMaxA == IsMaxB then
    return a.priority > b.priority
  else
    return IsMaxA < IsMaxB
  end
end

function UMG_MagicalStudy_C:OnActive(data)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    return
  end
  self.action = data.action
  self:OnAddEventListener()
  self:SetCommonTitle()
  self:UpdateData()
  local title = _G.DataConfigManager:GetLocalizationConf("exchange_academic_research")
  local req = _G.ProtoMessage:newZoneCheckVisualItemUpgradeRedPointReq()
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CHECK_VISUAL_ITEM_UPGRADE_RED_POINT_REQ, req)
  self:BindInputAction()
end

function UMG_MagicalStudy_C:OnDeactive()
  self:OnRemoveEventListener()
  self:UnBindInputAction()
end

function UMG_MagicalStudy_C:BindInputAction()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_NpcShop")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseNpcShopUI")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "OnPcClose")
end

function UMG_MagicalStudy_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseNpcShopUI")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_NpcShop")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
end

function UMG_MagicalStudy_C:OnPcClose()
  if not self.CloseBtn:IsVisible() then
    return
  end
  self:OnClickClose()
end

function UMG_MagicalStudy_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_MagicalStudy_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.AlchemyModuleEvent.ArdourUpPanelClosed, self.OnSubPanelClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.AlchemyModuleEvent.RecoverTimeUpPanelClosed, self.OnSubPanelClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.AlchemyModuleEvent.AlchemyVitalityPanelClosed, self.OnSubPanelClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.AlchemyModuleEvent.AlchemyOnShowUI, self.OnShowUI)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.AlchemyModuleEvent.AlchemyOnHideUI, self.OnHideUI)
end

function UMG_MagicalStudy_C:OnSubPanelClosed()
  local req = _G.ProtoMessage:newZoneCheckVisualItemUpgradeRedPointReq()
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CHECK_VISUAL_ITEM_UPGRADE_RED_POINT_REQ, req)
  self.CloseBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.PromoteList:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:PlayAnimation(self.Change_back)
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_MagicalStudy_C:OnSubPanelClosed")
  if self.titleConf and self.titleConf.subtitle then
    self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
  end
end

function UMG_MagicalStudy_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickClose)
  _G.NRCEventCenter:RegisterEvent("UMG_MagicalStudy_C", self, _G.AlchemyModuleEvent.ArdourUpPanelClosed, self.OnSubPanelClosed)
  _G.NRCEventCenter:RegisterEvent("UMG_MagicalStudy_C", self, _G.AlchemyModuleEvent.RecoverTimeUpPanelClosed, self.OnSubPanelClosed)
  _G.NRCEventCenter:RegisterEvent("UMG_MagicalStudy_C", self, _G.AlchemyModuleEvent.AlchemyVitalityPanelClosed, self.OnSubPanelClosed)
  _G.NRCEventCenter:RegisterEvent("UMG_MagicalStudy_C", self, _G.AlchemyModuleEvent.AlchemyOnShowUI, self.OnShowUI)
  _G.NRCEventCenter:RegisterEvent("UMG_MagicalStudy_C", self, _G.AlchemyModuleEvent.AlchemyOnHideUI, self.OnHideUI)
end

function UMG_MagicalStudy_C:OnClickClose()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_MagicalStudy_C:OnClickClose")
  if self:GetVisibility() ~= UE4.ESlateVisibility.HitTestInvisible and self:GetVisibility() ~= UE4.ESlateVisibility.Collapsed and self:GetVisibility() ~= UE4.ESlateVisibility.Hidden then
    self:PlayAnimation(self.Close)
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:OnStudyItemSelected(_G.Enum.VisualItem.VI_BOTTLE_TIMES)
  end
end

function UMG_MagicalStudy_C:OnAnimationFinished(Anim)
  if Anim == self.Close then
    if self.action then
      self.action:EndAction()
    end
    if self.module.TestOpen then
      self.module.TestOpen = false
      _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenPanelLobbyMain)
    end
    self:DoClose()
  elseif Anim == self.Select then
    if self.openType == _G.Enum.VisualItem.VI_ROLE_HP_MAX then
      _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenArdourPanel)
    elseif self.openType == _G.Enum.VisualItem.VI_BOTTLE_TIMES then
      _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenRecoverTimeUpPanel)
    elseif self.openType == _G.Enum.VisualItem.VI_STAMINA then
      _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenVitalityPanel)
    end
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PromoteList:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif Anim == self.Change_back then
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PromoteList:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_MagicalStudy_C:UpdateData()
  local StudyItems = {
    {
      priority = 3,
      type = _G.Enum.VisualItem.VI_ROLE_HP_MAX,
      parent = self,
      data = _G.NRCModeManager:DoCmd(_G.AlchemyModuleCmd.GetRoleHpMaxData)
    },
    {
      priority = 1,
      type = _G.Enum.VisualItem.VI_BOTTLE_TIMES,
      parent = self,
      data = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetBottleTimeData)
    },
    {
      priority = 2,
      type = _G.Enum.VisualItem.VI_STAMINA,
      parent = self,
      data = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetVitalityData)
    }
  }
  table.sort(StudyItems, _SortStudyItem)
  self.PromoteList:InitList(StudyItems)
  local moneyInfo = {}
  local coin_num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
  table.insert(moneyInfo, {
    moneyType = _G.Enum.VisualItem.VI_COIN,
    sum = coin_num,
    IsShowBuyIcon = false
  })
  self.MoneyBtn:InitGridView(moneyInfo)
end

function UMG_MagicalStudy_C:OnStudyItemSelected(type)
  self:RefreshCommonTitle(type)
  if self:GetVisibility() ~= UE4.ESlateVisibility.HitTestInvisible and self:GetVisibility() ~= UE4.ESlateVisibility.Collapsed and self:GetVisibility() ~= UE4.ESlateVisibility.Hidden then
    self.openType = type
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.PromoteList:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:PlayAnimation(self.Select)
    self:OnClickClose()
  end
end

function UMG_MagicalStudy_C:RefreshCommonTitle(index)
  if index == _G.Enum.VisualItem.VI_ROLE_HP_MAX then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[2].subtitle)
    end
  elseif index == _G.Enum.VisualItem.VI_STAMINA then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[3].subtitle)
    end
  elseif index == _G.Enum.VisualItem.VI_BOTTLE_TIMES and self.titleConf and self.titleConf.subtitle then
    self.Title1:SetSubtitle(self.titleConf.subtitle[4].subtitle)
  end
end

function UMG_MagicalStudy_C:OnShowUI()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.Select_back)
  self:UpdateData()
end

function UMG_MagicalStudy_C:OnHideUI()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:PlayAnimation(self.Select_close)
end

return UMG_MagicalStudy_C
