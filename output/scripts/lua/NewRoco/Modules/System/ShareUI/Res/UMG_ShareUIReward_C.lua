local UMG_ShareUIReward_C = _G.NRCPanelBase:Extend("UMG_ShareUIReward_C")

function UMG_ShareUIReward_C:Init(data)
  self.data = data
  self:ShowPanel(true)
  self:InitPanelInfo()
  self:AdjustPosition()
  self:DealHide()
  self:PlayInAnim()
end

function UMG_ShareUIReward_C:InitPanelInfo()
  local shareRewardConf = _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.GetShareRewardItemInfo, self.data.shareBaseId)
  if shareRewardConf then
    local icon
    local itemId = shareRewardConf.goods_id
    local itemType = shareRewardConf.goods_type
    if itemType == Enum.GoodsType.GT_VITEM then
      local VItem = DataConfigManager:GetVisualItemConf(itemId)
      icon = VItem.bigIcon
    elseif itemType == Enum.GoodsType.GT_BAGITEM then
      local BagItem = DataConfigManager:GetBagItemConf(itemId)
      icon = BagItem.icon
    end
    if icon then
      self.Icon:SetPath(icon)
    end
    local itemCount = shareRewardConf.goods_count
    self.Quantity:SetText(tostring(itemCount))
    local shareBaseConf = _G.DataConfigManager:GetShareBaseConf(self.data.shareBaseId)
    if shareBaseConf and shareBaseConf.share_reward_tips then
      self.Tips:SetText(shareBaseConf.share_reward_tips)
    end
  end
end

function UMG_ShareUIReward_C:AdjustPosition()
  if self.data.pos then
    local curPos = self.Slot:GetPosition()
    curPos.x = self.data.pos.X
    self.Slot:SetPosition(curPos)
  end
end

function UMG_ShareUIReward_C:PlayInAnim()
  if self.data.isUpAnim then
    self:PlayAnimation(self.In_up)
  else
    self:PlayAnimation(self.In_down)
  end
end

function UMG_ShareUIReward_C:PlayOutAnim()
  if self.data.isUpAnim then
    self:PlayAnimation(self.Out_up)
  else
    self:PlayAnimation(self.Out_down)
  end
end

function UMG_ShareUIReward_C:DealHide()
  local function cb()
    self:PlayOutAnim()
  end
  
  self.shareDelayId = _G.DelayManager:DelaySeconds(3.0, cb, self)
end

function UMG_ShareUIReward_C:ShowPanel(isShow)
  if isShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ShareUIReward_C:CancelShareDelayId()
  if self.shareDelayId then
    _G.DelayManager:CancelDelayById(self.shareDelayId)
    self.shareDelayId = nil
  end
end

function UMG_ShareUIReward_C:CheckPlayAnimOut()
  if self:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible and not self:IsAnimationPlaying(self.Out_up) and not self:IsAnimationPlaying(self.Out_down) then
    self:PlayOutAnim()
  end
end

function UMG_ShareUIReward_C:OnAnimationFinished(Animation)
  if Animation == self.Out_up or Animation == self.Out_down then
    self:ShowPanel(false)
  end
end

return UMG_ShareUIReward_C
