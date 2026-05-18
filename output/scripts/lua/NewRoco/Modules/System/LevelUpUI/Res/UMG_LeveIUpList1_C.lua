local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LeveIUpList1_C = Base:Extend("UMG_LeveIUpList1_C")

function UMG_LeveIUpList1_C:OnConstruct()
end

function UMG_LeveIUpList1_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function UMG_LeveIUpList1_C:OnItemUpdate(_data, datalist, index)
  self.ParentPanel = _data.panel
  self.Reward = _data.reward
  self.OldReward = _data.oldreward
  if self.OldReward and self.OldReward.value and tonumber(self.OldReward.value) then
    self.UiData = self.OldReward
  else
    self.UiData = self.Reward
  end
  if self.Reward.value and self.OldReward.value and tonumber(self.Reward.value) and tonumber(self.OldReward.value) then
    self.tempValue = self.Reward.value - self.OldReward.value
  end
  self.DelayCount = 0
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.NRCImage_23:SetPath(self.UiData.icon)
  if self.UiData.value then
    self.ContentTupo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ContentTupo:SetText(self.UiData.value)
    self.Arrows:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ContentTupo:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Arrows:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Content:SetText(self.UiData.content)
end

function UMG_LeveIUpList1_C:UpdateValue()
  if self.tempValue then
    self.DelayCount = self.DelayCount + 1
    if self.DelayCount >= 5 then
      self.ContentTupo:SetText(self.Reward.value)
      self.ParentPanel:SetBtnClick()
    else
      self.ContentTupo:SetText(math.floor(self.OldReward.value + self.tempValue * 0.2 * self.DelayCount + 0.5))
    end
    self.DelayId = _G.DelayManager:DelaySeconds(0.1, self.UpdateValue, self)
  else
    if self.Reward then
      self.Content:SetText(self.Reward.content)
      if self.Reward.value then
        self.ContentTupo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.ContentTupo:SetText(self.UiData.value)
        self.Arrows:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.ContentTupo:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Arrows:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    self.ParentPanel:SetBtnClick()
  end
end

function UMG_LeveIUpList1_C:OnDeactive()
end

function UMG_LeveIUpList1_C:OnAnimationFinished(anim)
  if anim == self.Star_in then
    self:PlayAnimation(self.Star_loop)
  end
  if anim == self.Star_loop then
    self:PlayAnimation(self.Star_loop)
  end
end

return UMG_LeveIUpList1_C
