local BattleInfoTypes = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Basic.BattleInfoTypes")
local Base = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Pet.ReversePetInfo")
local EnemyBattlePlayerInfo = Base:Extend("EnemyBattlePlayerInfo")

function EnemyBattlePlayerInfo:GetInfoFlags()
  return BattleInfoTypes.EFlags.Class3
end

return EnemyBattlePlayerInfo
