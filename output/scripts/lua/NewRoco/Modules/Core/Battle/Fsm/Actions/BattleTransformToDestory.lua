local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleTransformToDestory = BattleActionBase:Extend("BattleTransformToDestory")

function BattleTransformToDestory:OnEnter()
  self.fsm:SendEvent(BattleEvent.ExitBattle)
  self:Finish()
end

return BattleTransformToDestory
