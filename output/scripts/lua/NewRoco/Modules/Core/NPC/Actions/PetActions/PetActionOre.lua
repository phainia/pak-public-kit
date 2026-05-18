local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = PetActionBase
local ExplodeDelayTime = 4.0
local DisappearDelayTime = 2.0
local PetActionOre = Base:Extend("PetActionOre")

function PetActionOre:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionOre:OnExecute()
  Log.Warning("PetActionOre:OnExecute")
  local OwnerNPCView = self:GetOwnerNPCView()
  if not OwnerNPCView then
    self:Finish(false)
    return
  end
  if OwnerNPCView.UpdateState then
    self.isWallBreach = true
  end
  local HasControlAuthority = self:HasControlAuthority()
  if HasControlAuthority then
    OwnerNPCView.HoldOre = true
    OwnerNPCView.HoldPerform = true
    OwnerNPCView.isImpacted = false
    local OwnerNPC = self:GetOwnerNPC()
    OwnerNPC.bDisappearPerform = true
  end
  self:ResetSubmitTimeOutHandle()
  if self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.SceneNpc then
    self:SkillImpact()
    self:SkillFailed()
  else
    self:StartSkill()
  end
end

function PetActionOre:GetSide()
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
  return Dot > 0
end

function PetActionOre:GetHitInfo()
  local View = self:GetOwnerNPCView()
  if not View then
    return nil, nil
  end
  local RunnerView = self:GetRunnerView()
  if not RunnerView then
    return nil, nil
  end
  local P1 = View:Abs_K2_GetActorLocation()
  local P2 = RunnerView:Abs_K2_GetActorLocation()
  P2.Z = P1.Z
  local Dir = P1 - P2
  Dir:Normalize()
  local MidPos = (P1 + P2) / 2.0
  return MidPos, Dir
end

function PetActionOre:StartSkill()
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
  local SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneCaiji/G6_Scene_Caiji_Kuang.G6_Scene_Caiji_Kuang"
  if self.isWallBreach then
    SkillPath = "/Game/ArtRes/Effects/G6Skill/Dungeon/Dungeon_Wall_Breach.Dungeon_Wall_Breach"
  end
  local SkillComp = self:GetRunnerSkillComponent()
  local Skill = RocoSkillProxy.Create(SkillPath, SkillComp, PriorityEnum.Active_Throw_Pet)
  if not Skill then
    Log.Error("Can't find skill from skill component")
    self:SkillFailed()
    return
  end
  TargetView.Left = self:GetSide()
  if self.isWallBreach and TargetView.TurnOffCollision then
    TargetView:TurnOffCollision()
  end
  Skill:SetCaster(PetView)
  Skill:SetTargets({TargetView})
  Skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  Skill:RegisterEventCallback("End", self, self.SkillComplete)
  Skill:RegisterEventCallback("TriggerBeHit", self, self.SkillImpact)
  Skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  Skill:RegisterEventCallback("TriggerPreHit", self, self.SkillPreProcess)
  Skill:RegisterEventCallback("ActivateFailed", self, self.SkillFailed)
  Skill:PlaySkill(self, self.OnSkillStart)
end

function PetActionOre:OnSkillStart(Skill, Result)
  self.bSkillComplete = false
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:SkillFailed()
  end
end

function PetActionOre:SkillFailed()
  self.SkillStarted = false
  self:SkillPreProcess()
  self:SkillImpact()
  self.d_SubmitTimeOut = _G.DelayManager:DelaySeconds(5, self.SubmitTimeOut, self)
end

function PetActionOre:SubmitTimeOut()
  self:SkillComplete()
end

function PetActionOre:ResetSubmitTimeOutHandle()
  if self.d_SubmitTimeOut then
    _G.DelayManager:CancelDelayById(self.d_SubmitTimeOut)
    self.d_SubmitTimeOut = nil
  end
end

function PetActionOre:SkillComplete(Name, Skill)
  if self.bSkillComplete then
    return
  end
  self.bSkillComplete = true
  self:SetSessionRecycle(true)
  self.SkillStarted = false
  self:Finish(true)
  local OwnerNPC = self:GetOwnerNPC()
  if not OwnerNPC then
    Log.Error("\230\146\158\229\174\140\231\159\191\231\159\179\239\188\140\228\189\134\230\152\175\231\159\191\231\159\179NPC\229\183\178\231\187\143\232\162\171\233\148\128\230\175\129\228\186\134!")
    return
  end
  OwnerNPC.bDisappearPerform = false
  OwnerNPC:SetNotDestroyFlag(false)
  local OwnerNPCView = OwnerNPC.viewObj
  if OwnerNPCView then
    if OwnerNPCView.NeedDisappear then
      OwnerNPC:Disappear(true)
    elseif not self.bWaitForNPCDestroy then
      OwnerNPC:AdjustModelHeight()
    end
  end
end

function PetActionOre:OnInterrupted(Name, Skill)
  Log.Error("PetActionOre:OnInterrupted")
  self:SetSessionRecycle(true)
  self.SkillStarted = false
  if self.isSubmitDone then
    self:Finish(true)
    local OwnerNPC = self:GetOwnerNPC()
    if not OwnerNPC then
      Log.Error("\230\146\158\229\174\140\231\159\191\231\159\179\239\188\140\228\189\134\230\152\175\231\159\191\231\159\179NPC\229\183\178\231\187\143\232\162\171\233\148\128\230\175\129\228\186\134!")
      return
    end
    OwnerNPC.bDisappearPerform = false
    OwnerNPC:SetNotDestroyFlag(false)
    local OwnerNPCView = OwnerNPC.viewObj
    if OwnerNPCView then
      if OwnerNPCView.NeedDisappear then
        OwnerNPC:Disappear(true)
      elseif not self.bWaitForNPCDestroy then
        OwnerNPC:AdjustModelHeight()
      end
    end
  else
    self:Finish(false)
  end
end

function PetActionOre:SkillImpact(Name, Skill)
  self:SetSessionRecycle(true)
  local OwnerNpc = self:GetOwnerNPC()
  if not (OwnerNpc and self.bWaitForNPCDestroy) or not self.isWallBreach then
  end
  local OwnerNPCView = self:GetOwnerNPCView()
  if not OwnerNPCView then
    Log.Error("\230\146\158\229\174\140\231\159\191\231\159\179\239\188\140\228\189\134\230\152\175\231\159\191\231\159\179NPC\229\183\178\231\187\143\232\162\171\233\148\128\230\175\129\228\186\134!")
    return
  end
  if self.isWallBreach and self.submitBack and not self.performDone then
    OwnerNPCView.HoldPerform = false
    OwnerNPCView:UpdateState()
    if OwnerNPCView.ApplyPhysicsHit then
      OwnerNPCView:SetActorEnableCollision(false)
      OwnerNPCView:ApplyPhysicsHit(self:GetHitInfo())
      self.ExplodeDelayHandler = _G.DelayManager:DelaySeconds(ExplodeDelayTime, self.WallExplodeEnd, self, OwnerNPCView)
      self.performDone = true
    end
    return
  end
  OwnerNPCView.HoldOre = false
  OwnerNPCView.isImpacted = true
  if self:HasControlAuthority() then
    OwnerNPCView:Show()
  end
end

function PetActionOre:SkillPreProcess(Name, Skill)
  Log.Debug("PetActionOre:SkillPreProcess")
  self:SetSessionRecycle(false)
  self:Submit()
  self.isSubmitDone = true
end

function PetActionOre:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
  if 0 == rsp.ret_info.ret_code then
    if not self.SkillStarted then
      self:ResetSubmitTimeOutHandle()
      self:SkillComplete()
    end
    if not self:IsFakeSubmit() then
      self.bWaitForNPCDestroy = true
    end
  else
    self:Finish(false)
  end
  self.submitBack = true
  if not self.performDone then
    self:SkillImpact()
  end
end

function PetActionOre:WallExplodeEnd(OwnerNPCView)
  if UE.UObject.IsValid(OwnerNPCView) and OwnerNPCView.PlayDisappear then
    OwnerNPCView:PlayDisappear()
    self.DisappearDelayHandler = _G.DelayManager:DelaySeconds(DisappearDelayTime, self.WallDisappearEnd, self, OwnerNPCView)
  end
end

function PetActionOre:WallDisappearEnd(OwnerNPCView)
  if UE.UObject.IsValid(OwnerNPCView) and OwnerNPCView.HideWall then
    OwnerNPCView:HideWall()
  end
end

local DistanceParams = {300, 600}

function PetActionOre:GetRangeParams()
  return DistanceParams
end

return PetActionOre
