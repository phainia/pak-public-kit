require("UnLuaEx")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local OverlapAwareVisibilityComponent = require("NewRoco.Modules.Core.Scene.Component.Visibility.OverlapAwareVisibilityComponent")
local BP_NPCGuardSphere_C = Base:Extend("BP_NPCGuardSphere_C")
local GuardSphereMap = {}

function BP_NPCGuardSphere_C:SetSphereRadius()
end

function BP_NPCGuardSphere_C:ReceiveBeginPlay()
  self.contains_actor_id = {}
  self.Sphere:SetSphereRadius(200, false)
  self:Init()
  self.Sphere.OnComponentBeginOverlap:Add(self, self.OnSphereBeginOverlap)
end

function BP_NPCGuardSphere_C:OnSphereBeginOverlap(selfComp, otherActor, otherComp, otherBodyIndex, bFromSweep, result)
  self:OnActorEnter(otherActor)
end

function BP_NPCGuardSphere_C:OnSphereEndOverlap(selfComp, otherActor, otherComp, otherBodyIndex)
  self:OnActorLeave(otherActor)
end

function BP_NPCGuardSphere_C:ReceiveEndPlay(Reason)
  self.Sphere.OnComponentBeginOverlap:Remove(self, self.OnSphereBeginOverlap)
  self:ClearSelf()
end

function BP_NPCGuardSphere_C:OnActorEnter(actor)
  if not UE4.UObject.IsValid(actor) then
    return
  end
  if not actor.sceneCharacter then
    return
  end
  local serverData = actor.sceneCharacter.serverData
  local serverBase = serverData and serverData.base
  local actor_id = serverBase and serverBase.actor_id
  if actor_id then
    self:RegisterActor(actor_id)
  end
end

function BP_NPCGuardSphere_C:OnActorLeave(actor)
  if not UE4.UObject.IsValid(actor) then
    return
  end
  if not actor.sceneCharacter then
    return
  end
  local serverData = actor.sceneCharacter.serverData
  local serverBase = serverData and serverData.base
  local actor_id = serverBase and serverBase.actor_id
  if actor_id then
    self:UnRegisterActor(actor_id)
  end
end

function BP_NPCGuardSphere_C:RegisterActor(actor_id)
  self.contains_actor_id[actor_id] = true
  if not GuardSphereMap[actor_id] then
    GuardSphereMap[actor_id] = {}
  end
  GuardSphereMap[actor_id][self] = true
  self:SetCollisionDisableById(true, actor_id)
end

function BP_NPCGuardSphere_C:UnRegisterActor(actor_id)
  self.contains_actor_id[actor_id] = nil
  if not GuardSphereMap[actor_id] then
    return
  end
  GuardSphereMap[actor_id][self] = nil
  if table.isEmpty(GuardSphereMap[actor_id]) then
    GuardSphereMap[actor_id] = nil
    self:SetCollisionDisableById(false, actor_id)
  end
end

function BP_NPCGuardSphere_C:SetCollisionDisableById(disable, actor_id)
  local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, actor_id)
  if npc then
    npc:SetCollisionDisable(disable, NPCModuleEnum.NpcReasonFlags.GUARD_SPHERE)
    if disable and not npc:GetComponent(OverlapAwareVisibilityComponent) then
      npc:EnsureComponent(OverlapAwareVisibilityComponent):CheckInBoundAndMarkHidden(true, true, false, -5, true)
    end
  end
end

function BP_NPCGuardSphere_C:ClearSelf()
  local contains_actor_id = self.contains_actor_id
  self.contains_actor_id = {}
  for actor_id, _ in pairs(contains_actor_id) do
    self:UnRegisterActor(actor_id)
  end
end

return BP_NPCGuardSphere_C
