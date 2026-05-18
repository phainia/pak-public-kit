local UMG_PC_Mouse_C = _G.NRCPanelBase:Extend("UMG_PC_Mouse_C")

function UMG_PC_Mouse_C:OnConstruct()
  if UE4Helper.IsPCMode() then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PC_Mouse_C:OnDestruct()
end

function UMG_PC_Mouse_C:OnActive()
end

function UMG_PC_Mouse_C:OnDeactive()
end

function UMG_PC_Mouse_C:OnAddEventListener()
end

return UMG_PC_Mouse_C
