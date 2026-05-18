local DesiredSizeX = 32.0
local UMG_BlackBar_C = _G.NRCPanelBase:Extend("UMG_BlackBar_C")

function UMG_BlackBar_C:OnActive()
  self.TargetRatio = 2.15
end

function UMG_BlackBar_C:OnDeactive()
end

function UMG_BlackBar_C:OnAddEventListener()
end

function UMG_BlackBar_C:Tick(MyGeometry, InDeltaTime)
  self:UpdateScreenSize(UE4.USlateBlueprintLibrary.GetLocalSize(MyGeometry))
end

function UMG_BlackBar_C:OnLogin()
end

function UMG_BlackBar_C:OnConstruct()
end

function UMG_BlackBar_C:OnDestruct()
end

function UMG_BlackBar_C:OnAnimationFinished(anim)
end

function UMG_BlackBar_C:UpdateScreenSize(InScreenSize)
  if self.ScreenSizeRecord == nil then
    self.ScreenSizeRecord = _G.ProtoMessage:newPosition2D()
  end
  if self.ScreenSizeRecord.x ~= InScreenSize.X or self.ScreenSizeRecord.y ~= InScreenSize.Y then
    self.ScreenSizeRecord.x = InScreenSize.X
    self.ScreenSizeRecord.y = InScreenSize.Y
    self:UpdateWidgetSize(self.ScreenSizeRecord.x, self.ScreenSizeRecord.y)
  end
end

function UMG_BlackBar_C:UpdateWidgetSize(sizeX, sizeY)
  local xToRatio = sizeX / self.TargetRatio
  local alignHeight = (sizeY - xToRatio) / 2.0
  if alignHeight < 0 then
    alignHeight = 0
  end
  self.Top:SetBrushSize(UE4.FVector2D(DesiredSizeX, alignHeight))
  self.bottom:SetBrushSize(UE4.FVector2D(DesiredSizeX, alignHeight))
end

return UMG_BlackBar_C
