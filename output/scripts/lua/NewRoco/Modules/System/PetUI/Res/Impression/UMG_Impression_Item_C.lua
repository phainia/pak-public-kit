local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Impression_Item_C = _G.NRCViewBase:Extend("UMG_Impression_Item_C")

function UMG_Impression_Item_C:OnActive()
end

function UMG_Impression_Item_C:RegisterGroupButton(index)
  self.isButton = true
  self.index = index
  self.isSelect = false
  _G.NRCModuleManager:GetModule("PetUIModule"):RegisterEvent(self, PetUIModuleEvent.ImpressionChangeSelect, self.OnSelectChange)
end

function UMG_Impression_Item_C:SetInfo(data)
  self.data = data
  self.curLevel = self.data.level
  self.Icon_Unlocked:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("C4C2B6FF"))
  self.Icon_fang:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("C4C2B6FF"))
  if self.data.conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_NONE then
    self.Not_UnlockedIcon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_sheng:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_sheng_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self.data.conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_POSITIVE then
    self.Not_UnlockedIcon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self.data.conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_NEGATIVE then
    self.Not_UnlockedIcon_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Icon_sheng:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_sheng_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_Unlocked:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FBC664FF"))
  end
  if self.curLevel < self.data.conf.group_number then
    self:LockItem()
  else
    self:UnLockItem()
  end
  self:SetRedPoint(self.data.gid, self.data.conf.group_id, self.data.conf.group_number)
end

function UMG_Impression_Item_C:OnLevelUp()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.ZoneUnlockPetHabitReq, self.data.conf.group_id, self.data.conf.group_number)
end

function UMG_Impression_Item_C:SetRedPoint(petId, group_id, level)
  self.NrcRedPoint:SetupKey(151, {
    petId,
    group_id,
    level - 1
  })
end

function UMG_Impression_Item_C:SelectItem()
  self.isSelect = true
  _G.NRCAudioManager:PlaySound2DAuto(40002021, "UMG_PetLeftPanelMenuButton_C:OnTouchEnded")
  self.UMG_Impression_Select:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.Select_In)
end

function UMG_Impression_Item_C:UnSelectItem()
  self.isSelect = false
  self:PlayAnimation(self.Select_Out)
end

function UMG_Impression_Item_C:LockItem()
  self.Not_Unlocked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Default:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Icon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Icon_Unlocked:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("C4C2B6FF"))
  self.Not_UnlockedIcon_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("C4C2B6FF"))
  self.Icon_fang:SetPath(self.data.conf.habit_locked_icon_path)
  self.Icon_fang:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Icon_Unlocked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_NEGATIVE then
    self.Icon_fang:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("292D2EFF"))
    self:SetIconScale(UE4.FVector2D(0.455, 0.455))
  else
    self:SetIconScale(UE4.FVector2D(0.65, 0.65))
  end
  if self.data.conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_POSITIVE then
    self.Icon_sheng:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_sheng_1:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Impression_Item_C:UnLockItem()
  self.Not_Unlocked:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Default:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Icon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Icon_Unlocked:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("652800FF"))
  self.Not_UnlockedIcon_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("652800FF"))
  self.Icon_Unlocked:SetPath(self.data.conf.habit_icon_path)
  self.Icon_Unlocked:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Icon_fang:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_NEGATIVE then
    self.Icon_Unlocked:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FAC563FF"))
    self:SetIconScale(UE4.FVector2D(0.455, 0.455))
  else
    self:SetIconScale(UE4.FVector2D(0.65, 0.65))
  end
  if self.data.conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_POSITIVE then
    self.Icon_sheng:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Icon_sheng_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Impression_Item_C:DefaultItem()
  self.UMG_Impression_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Impression_Item_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_Impression_Item_C:OnAddEventListener()
  self:AddButtonListener(self.ItemButton, self.ClickItemButton)
end

function UMG_Impression_Item_C:OnSelectChange(index)
  if index == self.index then
    if self.isSelect ~= true then
      self:SelectItem()
    end
  elseif self.isSelect ~= false then
    self:UnSelectItem()
  end
end

function UMG_Impression_Item_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Impression_Item_C:OnDestruct()
  if self.isButton then
    _G.NRCModuleManager:GetModule("PetUIModule"):UnRegisterEvent(self, PetUIModuleEvent.ImpressionChangeSelect, self.OnSelectChange)
  end
end

function UMG_Impression_Item_C:OnAnimationFinished(anim)
  if anim == self.Light then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.ZoneUnlockPetHabitReq, self.data.conf.group_id, self.data.conf.group_number)
  end
end

function UMG_Impression_Item_C:ClickItemButton()
  if self.isButton then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetCurSelectImpressionIndex, self.index, self.data)
  end
end

return UMG_Impression_Item_C
