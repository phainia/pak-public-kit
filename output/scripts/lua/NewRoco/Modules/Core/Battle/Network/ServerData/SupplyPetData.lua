local SupplyPetData = NRCClass()

function SupplyPetData:Ctor()
  self.playerSupplyPetReq = {}
  self.enemySupplyPetReq = {}
end

function SupplyPetData:Clear()
  self.playerSupplyPetReq = {}
  self.enemySupplyPetReq = {}
end

function SupplyPetData:IsEmpty()
  if 0 == #self.playerSupplyPetReq and 0 == #self.enemySupplyPetReq then
    return true
  end
  return false
end

return SupplyPetData
