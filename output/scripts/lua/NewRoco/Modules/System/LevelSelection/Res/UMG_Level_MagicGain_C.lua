local UMG_Level_MagicGain_C = _G.NRCPanelBase:Extend("UMG_Level_MagicGain_C")

function UMG_Level_MagicGain_C:OnActive(activityId, buffIds)
  self:LoadAnimation(0)
  self.activityId = activityId
  self.SecondLine:InitGridView(buffIds)
  self:SetCommonPopUpInfo()
end

function UMG_Level_MagicGain_C:OnDeactive()
end

function UMG_Level_MagicGain_C:OnAddEventListener()
end

function UMG_Level_MagicGain_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
  self:OnAddEventListener()
end

function UMG_Level_MagicGain_C:OnDestruct()
end

function UMG_Level_MagicGain_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnClickbtnCloseRenamePanel
  CommonPopUpData.Btn_RightHandler = self.OnClickOnClickBtnBuy
  CommonPopUpData.ClosePanelHandler = self.OnClickbtnCloseRenamePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_Level_MagicGain_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Level_MagicGain_C:OnClickOnClickBtnBuy()
  local curSelecedId = _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdGetCurSelectRuleBuffId)
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdReplaceRuleBuffId, self.activityId, curSelecedId)
  self:OnClickbtnCloseRenamePanel()
end

function UMG_Level_MagicGain_C:OnClickbtnCloseRenamePanel()
  if self:IsAnimationPlaying(self:GetAnimByIndex(2)) then
    return
  end
  self:LoadAnimation(2)
end

return UMG_Level_MagicGain_C
