local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local UnknownActivityObject = Base:Extend("UnknownActivityObject")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UnknownActivityObject:OnConstruct(_conf, _briefInfo)
  self.activityConf = {
    activity_type = ActivityEnum.ActivityTypeSpecial.UnknownActivity,
    id = _briefInfo.activity_id,
    activity_name = _briefInfo.activity_name,
    maintab_id = _briefInfo.maintab_id,
    priority = _briefInfo.priority,
    umg_path = "WidgetBlueprint'/Game/NewRoco/Modules/System/Activity/Res/UMG_Activity_404NotFound.UMG_Activity_404NotFound_C'",
    icon = nil,
    icon_select = nil
  }
end

return UnknownActivityObject
