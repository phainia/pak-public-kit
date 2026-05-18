local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local VitalityCostRegistry = {}
VitalityCostRegistry[ProtoEnum.WorldPlayerStatusType.WPST_DASHING] = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.DashVitalityCost")
VitalityCostRegistry[ProtoEnum.WorldPlayerStatusType.WPST_CLIMB] = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.ClimbVitalityCost")
VitalityCostRegistry[ProtoEnum.WorldPlayerStatusType.WPST_GANZHI] = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.PerceptionVitalityCost")
VitalityCostRegistry[ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING] = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.SwimVitalityCost")
VitalityCostRegistry[ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY] = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.RideAllSkillVitalityCost")
VitalityCostRegistry[ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL] = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.RideAllVitalityCost")
VitalityCostRegistry[ProtoEnum.WorldPlayerStatusType.WPST_MAGIC] = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.MagicVitalityCost")
return VitalityCostRegistry
