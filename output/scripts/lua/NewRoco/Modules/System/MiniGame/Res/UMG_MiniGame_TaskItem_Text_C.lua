local UMG_MiniGame_TaskItem_Text_C = _G.NRCPanelBase:Extend("UMG_MiniGame_TaskItem_Text_C")

function UMG_MiniGame_TaskItem_Text_C:SetData(Progress, Max, GuideText)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  if GuideText and self.Process_Guide then
    local text = GuideText .. "(" .. tostring(math.max(Progress.value or 0, 0)) .. "/" .. tostring(math.max(Max or 0, 0)) .. ")"
    self.Process_Guide:SetText(text)
  end
end

return UMG_MiniGame_TaskItem_Text_C
