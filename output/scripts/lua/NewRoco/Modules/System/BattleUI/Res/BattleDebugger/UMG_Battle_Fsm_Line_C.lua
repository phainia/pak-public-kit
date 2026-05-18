local UMG_Battle_Fsm_Line_C = _G.NRCPanelBase:Extend("UMG_Battle_Fsm_Line_C")

function UMG_Battle_Fsm_Line_C:OnActive()
end

function UMG_Battle_Fsm_Line_C:OnConstruct()
  self.IsActivated = false
end

function UMG_Battle_Fsm_Line_C:OnDeactive()
end

function UMG_Battle_Fsm_Line_C:OnAddEventListener()
end

function UMG_Battle_Fsm_Line_C:SetSize(size)
  local Size = UE4.FVector2D(size, self.Line.Slot:GetSize().Y)
  self.Line.Slot:SetSize(Size)
end

function UMG_Battle_Fsm_Line_C:GetAbsoluteSize()
  local AbsoluteSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(self:GetCachedGeometry())
  return AbsoluteSize
end

function UMG_Battle_Fsm_Line_C:IsShowCable(IsShowLine)
  if IsShowLine then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Fsm_Line_C:SetColour()
  self.IsActivated = true
  self.Line:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FF0000FF"))
  local Size = self.Line.Slot:GetSize()
  Size.Y = 6
  self.Line.Slot:SetSize(Size)
end

function UMG_Battle_Fsm_Line_C:GetIsActivated()
  return self.IsActivated
end

return UMG_Battle_Fsm_Line_C
