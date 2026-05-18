local UMG_Compass_Part_C = _G.NRCPanelBase:Extend("UMG_Compass_Part_C")
local math_abs = math.abs

function UMG_Compass_Part_C:OnDestruct()
  self.AngleConvertString = nil
end

function UMG_Compass_Part_C:InitUI(Angle, Space, DesText)
  self.AngleLength = 90
  self.StartAngle = Angle
  self.SpacePerAngle = Space
  self.CompassText:SetText(DesText)
  local Offsets = self.LeftLine.Slot:GetSize()
  Offsets.X = self.AngleLength * self.SpacePerAngle / 2
  self.LeftLine.Slot:SetSize(Offsets)
  Offsets.X = self.AngleLength * self.SpacePerAngle / 2
  self.RightLine.Slot:SetSize(Offsets)
  local Position = self.LeftThin.Slot:GetPosition()
  Position.X = -1 * (self.AngleLength * self.SpacePerAngle) / 2
  self.LeftThin.Slot:SetPosition(Position)
end

local SetPosByCameraTempVector2D = UE4.FVector2D()

function UMG_Compass_Part_C:SetPosByCamera(CameraDir)
  local gap = self.StartAngle - CameraDir
  if math_abs(gap) > 180 then
    if gap > 0 then
      gap = gap - 360
    else
      gap = 360 + gap
    end
  end
  SetPosByCameraTempVector2D:Set(gap * self.SpacePerAngle, 50)
  if self.Slot and UE4.UObject.IsValid(self.Slot) then
    self.Slot:SetPosition(SetPosByCameraTempVector2D)
  end
end

return UMG_Compass_Part_C
