local BattlePetStateLogic = NRCClass()

function BattlePetStateLogic:Ctor(battlePet)
  self.battlePet = battlePet
  self.battlePetState = battlePet.card.petState
end

function BattlePetStateLogic:PlayAnimation(animName)
end

return BattlePetStateLogic
