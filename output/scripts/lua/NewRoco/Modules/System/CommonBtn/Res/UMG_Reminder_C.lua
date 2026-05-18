local UMG_Reminder_C = _G.NRCPanelBase:Extend("UMG_Reminder_C")

function UMG_Reminder_C:OnActive()
  self:OnAddEventListener()
end

function UMG_Reminder_C:OnDeactive()
end

function UMG_Reminder_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Reminder_C:OnDestruct()
end

function UMG_Reminder_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_Btn.btnLevelUp, self.OnClickHandler)
end

function UMG_Reminder_C:SetSwitcherType(index, text)
  self.Switcher:SetActiveWidgetIndex(index)
  if text then
    if 0 == index then
      self.Title_1:SetText(text)
    elseif 1 == index then
      self.Title:SetText(text)
    elseif 2 == index then
      self.Title_2:SetText(text)
    end
  end
end

function UMG_Reminder_C:SetClickCallback(_caller, _callback)
  self.callback = _G.MakeWeakFunctor(_caller, _callback)
end

function UMG_Reminder_C:OnClickHandler()
  if self.callback then
    self.callback()
  end
end

return UMG_Reminder_C
