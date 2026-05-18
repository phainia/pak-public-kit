local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleInfoTypes = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Basic.BattleInfoTypes")
local Base = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Pet.BattlePetInfo")
local ReversePetInfo = Base:Extend("ReversePetInfo")
local _nullable_field = table.createNullableTable()

function ReversePetInfo:_OnCtor(role_uin, battle_common_pet_info, battle_inside_pet_info)
  Base._OnCtor(self, battle_inside_pet_info.pet_id, role_uin)
  self:_OnModify(battle_common_pet_info, battle_inside_pet_info)
end

function ReversePetInfo:_OnModify(battle_common_pet_info, battle_inside_pet_info)
  self.battle_common_pet_info = battle_common_pet_info
  self.battle_inside_pet_info = battle_inside_pet_info
end

function ReversePetInfo:IsAlive()
  local hp = PetUtils.GetHP(self.battle_inside_pet_info)
  return hp > 0
end

return ReversePetInfo
