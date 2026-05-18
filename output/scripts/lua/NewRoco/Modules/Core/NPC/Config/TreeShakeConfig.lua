local config = {}

local function shakeFunc(x0, p, w, phase, time, timeSpeed)
  local t = time * timeSpeed
  return x0 * math.exp(-p * t) * math.cos(t * math.sqrt(w * w - p * p) + phase)
end

config.TreeShake = {
  x0 = 0.006,
  p = 0.6,
  w = 4,
  timeSpeed = 4.8,
  start_height = -200,
  x02 = 0.004,
  p2 = 0.1,
  w2 = 1,
  timeSpeed2 = 15,
  start_height2 = -100,
  func = shakeFunc
}
config.FruitWind = {
  x0 = 0.02,
  p = 0,
  w = 1,
  timeSpeed = 10,
  func = shakeFunc
}
config.FruitShake = {
  x0 = 0.03,
  p = 0.1,
  w = 1,
  timeSpeed = 30,
  func = shakeFunc
}
return config
