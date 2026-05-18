local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Enum = require("Data.Config.Enum")
local BattlePvpInitAction = BattleActionBase:Extend("BattleInitAction")

function BattlePvpInitAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
end

function BattlePvpInitAction:OnEnter()
  self.fsm:SendEvent(BattleEvent.EnterPVPEnter, self)
  self:Finish()
end

return BattlePvpInitAction
