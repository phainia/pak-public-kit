local MarkerUtils = require("NewRoco.Modules.Core.Marker.MarkerUtils")
local UMG_PointOfInterest_C = NRCViewBase:Extend("UMG_PointOfInterest_C")
local Alignment = UE4.FVector2D(0.5, 0)

function UMG_PointOfInterest_C:GetPosition()
  return self.Tracker:GetPosition()
end

function UMG_PointOfInterest_C:GetSourceType()
  return self.Tracker.Source
end

function UMG_PointOfInterest_C:CheckValid()
  if self.Tracker then
    return self.Tracker.Valid
  end
  return false
end

function UMG_PointOfInterest_C:SetTracker(item)
  self.Tracker = item
  self.Slot:SetAlignment(Alignment)
  MarkerUtils.SetupPoiIcon(item.PointKlass, self.Icon)
end

function UMG_PointOfInterest_C:ToggleArrow(show, dist)
  if show then
    self.Arrow:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Distance:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Arrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Distance:SetVisibility(UE4.ESlateVisibility.Visible)
    if nil ~= dist then
      dist = dist / 100
      self.Distance:SetText(string.format("%dm", math.round(dist)))
    end
  end
end

function UMG_PointOfInterest_C:UpdateArrow(theta)
  self:ToggleArrow(true)
  self.Arrow:SetRenderTransformAngle(math.deg(theta) + 90)
end

function UMG_PointOfInterest_C:SetPosition(position)
  self.Slot:SetPosition(position)
end

function UMG_PointOfInterest_C:UpdateAnimation()
  if self.Tracker.Shine then
    if self.Icon_Tips then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1042, "UMG_PointOfInterest_C:UpdateAnimation")
      self:PlayAnimation(self.Icon_Tips)
    end
    self.Tracker.Shine = false
  end
end

function UMG_PointOfInterest_C:Destruct()
  self.Icon:ReleaseForce()
end

return UMG_PointOfInterest_C
