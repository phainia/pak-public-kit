local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local PetActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PetActionEvent")
local Base = PetActionBase
local PetActionWall = Base:Extend("PetActionWall")

function PetActionWall:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionWall:OnExecute()
  self:GetOwnerNPCView().HoldPerform = true
  self:Submit()
  self:StartSkill()
end

function PetActionWall:GetSide()
  local View = self:GetOwnerNPCView()
  if not View then
    return true
  end
  local RunnerView = self:GetRunnerView()
  if not RunnerView then
    return true
  end
  local Forward = View:GetActorForwardVector()
  Forward = Forward:RotateAngleAxis(-90, UE.FVector(0, 0, 1))
  Forward = UE.FVector2D(Forward.X, Forward.Y)
  local P1 = View:K2_GetActorLocation()
  local P2 = RunnerView:K2_GetActorLocation()
  local Dir = P1 - P2
  Dir = UE.FVector2D(Dir.X, Dir.Y)
  Forward:Normalize()
  Dir:Normalize()
  local Dot = Forward:Dot(Dir)
  return Dot < 0
end

function PetActionWall:StartSkill()
  local PetView = self:GetRunnerView()
  if not PetView then
    Log.Error("Can't find pet view")
    self:SkillFailed()
    return
  end
  local TargetView = self:GetOwnerNPCView()
  if not TargetView then
    Log.Error("Can't find target view")
    self:SkillFailed()
    return
  end
  local SkillPath = "/Game/ArtRes/Effects/G6Skill/Dungeon/Dungeon_Wall_Breach.Dungeon_Wall_Breach"
  local SkillComp = self:GetRunnerSkillComponent()
  local Skill = RocoSkillProxy.Create(SkillPath, SkillComp, PriorityEnum.Active_Throw_Pet)
  if not Skill then
    Log.Error("Can't find skill from skill component")
    self:SkillFailed()
    return
  end
  TargetView.Left = self:GetSide()
  TargetView:TurnOffCollision()
  Skill:SetCaster(PetView)
  Skill:SetTargets({TargetView})
  Skill:RegisterEventCallback("End", self, self.SkillComplete)
  Skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  Skill:RegisterEventCallback("PreEndAnim", self, self.SkillComplete)
  Skill:RegisterEventCallback("TriggerBeHit", self, self.SkillImpact)
  Skill:RegisterEventCallback("Interrupt", self, self.SkillFailed)
  Skill:PlaySkill()
end

function PetActionWall:SkillFailed()
  Log.Error("Wall Has Not Been Breached!!")
  self:Finish(false)
end

function PetActionWall:SkillComplete(Name, Skill)
  self:SendEvent(PetActionEvent.OnFinish, self, true, true)
  self.Runner = nil
end

function PetActionWall:SkillImpact(Name, Skill)
  self:GetOwnerNPCView().HoldPerform = false
  self:GetOwnerNPCView():UpdateState()
end

function PetActionWall:OnSubmit(rsp)
  if 0 == rsp.ret_info.ret_code then
  else
    self:Finish(false)
  end
end

return PetActionWall
