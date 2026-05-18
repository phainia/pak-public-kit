local BattlePerformPlayerUtils = {}
local Enum = require("Data.Config.Enum")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local ProtoEnum = require("Data.PB.ProtoEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BagModuleCmd = require("NewRoco.Modules.System.Bag.BagModuleCmd")

function BattlePerformPlayerUtils.PerformChcek()
end

function BattlePerformPlayerUtils.IsCmdCriticalFailure(checkResult)
  return checkResult == BattleEnum.PerformCmdValidCheckResult.GroupIdxJump or checkResult == BattleEnum.PerformCmdValidCheckResult.RefDeadLoop
end

return BattlePerformPlayerUtils
