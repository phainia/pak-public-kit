local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local CertificationActivityObject = Base:Extend("CertificationActivityObject")

function CertificationActivityObject:OnSvrUpdateActivityData(cmdId, _updateData, _initUpdate)
  if cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.activity_data = _updateData.pet_certification_data
    self:SendEvent(ActivityModuleEvent.RefreshCertificationActivityData, _updateData.pet_certification_data)
  end
end

function CertificationActivityObject:GetActivityData()
  return self.activity_data
end

function CertificationActivityObject:OnReconnectFinish()
  local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if petUIModule then
    petUIModule.certificationGid = nil
  end
  return false
end

return CertificationActivityObject
