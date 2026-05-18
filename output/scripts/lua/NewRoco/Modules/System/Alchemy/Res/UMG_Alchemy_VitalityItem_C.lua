local UMG_Alchemy_VitalityItem_C = _G.NRCPanelBase:Extend("UMG_Alchemy_VitalityItem_C")
UMG_Alchemy_VitalityItem_C.ColorEnum = {
  RED = 0,
  YELLOW = 1,
  GREEN = 2,
  BLUE = 3
}

function UMG_Alchemy_VitalityItem_C:OnActive()
end

function UMG_Alchemy_VitalityItem_C:OnDeactive()
end

function UMG_Alchemy_VitalityItem_C:OnAddEventListener()
end

function UMG_Alchemy_VitalityItem_C:OnConstruct()
  self.CurColor = UMG_Alchemy_VitalityItem_C.ColorEnum.RED
  self.growPowerCircleCount = _G.DataConfigManager:GetRoleGlobalConfig("grow_power_circle").num
end

function UMG_Alchemy_VitalityItem_C:OnDestruct()
end

function UMG_Alchemy_VitalityItem_C:SetUpgradeTimes(times)
  local numPerRound = _G.DataConfigManager:GetRoleGlobalConfig("born_power_increase_peer_max").num
  local upgradeLowerLimit = _G.DataConfigManager:GetPowerMaxConf(1).lower_limit
  if 0 == times then
    self.CurColor = UMG_Alchemy_VitalityItem_C.ColorEnum.YELLOW
  elseif times > 0 then
    local powerStageInfo = _G.DataConfigManager:GetPowerMaxConf(times)
    if powerStageInfo then
      if powerStageInfo.lower_limit < upgradeLowerLimit + numPerRound then
        self.CurColor = UMG_Alchemy_VitalityItem_C.ColorEnum.GREEN
      elseif powerStageInfo.lower_limit >= upgradeLowerLimit + numPerRound and powerStageInfo.lower_limit < upgradeLowerLimit + numPerRound * 2 then
        self.CurColor = UMG_Alchemy_VitalityItem_C.ColorEnum.BLUE
      end
    end
  end
  self:SetColorVisible(self.CurColor, times)
end

function UMG_Alchemy_VitalityItem_C:SetColorVisible(colorEnum, times)
  local numPerRound = _G.DataConfigManager:GetRoleGlobalConfig("born_power_increase_peer_max").num
  local upgradeLowerLimit = _G.DataConfigManager:GetPowerMaxConf(1).lower_limit
  local progressStartPercentage = 0
  local progressEndPercentage = 0
  local bOverRound = false
  if times > 0 then
    local powerStageInfo = _G.DataConfigManager:GetPowerMaxConf(times)
    if powerStageInfo then
      if powerStageInfo.lower_limit < upgradeLowerLimit + numPerRound then
        progressStartPercentage = (powerStageInfo.lower_limit - upgradeLowerLimit) / numPerRound
        progressEndPercentage = (powerStageInfo.upper_limit - upgradeLowerLimit) / numPerRound
      elseif powerStageInfo.lower_limit < upgradeLowerLimit + numPerRound and powerStageInfo.upper_limit > upgradeLowerLimit + numPerRound then
        progressStartPercentage = (powerStageInfo.lower_limit - upgradeLowerLimit) / numPerRound
        progressEndPercentage = (powerStageInfo.upper_limit - upgradeLowerLimit - numPerRound) / numPerRound
        bOverRound = true
      elseif powerStageInfo.lower_limit >= upgradeLowerLimit + numPerRound and powerStageInfo.upper_limit <= upgradeLowerLimit + numPerRound * 2 then
        progressStartPercentage = (powerStageInfo.lower_limit - upgradeLowerLimit - numPerRound) / numPerRound
        progressEndPercentage = (powerStageInfo.upper_limit - upgradeLowerLimit - numPerRound) / numPerRound
      end
    end
  end
  
  local function linearInterpolation(x)
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
  
  progressEndPercentage = linearInterpolation(progressEndPercentage)
  self.Yellow:SetFillAmount(1)
  if colorEnum == UMG_Alchemy_VitalityItem_C.ColorEnum.YELLOW then
    self.Yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Green:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Blue:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Shadow_up.Slot:SetZorder(0)
    self.ShadowPanel.Slot:SetZorder(0)
  elseif colorEnum == UMG_Alchemy_VitalityItem_C.ColorEnum.GREEN then
    self.Yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Green:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if bOverRound then
      self.Blue:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Green:SetFillAmount(1)
      self.Blue:SetFillAmount(progressEndPercentage)
      self.Shadow_up.Slot:SetZorder(4)
      self.ShadowPanel:SetRenderTransformAngle(progressEndPercentage * 360)
      self.ShadowPanel.Slot:SetZorder(4)
    else
      self.Blue:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Green:SetFillAmount(progressEndPercentage)
      self.Shadow_up.Slot:SetZorder(2)
      self.ShadowPanel:SetRenderTransformAngle(progressEndPercentage * 360)
      self.ShadowPanel.Slot:SetZorder(2)
    end
  elseif colorEnum == UMG_Alchemy_VitalityItem_C.ColorEnum.BLUE then
    self.Yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Green:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Blue:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Green:SetFillAmount(1)
    self.Blue:SetFillAmount(progressEndPercentage)
    self.Shadow_up.Slot:SetZorder(4)
    self.ShadowPanel:SetRenderTransformAngle(progressEndPercentage * 360)
    self.ShadowPanel.Slot:SetZorder(4)
  end
end

return UMG_Alchemy_VitalityItem_C
