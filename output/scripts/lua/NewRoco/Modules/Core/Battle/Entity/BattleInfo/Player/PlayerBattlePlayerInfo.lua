local BattleInfoTypes = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Basic.BattleInfoTypes")
local Base = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Pet.ReversePetInfo")
local PlayerBattlePlayerInfo = Base:Extend("PlayerBattlePlayerInfo")

function PlayerBattlePlayerInfo:GetInfoFlags()
  return BattleInfoTypes.EFlags.Class2
end

return PlayerBattlePlayerInfo
