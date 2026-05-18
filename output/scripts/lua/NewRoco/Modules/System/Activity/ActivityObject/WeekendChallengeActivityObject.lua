local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local WeekendChallengeActivityObject = Base:Extend("WeekendChallengeActivityObject")

function WeekendChallengeActivityObject:EraseNewActivityRedPoint()
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPoint, ActivityEnum.RedPointKey.NewActivity, tostring(self:GetActivityId()), false)
end

return WeekendChallengeActivityObject
