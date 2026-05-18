local VitalityUtil = NRCClass()
VitalityUtil.VitalityCostType = {Once = 1, Duration = 2}
VitalityUtil.VitalityState = {
  Normal = 1,
  Costing = 2,
  Recovering = 3,
  Forbidden = 4
}
return VitalityUtil
