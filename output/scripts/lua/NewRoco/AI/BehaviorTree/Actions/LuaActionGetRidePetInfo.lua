local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetRidePetInfo = Base:Extend("LuaActionGetRidePetInfo")

function LuaActionGetRidePetInfo:OnStart(owner)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local rideComp = localPlayer.viewObj.BP_RideComponent
  local ridingPet = rideComp.ScenePet
  local socketType = rideComp.SocketType
  if ridingPet and ridingPet.config then
    self.OutPetbaseID:SetValue(owner, ridingPet.config.id)
    self.OutRideSocketType:SetValue(owner, socketType or 0)
    return self:Finish(true)
  end
  self.OutPetbaseID:SetValue(owner, 0)
  self.OutRideSocketType:SetValue(owner, -1)
  return self:Finish(false)
end

return LuaActionGetRidePetInfo
