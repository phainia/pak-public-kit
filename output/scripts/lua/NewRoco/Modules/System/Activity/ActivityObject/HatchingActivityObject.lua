local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local HatchingActivityObject = Base:Extend("HatchingActivityObject")

function HatchingActivityObject:OnConstruct(_conf)
end

function HatchingActivityObject:OnDestruct()
end

function HatchingActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.svrActivityData = _updateData
  end
  local viewPanel = self.weakRef.viewPanel
  if viewPanel and viewPanel.OnSvrUpdateActivityData then
    local _activityData = _updateData
    viewPanel:OnSvrUpdateActivityData(_cmdId, _activityData, _initUpdate)
  end
end

return HatchingActivityObject
