local UMG_Friend_CaptureTips_C = _G.NRCPanelBase:Extend("UMG_Friend_CaptureTips_C")

function UMG_Friend_CaptureTips_C:OnActive()
  local tipStr = _G.DataConfigManager:GetGlobalConfig("visit_catch_number_rule_tips").str
  local strList = {}
  for str in string.gmatch(tipStr, [[
([^
]+)]]) do
    table.insert(strList, str)
  end
  self.TipsText:SetText(strList[1])
  self.TipsText_1:SetText(strList[2])
  self.TipsText_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TipsText_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TipsText_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_Friend_Item_C:StartFriendVisit")
  self:OnAddEventListener()
  self:BindInputAction()
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "Friend").VISIT
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
end

function UMG_Friend_CaptureTips_C:OnDeactive()
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_Friend_Item_C:StartFriendVisit")
end

function UMG_Friend_CaptureTips_C:OnAddEventListener()
  self:AddButtonListener(self.HotArea, self.OnCloseBtnClick)
end

function UMG_Friend_CaptureTips_C:OnCloseBtnClick()
  self:OnClose()
end

function UMG_Friend_CaptureTips_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_FriendCaptureTips")
  if mappingContext then
    mappingContext:BindAction("IA_CloseFriendCaptureTips", self, "OnPcClose2")
  end
end

function UMG_Friend_CaptureTips_C:OnPcClose2()
  self:OnCloseBtnClick()
end

return UMG_Friend_CaptureTips_C
