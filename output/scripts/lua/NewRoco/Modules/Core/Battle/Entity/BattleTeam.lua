local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleTeam = NRCClass()

function BattleTeam:Ctor(teamEnm, battleConfig)
  self.battleConfig = battleConfig
  self.capacity = 0
  if teamEnm == BattleEnum.Team.ENUM_TEAM then
    self.capacity = battleConfig.challanger_unit_num
  elseif teamEnm == BattleEnum.Team.ENUM_ENEMY then
    self.capacity = battleConfig.bechallanger_unit_num
  end
  self.player = nil
  self.pets = {}
  self.RestPets = {}
  self.teamEnm = teamEnm
  self.npcid = nil
end

function BattleTeam:InitWithData()
  self:AddListener()
end

function BattleTeam:ReplaceByServer(playerInfo)
  if not playerInfo then
    return
  end
  if self.player then
    self.player:ReplaceByServer(playerInfo)
  end
end

function BattleTeam:AddListener()
end

function BattleTeam:RemoveListener()
end

function BattleTeam:ClearSkill()
  self:RemoveListener()
  if self.player then
    self.player:ClearSkill()
  end
  if self.pets then
    for _, v in pairs(self.pets) do
      v:ClearSkill()
    end
  end
  if self.RestPets then
    for _, v in pairs(self.RestPets) do
      v:ClearSkill()
    end
  end
end

function BattleTeam:LeaveBattle()
  self:RemoveListener()
  if self.player then
    self.player:Destroy()
    self.player = nil
  end
  self:QuitBattle()
end

function BattleTeam:QuitBattle()
  Log.Debug("BattleTeam QuitBattle")
  if self.pets then
    for _, v in pairs(self.pets) do
      local pet = v
      pet:Destroy()
    end
    self.pets = {}
  end
  if self.RestPets then
    for _, v in pairs(self.RestPets) do
      local pet = v
      pet:Destroy()
    end
    self.RestPets = {}
  end
end

function BattleTeam:GetPlayerByGuid(playerGuid)
  if self.player and self.player.guid == playerGuid then
    return self.player
  else
    return nil
  end
end

function BattleTeam:GetPlayer()
  return self.player
end

function BattleTeam:GetAllPets()
  local rsl = {}
  for _, v in pairs(self.pets) do
    table.insert(rsl, v)
  end
  return rsl
end

function BattleTeam:GetAllPetsCard()
  local rsl = {}
  for _, v in pairs(self.pets) do
    table.insert(rsl, v.card)
  end
  return rsl
end

function BattleTeam:GetPetByGuid(guid)
  for _, v in pairs(self.pets) do
    if v.guid == guid then
      return v
    end
  end
  for _, v in pairs(self.RestPets) do
    if v.guid == guid then
      return v
    end
  end
  return nil
end

function BattleTeam:GetCardByGuid(guid)
  if self.player then
    return self.player.deck:GetCardByGuid(guid)
  end
  return nil
end

function BattleTeam:GetEmptyPosCount()
  local count = 0
  for _, v in pairs(self.pets) do
    if v.health and v.health.hp > 0 and not v.card:IsBeRidOf() then
      count = count + 1
    end
  end
  local rest = self.capacity - count
  return math.abs(rest)
end

function BattleTeam:GetInBattleCards()
  return self.player.deck:GetInBattleCards()
end

function BattleTeam:GetReservesPetCards()
  return self.player.deck:GetReservesPetCards()
end

function BattleTeam:GetInBattlePets()
  local pets = {}
  for _, pet in pairs(self.pets) do
    if pet.card:IsInBattle() then
      table.insert(pets, pet)
    end
  end
  return pets
end

function BattleTeam:GetReservesPets()
  local pets = {}
  for _, pet in pairs(self.pets) do
    if not pet.card:IsInBattle() then
      table.insert(pets, pet)
    end
  end
  return pets
end

function BattleTeam:RecallPet(pet)
  if pet then
    pet:OnRecall()
    self:RemovePet(pet)
  end
end

function BattleTeam:RemovePet(pet)
  if pet then
    local index
    for i, v in pairs(self.pets) do
      if v == pet then
        index = i
      end
    end
    if index then
      self.pets[index] = nil
    end
  end
end

function BattleTeam:SpawnPet()
end

function BattleTeam:PrintGuid()
  for k, v in pairs(self.pets) do
    Log.Debug("list pets idx-guid:" .. k .. "-" .. v.guid .. ", at " .. v.index)
  end
end

function BattleTeam:TogglePetBuffsVisible(visible)
  for _, pet in pairs(self.pets) do
    if pet then
      pet:ChangeBuffVisibility(visible)
    end
  end
end

function BattleTeam:ClearBuffsEffect()
  for _, pet in pairs(self.pets) do
    if pet then
      pet.buffComponent:StopStateEffect(Enum.BuffGroupSign.BGS_LEADERDIZZY)
    end
  end
end

function BattleTeam:HideAll(petOnly)
  if not petOnly and self.player then
    self.player:HidePlayer()
  end
  for _, p in pairs(self.pets) do
    if p then
      p:HidePet()
    end
  end
end

function BattleTeam:GetDeadPetInBattle()
  for _, p in pairs(self.pets) do
    if not p or p:IsDead() then
    end
  end
end

function BattleTeam:ResumeRest(pos, isPlayEffect)
  if self.RestPets then
    for i = 1, self.capacity do
      if not pos or i == pos then
        local pet = self.RestPets[i]
        if pet then
          if pet.model then
            pet:ShowPet()
            pet:ChangeBuffVisibility(true)
            if isPlayEffect then
              pet:PlayChangeEffect()
            end
          end
          if self.pets[i] then
            self.pets[i].card:SetInBattleField(false)
            self.pets[i]:Destroy()
          end
          self.pets[i] = pet
          self.pets[i].card:SetInBattleField(true)
          self.RestPets[i] = nil
        end
      end
    end
  end
end

function BattleTeam:GetPets()
  return self.pets
end

function BattleTeam:GetRestPets()
  return self.RestPets
end

function BattleTeam:RelocatePet(battlePet, nextPosition)
  local petList = self:GetPets() or {}
  local currentPosition
  for pos, pet in pairs(petList) do
    if pet == battlePet then
      currentPosition = pos
    end
  end
  local currentPetAtNextPosition = petList[nextPosition]
  if currentPosition and nextPosition then
    petList[nextPosition] = battlePet
    if currentPetAtNextPosition then
      petList[currentPosition] = currentPetAtNextPosition
      local petCard = currentPetAtNextPosition and currentPetAtNextPosition.card
      local petName = petCard and petCard.name
      Log.Info("BattleTeam:RelocatePet \229\176\134", petName, "\228\186\164\230\141\162\229\136\176\228\189\141\231\189\174", currentPosition)
    end
  end
end

return BattleTeam
