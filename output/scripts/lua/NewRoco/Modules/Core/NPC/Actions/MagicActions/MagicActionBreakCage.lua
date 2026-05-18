local MagicActionBase = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local Base = MagicActionBase
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NRCResourceManagerEnum = require("Core.Service.ResourceManager.NRCResourceManagerEnum")
local MagicActionBreakCage = Base:Extend("MagicActionBreakCage")
local NightmareCleanPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_NightMare_Cleaning.G6_Scene_NightMare_Cleaning"

function MagicActionBreakCage:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.isPlaying = false
end

function MagicActionBreakCage:OnExecute(LightBallNPC)
  self:ExecuteWithModel(LightBallNPC)
end

function MagicActionBreakCage:OnSubmit(rsp)
end

function MagicActionBreakCage:ExecuteWithModel(LightBallNPC)
  local npc = self:GetOwnerNPC()
  local npcView = self:GetOwnerNPCView()
  if not npc then
    return
  end
  if not npcView then
    Log.Debug("MagicActionBreakCage:ExecuteWithModel npcView is not ready or destroyed")
    self:Finish(true)
    return
  end
  if not LightBallNPC or not LightBallNPC.viewObj then
    Log.Debug("MagicActionBreakCage:ExecuteWithModel LightBallNPC is not ready or destroyed")
    self:Finish(true)
    return
  end
  local LightBallNPCView = LightBallNPC.viewObj
  local hitPos, hitVec = self:GetHitInfo(npcView, LightBallNPCView)
  if nil ~= hitPos and nil ~= hitVec then
    npc:SetNotDestroyFlag(true)
    if npcView.ApplyPhysicsHit then
      npcView:ApplyPhysicsHit(hitPos, hitVec)
    else
      Log.Debug("MagicActionBreakCage:ExecuteWithModel apply to wrong npc ", npcView:GetDebugInfo())
    end
  end
  self.delayId = _G.DelayManager:DelaySeconds(3, self.OnPerformEnd, self)
end

function MagicActionBreakCage:OnPerformEnd()
  local npc = self:GetOwnerNPC()
  npc:SetNotDestroyFlag(false)
  self:Finish(true)
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

function MagicActionBreakCage:OnReConnect()
  Log.Error("MagicActionBreakCage:OnReConnect need to reset skill!")
end

function MagicActionBreakCage:GetHitInfo(NPCView, LightBallNPCView)
  local P1 = NPCView:Abs_K2_GetActorLocation()
  local P2 = LightBallNPCView:Abs_K2_GetActorLocation()
  P2.Z = P1.Z
  local Dir = P1 - P2
  Dir:Normalize()
  local MidPos = (P1 + P2) / 2.0
  return MidPos, Dir
end

return MagicActionBreakCage
