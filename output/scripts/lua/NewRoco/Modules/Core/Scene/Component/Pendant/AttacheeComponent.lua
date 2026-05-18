local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PendantComponent
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local AttacheeComponent = Base:Extend("AttacheeComponent")

function AttacheeComponent:Attach(owner)
  Base.Attach(self, owner)
  self.attacher = nil
  self.status = ProtoEnum.PendantItemStatus.PIS_NONE
  self.interactionDistance = 0
  self.pendantGroupIdx = 0
  self.cfgId = 0
  self.itemId = 0
  self.pendingInteract = false
end

function AttacheeComponent:DeAttach()
  self.attacher = nil
  Base.DeAttach(self)
end

function AttacheeComponent:InitByAttacher(attacher, pendantGroup, itemId, initState)
  self.attacher = attacher
  self.itemId = itemId
  if not PendantComponent then
    PendantComponent = require("NewRoco.Modules.Core.Scene.Component.Pendant.PendantComponent")
  end
  local attacher_comp = attacher:EnsureComponent(PendantComponent)
  self.interactionDistance = pendantGroup.cfg.distance
  self.cfgId = pendantGroup.cfg.id
  self.status = initState
  self:SetState(initState or false)
end

function AttacheeComponent:SetState(Status)
  if self.status == Status then
    return
  end
  self.pendingInteract = false
  self.status = Status
  self:ApplyState()
end

function AttacheeComponent:ApplyState()
  self.owner:SendEvent(NPCModuleEvent.SetAttacheeState, self.status)
end

function AttacheeComponent:OnResourceLoaded()
  self.pendingInteract = false
  self:ApplyState()
end

function AttacheeComponent:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  if not self.attacher then
    return
  end
  if self.pendingInteract then
    return
  end
  if not self.owner.viewObj or not self.owner.viewObj.resourceLoaded then
    return
  end
  local WorldOwnerID = self.attacher.serverData.base.owner_id
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if WorldOwnerID ~= player.serverData.base.actor_id then
    return
  end
  if self.owner:DistanceTo(player) < self.interactionDistance then
    if self.status == ProtoEnum.PendantItemStatus.PIS_ENABLE or self.status == ProtoEnum.PendantItemStatus.PIS_TRANSPARENT then
      local req = ProtoMessage.newZoneSceneNpcPendantInteractReq()
      req.npc_id = self.attacher:GetServerId()
      req.pendant_cfg_id = self.cfgId
      req.id = self.itemId
      _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_PENDANT_INTERACT_REQ, req, self, self.OnInteractRsp, false, true)
    end
    self.pendingInteract = true
  end
end

function AttacheeComponent:OnInteractRsp(rsp)
end

function AttacheeComponent:Disappear()
  self.owner:SendEvent(NPCModuleEvent.PendantDestroy)
end

return AttacheeComponent
