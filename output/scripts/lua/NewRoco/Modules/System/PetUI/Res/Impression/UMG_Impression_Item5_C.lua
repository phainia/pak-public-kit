local UMG_Impression_Item5_C = _G.NRCPanelBase:Extend("UMG_Impression_Item5_C")

function UMG_Impression_Item5_C:OnActive()
end

function UMG_Impression_Item5_C:OnConstruct()
  self.Defaults = {
    self.Default_5,
    self.Default_6,
    self.Default_3,
    self.Default
  }
  self.Locks = {
    self.Not_Unlocked_2,
    self.Not_Unlocked_3,
    self.Not_Unlocked_1,
    self.Not_Unlocked
  }
end

function UMG_Impression_Item5_C:SetInfo(data, isLock)
  self.data = data
  self.curLevel = self.data.level
  local conf = _G.DataConfigManager:GetPetHabitConf(self.data.conf.id)
  local iconPath = conf.habit_icon_path
  self.Icon:SetPath(iconPath)
  self.Icon_1:SetPath(iconPath)
  self.Icon_2:SetPath(iconPath)
  self.Icon_3:SetPath(iconPath)
  self.Switcher:SetActiveWidgetIndex(self.data.conf.group_number - 1)
  self:OnLock(self.data.conf.group_number - 1, isLock)
end

function UMG_Impression_Item5_C:OnLock(index, isLock)
  for i = 1, 4 do
    if i == index + 1 then
      if isLock then
        self.Defaults[i]:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Locks[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.Locks[i]:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Defaults[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_Impression_Item5_C:OnDeactive()
end

function UMG_Impression_Item5_C:OnAddEventListener()
end

return UMG_Impression_Item5_C
