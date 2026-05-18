local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local RecoverRideStatusAction = BattleActionBase:Extend("RecoverRideStatusAction")
FsmUtils.MergeMembers(BattleActionBase, RecoverRideStatusAction, {})

function RecoverRideStatusAction:OnEnter()
  self:Finish()
end

return RecoverRideStatusAction
