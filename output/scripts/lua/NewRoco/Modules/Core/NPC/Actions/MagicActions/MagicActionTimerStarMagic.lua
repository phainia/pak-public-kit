local Base = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local BornDieComponent = require("NewRoco.Modules.Core.Scene.Component.BornDie.BornDieComponent")
local MagicActionTimerStarMagic = Base:Extend("MagicActionTimerStarMagic")
local ExplodeDelayTime = 4.0
local DisappearDelayTime = 2.0

function MagicActionTimerStarMagic:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionTimerStarMagic:OnExecute(LightBallNPC)
  self.LightBallNPC = LightBallNPC
end

function MagicActionTimerStarMagic:OnSubmit(rsp)
  if not self.Runner then
    Log.Error("MagicActionTimerStarMagic:OnSubmit \230\137\190\228\184\141\229\136\176\229\174\131\231\154\132Runner\228\186\134\239\188\140\229\174\131\229\190\136\229\173\164\229\141\149")
    return
  end
  local param2 = tonumber(self.Config.action_param2)
  if nil == param2 or 1 ~= param2 then
    self:Finish()
    return
  end
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("MagicActionTimerStarMagic:Submit Failed!", rsp.ret_info.ret_code, rsp.ret_info.ret_msg)
    return
  end
  local OwnerNPCView = self.Runner.viewObj
  if UE4.UObject.IsValid(OwnerNPCView) and OwnerNPCView.ApplyPhysicsHit then
    OwnerNPCView:SetActorEnableCollision(false)
    OwnerNPCView:ApplyPhysicsHit(self:GetHitInfo(OwnerNPCView, self.LightBallNPC.viewObj))
    self.ExplodeDelayHandler = _G.DelayManager:DelaySeconds(ExplodeDelayTime, self.ItemExplodeEnd, self, OwnerNPCView)
    if self.Runner then
      self.Runner:SetNotDestroyFlag(true)
    end
    return
  end
  local bornDie = self.Runner:EnsureComponent(BornDieComponent)
  local action = _G.ProtoMessage:newSpaceAct_ActorDieBegin()
  action.die_reason = _G.ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_NONE
  action.skill_or_anim = self.Runner.config and self.Runner.config.disappear_skill
  action.is_skill = true
  bornDie:OnBeginDying(action)
  self:Finish()
end

function MagicActionTimerStarMagic:GetHitInfo(NPCView, LightBallNPCView)
  local P1 = NPCView:Abs_K2_GetActorLocation()
  local P2 = LightBallNPCView:Abs_K2_GetActorLocation()
  P2.Z = P1.Z
  local Dir = P1 - P2
  Dir:Normalize()
  local MidPos = (P1 + P2) / 2.0
  return MidPos, Dir
end

function MagicActionTimerStarMagic:ItemExplodeEnd(OwnerNPCView)
  if UE4.UObject.IsValid(OwnerNPCView) and OwnerNPCView.PlayDisappear then
    OwnerNPCView:PlayDisappear()
    self.DisappearDelayHandler = _G.DelayManager:DelaySeconds(DisappearDelayTime, self.ItemDisappearEnd, self, OwnerNPCView)
  end
end

function MagicActionTimerStarMagic:ItemDisappearEnd(OwnerNPCView)
  if UE4.UObject.IsValid(OwnerNPCView) and OwnerNPCView.HideItem then
    OwnerNPCView:HideItem()
  end
  if self.Runner then
    self.Runner:SetNotDestroyFlag(false)
  end
end

return MagicActionTimerStarMagic
