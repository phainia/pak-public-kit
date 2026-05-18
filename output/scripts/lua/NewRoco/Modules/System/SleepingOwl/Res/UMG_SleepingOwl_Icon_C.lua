local UMG_SleepingOwl_Icon_C = _G.NRCPanelBase:Extend("UMG_SleepingOwl_Icon_C")

function UMG_SleepingOwl_Icon_C:Construct()
  self.CanClick = false
  self.NeedAudio = true
end

function UMG_SleepingOwl_Icon_C:Destruct()
end

function UMG_SleepingOwl_Icon_C:Init(UnLock, ItemData, index)
  self.data = ItemData
  self.index = index
  local isNilFruit = true
  if self.data then
    self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Icon:SetPath(NRCUtils:FormatConfIconPath(_G.DataConfigManager:GetBagItemConf(self.data.BagItemId).icon, _G.UIIconPath.BagItemPath))
    isNilFruit = false
  else
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if UnLock then
    self.UnLock = true
    if not isNilFruit then
      self.Switcher:SetActiveWidgetIndex(2)
    end
    self.Unlocked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Add:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UnLock = false
    self.Switcher:SetActiveWidgetIndex(1)
    self.Unlocked:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_SleepingOwl_Icon_C:OnUpdateIconTimer()
  if self.index == nil then
    return
  end
  local slotTimer = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdGetEmptyTimer, self.index + 1)
  local fruitTimer = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdGetFruitTimer, self.index + 1)
  if slotTimer > 0 or fruitTimer > 0 then
    self.CDPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CDPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_SleepingOwl_Icon_C:ShowUnlockSlot()
end

function UMG_SleepingOwl_Icon_C:AsRewardItem()
  self.UnLock = false
  self.Unlocked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Add:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_SleepingOwl_Icon_C:OnAddEventListener()
end

function UMG_SleepingOwl_Icon_C:SetCancelSelect()
  self.IsSelect = false
  self:PlayAnimation(self.UnSelect_Icon)
end

function UMG_SleepingOwl_Icon_C:OnTouchEnded(MyGeometry, InTouchEvent)
  if self.CanClick then
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_SleepingOwl_Icon_C:OnTouchEnded")
    if self.UnLock then
      if self:IsAnimationPlaying(self.UnSelect_Icon) then
        return UE.UWidgetBlueprintLibrary.Unhandled()
      end
      if self:IsAnimationPlaying(self.Select_Icon) then
        return UE.UWidgetBlueprintLibrary.Unhandled()
      end
      _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OpenSleepingOwlFruitPanel, self.data, self.index)
      if self.IsSelect then
        return UE.UWidgetBlueprintLibrary.Unhandled()
      end
      if self.NeedAudio then
      else
        self.NeedAudio = true
      end
      self.IsSelect = true
      self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAnimation(self.Select_Icon)
    end
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_SleepingOwl_Icon_C:OnAnimationFinished(Anim)
  if Anim == self.UnSelect_Icon then
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Select:StopAllAnimations()
  end
  if Anim == self.Select_Icon then
    self.Select:PlayAnimation(self.Select.Loop_IconSelect, 0, 99999)
  end
end

return UMG_SleepingOwl_Icon_C
