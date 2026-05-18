local UMG_Alchemy_VitalityUpTips_Item_C = _G.NRCPanelBase:Extend("UMG_Alchemy_VitalityUpTips_Item_C")
UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum = {
  RED = 0,
  YELLOW = 1,
  GREEN = 2,
  BLUE = 3
}

function UMG_Alchemy_VitalityUpTips_Item_C:OnActive()
end

function UMG_Alchemy_VitalityUpTips_Item_C:OnDeactive()
end

function UMG_Alchemy_VitalityUpTips_Item_C:OnAddEventListener()
end

function UMG_Alchemy_VitalityUpTips_Item_C:OnConstruct()
  self.CurColor = UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.RED
  self.curTimes = 0
  self.progressPercentage = 0
  self.bOverRound = false
  self.tickStart = false
  self.frameIntervalNum = 0
  self.devideNum = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.POWER_MAX_CONF):GetDataCount()
  self.UpgradeLimit = 0
  self.growPowerCircleCount = _G.DataConfigManager:GetRoleGlobalConfig("grow_power_circle").num
  if 1 == self.devideNum % 2 then
    if 1 == self.growPowerCircleCount then
      self.devideNum = self.devideNum + 1
      self.UpgradeLimit = self.devideNum - 1
    elseif 2 == self.growPowerCircleCount then
      self.devideNum = (self.devideNum + 1) / 2
      self.UpgradeLimit = self.devideNum * 2 - 1
    end
  elseif 1 == self.growPowerCircleCount then
    self.devideNum = self.devideNum
    self.UpgradeLimit = self.devideNum
  elseif 2 == self.growPowerCircleCount then
    self.devideNum = self.devideNum / 2
    self.UpgradeLimit = self.devideNum * 2
  end
end

function UMG_Alchemy_VitalityUpTips_Item_C:OnDestruct()
end

function UMG_Alchemy_VitalityUpTips_Item_C:OnTick(deltaTime)
  if self.tickStart == true and self.frameIntervalNum <= 27 then
    local numPerRound = _G.DataConfigManager:GetRoleGlobalConfig("born_power_increase_peer_max").num
    local numThisUpgrade = self.powerStageInfo.upper_limit - self.powerStageInfo.lower_limit
    if self.CurColor == UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.GREEN then
      if self.frameIntervalNum > 0 then
        if self.bOverRound then
          if self.progressStartPercentage + (self.progressEndPercentage - self.progressStartPercentage) / 27 * self.frameIntervalNum > 1 then
            if self.Blue:GetVisibility() == UE4.ESlateVisibility.Collapsed then
              self.Green:SetFillAmount(1)
              self.Shadow.Slot:SetZOrder(3)
              self.ShadowPanel.Slot:SetZOrder(3)
              self.Shadow_up.Slot:SetZOrder(3)
              self.Blue:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
              self.Green_light:SetVisibility(UE4.ESlateVisibility.Collapsed)
              self.Blue_light:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
              self.Blue_light:SetRenderTransformAngle(0)
            end
            local fillPercentage = self:VitalityLinearInterpolation(self.progressStartPercentage + numThisUpgrade / numPerRound / 27 * self.frameIntervalNum - 1)
            self.Blue:SetFillAmount(fillPercentage)
          else
            local fillPercentage = self:VitalityLinearInterpolation(self.progressStartPercentage + numThisUpgrade / numPerRound / 27 * self.frameIntervalNum)
            self.Green:SetFillAmount(fillPercentage)
          end
        else
          local fillPercentage = self:VitalityLinearInterpolation(self.progressStartPercentage + numThisUpgrade / numPerRound / 27 * self.frameIntervalNum)
          self.Green:SetFillAmount(fillPercentage)
        end
      end
    elseif self.CurColor == UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.BLUE and self.frameIntervalNum > 0 then
      local fillPercentage = self:VitalityLinearInterpolation(self.progressStartPercentage + numThisUpgrade / numPerRound / 27 * self.frameIntervalNum)
      self.Blue:SetFillAmount(fillPercentage)
    end
    if 27 == self.frameIntervalNum then
      self.ShadowPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ShadowPanel:SetRenderTransformAngle(self.progressEndPercentage * 360)
      self:PlayAnimation(self.Shadow_in)
      self:PlayAnimation(self.Reduce)
      self.tickStart = false
      self.Blue_light:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Green_light:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.frameIntervalNum = self.frameIntervalNum + 1
  end
end

function UMG_Alchemy_VitalityUpTips_Item_C:SetUpgradeTimes(times)
  local numPerRound = _G.DataConfigManager:GetRoleGlobalConfig("born_power_increase_peer_max").num
  local upgradeLowerLimit = _G.DataConfigManager:GetPowerMaxConf(1).lower_limit
  if 0 == times then
    self.CurColor = UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.YELLOW
  elseif times > 0 then
    local powerStageInfo = _G.DataConfigManager:GetPowerMaxConf(times)
    if powerStageInfo then
      if powerStageInfo.lower_limit < upgradeLowerLimit + numPerRound then
        self.CurColor = UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.GREEN
      elseif powerStageInfo.lower_limit >= upgradeLowerLimit + numPerRound and powerStageInfo.lower_limit < upgradeLowerLimit + numPerRound * 2 then
        self.CurColor = UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.BLUE
      end
    end
  end
  self:SetColorVisible(self.CurColor, times)
end

function UMG_Alchemy_VitalityUpTips_Item_C:SetColorVisible(colorEnum, times)
  local numPerRound = _G.DataConfigManager:GetRoleGlobalConfig("born_power_increase_peer_max").num
  local upgradeLowerLimit = _G.DataConfigManager:GetPowerMaxConf(1).lower_limit
  self.progressStartPercentage = 0
  self.progressEndPercentage = 0
  self.bOverRound = false
  if times > 0 then
    self.powerStageInfo = _G.DataConfigManager:GetPowerMaxConf(times)
    if self.powerStageInfo then
      if self.powerStageInfo.lower_limit < upgradeLowerLimit + numPerRound then
        self.progressStartPercentage = (self.powerStageInfo.lower_limit - upgradeLowerLimit) / numPerRound
        self.progressEndPercentage = (self.powerStageInfo.upper_limit - upgradeLowerLimit) / numPerRound
      elseif self.powerStageInfo.lower_limit < upgradeLowerLimit + numPerRound and self.powerStageInfo.upper_limit > upgradeLowerLimit + numPerRound then
        self.progressStartPercentage = (self.powerStageInfo.lower_limit - upgradeLowerLimit) / numPerRound
        self.progressEndPercentage = (self.powerStageInfo.upper_limit - upgradeLowerLimit - numPerRound) / numPerRound
        self.bOverRound = true
      elseif self.powerStageInfo.lower_limit >= upgradeLowerLimit + numPerRound and self.powerStageInfo.upper_limit <= upgradeLowerLimit + numPerRound * 2 then
        self.progressStartPercentage = (self.powerStageInfo.lower_limit - upgradeLowerLimit - numPerRound) / numPerRound
        self.progressEndPercentage = (self.powerStageInfo.upper_limit - upgradeLowerLimit - numPerRound) / numPerRound
      end
    end
  end
  self.progressEndPercentage = self:VitalityLinearInterpolation(self.progressEndPercentage)
  local fillPercentage = self:VitalityLinearInterpolation(self.progressStartPercentage)
  self.Yellow:SetFillAmount(1)
  self.curTimes = times
  self.ShadowPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if colorEnum == UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.YELLOW then
    self.Yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Green:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Blue:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif colorEnum == UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.GREEN then
    if self.bOverRound then
      self.Shadow.Slot:SetZOrder(1)
      self.ShadowPanel.Slot:SetZOrder(1)
      self.Shadow_up.Slot:SetZOrder(1)
      self.Yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Green:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Blue:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Green_light:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Blue_light:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Green_light:SetRenderTransformAngle(self.progressStartPercentage * 360)
      self:PlayAnimation(self.Green_shine)
      self.Green:SetFillAmount(fillPercentage)
    else
      self.Shadow.Slot:SetZOrder(1)
      self.ShadowPanel.Slot:SetZOrder(1)
      self.Shadow_up.Slot:SetZOrder(1)
      self.Yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Green:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Blue:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Green_light:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Blue_light:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Green_light:SetRenderTransformAngle(self.progressStartPercentage * 360)
      self:PlayAnimation(self.Green_shine)
      self.Green:SetFillAmount(fillPercentage)
    end
  elseif colorEnum == UMG_Alchemy_VitalityUpTips_Item_C.ColorEnum.BLUE then
    self.Shadow.Slot:SetZOrder(3)
    self.ShadowPanel.Slot:SetZOrder(3)
    self.Shadow_up.Slot:SetZOrder(3)
    self.Yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Green:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Blue:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Green_light:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Blue_light:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Green:SetFillAmount(1)
    self.Blue_light:SetRenderTransformAngle(self.progressStartPercentage * 360)
    self:PlayAnimation(self.Blue_shine)
    self.Blue:SetFillAmount(fillPercentage)
  end
end

function UMG_Alchemy_VitalityUpTips_Item_C:VitalityLinearInterpolation(x)
  local segments = {
    0.088,
    0.176,
    0.25,
    0.323,
    0.435,
    0.5,
    0.588,
    0.676,
    0.75,
    0.823,
    0.935,
    1
  }
  local originalSegments = {
    0.08333333333333333,
    0.16666666666666666,
    0.25,
    0.3333333333333333,
    0.4166666666666667,
    0.5,
    0.5833333333333334,
    0.6666666666666666,
    0.75,
    0.8333333333333334,
    0.9166666666666666,
    1.0
  }
  if x <= 0 then
    return 0
  end
  if x >= 1 then
    return 1
  end
  for i = 1, #originalSegments do
    if 1 == i then
      if x <= originalSegments[i] then
        return segments[i] * (x / originalSegments[i])
      end
    elseif x > originalSegments[i - 1] and x <= originalSegments[i] then
      local a = originalSegments[i - 1]
      local b = originalSegments[i]
      local c = segments[i - 1]
      local d = segments[i]
      return c + (x - a) * (d - c) / (b - a)
    end
  end
  return x
end

function UMG_Alchemy_VitalityUpTips_Item_C:OnAnimationFinished(anim)
  if anim == self.Green_shine then
    _G.NRCAudioManager:PlaySound2DAuto(11701603, "UMG_Alchemy_VitalityUpTips_Item_C:OnAnimationFinished")
    self.tickStart = true
  elseif anim == self.Blue_shine then
    _G.NRCAudioManager:PlaySound2DAuto(11701603, "UMG_Alchemy_VitalityUpTips_Item_C:OnAnimationFinished")
    self.tickStart = true
  end
end

return UMG_Alchemy_VitalityUpTips_Item_C
