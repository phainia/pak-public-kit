local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local PetTypeInteractActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetTypeInteractActionBase")
local AIComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIComponent")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetTypeInteractActionBase
local PetActionLightBonfire = Base:Extend("PetActionLightBonfire")

function PetActionLightBonfire:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.interact_type = _G.Enum.SkillDamType.SDT_NONE
end

function PetActionLightBonfire:GetThrowEffectType()
  return ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
end

function PetActionLightBonfire:OnExecute()
  local RunnerView = self:GetRunnerView()
  if not RunnerView then
    self:Finish(false)
    return
  end
  local Pet = RunnerView.sceneCharacter
  if not Pet then
    self:Finish(false)
    return
  end
  local PetBaseConf
  if Pet.ThrowSession then
    PetBaseConf = _G.DataConfigManager:GetPetbaseConf(Pet.ThrowSession.petData.base_conf_id)
  elseif Pet.serverData and Pet.serverData.pet_info then
    PetBaseConf = _G.DataConfigManager:GetPetbaseConf(Pet.serverData.pet_info.pet_base_conf_id)
  end
  if not PetBaseConf then
    self:Finish(false)
    return
  end
  local DamageTypes = PetBaseConf.unit_type
  if #DamageTypes > 1 then
    self.interact_type = DamageTypes[2]
  else
    self.interact_type = DamageTypes[1]
  end
  self:SetPetAILock(true)
  self:TryDisableInteraction()
  self:DoPetTypeInteraction(self, self.PreSubmit)
end

function PetActionLightBonfire:PreSubmit()
  local Bonfire = self:GetOwnerNPCView()
  if Bonfire then
    Bonfire.OnActivateFinishDelegate:Add(self, self.OnActivate, Bonfire)
    Bonfire:SetActivatedPet(self:GetRunnerView())
  else
    self:SetPetAILock(false)
  end
  self:Submit()
end

function PetActionLightBonfire:OnActivate(Bonfire)
  self:Finish(true)
  if Bonfire then
    Bonfire.OnActivateFinishDelegate:Remove(self, self.OnActivate)
  end
end

function PetActionLightBonfire:SetPetAILock(lock)
  local sceneCharacter = self.Runner
  if not sceneCharacter then
    return
  end
  local AIComp = sceneCharacter:EnsureComponent(AIComponent)
  if not AIComp then
    return
  end
  AIComp:ForceLockForReason(lock, true, _G.AIDefines.LockReason.UNLOCK_BONFIRE)
end

function PetActionLightBonfire:ContinueWhenSuccess()
  return false
end

function PetActionLightBonfire:TryDisableInteraction()
  local OwnerNPC = self:GetOwnerNPC()
  local InteractionComponent = OwnerNPC and OwnerNPC.InteractionComponent
  if InteractionComponent and InteractionComponent.TryDisableInteraction then
    InteractionComponent:TryDisableInteraction()
  end
end

return PetActionLightBonfire
