local EventDispatcher = require("Common.EventDispatcher")
local PowerDashActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PowerDashAction.PowerDashActionEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local PowerDashActionBase = Class("PowerDashActionBase")
local ExplodeDelayTime = 4.0
local DisappearDelayTime = 2.0

function PowerDashActionBase:Ctor(Owner, Conf)
  EventDispatcher():Attach(self)
  self.Owner = Owner
  self.Conf = Conf
  self.ImpactLocation = false
  self.OwnerName = ""
end

function PowerDashActionBase:Execute(Skill, DashCaster)
  self.Runner = Skill
  self.DashCaster = DashCaster
  self:SendEvent(PowerDashActionEvent.OnExecute, self)
  self:OnExecute()
end

function PowerDashActionBase:SyncExecute()
  local rsp = _G.ProtoMessage:newZoneScenePetPowerDashInteractRsp()
  rsp.ret_info.ret_code = 0
  self:OnSubmit(rsp)
end

function PowerDashActionBase:OnExecute()
  self:Submit()
end

function PowerDashActionBase:Submit()
  local Owner = self.Owner and self.Owner.owner
  local OwnerView = Owner and Owner.viewObj
  if OwnerView then
    self.OwnerName = OwnerView.name
    self.ImpactLocation = OwnerView:K2_GetActorLocation()
  end
  local Req = _G.ProtoMessage:newZoneScenePetPowerDashInteractReq()
  Req.gid = self.Runner.RideComp.ScenePet.gid
  Req.npc_actor_id = self.Owner.owner:GetServerId()
  Req.option_id = self.Owner.config.id
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PET_POWER_DASH_INTERACT_REQ, Req, self, self.OnSubmit, false, true)
end

function PowerDashActionBase:OnSubmit(rsp)
  local Success = 0 == rsp.ret_info.ret_code
  local Owner = self.Owner and self.Owner.owner
  local OwnerView = Owner and Owner.viewObj
  if Success and UE.UObject.IsValid(OwnerView) then
    if self.OwnerName == "BP_NPCTree_C" then
      self:PlaySound(3530069)
    elseif self.OwnerName == "BP_NPCOreBase_C" then
      self:PlaySound(3530068)
    elseif OwnerView.ApplyPhysicsHit then
      OwnerView:SetActorEnableCollision(false)
      if not self.npcInfo then
        OwnerView:ApplyPhysicsHit(self:GetHitInfo(OwnerView, self.DashCaster))
      else
        OwnerView:ApplyPhysicsHit(self:GetHitInfoByBothPos(OwnerView:Abs_K2_GetActorLocation(), SceneUtils.ServerPos2ClientPos(self.npcInfo.operator_location.pos)))
      end
      self.ExplodeDelayHandler = _G.DelayManager:DelaySeconds(ExplodeDelayTime, self.ItemExplodeEnd, self, OwnerView)
      if Owner then
        Owner:SetNotDestroyFlag(true)
      end
    end
  end
  self:Finish(Success)
end

function PowerDashActionBase:GetHitInfo(NPCView, DashCasterView)
  if not UE.UObject.IsValid(NPCView) then
    return _G.UE4Helper.ZeroVector, _G.UE4Helper.ZeroVector
  end
  if not UE.UObject.IsValid(DashCasterView) then
    return NPCView:Abs_K2_GetActorLocation(), NPCView:GetActorForwardVector()
  end
  local P1 = NPCView:Abs_K2_GetActorLocation()
  local P2 = DashCasterView:Abs_K2_GetActorLocation()
  self:GetHitInfoByBothPos(P1, P2)
end

function PowerDashActionBase:GetHitInfoByBothPos(OwnerPos, CasterPos)
  CasterPos.Z = OwnerPos.Z
  local Dir = OwnerPos - CasterPos
  Dir:Normalize()
  local MidPos = (OwnerPos + CasterPos) / 2.0
  return MidPos, Dir
end

function PowerDashActionBase:ItemExplodeEnd(OwnerNPCView)
  if OwnerNPCView.PlayDisappear then
    OwnerNPCView:PlayDisappear()
    self.DisappearDelayHandler = _G.DelayManager:DelaySeconds(DisappearDelayTime, self.ItemDisappearEnd, self, OwnerNPCView)
  end
end

function PowerDashActionBase:ItemDisappearEnd(OwnerNPCView)
  if OwnerNPCView.HideWall then
    OwnerNPCView:HideWall()
  end
  local Owner = self.Owner and self.Owner.owner
  if Owner then
    Owner:SetNotDestroyFlag(false)
  end
end

function PowerDashActionBase:CacheSyncInfo(npcInfo)
  self.npcInfo = npcInfo
end

function PowerDashActionBase:Finish(Success)
  self:SendEvent(PowerDashActionEvent.OnFinish, self, Success)
  self.Runner = nil
end

function PowerDashActionBase:PlaySound(SoundID)
  if not SoundID or 0 == SoundID then
    return
  end
  local Location = self.ImpactLocation
  if Location then
    _G.NRCAudioManager:PlaySound3DAtLocationAuto(SoundID, Location)
  end
end

return PowerDashActionBase
