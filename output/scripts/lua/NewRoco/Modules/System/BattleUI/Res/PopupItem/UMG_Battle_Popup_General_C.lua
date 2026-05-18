local UMG_Battle_Popup_General_C = _G.NRCUmgClass:Extend("UMG_Battle_Popup_General_C")

function UMG_Battle_Popup_General_C:SetContent(Popup)
  self.Popup = Popup
  if self.Content.SetContent then
    self.Content:SetContent(Popup)
  else
    Log.Error("zgx weird thing happened!!!  Content no SetContent")
  end
  if self.Content_1.SetContent then
    self.Content_1:SetContent(Popup)
  else
    Log.Error("zgx weird thing happened!!!  Content_1 no SetContent")
  end
  self:SetPreFix()
  self.CurPerformNumber = 1
  self.CurPerformDamage = {}
end

function UMG_Battle_Popup_General_C:Play()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  if not self.Popup then
    Log.Warning("UMG_Battle_Popup_General_C Popup is nil")
    return
  end
  if self.Popup:IsCritical() then
    self:PlayAnimation(self.Open_Crit)
  elseif self.Popup:IsRestraint() then
    self:PlayAnimation(self.Open_Restraint)
  elseif self.Popup:IsRestrainted() then
    self:PlayAnimation(self.Open_HoldOut)
    self.FX:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.FX:PlayAnimation(self.FX.HoldOut)
  else
    self:PlayAnimation(self.Open_HoldOut)
  end
  if 1 == self.Popup.TotalDamageNumber then
    self.Content:Play()
    self.Content_1:Play()
  else
    self.CurPerformDamage[1] = self.Popup.content
  end
end

function UMG_Battle_Popup_General_C:RePlay(curNumber, addDamage)
  if not self.Popup then
    Log.Warning("UMG_Battle_Popup_General_C Popup is nil")
    return
  end
  self.Popup:SetDamageNumber(self.Popup.TotalDamageNumber, curNumber, addDamage)
  self:DoReplay(curNumber)
end

function UMG_Battle_Popup_General_C:DoReplay(curNumber)
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self.CurPerformDamage[curNumber] = tostring(self.Popup.CurDamage)
  if self:IsAnimationPlaying(self.Loop) or not self:IsAnyAnimationPlaying() then
    self:StopAnimation(self.Loop)
    self:RollDamage()
  end
end

function UMG_Battle_Popup_General_C:RollDamage()
  if self.CurPerformNumber < self.Popup.CurDamageNumber then
    self.Popup.content = self.CurPerformDamage[self.CurPerformNumber]
    self.Content:SetContent(self.Popup)
    self.CurPerformNumber = self.CurPerformNumber + 1
    self.Popup.content = self.CurPerformDamage[self.CurPerformNumber]
    self.Content_1:SetContent(self.Popup)
    self:PlayAnimation(self.Loop_roll)
    if self.Popup:IsRestrainted() then
      self.FX:PlayAnimation(self.FX.HoldOut)
    end
  end
end

function UMG_Battle_Popup_General_C:OnAnimationFinished(Animation)
  if Animation == self.Open_Crit or Animation == self.Open_HoldOut or Animation == self.Open_Restraint then
    self.Content_1:SetRenderScale(UE4.FVector2D(1, 1))
    self.Content:SetRenderScale(UE4.FVector2D(1, 1))
    if self.CurPerformNumber >= self.Popup.TotalDamageNumber then
      self.DelayCloseId = _G.DelayManager:DelaySeconds(0.6, self.PlayCloseAni, self)
    else
      self:RollDamage()
    end
  elseif Animation == self.Loop_roll then
    if self.CurPerformNumber >= self.Popup.TotalDamageNumber then
      self.Content:SetContent(self.Popup)
      self:PlayAnimation(self.Close_Total)
    else
      self:RollDamage()
    end
  elseif (Animation == self.Close or Animation == self.Open_Other or Animation == self.Close_Total) and self.CurPerformNumber >= self.Popup.TotalDamageNumber then
    if self.PopupData then
      self:PlayAnimation(self.ResetAnim)
      self.PopupData:RecycleUMG(self)
    else
      self:RemoveFromParent()
    end
  end
end

function UMG_Battle_Popup_General_C:PlayCloseAni()
  self:PlayAnimation(self.Close)
end

function UMG_Battle_Popup_General_C:SetPreFix()
  if self.Popup:IsRestraint() then
    self.Prefix:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Prefix_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Prefix:SetText(LuaText.umg_battle_popup_general_1)
    self.Prefix_1:SetText(LuaText.umg_battle_popup_general_1)
  elseif self.Popup:IsRestrainted() then
    self.Prefix:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Prefix_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Prefix:SetText(LuaText.umg_battle_popup_general_2)
    self.Prefix_1:SetText(LuaText.umg_battle_popup_general_2)
  else
    self.Prefix:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Prefix_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Popup_General_C:SetCallBack(Caller, CallBack, PopupData)
  self.Caller = Caller
  self.CallBack = CallBack
  self.PopupData = PopupData
end

function UMG_Battle_Popup_General_C:Reset()
  if self.DelayCloseId then
    _G.DelayManager:CancelDelayById(self.DelayCloseId)
    self.DelayCloseId = nil
  end
  if self.Caller and self.CallBack then
    self.CallBack(self.Caller, self.PopupData)
  end
  self.Caller = nil
  self.CallBack = nil
  self.PopupData = nil
end

function UMG_Battle_Popup_General_C:OnDestruct()
  self:Reset()
end

return UMG_Battle_Popup_General_C
