local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local ProtoEnum = require("Data.PB.ProtoEnum")
local BattlePlayerPredictionInfo = NRCClass()

function BattlePlayerPredictionInfo:Ctor(playerID)
  self.playerID = playerID
end

return BattlePlayerPredictionInfo
