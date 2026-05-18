local UMG_CommonAddSubtract_C = _G.NRCPanelBase:Extend("UMG_CommonAddSubtract_C")

function UMG_CommonAddSubtract_C:OnConstruct()
  self.CommonAddSubtractData = nil
  self:SetDefaultIconBrush()
  self:OnAddEventListener()
end

function UMG_CommonAddSubtract_C:OnDestruct()
end

function UMG_CommonAddSubtract_C:OnActive()
end

function UMG_CommonAddSubtract_C:OnDeactive()
end

function UMG_CommonAddSubtract_C:OnAddEventListener()
  if self.SubtractBtn then
    self:AddButtonListener(self.SubtractBtn.btnLevelUp, self.OnSubtractBtnClicked)
    self.SubtractBtn.btnLevelUp.OnPressed:Add(self, self.OnSubTractBtnPressed)
    self.SubtractBtn.btnLevelUp.OnReleased:Add(self, self.OnSubTractBtnReleased)
  end
  if self.SubtractBtn_1 then
    self:AddButtonListener(self.SubtractBtn_1.btnLevelUp, self.OnAddBtnClicked)
    self.SubtractBtn_1.btnLevelUp.OnPressed:Add(self, self.OnAddBtnPressed)
    self.SubtractBtn_1.btnLevelUp.OnReleased:Add(self, self.OnAddBtnReleased)
  end
  if self.SubtractBtn_2 then
    self:AddButtonListener(self.SubtractBtn_2.btnLevelUp, self.OnMaxBtnClicked)
    self.SubtractBtn_2.btnLevelUp.OnReleased:Add(self, self.OnMaxBtnReleased)
  end
  if self.AddBtn then
    self:AddButtonListener(self.AddBtn.btnLevelUp, self.OnAddBtnClicked)
    self.AddBtn.btnLevelUp.OnPressed:Add(self, self.OnAddBtnPressed)
    self.AddBtn.btnLevelUp.OnReleased:Add(self, self.OnAddBtnReleased)
  end
  if self.FastReductionBtn then
    self:AddButtonListener(self.FastReductionBtn.btnLevelUp, self.OnMultipleSubtractBtnClicked)
    self.FastReductionBtn.btnLevelUp.OnPressed:Add(self, self.OnFastReductionBtnPressed)
    self.FastReductionBtn.btnLevelUp.OnReleased:Add(self, self.OnFastReductionBtnReleased)
  end
  if self.QuickAdditionBtn then
    self:AddButtonListener(self.QuickAdditionBtn.btnLevelUp, self.OnMultipleAddBtnClicked)
    self.QuickAdditionBtn.btnLevelUp.OnPressed:Add(self, self.OnQuickAdditionBtnPressed)
    self.QuickAdditionBtn.btnLevelUp.OnReleased:Add(self, self.OnQuickAdditionBtnReleased)
  end
  if self.Slider_95 then
    self:AddDelegateListener(self.Slider_95.OnValueChanged, self.OnSliderValueChanged)
  end
end

function UMG_CommonAddSubtract_C:SetPanelInfo(CommonAddSubtractData)
  self.CommonAddSubtractData = CommonAddSubtractData
  if self.Digital then
    if self.CommonAddSubtractData.SliderInfo and self.CommonAddSubtractData.ProgressBarInfo then
      if self.SubtractBtn then
        self.SubtractBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.SubtractBtn_1 then
        self.SubtractBtn_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.SubtractBtn_2 and (self.CommonAddSubtractData.MaxBtnHandler or self.CommonAddSubtractData.MaxBtnOnReleasedHandler) then
        self.SubtractBtn_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self.Digital:SetText(self.CommonAddSubtractData.SliderInfo.num1)
    elseif self.CommonAddSubtractData.MultipleSubtractBtnText then
      self.Digital:SetText(self.CommonAddSubtractData.MultipleSubtractBtnText)
    end
  end
  if self.Digital_1 then
    if self.CommonAddSubtractData.SliderInfo and self.CommonAddSubtractData.ProgressBarInfo then
      self.Digital_1:SetText(self.CommonAddSubtractData.SliderInfo.num2)
    elseif self.CommonAddSubtractData.SelectNum then
      if self.SubtractBtn then
        self.SubtractBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.AddBtn then
        self.AddBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self.Digital_1:SetText(self.CommonAddSubtractData.SelectNum)
    end
  end
  if self.Digital_2 and self.CommonAddSubtractData.MultipleAddBtnText then
    self.Digital_2:SetText(self.CommonAddSubtractData.MultipleAddBtnText)
  end
  if self.Schedule and self.CommonAddSubtractData.ProgressBarInfo then
    self.Schedule:SetPercent(self.CommonAddSubtractData.ProgressBarInfo.num1, self.CommonAddSubtractData.ProgressBarInfo.num2)
  end
  if self.Slider_95 and self.CommonAddSubtractData.SliderInfo then
    self.Slider_95:SetStepSize(1)
    self.Slider_95:SetValue(self.CommonAddSubtractData.SliderInfo.num1)
    self.Slider_95:SetMinValue(self.CommonAddSubtractData.SliderInfo.num1)
    self.Slider_95:SetMaxValue(self.CommonAddSubtractData.SliderInfo.num2)
  end
  if self.FastReductionBtn then
    if self.CommonAddSubtractData.MultipleAddBtnHandler then
      self.FastReductionBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.FastReductionBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.QuickAdditionBtn then
    if self.CommonAddSubtractData.MultipleSubtractBtnHandler then
      self.QuickAdditionBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.QuickAdditionBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_CommonAddSubtract_C:OnAddBtnClicked()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.AddBtnHandler then
    self.CommonAddSubtractData.AddBtnHandler(self.CommonAddSubtractData.Call)
    _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_CommonAddSubtract_C:OnAddBtnClicked")
  end
end

function UMG_CommonAddSubtract_C:OnAddBtnPressed()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.AddBtnPressedHandler then
    self.CommonAddSubtractData.AddBtnPressedHandler(self.CommonAddSubtractData.Call)
  end
end

function UMG_CommonAddSubtract_C:OnAddBtnReleased()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.AddBtnReleasedHandler then
    self.CommonAddSubtractData.AddBtnReleasedHandler(self.CommonAddSubtractData.Call)
  end
end

function UMG_CommonAddSubtract_C:OnSubtractBtnClicked()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.SubtractBtnHandler then
    self.CommonAddSubtractData.SubtractBtnHandler(self.CommonAddSubtractData.Call)
    _G.NRCAudioManager:PlaySound2DAuto(41401008, "UMG_CommonAddSubtract_C:OnSubtractBtnClicked")
  end
end

function UMG_CommonAddSubtract_C:OnSubTractBtnPressed()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.SubtractBtnPressedHandler then
    self.CommonAddSubtractData.SubtractBtnPressedHandler(self.CommonAddSubtractData.Call)
  end
end

function UMG_CommonAddSubtract_C:OnSubTractBtnReleased()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.SubtractBtnReleasedHandler then
    self.CommonAddSubtractData.SubtractBtnReleasedHandler(self.CommonAddSubtractData.Call)
  end
end

function UMG_CommonAddSubtract_C:OnMaxBtnClicked()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.MaxBtnHandler then
    self.CommonAddSubtractData.MaxBtnHandler(self.CommonAddSubtractData.Call)
  end
end

function UMG_CommonAddSubtract_C:OnMaxBtnReleased()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.MaxBtnOnReleasedHandler then
    self.CommonAddSubtractData.MaxBtnOnReleasedHandler(self.CommonAddSubtractData.Call)
  end
end

function UMG_CommonAddSubtract_C:OnMultipleAddBtnClicked()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.MultipleAddBtnHandler then
    self.CommonAddSubtractData.MultipleAddBtnHandler(self.CommonAddSubtractData.Call)
    _G.NRCAudioManager:PlaySound2DAuto(1220002011, "UMG_CommonAddSubtract_C:OnMultipleAddBtnClicked")
  end
end

function UMG_CommonAddSubtract_C:OnMultipleSubtractBtnClicked()
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.MultipleSubtractBtnHandler then
    self.CommonAddSubtractData.MultipleSubtractBtnHandler(self.CommonAddSubtractData.Call)
    _G.NRCAudioManager:PlaySound2DAuto(1220002009, "UMG_CommonAddSubtract_C:OnMultipleSubtractBtnClicked")
  end
end

function UMG_CommonAddSubtract_C:OnFastReductionBtnPressed()
  if self.Reduce_Press then
    self:PlayAnimation(self.Reduce_Press)
  end
end

function UMG_CommonAddSubtract_C:OnFastReductionBtnReleased()
  if self.Reduce_Up then
    self:PlayAnimation(self.Reduce_Up)
  end
end

function UMG_CommonAddSubtract_C:OnQuickAdditionBtnPressed()
  if self.Add_Press then
    self:PlayAnimation(self.Add_Press)
  end
end

function UMG_CommonAddSubtract_C:OnQuickAdditionBtnReleased()
  if self.Add_Up then
    self:PlayAnimation(self.Add_Up)
  end
end

function UMG_CommonAddSubtract_C:SetDefaultIconBrush()
  if self.SubtractBtn and self.SubtractBtn_1 and self.SubtractBtn_2 then
    self.SubtractBtnBrush = self.SubtractBtn:GetNormalIcon()
    self.SubtractBtnSelectBrush = self.SubtractBtn:GetSelectIcon()
    self.AddBtnBrush = self.SubtractBtn_1:GetNormalIcon()
    self.AddBtnSelectBrush = self.SubtractBtn_1:GetSelectIcon()
    self.MaxBtnBrush = self.SubtractBtn_2:GetNormalIcon()
    self.MaxBtnSelectBrush = self.SubtractBtn_2:GetSelectIcon()
    self.DisableMaxBtnBrush = self.SubtractBtn_2:GetSelectIcon()
    self.DisableMaxBtnSelectBrush = self.SubtractBtn_2:GetSelectIcon()
  elseif self.FastReductionBtn and self.SubtractBtn and self.AddBtn and self.QuickAdditionBtn then
    self.SubtractBtnBrush = self.SubtractBtn:GetNormalIcon()
    self.SubtractBtnSelectBrush = self.SubtractBtn:GetSelectIcon()
    self.AddBtnBrush = self.AddBtn:GetNormalIcon()
    self.AddBtnSelectBrush = self.AddBtn:GetSelectIcon()
    self.FastReductionBrush = self.FastReductionBtn:GetNormalIcon()
    self.FastReductionSelectBrush = self.FastReductionBtn:GetSelectIcon()
    self.QuickAdditionBrush = self.QuickAdditionBtn:GetNormalIcon()
    self.QuickAdditionSelectBrush = self.QuickAdditionBtn:GetSelectIcon()
  end
end

function UMG_CommonAddSubtract_C:OnSliderValueChanged(value)
  if self.CommonAddSubtractData and self.CommonAddSubtractData.Call and self.CommonAddSubtractData.SliderHandler then
    self.CommonAddSubtractData.SliderHandler(self.CommonAddSubtractData.Call, math.floor(value))
  end
end

function UMG_CommonAddSubtract_C:SetProgressBarPercent(value)
  if self.Schedule and value then
    self.Schedule:SetPercent(value)
  end
end

function UMG_CommonAddSubtract_C:SetSliderStepSize(StepSize)
  if self.Slider_95 and StepSize then
    self.Slider_95:SetStepSize(StepSize)
  end
end

function UMG_CommonAddSubtract_C:SetSliderMinValue(MinValue)
  if self.Slider_95 and MinValue then
    self.Slider_95:SetMinValue(MinValue)
  end
end

function UMG_CommonAddSubtract_C:GetSliderMinValue()
  if self.Slider_95 then
    return self.Slider_95.MinValue
  end
end

function UMG_CommonAddSubtract_C:SetSliderMaxValue(MaxValue)
  if self.Slider_95 and MaxValue then
    self.Slider_95:SetMaxValue(MaxValue)
  end
end

function UMG_CommonAddSubtract_C:GetSliderMaxValue()
  if self.Slider_95 then
    return self.Slider_95.MaxValue
  end
end

function UMG_CommonAddSubtract_C:SetSliderValue(SliderValue)
  if self.Slider_95 and SliderValue then
    self.Slider_95:SetValue(SliderValue)
  end
end

function UMG_CommonAddSubtract_C:GetSliderValue()
  if self.Slider_95 then
    return self.Slider_95:GetValue()
  end
end

function UMG_CommonAddSubtract_C:SetSliderLocked(bLocked)
  if self.Slider_95 and bLocked then
    self.Slider_95:SetLocked(bLocked)
  end
end

function UMG_CommonAddSubtract_C:SetSliderVisibility(_IsShow)
  if self.Slider_95 then
    if _IsShow then
      self.Slider_95:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Slider_95:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_CommonAddSubtract_C:SetMultipleAddBtnText(text)
  if self.Digital then
    if text then
      self.Digital:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Digital:SetText(text)
    else
      self.Digital:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_CommonAddSubtract_C:SetMultipleSubtractBtnText(text)
  if self.Digital_2 then
    if text then
      self.Digital_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Digital_2:SetText(text)
    else
      self.Digital_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_CommonAddSubtract_C:SetSelectNumText(text)
  if self.Digital_1 then
    if text then
      self.Digital_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Digital_1:SetText(text)
    else
      self.Digital_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_CommonAddSubtract_C:SetDigitalEnable(CurrentNum)
  local curValue = self:GetSliderValue()
  local minValue = self:GetSliderMinValue()
  local maxValue = self:GetSliderMaxValue()
  if 0 == curValue or 1 == curValue then
    self:SetSubtractBtnIsEnabledNewStyle(false)
  else
    self:SetSubtractBtnIsEnabledNewStyle(curValue ~= minValue)
  end
  self:SetAddBtnIsEnabledNewStyle(curValue ~= maxValue)
end

function UMG_CommonAddSubtract_C:SetAddBtnIsEnabled(bInIsEnabled)
  if self.SubtractBtn_1 then
    self.SubtractBtn_1:SetIsEnabled(bInIsEnabled)
  end
  if self.AddBtn then
    self.AddBtn:SetIsEnabled(bInIsEnabled)
  end
  if self.QuickAdditionBtn then
    self.QuickAdditionBtn:SetIsEnabled(bInIsEnabled)
  end
end

function UMG_CommonAddSubtract_C:SetSubtractBtnIsEnabled(bInIsEnabled)
  if self.SubtractBtn then
    self.SubtractBtn:SetIsEnabled(bInIsEnabled)
  end
  if self.FastReductionBtn then
    self.FastReductionBtn:SetIsEnabled(bInIsEnabled)
  end
end

function UMG_CommonAddSubtract_C:SetAddBtnIsEnabledNewStyle(bInIsEnabled)
  if self.AddBtnBrush then
    if bInIsEnabled then
      if self.SubtractBtn_1 then
        self.SubtractBtn_1.Ordinary:SetBrush(self.AddBtnBrush)
        self.SubtractBtn_1.ps:SetBrush(self.AddBtnBrush)
        self.SubtractBtn_1.Select:SetBrush(self.AddBtnBrush)
        self.SubtractBtn_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.AddBtn then
        self.AddBtn.Ordinary:SetBrush(self.AddBtnBrush)
        self.AddBtn.ps:SetBrush(self.AddBtnBrush)
        self.AddBtn.Select:SetBrush(self.AddBtnBrush)
        self.AddBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.QuickAdditionBtn then
        if self.QuickAdditionBrush then
          self.QuickAdditionBtn.Ordinary:SetBrush(self.QuickAdditionBrush)
          self.QuickAdditionBtn.ps:SetBrush(self.QuickAdditionBrush)
          self.QuickAdditionBtn.Select:SetBrush(self.QuickAdditionBrush)
        end
        self.QuickAdditionBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.SubtractBtn_2 and self.SubtractBtn_2:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        if self.MaxBtnBrush then
          self.SubtractBtn_2.Ordinary:SetBrush(self.MaxBtnBrush)
          self.SubtractBtn_2.ps:SetBrush(self.MaxBtnBrush)
          self.SubtractBtn_2.Select:SetBrush(self.MaxBtnBrush)
        end
        self.SubtractBtn_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      if self.SubtractBtn_1 then
        self.SubtractBtn_1.Ordinary:SetBrush(self.AddBtnSelectBrush)
        self.SubtractBtn_1.ps:SetBrush(self.AddBtnSelectBrush)
        self.SubtractBtn_1.Select:SetBrush(self.AddBtnSelectBrush)
        self.SubtractBtn_1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
      if self.AddBtn then
        self.AddBtn.Ordinary:SetBrush(self.AddBtnSelectBrush)
        self.AddBtn.ps:SetBrush(self.AddBtnSelectBrush)
        self.AddBtn.Select:SetBrush(self.AddBtnSelectBrush)
        self.AddBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
      if self.QuickAdditionBtn then
        local quickAdditionPath = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_NumberBtn3_png.img_NumberBtn3_png'"
        self.QuickAdditionBtn:SetPath(quickAdditionPath, quickAdditionPath, quickAdditionPath)
        self.QuickAdditionBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
      if self.SubtractBtn_2 and self.SubtractBtn_2:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        if self.DisableMaxBtnBrush then
          self.SubtractBtn_2.Ordinary:SetBrush(self.DisableMaxBtnBrush)
          self.SubtractBtn_2.ps:SetBrush(self.DisableMaxBtnBrush)
          self.SubtractBtn_2.Select:SetBrush(self.DisableMaxBtnBrush)
        end
        self.SubtractBtn_2:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
    end
  end
end

function UMG_CommonAddSubtract_C:SetSubtractBtnIsEnabledNewStyle(bInIsEnabled)
  if self.SubtractBtnBrush then
    if bInIsEnabled then
      if self.SubtractBtn then
        self.SubtractBtn.Ordinary:SetBrush(self.SubtractBtnBrush)
        self.SubtractBtn.ps:SetBrush(self.SubtractBtnBrush)
        self.SubtractBtn.Select:SetBrush(self.SubtractBtnBrush)
        self.SubtractBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.FastReductionBtn then
        if self.FastReductionBrush then
          self.FastReductionBtn.Ordinary:SetBrush(self.FastReductionBrush)
          self.FastReductionBtn.ps:SetBrush(self.FastReductionBrush)
          self.FastReductionBtn.Select:SetBrush(self.FastReductionBrush)
        end
        self.FastReductionBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      if self.SubtractBtn then
        self.SubtractBtn.Ordinary:SetBrush(self.SubtractBtnSelectBrush)
        self.SubtractBtn.ps:SetBrush(self.SubtractBtnSelectBrush)
        self.SubtractBtn.Select:SetBrush(self.SubtractBtnSelectBrush)
        self.SubtractBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
      if self.FastReductionBtn then
        local fastReductionPath = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_NumberBtn3_png.img_NumberBtn3_png'"
        self.FastReductionBtn:SetPath(fastReductionPath, fastReductionPath, fastReductionPath)
        self.FastReductionBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
    end
  end
end

return UMG_CommonAddSubtract_C
