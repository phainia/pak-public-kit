local Base = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local MagicActionItemBurst = Base:Extend("MagicActionItemBurst")
local ExplodeDelayTime = 4.0
local DisappearDelayTime = 2.0

function MagicActionItemBurst:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionItemBurst:OnExecute(LightBallNPC)
  self.LightBallNPC = LightBallNPC
end

function MagicActionItemBurst:OnSubmit(rsp)
  self:StartSkill()
end

function MagicActionItemBurst:StartSkill()
  local PetView = self:GetRunnerView()
  PetView.sceneCharacter:SetNotDestroyFlag(true)
  local OwnerNPCView = self.Runner.viewObj
  local SkillComp = OwnerNPCView:GetComponentByClass(UE4.URocoSkillComponent)
  if PetView.BrokenSkill then
    local SkillProxy = RocoSkillProxy.Create(UE.UNRCStatics.GetSoftObjPath(PetView.BrokenSkill), SkillComp, PriorityEnum.Active_Player_Action)
    local TargetView = self:GetOwnerNPCView()
    SkillProxy:SetCaster(PetView)
    SkillProxy:SetTargets({TargetView})
    SkillProxy:RegisterEventCallback("PreEnd", self, self.SkillComplete)
    SkillProxy:RegisterEventCallback("End", self, self.SkillComplete)
    SkillProxy:PlaySkill()
  elseif OwnerNPCView.ApplyPhysicsHit then
    OwnerNPCView:SetActorEnableCollision(false)
    OwnerNPCView:ApplyPhysicsHit(self:GetHitInfo(OwnerNPCView, self.LightBallNPC.viewObj))
    self.ExplodeDelayHandler = _G.DelayManager:DelaySeconds(ExplodeDelayTime, self.ItemExplodeEnd, self, OwnerNPCView)
    if self.Runner then
      self.Runner:SetNotDestroyFlag(true)
    end
  end
end

function MagicActionItemBurst:GetHitInfo(NPCView, LightBallNPCView)
  local P1 = NPCView:Abs_K2_GetActorLocation()
  local P2 = LightBallNPCView:Abs_K2_GetActorLocation()
  P2.Z = P1.Z
  local Dir = P1 - P2
  Dir:Normalize()
  local MidPos = (P1 + P2) / 2.0
  return MidPos, Dir
end

function MagicActionItemBurst:ItemExplodeEnd(OwnerNPCView)
  if OwnerNPCView.PlayDisappear then
    OwnerNPCView:PlayDisappear()
    self.DisappearDelayHandler = _G.DelayManager:DelaySeconds(DisappearDelayTime, self.ItemDisappearEnd, self, OwnerNPCView)
  end
end

function MagicActionItemBurst:ItemDisappearEnd(OwnerNPCView)
  if OwnerNPCView.HideItem then
    OwnerNPCView:HideItem()
  end
  if self.Runner then
    self.Runner:SetNotDestroyFlag(false)
  end
end

function MagicActionItemBurst:SkillComplete()
  self:Finish(true)
  local OwnerNPC = self:GetOwnerNPC()
  OwnerNPC.bDisappearPerform = false
  local OwnerNpcView = OwnerNPC.viewObj
  if OwnerNpcView then
    OwnerNPC:Disappear(true)
  end
end

return MagicActionItemBurst
