local BattleSelectTarget = NRCClass()

function BattleSelectTarget:Ctor()
  self.TargetPets = {}
  self.CurWillChoosePet = nil
  self.CurWillChooseIndex = 0
end

function BattleSelectTarget:AddSelectTarget(pet, data)
  if not UE4Helper.IsPCMode() then
    return
  end
  if self.TargetPets and not table.contains(self.TargetPets, pet) then
    table.insert(self.TargetPets, pet)
  end
  if data and data.catchGrade then
    local colorIndex = 0
    if 1 == data.catchGrade then
      colorIndex = 0
    elseif 2 == data.catchGrade then
      colorIndex = 2
    elseif 3 == data.catchGrade then
      colorIndex = 1
    end
    pet:SetSelectMarkColorIndex(colorIndex)
  end
  if not self.CurWillChoosePet then
    self:SelectNext()
  elseif self.CurWillChoosePet.card.posInField > pet.card.posInField and self.TargetPets and #self.TargetPets > 0 then
    self:SelectByIndex(#self.TargetPets)
  end
end

function BattleSelectTarget:RemoveSelectTarget(pet)
  if not UE4Helper.IsPCMode() then
    return
  end
  if self.TargetPets then
    pet:HidePreselectTips()
    if self.CurWillChoosePet and self.CurWillChoosePet == pet then
      self.CurWillChoosePet = nil
      self.CurWillChooseIndex = 0
    end
    table.removeValue(self.TargetPets, pet)
    if #self.TargetPets >= 1 then
      if not self.CurWillChoosePet then
        self:SelectNext()
      else
        self:RefreshIndex()
      end
    end
  end
end

function BattleSelectTarget:SelectNext()
  if self.TargetPets and #self.TargetPets > 0 then
    self:SelectByIndex(self.CurWillChooseIndex + 1)
  else
    self:Clear()
  end
end

function BattleSelectTarget:SelectPre()
  if self.TargetPets and #self.TargetPets > 0 then
    self:SelectByIndex(self.CurWillChooseIndex - 1)
  else
    self:Clear()
  end
end

function BattleSelectTarget:SelectByPet(pet)
  if not self.TargetPets or not table.contains(self.TargetPets, pet) then
    return
  end
  if self.CurWillChoosePet == pet then
    return
  end
  if self.CurWillChoosePet then
    self.CurWillChoosePet:HidePreselectTips()
  end
  self.CurWillChoosePet = pet
  self.CurWillChoosePet:ShowPreselectTips()
  self:RefreshIndex()
end

function BattleSelectTarget:SelectByIndex(index)
  if self.CurWillChoosePet then
    self.CurWillChoosePet:HidePreselectTips()
  end
  if index > #self.TargetPets then
    index = 1
  end
  if index <= 0 then
    index = #self.TargetPets
  end
  self.CurWillChooseIndex = index
  self.CurWillChoosePet = self.TargetPets[index]
  self.CurWillChoosePet:ShowPreselectTips()
end

function BattleSelectTarget:RefreshIndex()
  if self.TargetPets and #self.TargetPets > 0 and self.CurWillChoosePet then
    for index, pet in ipairs(self.TargetPets) do
      if pet == self.CurWillChoosePet then
        self.CurWillChooseIndex = index
      end
    end
  end
end

function BattleSelectTarget:GetCurSelectPet()
  return self.CurWillChoosePet
end

function BattleSelectTarget:EnsureCurSelect()
  if self.CurWillChoosePet then
    self.CurWillChoosePet:OnPetClick()
  end
end

function BattleSelectTarget:Clear()
  if self.TargetPets then
    for _, pet in ipairs(self.TargetPets) do
      pet:HidePreselectTips()
    end
    self.TargetPets = {}
  end
  self.CurWillChoosePet = nil
  self.CurWillChooseIndex = 0
end

return BattleSelectTarget
