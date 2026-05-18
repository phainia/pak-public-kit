local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local ResQueue = require("NewRoco.Utils.ResQueue")
local Base = PetActionBase
local PetTypeInteractActionBase = Base:Extend("PetTypeInteractActionBase")

function PetTypeInteractActionBase:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.State = 0
  self.LoadQueue = nil
end

function PetTypeInteractActionBase:DoPetTypeInteraction(caller, callback)
  if 0 ~= self.State then
    self.State = 0
    self:FireCallback(false)
    self:Finish(false)
    return
  end
  self.caller = caller
  self.callback = callback
  self.State = 1
  if self.LoadQueue then
    self.LoadQueue:Release()
  else
    self.LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Active_Player_Action)
  end
  self.LoadQueue:InsertClass("Unlock", self:GetUnLockSkillByType())
  self.LoadQueue:InsertClass("Activate", self:GetActivatedSkill())
  self.LoadQueue:StartLoad(self, self.OnResLoaded)
end

function PetTypeInteractActionBase:OnResLoaded(Res, Success)
  if not Success then
    self.State = 0
    self:FireCallback(false)
    self:Finish(false)
    return
  end
  local Runner = self:GetRunnerView()
  if not Runner then
    self.State = 0
    self:FireCallback(false)
    self:Finish(false)
    return
  end
  local Skill = Runner.RocoSkill:FindOrAddSkillObj(Res:Get("Unlock"))
  if not Skill then
    self.State = 0
    self:FireCallback(false)
    self:Finish(false)
    return
  end
  Skill:SetPassive(false)
  Skill:SetCaster(Runner)
  Skill:SetTargets({
    self:GetOwnerNPCView()
  })
  Skill:RegisterEventCallback("PreEnd", self, self.PetShowFinish)
  Skill:RegisterEventCallback("Interrupt", self, self.OnShowInterrupted)
  Skill:RegisterEventCallback("End", self, self.PetShowFinish)
  Skill:RegisterEventCallback("TriggerBeHit", self, self.SkillImpact)
  Skill:RegisterEventCallback("TriggerPreHit", self, self.SkillPreProcess)
  local Result = Runner.RocoSkill:LoadAndPlaySkill(Skill)
  if Result ~= UE.ESkillStartResult.Success then
    self.State = 0
    self:FireCallback(false)
    self:Finish(false)
  end
end

function PetTypeInteractActionBase:OnShowInterrupted(Name, Skill)
  Log.Error("Skill Interrupted!!!!!!")
  if 1 ~= self.State then
    return
  end
  self.State = 0
  self:FireCallback(false)
  self:Finish(false)
end

function PetTypeInteractActionBase:PetShowFinish(Name, Skill)
  if 1 ~= self.State then
    return
  end
  self.State = 2
  self:FireCallback(true)
  self:SetSessionRecycle(true)
end

function PetTypeInteractActionBase:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
  if 0 ~= rsp.ret_info.ret_code then
    self:Finish(false)
    return
  end
  self:PlayActivatedSkill()
end

function PetTypeInteractActionBase:PlayActivatedSkill()
  if 2 ~= self.State then
    self:Finish(false)
    return
  end
  local OwnerView = self:GetOwnerNPCView()
  if not OwnerView then
    self:Finish(false)
    self.State = 0
    return
  end
  if not self.LoadQueue then
    self:Finish(false)
    self.State = 0
    return
  end
  local RocoSkill = OwnerView.RocoSkill
  if not RocoSkill then
    self:Finish(false)
    self.State = 0
    Log.Error("\230\146\173\230\148\190\231\179\187\229\136\171\232\167\163\233\148\129\231\154\132\229\175\185\232\177\161\230\178\161\230\156\137RocoSkill!!!", UE4.UObject.IsValid(OwnerView) and OwnerView:GetFullName())
    return
  end
  local Skill = RocoSkill:AddSkillObjFromClassAndReturn(self.LoadQueue:Get("Activate"))
  if not Skill then
    self:Finish(false)
    self.State = 0
    return
  end
  Skill:SetCaster(self:GetOwnerNPCView())
  Skill:SetPassive(true)
  Skill:RegisterEventCallback("Unlock", self, self.OnUnlock)
  Skill:RegisterEventCallback("End", self, self.ActivatedFinish)
  Skill:RegisterEventCallback("PreEnd", self, self.ActivatedFinish)
  local Result = RocoSkill:LoadAndPlaySkill(Skill)
  if Result ~= UE.ESkillStartResult.Success then
    self:Finish(false)
    self.State = 0
  end
end

function PetTypeInteractActionBase:OnUnlock()
end

function PetTypeInteractActionBase:ActivatedFinish()
  self:Finish(true)
  self.State = 0
end

function PetTypeInteractActionBase:SkillImpact(Name, Skill)
end

function PetTypeInteractActionBase:SkillPreProcess(Name, Skill)
  if 1 ~= self.State then
    return
  end
  self:SetSessionRecycle(false)
end

function PetTypeInteractActionBase:Finish(Success)
  self.State = 0
  if self.LoadQueue then
    self.LoadQueue:Release()
  end
  Base.Finish(self, Success)
end

function PetTypeInteractActionBase:GetUnLockSkillByType()
  local skill_path = NPCModuleEnum.UnLockSkillPathMap[self.interact_type]
  if string.IsNilOrEmpty(skill_path) then
    return nil
  end
  return string.format("/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/%s", skill_path)
end

function PetTypeInteractActionBase:GetActivatedSkill()
  local skill_path = NPCModuleEnum.UnLockSkillPathMap[self.interact_type]
  if string.IsNilOrEmpty(skill_path) then
    return nil
  end
  return string.format("/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/%s01", skill_path)
end

function PetTypeInteractActionBase:FireCallback(Success)
  local Caller = self.caller
  local Callback = self.callback
  self.caller = nil
  self.callback = nil
  if Caller and Callback then
    Callback(Caller, Success)
  end
end

return PetTypeInteractActionBase
