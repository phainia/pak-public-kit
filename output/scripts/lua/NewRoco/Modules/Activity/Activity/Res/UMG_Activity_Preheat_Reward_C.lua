local UMG_Activity_Preheat_Reward_C = _G.NRCPanelBase:Extend("UMG_Activity_Preheat_Reward_C")

function UMG_Activity_Preheat_Reward_C:OnConstruct()
  self:SetChildViews(self.PopUp)
  self:InitPopUp()
end

function UMG_Activity_Preheat_Reward_C:OnDestruct()
end

function UMG_Activity_Preheat_Reward_C:OnActive(items)
  self.List:InitGridView(items or {})
  self:LoadAnimation(0)
end

function UMG_Activity_Preheat_Reward_C:InitPopUp()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = _G.LuaText.preheat_activity_reward_title
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnClickClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Activity_Preheat_Reward_C:OnClickClose()
  if not self:LoadAnimation(2) then
    self:DoClose()
  end
end

function UMG_Activity_Preheat_Reward_C:OnPcClose()
  self:OnClickClose()
end

function UMG_Activity_Preheat_Reward_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Activity_Preheat_Reward_C
