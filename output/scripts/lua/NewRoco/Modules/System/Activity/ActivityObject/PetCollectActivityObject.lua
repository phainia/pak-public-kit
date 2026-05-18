local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local PetCollectActivityObject = Base:Extend("PetCollectActivityObject")

function PetCollectActivityObject:OnConstruct(_conf)
  self.PlayerCardData = nil
end

function PetCollectActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.returnActivityData = _updateData
    self:SendEvent(ActivityModuleEvent.RefreshPetCollectActivityPetList, self, _updateData)
  end
end

return PetCollectActivityObject
