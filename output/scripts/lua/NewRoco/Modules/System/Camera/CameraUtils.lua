local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")
local CameraUtils = {}
CameraUtils.Debug = false

function CameraUtils.IsMainTargetAtLeft(CameraLocation, MainTargetLocation, SubTargetLocation)
  local CameraToMain = MainTargetLocation - CameraLocation
  local CameraToSub = SubTargetLocation - CameraLocation
  CameraToMain.Z = 0
  CameraToSub.Z = 0
  local bMainIsAtLeft = false
  local CrossedVector = CameraToMain:Cross(CameraToSub)
  if CrossedVector.Z > 0 then
    bMainIsAtLeft = false
  else
    bMainIsAtLeft = true
  end
  return bMainIsAtLeft
end

function CameraUtils.GetXYPlaneCircle(A, B, theta)
  local AonXY = UE4.FVector2D(A.X, A.Y)
  local BonXY = UE4.FVector2D(B.X, B.Y)
  local offset = AonXY - BonXY
  local D = math.sqrt(offset:Dot(offset))
  local midPoint = (AonXY + BonXY) / 2
  local othoDirection = (A - B):Cross(UE4.FVector(0, 0, 1))
  othoDirection:Normalize()
  local Norm = UE4.FVector2D(othoDirection.X, othoDirection.Y)
  local R = D / 2 / math.sin(theta)
  local CircleCenter = midPoint + Norm * R * math.cos(theta)
  return CircleCenter, R
end

function CameraUtils.GetTriangleArea(A, B, C)
  local AB = B - A
  local AC = C - A
  local ABl = math.sqrt(AB:Dot(AB))
  local ACl = math.sqrt(AC:Dot(AC))
  local AngleBAC = math.abs(math.asin(AB:Dot(AC) / (ABl * ACl)))
  return ABl * ACl * math.cos(AngleBAC) / 2
end

function CameraUtils.DrawDebugLine(p1, p2)
  UE4.UKismetSystemLibrary.Abs_DrawDebugLine(UE4Helper.GetCurrentWorld(), p1, p2, UE4.FLinearColor(0.5, 0.5, 0, 1), 25, 5)
end

function CameraUtils.DrawDebugBall(Center, Color, Size)
  UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), Center, 80, 20, Color or UE4.FLinearColor(0.0, 1.0, 0.0, 1), 25, 2)
end

return CameraUtils
