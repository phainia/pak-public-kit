local BattleInfoTypes = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Basic.BattleInfoTypes")
local Base = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Pet.ReversePetInfo")
local EnemyReversePetInfo = Base:Extend("EnemyReversePetInfo")

function EnemyReversePetInfo:_OnCtor(role_uin, battle_common_pet_info, battle_inside_pet_info)
  Base._OnCtor(self, role_uin, battle_common_pet_info, battle_inside_pet_info)
end

function EnemyReversePetInfo:GetInfoFlags()
  return BattleInfoTypes.EFlags.Class4
end

return EnemyReversePetInfo
