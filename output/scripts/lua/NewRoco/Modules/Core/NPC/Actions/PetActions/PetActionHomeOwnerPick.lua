local Base = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local PetActionHomeOwnerPick = Base:Extend("PetActionHomeOwnerPick")

function PetActionHomeOwnerPick:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionHomeOwnerPick:Execute(Runner)
  Base.Execute(self, Runner)
  self:LockAI()
  self:Submit()
end

function PetActionHomeOwnerPick:OnExecute()
  local SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneCaiji/Pet_Caiji_Common_Happy.Pet_Caiji_Common_Happy"
  local View = self:GetRunnerView()
  if not View then
    Log.Error("PetActionHomeOwnerPick:Execute View")
    self:Finish(false)
    return
  end
  local SkillComp = View.RocoSkill
  local skill = RocoSkillProxy.Create(SkillPath, SkillComp)
  if not skill then
    Log.Error("PetActionHomeOwnerPick:Execute \230\137\190\228\184\141\229\136\176Skill")
    self:Finish(false)
    return
  end
  skill:SetCaster(View)
  skill:SetWithLoadAndPlay(true)
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  SkillComp:StopCurrentSkill()
  skill:PlaySkill(self, self.OnSkillStart)
  self:TurnToTargetLand()
  _G.NRCEventCenter:RegisterEvent("PetActionHomeOwnerPick", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function PetActionHomeOwnerPick:TurnToTargetLand()
  local owner = self:GetOwnerNPC()
  if not owner then
    return
  end
  local ownerLandId = owner:GetFarmLandId()
  if not ownerLandId or 0 == ownerLandId then
    return
  end
  local ownerLandNpc = FarmUtils.GetLandNPC(ownerLandId)
  if not ownerLandNpc or not ownerLandNpc.viewObj then
    return
  end
  local ownerLandNpcLocation = ownerLandNpc.viewObj:K2_GetActorLocation()
  local pet = self.Runner
  local petView = self:GetRunnerView()
  if not (pet and petView) or not ownerLandNpcLocation then
    return
  end
  local Direction = ownerLandNpcLocation - petView:K2_GetActorLocation()
  Direction.Z = 0
  local Rotator = Direction:ToRotator()
  local TurnComp = pet.TurnComponent
  if TurnComp then
    TurnComp:StartTurn_S(Rotator.Yaw, 0.1, true)
  else
    pet:SetActorRotation(Rotator)
  end
end

function PetActionHomeOwnerPick:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
end

function PetActionHomeOwnerPick:OnSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:SkillFailed()
  end
end

function PetActionHomeOwnerPick:SkillFailed()
  Log.Error("PetActionHomeOwnerPick:SkillFailed")
  self.SkillStarted = false
  self:SkillComplete()
end

function PetActionHomeOwnerPick:SkillComplete(Name, Skill)
  self.SkillStarted = false
  self:FreeAI()
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function PetActionHomeOwnerPick:OnInterrupted(Name, Skill)
  Log.Error("PetActionHomeOwnerPick:OnInterrupted")
  self.SkillStarted = false
  self:SkillComplete()
end

function PetActionHomeOwnerPick:OnReconnect()
  Log.Error("PetActionHomeOwnerPick:OnReconnect need to complete skill!")
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function PetActionHomeOwnerPick:FreeAI()
  if self.LockedAI then
    self.LockedAI.AIComponent:ForceLockForReason(false, false, _G.AIDefines.LockReason.INTERACT)
    self.LockedAI = nil
  else
    Log.Error("FreeAI\230\151\182\239\188\140\231\178\190\231\129\181\230\182\136\229\164\177\228\186\134\239\188\129")
  end
end

function PetActionHomeOwnerPick:LockAI()
  if self.Runner then
    self.Runner.AIComponent:ForceLockForReason(true, false, _G.AIDefines.LockReason.INTERACT)
    self.LockedAI = self.Runner
  else
    Log.Error("LockAI\230\151\182\239\188\140\231\178\190\231\129\181\230\182\136\229\164\177\228\186\134\239\188\129")
  end
end

function PetActionHomeOwnerPick:ContinueWhenSuccess()
  return false
end

return PetActionHomeOwnerPick
