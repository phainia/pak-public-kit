local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.BattleInfo")
local BattlePetInfo = Base:Extend("BattlePetInfo")

function BattlePetInfo:_OnCtor(pet_id, role_uin)
  self.pet_id = pet_id
  self.role_uin = role_uin
end

function BattlePetInfo:GetGuid()
  return self.pet_id
end

return BattlePetInfo
