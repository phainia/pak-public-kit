require("UnLuaEx")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local ProtoEnum = require("Data.PB.ProtoEnum")
local SkillPlayer = require("NewRoco.Modules.Core.Battle.Common.SkillPlayer")
local BattlePetController = NRCClass()

function BattlePetController:Ctor()
  self.isDestroyed = false
  self.isHighlight = false
  self.highlightSkill = nil
end

function BattlePetController:Attach(pet)
  function pet.ChangeOperation(_self, path)
    if _self.battlePetController then
      _self.battlePetController:ChangeOperation(path)
    end
  end
  
  function pet.BindBattlePet(_self, battlePet)
    if _self.battlePetController then
      _self.battlePetController:BindBattlePet(battlePet)
    end
  end
  
  function pet.UnbindBattlePet(_self)
    if _self.battlePetController then
      _self.battlePetController:UnbindBattlePet()
    end
  end
  
  self.pet = pet
end

function BattlePetController:BindBattlePet(battlePet)
  if not battlePet then
    Log.Error("BattlePetController:BindBattlePet battlePet is nil")
    return
  end
  if self.battlePet then
    if self.battlePet == battlePet then
      return
    else
      self:UnbindBattlePet()
    end
  end
  self.battlePet = battlePet
  self:AddListener()
  self.pet.IsInBattle = true
end

function BattlePetController:UnbindBattlePet()
  self:RemoveListener()
  self.battlePet = nil
end

function BattlePetController:ReceiveBeginPlay()
  local params = {}
  params.pet = self.pet
  BattleResourceManager:LoadActorAsync(self, _G.UEPath.BP_BattlePetComponents, UE4.FTransform(UE4.FQuat(), UE4.FVector(0, 0, 0)), params, self.OnActorLoad)
end

function BattlePetController:OnActorLoad(actor)
  local battlePetComponents = actor
  battlePetComponents:K2_AttachRootComponentToActor(self.pet)
  if battlePetComponents.BuffOffset then
    battlePetComponents.BuffOffset:K2_AttachTo(self.pet:GetComponentByClass(UE4.USkeletalMeshComponent), "Root")
  end
  self.battlePetComponents = battlePetComponents
  self.transparentSkill = SkillPlayer(self.pet.RocoSkill, self.pet, BattleConst.PetTransparent.Sequence)
end

return BattlePetController
