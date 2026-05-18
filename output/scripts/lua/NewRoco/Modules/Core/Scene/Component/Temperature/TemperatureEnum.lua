local TemperatureEnum = {}
TemperatureEnum.BodyState = {
  INIT = 0,
  NORMAL = 1,
  HOT = 2,
  COLD = 3
}
TemperatureEnum.HPItemState = {
  NORMAL = 1,
  HOT = 2,
  HOT_LOOP = 3,
  HOT_BROKEN = 6,
  COLD = 4,
  COLD_LOOP = 5,
  COLD_BROKEN = 7,
  HEALTH = 8,
  TEMPORAL = 9
}
TemperatureEnum.BT = {MIN = -10000, MAX = 10000}
return TemperatureEnum
