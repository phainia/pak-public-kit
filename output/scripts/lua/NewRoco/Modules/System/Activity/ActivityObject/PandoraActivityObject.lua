local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local PandoraActivityObject = Base:Extend("PandoraActivityObject")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function PandoraActivityObject:OnConstruct(_conf, _briefInfo)
  assert(nil ~= _briefInfo, "Pandora activity briefInfo is nil")
  self.activityConf = {
    activity_type = ActivityEnum.ActivityTypeSpecial.PandoraActivity,
    id = _briefInfo.activityId,
    activity_name = _briefInfo.activityName,
    maintab_id = _briefInfo.maintabId,
    priority = _briefInfo.priority,
    icon = _briefInfo.icon,
    icon_select = _briefInfo.iconSelect,
    if_appear = true
  }
end

function PandoraActivityObject:LoadViewClass(caller, callbackLoaded)
  return true
end

return PandoraActivityObject
