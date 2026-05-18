require("UnLuaEx")
local RoleHPComponent = require("NewRoco.Modules.Core.Scene.Component.RoleHP.RoleHPComponent")
local BP_WindResponseComponent_C = NRCClass()

function BP_WindResponseComponent_C:OnEnterTerribleWind()
  Log.Debug("BP_WindResponseComponent_C OnEnterTerribleWind")
  if not self._inTerribleWind then
    self._inTerribleWind = true
    if not NRCEnv:IsLocalMode() then
      local req = ProtoMessage:newZoneSceneStrongStormNty()
      req.enter = true
      ZoneServer:Send(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_STRONG_STORM_NTY, req)
    end
  end
end

function BP_WindResponseComponent_C:OnExitTerribleWind()
  if self._inTerribleWind then
    self._inTerribleWind = false
    Log.Debug("BP_WindResponseComponent_C OnExitTerribleWind")
    if not NRCEnv:IsLocalMode() then
      local req = ProtoMessage:newZoneSceneStrongStormNty()
      req.enter = false
      ZoneServer:Send(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_STRONG_STORM_NTY, req)
    end
  end
end

return BP_WindResponseComponent_C
