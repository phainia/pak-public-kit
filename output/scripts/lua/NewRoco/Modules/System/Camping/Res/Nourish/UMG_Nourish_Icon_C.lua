local UMG_Nourish_Icon_C = _G.NRCPanelBase:Extend("UMG_Nourish_Icon_C")

function UMG_Nourish_Icon_C:Construct()
  Log.Error("\230\158\175\230\158\157\230\187\139\229\133\187\231\155\184\229\133\179\229\138\159\232\131\189\232\162\171\229\185\178\230\142\137\228\186\134\239\188\140\233\135\141\230\150\176\229\144\175\231\148\168\232\175\183\233\135\141\230\150\176\230\143\144\233\156\128\230\177\130\229\129\154")
  self.CanClick = false
end

function UMG_Nourish_Icon_C:Destruct()
end

function UMG_Nourish_Icon_C:Init(UnLock, ItemData, index)
  self.data = ItemData
  self.index = index
  if self.data then
    self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Icon:SetPath(NRCUtils:FormatConfIconPath(_G.DataConfigManager:GetBagItemConf(self.data.BagItemId).icon, _G.UIIconPath.BagItemPath))
  else
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if UnLock then
    self.UnLock = true
    self.Unlocked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Add:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UnLock = false
    self.Unlocked:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Nourish_Icon_C:AsRewardItem()
  self.UnLock = false
  self.Unlocked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Add:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Nourish_Icon_C:OnAddEventListener()
end

function UMG_Nourish_Icon_C:SetCancelSelect()
  self.IsSelect = false
  self:PlayAnimation(self.UnSelect_Icon)
end

function UMG_Nourish_Icon_C:OnTouchEnded()
  if self.CanClick and self.UnLock then
    if self:IsAnimationPlaying(self.UnSelect_Icon) then
      return
    end
    if self:IsAnimationPlaying(self.Select_Icon) then
      return
    end
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.OpenNourishRightFruitPanel, self.data, self.index)
    if self.IsSelect then
      return
    end
    self.IsSelect = true
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Select_Icon)
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Nourish_Icon_C:OnAnimationFinished(Anim)
  if Anim == self.UnSelect_Icon then
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Select:StopAllAnimations()
  end
  if Anim == self.Select_Icon then
    self.Select:PlayAnimation(self.Select.Loop_IconSelect, 0, 99999)
  end
end

return UMG_Nourish_Icon_C
