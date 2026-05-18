local FVector2DUtils = Class()

function FVector2DUtils.Angle(Vector)
  return math.deg(math.atan(Vector.Y, Vector.X))
end

function FVector2DUtils.AngleBetweenRelative(VectorA, VectorB)
  local angleFrom = FVector2DUtils.Angle(VectorA)
  local angleTo = FVector2DUtils.Angle(VectorB)
  local delta = angleTo - angleFrom
  if delta < -180 then
    delta = delta + 360
  elseif delta > 180 then
    delta = delta - 360
  end
  return delta
end

function FVector2DUtils.AngleBetween(VectorA, VectorB)
  local angleFrom = FVector2DUtils.Angle(VectorA)
  local angleTo = FVector2DUtils.Angle(VectorB)
  return angleTo - angleFrom
end

function FVector2DUtils.Lerp(fromPos, toPos, percent)
  percent = math.clamp(percent, 0, 1)
  local pos = UE4.FVector2D()
  pos.X = fromPos.X * (1 - percent) + toPos.X * percent
  pos.Y = fromPos.Y * (1 - percent) + toPos.Y * percent
  return pos
end

function FVector2DUtils.InterpConstantTo(start, target, deltaTime, interpSpeed)
  local delta = target - start
  local deltaMag = delta:Size()
  local maxStep = interpSpeed * deltaTime
  if deltaMag > maxStep then
    if maxStep > 0 then
      local deltaNormal = delta / deltaMag
      return start + deltaNormal * maxStep
    else
      return start
    end
  end
  return target
end

local math_cos = math.cos
local math_sin = math.sin
local math_sqrt = math.sqrt

function FVector2DUtils.GetEllipse(axis, theta)
  local cosT = math_cos(theta)
  local cosS = cosT * cosT
  local sinT = math_sin(theta)
  local sinS = sinT * sinT
  local k = axis.X * axis.Y / math_sqrt(axis.Y * axis.Y * cosS + axis.X * axis.X * sinS)
  return UE4.FVector2D(k * cosT, k * sinT)
end

function FVector2DUtils.GetEllipseInplace(axis, theta, out)
  local cosT = math_cos(theta)
  local cosS = cosT * cosT
  local sinT = math_sin(theta)
  local sinS = sinT * sinT
  local k = axis.X * axis.Y / math_sqrt(axis.Y * axis.Y * cosS + axis.X * axis.X * sinS)
  out:Set(k * cosT, k * sinT)
end

return FVector2DUtils
