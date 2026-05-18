local PowerDashActionBase = require("NewRoco.Modules.Core.NPC.Actions.PowerDashAction.PowerDashActionBase")
local PowerDashActionFactory = {}
PowerDashActionFactory.Registry = {
  [Enum.ActionType.ACT_TRIG_PET_INTERACT] = PowerDashActionBase,
  [Enum.ActionType.ACT_ITEM_BURST] = PowerDashActionBase,
  [Enum.ActionType.ACT_PETSHAKETREE] = PowerDashActionBase,
  [Enum.ActionType.ACT_PETCOLLORE] = PowerDashActionBase
}

function PowerDashActionFactory:Get(Option, Action)
  local ActionKlass = PowerDashActionFactory.Registry[Action.action_type]
  ActionKlass = ActionKlass or PowerDashActionBase
  return ActionKlass(Option, Action)
end

return PowerDashActionFactory
