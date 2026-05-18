local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local OnlineState = require("Core.Service.NetManager.OnlineState")
local Base = ActorComponent
local CaveComponent = Base:Extend("CaveComponent")

function CaveComponent:Attach(owner)
  Base.Attach(self, owner)
  self.longTickTimer = 0
  self.clientCaveName = nil
  self.serverCaveInfo = nil
  self.teleportTriggered = true
  _G.NRCEventCenter:RegisterEvent("CaveComponent", self, _G.NRCGlobalEvent.OnOnlineStateChanged, self.OnOnlineStateChanged)
  _G.NRCEventCenter:RegisterEvent("CaveComponent", self, _G.NRCGlobalEvent.OnCaveAddedToWorld, self.CaveInfoCheck)
  _G.NRCEventCenter:RegisterEvent("CaveComponent", self, _G.NRCGlobalEvent.OnCaveRemoveFromWorld, self.CaveInfoCheck)
  _G.NRCEventCenter:RegisterEvent("CaveComponent", self, SceneEvent.OnPreTeleportNotify, self.OnPreTeleportNotify)
end

function CaveComponent:DeAttach()
  self.longTickTimer = 0
  self.clientCaveName = nil
  self.serverCaveInfo = nil
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnOnlineStateChanged, self.OnOnlineStateChanged)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnCaveAddedToWorld, self.CaveInfoCheck)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnCaveRemoveFromWorld, self.CaveInfoCheck)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnPreTeleportNotify, self.OnPreTeleportNotify)
  Base.DeAttach(self)
end

function CaveComponent:Destroy()
  Base.Destroy(self)
end

function CaveComponent:Update(deltaTime)
  if self.teleportTriggered then
    return
  end
  if self.longTickTimer > 0 then
    self.longTickTimer = self.longTickTimer - deltaTime
    return
  end
  self.longTickTimer = 1
  self:CaveInfoCheck()
end

function CaveComponent:CaveInfoCheck()
  if self.teleportTriggered then
    return
  end
  self.clientCaveName = self:GetClientCaveInfo()
  self.serverCaveInfo = self:GetServerCaveInfo()
  local ret, caveName = self:IsServerAndClientDifferentCave(self.clientCaveName, self.serverCaveInfo)
  if ret then
    self:SendZoneSceneClientCaveStateReq(caveName)
  end
end

function CaveComponent:SendZoneSceneClientCaveStateReq(caveName, pos)
  local req = _G.ProtoMessage:newZoneSceneClientCaveStateReq()
  req.cave_name = caveName or ""
  if not pos then
    self.owner:GetServerPosition(req.pos)
  else
    req.pos = pos
  end
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CLIENT_CAVE_STATE_REQ, req)
end

function CaveComponent:OnZoneSceneClientCaveStateRsp(rsp)
  if rsp and rsp.ret_info and 0 ~= rsp.ret_info.ret_code then
    Log.Error("CaveComponent:OnZoneSceneClientCaveStateRsp: ", rsp.ret_info.ret_code)
  end
end

function CaveComponent:GetServerCaveInfo()
  return _G.NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.GetCaveInfo)
end

function CaveComponent:GetClientCaveInfo()
  local caveName = UE4.UNRCStatics.GetCaveSteamingLevelName()
  return caveName
end

function CaveComponent:IsServerAndClientDifferentCave(clientCaveName, serverCaveInfo)
  if not serverCaveInfo then
    if clientCaveName and "" ~= clientCaveName and "None" ~= clientCaveName then
      return true, clientCaveName
    else
      return false, nil
    end
  elseif not clientCaveName or "" == clientCaveName or "None" == clientCaveName then
    return true, nil
  else
    for _, name in pairs(serverCaveInfo.belong_cave) do
      if clientCaveName == name then
        return false, nil
      end
    end
    return true, clientCaveName
  end
end

function CaveComponent:OnOnlineStateChanged(oldOnlineState, newOnlineState, disOnlineState)
  if newOnlineState == OnlineState.EnteredCell and self.teleportTriggered then
    self.teleportTriggered = false
    self:CaveInfoCheck()
  elseif newOnlineState == OnlineState.EnteringCell and not self.teleportTriggered then
    self.teleportTriggered = true
  end
end

function CaveComponent:OnPreTeleportNotify()
  self.teleportTriggered = true
end

return CaveComponent
