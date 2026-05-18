local UMG_Handbook_HabitReminder_C = _G.NRCPanelBase:Extend("UMG_Handbook_HabitReminder_C")

function UMG_Handbook_HabitReminder_C:OnActive(parms)
  if not parms then
    self:DoClose()
    return
  end
  self.pet_base_id = parms.pet_base_id
  self.handBookId = parms.handBookId
  self.area_info = parms.area_info
  self:UpdateUI()
  self:PlayAnimation(self.In)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1365, "UMG_Handbook_HabitReminder_C:OnActive")
end

function UMG_Handbook_HabitReminder_C:DoStartClosing()
  if not self:IsAnimationPlaying(self.Out) then
    self:PlayAnimation(self.Out)
  end
end

function UMG_Handbook_HabitReminder_C:OnDestruct()
end

function UMG_Handbook_HabitReminder_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    self:DoClose()
  end
end

function UMG_Handbook_HabitReminder_C:UpdateUI()
  local record = self.module.data:GetPetHandBookRecordData(self.handBookId, self.pet_base_id)
  self.Number:SetText(string.format(LuaText.umg_handbook_habitreminder_1, self.handBookId))
  self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCpetIcon3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if record.State == _G.ProtoEnum.PetHandbookStatus.PHS_NOT_FOUND then
    self.Name:SetText("?????")
    self.QuestionMark:SetPath(NRCUtils:FormatConfIconPath(record.HandbookPetIcon.ui_icon, _G.UIIconPath.UIHeadIconPath))
    self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Visible)
    self.QuestionMark:SetBrushTintColor(UE4.UNRCStatics.HexToSlateColor("#000000"))
    self.QuestionMark:SetOpacity(0.4)
  else
    if record.State == _G.ProtoEnum.PetHandbookStatus.PHS_FOUND then
      self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCpetIcon3:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCpetIcon:SetPath(NRCUtils:FormatConfIconPath(record.HandbookPetIcon.ui_icon, _G.UIIconPath.UIHeadIconPath))
      self.NRCpetIcon3:SetPath(NRCUtils:FormatConfIconPath(record.HandbookPetIcon.ui_icon, _G.UIIconPath.UIHeadIconPath))
    elseif record.State == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
      self.NRCpetIcon3:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCpetIcon3:SetPath(NRCUtils:FormatConfIconPath(record.HandbookPetIcon.ui_icon, _G.UIIconPath.UIHeadIconPath))
    end
    self.Name:SetText(record.PetBaseConf.name)
  end
  self.Switcher:SetActiveWidgetIndex(record.State - 1)
  local habitListData = {}
  if self.area_info and self.area_info.habitat_areas and #self.area_info.habitat_areas > 0 then
    for i = 1, 3 do
      table.insert(habitListData, record.PetBaseConf["habit_" .. i])
    end
  else
    table.insert(habitListData, LuaText.umg_handbook_habitreminder_2)
  end
  self.HabitList:InitGridView(habitListData)
end

return UMG_Handbook_HabitReminder_C
