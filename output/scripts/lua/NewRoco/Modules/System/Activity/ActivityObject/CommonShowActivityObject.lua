local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local CommonShowActivityObject = Base:Extend("CommonShowActivityObject")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function CommonShowActivityObject:OnConstruct(_conf)
  self.commonShowConf = _G.DataConfigManager:GetActivityCommonShowConf(self:GetSinglePartId())
end

function CommonShowActivityObject:GetPetBaseId()
  return self.commonShowConf and self.commonShowConf.petbase_id
end

function CommonShowActivityObject:GetPetShowParam()
  return self.commonShowConf and self.commonShowConf.petshow_group
end

function CommonShowActivityObject:GetLogoIcon()
  return self.commonShowConf and self.commonShowConf.image_path
end

function CommonShowActivityObject:GetRewardPreview()
  return self.commonShowConf and self.commonShowConf.reward_show
end

function CommonShowActivityObject:GetJumpOption()
  local commonShowConf = self.commonShowConf
  if commonShowConf then
    return ActivityUtils.GetActivityOptionData(commonShowConf.option_id)
  end
end

function CommonShowActivityObject:ExecuteJumpOption()
  local commonShowConf = self.commonShowConf
  if not commonShowConf then
    return
  end
  ActivityUtils.DoActivityOptionCmd(commonShowConf.option_id)
end

function CommonShowActivityObject:GetActivityEndTime()
  if self.commonShowConf then
    return ActivityUtils.ToTimestamp(self.commonShowConf.end_time)
  end
  return Base.GetActivityEndTime(self)
end

return CommonShowActivityObject
