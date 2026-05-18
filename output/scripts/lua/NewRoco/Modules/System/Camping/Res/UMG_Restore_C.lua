local UMG_Restore_C = _G.NRCPanelBase:Extend("UMG_Restore_C")

function UMG_Restore_C:OnConstruct()
end

function UMG_Restore_C:OnDestruct()
  self.shouldPlayAnimation = false
end

function UMG_Restore_C:OnActive()
end

function UMG_Restore_C:OnDeactive()
end

function UMG_Restore_C:Init()
  self.bIsUpdating = false
end

function UMG_Restore_C:OnShiningDone()
  if self.DataPack.target_origin_value == self.DataPack.max_value then
    self:PlayAnimation(self.BottleChangeMax)
  else
    self:PlayAnimation(self.BottleChange)
  end
end

function UMG_Restore_C:StopArrowAnimation()
  self:StopAllAnimations()
  self:PlayAnimation(self.BottleNormal)
  self.shouldPlayAnimation = false
end

function UMG_Restore_C:OnAnimationFinished(Animation)
  if Animation == self.BottleChange or Animation == self.BottleChangeMax then
    self:PlayAnimation(self.Bottle_TJ)
  elseif Animation == self.Bottle_TJ then
    self:SetUnderData(self.DataPack.target_origin_value, self.DataPack.target_target_value, self.DataPack.max_value)
    self.DataPack.callback(self.DataPack.caller)
    self.DataPack = nil
  end
end

function UMG_Restore_C:PushLevelUpData(DataPack)
  self.DataPack = DataPack
  self:SetUnderData(self.DataPack.origin_origin_value, self.DataPack.origin_target_value, self.DataPack.max_value)
  self:SetUnderBackData(self.DataPack.target_origin_value, self.DataPack.target_target_value, self.DataPack.max_value)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1232, "UMG_Restore_C:PushLevelUpData")
  self.UMG_Camping_FontFX:PlayChangeAnimation(self, self.OnShiningDone)
end

function UMG_Restore_C:SetUnderData(origin_value, target_value, max_value)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  if origin_value == max_value then
    self.MaxValueText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText_MAX:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Under:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.MaxValueText:SetText(origin_value)
    self.BottleMaxIconText:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif target_value == max_value then
    self.MaxValueText:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_MAX:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Under:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRC_NoChange:SetText(origin_value)
    self.NRC_Change:SetText(target_value)
    self.BottleMaxIconText:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.MaxValueText:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_MAX:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Under:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRC_NoChange:SetText(origin_value)
    self.NRC_Change:SetText(target_value)
    self.BottleMaxIconText:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Restore_C:SetUnderBackData(origin_value, target_value, max_value)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  if origin_value == max_value then
    self.NRCText_MAX_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Under_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif target_value == max_value then
    self.NRCText_MAX_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Under_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRC_NoChange_1:SetText(origin_value)
    self.NRC_Change_1:SetText(target_value)
  else
    self.NRCText_MAX_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Under_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRC_NoChange_1:SetText(origin_value)
    self.NRC_Change_1:SetText(target_value)
  end
end

return UMG_Restore_C
