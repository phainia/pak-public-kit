local PlayerActionFactory = {}
PlayerActionFactory.Registry = {
  [Enum.ActionType.ACT_NONE] = require("NewRoco.Modules.Core.NPC.Actions.PlayerActions.PlayerActionHUDCard"),
  [Enum.ActionType.ACT_RELATION_PREPARE] = require("NewRoco.Modules.Core.NPC.Actions.PlayerActions.PlayerActionAcceptInvite"),
  [Enum.ActionType.ACT_INTERACTION_CIFU_PREPARE] = require("NewRoco.Modules.Core.NPC.Actions.PlayerActions.PlayerActionAcceptBlessingInvite"),
  [Enum.ActionType.ACT_RELATION_ACCEPT] = require("NewRoco.Modules.Core.NPC.Actions.PlayerActions.PlayerActionRelationHUDCard")
}

function PlayerActionFactory:Get(Option, Action)
  local ActionKlass = PlayerActionFactory.Registry[Action.action_type]
  if ActionKlass then
    return ActionKlass(Option, Action)
  end
end

return PlayerActionFactory
