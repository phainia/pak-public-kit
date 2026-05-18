local LuaMathUtils = {}

function LuaMathUtils.LerpWithMin(Origin, Target, Min, Alpha)
  if Origin < Target then
    local ret = Origin + math.max(Target - Origin, Min) * Alpha
    ret = math.min(ret, Target)
    return ret
  else
    local ret = Origin + math.min(Target - Origin, -Min) * Alpha
    ret = math.max(ret, Target)
    return ret
  end
end

function LuaMathUtils.LerpWithLength(Origin, Target, Length)
  if Origin < Target then
    local ret = Origin + Length
    ret = math.min(ret, Target)
    return ret
  else
    local ret = Origin - Length
    ret = math.max(ret, Target)
    return ret
  end
end

function LuaMathUtils.LerpWithAlpha(Origin, Target, Alpha)
  local Distance = Target - Origin
  if Alpha > 1 then
    Alpha = 1
  end
  if Alpha < 0 then
    Alpha = 0
  end
  return Origin + Distance * Alpha
end

function LuaMathUtils.ExpLerp(cur, tar, deltaTime, lerpSpeed)
  return LuaMathUtils.LerpWithAlpha(cur, tar, 1 - LuaMathUtils.FastNegExp(0.69314718056 * deltaTime * lerpSpeed))
end

function LuaMathUtils.CriticalSpringDamper(tar, velocity, cur, deltaTime, speed, mass)
  mass = mass or 2
  local y = LuaMathUtils.SpeedToDamping(speed, mass)
  local j0 = cur - tar
  local j1 = velocity + j0 * y
  local eydt = LuaMathUtils.FastNegExp(y * deltaTime)
  cur = tar + (j0 + j1 * deltaTime) * eydt
  velocity = (velocity - j1 * y * deltaTime) * eydt
  return cur, velocity
end

function LuaMathUtils.FastNegExp(num)
  return 1 / (1 + num + 0.48 * num * num + 0.235 * num * num * num)
end

function LuaMathUtils.SpeedToDamping(speed, mass)
  return 2.77258872224 * speed / mass
end

function LuaMathUtils.LerpVector(Origin, Target, Alpha)
  Alpha = math.clamp(Alpha, 0, 1)
  return Target * Alpha + Origin * (1 - Alpha)
end

function LuaMathUtils.ClampAngle(Angle)
  Angle = math.fmod(Angle or 0, 360)
  if Angle < 0 then
    Angle = Angle + 360
  end
  return Angle
end

function LuaMathUtils.DiffAngle(Target, Source)
  Target = LuaMathUtils.ClampAngle(Target)
  Source = LuaMathUtils.ClampAngle(Source)
  local Delta = Target - Source
  if Delta > 180 then
    Delta = Delta - 360
  elseif Delta < -180 then
    Delta = Delta + 360
  end
  return Target, Source, Delta
end

function LuaMathUtils.Linear(s)
  return s
end

function LuaMathUtils.Quad(s)
  return s * s
end

function LuaMathUtils.Cubic(s)
  return s * s * s
end

function LuaMathUtils.Quart(s)
  return s * s * s * s
end

function LuaMathUtils.Quint(s)
  return s * s * s * s * s
end

function LuaMathUtils.Sine(s)
  return 1 - math.cos(s * math.pi / 2)
end

function LuaMathUtils.Expo(s)
  return 2 ^ (10 * (s - 1))
end

function LuaMathUtils.Circ(s)
  return 1 - math.sqrt(1 - s * s)
end

function LuaMathUtils.Back(s, bounciness)
  bounciness = bounciness or 1.70158
  return s * s * ((bounciness + 1) * s - bounciness)
end

function LuaMathUtils.Bounce(s)
  local a, b = 7.5625, 0.36363636363636365
  return math.min(a * s ^ 2, a * (s - 1.5 * b) ^ 2 + 0.75, a * (s - 2.25 * b) ^ 2 + 0.9375, a * (s - 2.625 * b) ^ 2 + 0.984375)
end

function LuaMathUtils.Elastic(s, amp, period)
  amp, period = amp and math.max(1, amp) or 1, period or 0.3
  return -amp * math.sin(2 * math.pi / period * (s - 1) - math.asin(1 / amp)) * 2 ^ (10 * (s - 1))
end

LuaMathUtils.Ease = {
  Linear = "Linear",
  Quad = "Quad",
  Cubic = "Cubic",
  Quart = "Quart",
  Quint = "Quint",
  Sine = "Sine",
  Expo = "Expo",
  Circ = "Circ",
  Back = "Back",
  Bounce = "Bounce",
  Elastic = "Elastic"
}

local function distance(p1, p2)
  return math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)
end

local function circle_from_2(p1, p2)
  local centerX = (p1.x + p2.x) / 2
  local centerY = (p1.y + p2.y) / 2
  local r = distance(p1, p2) / 2
  return {x = centerX, y = centerY}, r
end

local function get_circle_center(bx, by, cx, cy)
  local B = bx * bx + by * by
  local C = cx * cx + cy * cy
  local D = bx * cy - by * cx
  return {
    x = (cy * B - by * C) / (2 * D),
    y = (bx * C - cx * B) / (2 * D)
  }
end

local function circle_from_3(A, B, C)
  local I = get_circle_center(B.x - A.x, B.y - A.y, C.x - A.x, C.y - A.y)
  I.x = I.x + A.x
  I.y = I.y + A.y
  return I, distance(I, A)
end

local function is_inside(c, r, p)
  return r >= distance(c, p)
end

local function is_valid_circle(c, r, points)
  for i, p in ipairs(points) do
    if not is_inside(c, r, p) then
      return false
    end
  end
  return true
end

local function mini_circle_trivial(points)
  if not points or 0 == #points then
    return {x = 0, y = 0}, 0
  elseif 1 == #points then
    return points[1], 0
  elseif 2 == #points then
    return circle_from_2(points[1], points[2])
  end
  for i = 1, 3 do
    for j = i + 1, 3 do
      local c, r = circle_from_2(points[i], points[j])
      if is_valid_circle(c, r, points) then
        return c, r
      end
    end
  end
  return circle_from_3(points[1], points[2], points[3])
end

local welzl_helper = function(points, r_points, n)
  if 0 == n or 3 == #r_points then
    return mini_circle_trivial(r_points)
  end
  local idx = math.random(n)
  local p = points[idx]
  points[idx], points[n] = points[n], points[idx]
  local c, r = welzl_helper(points, {
    table.unpack(r_points)
  }, n - 1)
  if is_inside(c, r, p) then
    return c, r
  end
  table.insert(r_points, p)
  return welzl_helper(points, {
    table.unpack(r_points)
  }, n - 1)
end

local function welzl(points)
  math.randomseed(os.time())
  local shuffled = {}
  for i, v in ipairs(points) do
    shuffled[i] = v
  end
  for i = #shuffled, 2, -1 do
    local j = math.random(i)
    shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
  end
  local r_points = {}
  return welzl_helper(shuffled, r_points, #shuffled)
end

function LuaMathUtils.MiniEnclosingCircle(points)
  return welzl(points)
end

function LuaMathUtils.ConvVectorToPosition(vector)
  return {
    x = vector.X,
    y = vector.Y,
    z = vector.Z
  }
end

function LuaMathUtils.ConvPositionToVector(vector)
  return UE.FVector(vector.x, vector.y, vector.z)
end

function LuaMathUtils.AngleBetweenVectors(vector_1, vector_2)
  vector_1 = UE.UKismetMathLibrary.Normal(vector_1, 0.01)
  vector_2 = UE.UKismetMathLibrary.Normal(vector_2, 0.01)
  local innerCos = math.clamp(UE.UKismetMathLibrary.Dot_VectorVector(vector_1, vector_2), -1, 1)
  local degree = 0
  if innerCos < 1 then
    degree = math.deg(math.acos(innerCos))
  end
  return degree
end

function LuaMathUtils.Slerp(vec1, vec2, w)
  vec1 = UE.UKismetMathLibrary.Normal(vec1, 0.01)
  vec2 = UE.UKismetMathLibrary.Normal(vec2, 0.01)
  local innerAngle = math.rad(LuaMathUtils.AngleBetweenVectors(vec1, vec2))
  return vec1 * (math.sin((1 - w) * innerAngle) / math.sin(innerAngle)) + vec2 * (math.sin(w * innerAngle) / math.sin(innerAngle))
end

function LuaMathUtils.OneDecimalPlace(value)
  return (string.format("%.1f", value))
end

function LuaMathUtils.FInterpTo(Current, Target, DeltaTime, InterpSpeed)
  if InterpSpeed <= 0 then
    return Target
  end
  local Dist = Target - Current
  if Dist * Dist < 1.0E-6 then
    return Target
  end
  local DeltaMove = Dist * math.clamp(DeltaTime * InterpSpeed, 0, 1)
  return Current + DeltaMove
end

return LuaMathUtils
