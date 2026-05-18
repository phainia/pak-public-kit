local UMG_Settlement_Tips_C = _G.NRCPanelBase:Extend("UMG_Settlement_Tips_C")

function UMG_Settlement_Tips_C:OnConstruct()
  self.data = self.module:GetData("BattleRogueModuleData")
  self.data:SetSelectBuffList(nil)
  self:OnAddEventListener()
end

function UMG_Settlement_Tips_C:OnDestruct()
end

function UMG_Settlement_Tips_C:OnActive()
  self:SetBaseInfo()
  self:SetRogueCoin(self.data:GetRogueCoinNum())
end

function UMG_Settlement_Tips_C:OnDeactive()
end

function UMG_Settlement_Tips_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnCloseBtn)
  self:AddButtonListener(self.ConFirmBtn.btnLevelUp, self.OnConFirmBtn)
end

local DebugData = {
  "\229\188\186\229\140\150\230\172\161\230\149\176:"
}

function UMG_Settlement_Tips_C:SetBaseInfo()
  local UIBuffDatas = self.data:GetUIBuffDatas()
  if UIBuffDatas and #UIBuffDatas > 0 then
    self.BuffPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ConFirmBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ClosePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PropertyList:InitGridView(UIBuffDatas)
    local num = self.data:GetCanChooseBuffNum()
    self.Count:SetText(string.format("%s%s", DebugData[1], num))
  else
    self.BuffPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ConFirmBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ClosePanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Settlement_Tips_C:SetRogueCoin(RogueCoin)
  local MoneyList = {
    {
      moneyType = _G.Enum.VisualItem.VI_ROGUE_COIN,
      sum = RogueCoin,
      IsShowBuyIcon = false
    }
  }
  self.MoneyList:InitGridView(MoneyList)
end

function UMG_Settlement_Tips_C:OpenBuffTips()
  local CurBuffDatas = self.data:GetCurBuffDatas()
  if CurBuffDatas and #CurBuffDatas > 0 then
    self.module:OpenBuffTips(CurBuffDatas)
  end
end

function UMG_Settlement_Tips_C:OnCloseBtn()
  _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.ChangeState, 2)
  self.data:SetIsOpenSettlementTips(false)
  self.module:OpenSettlementTipsPanelChange(false)
  self:DoClose()
end

function UMG_Settlement_Tips_C:OnConFirmBtn()
  if not self.module:CheckBuffIndexes(self.data:GetSelectBuffList()) then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\233\128\137\230\139\169buff\230\156\137\233\151\174\233\162\152")
    return
  end
  _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.SendChooseBuffReq, self.data:GetSelectBuffList())
  self.data:SetIsOpenSettlementTips(false)
  self:DoClose()
end

return UMG_Settlement_Tips_C
