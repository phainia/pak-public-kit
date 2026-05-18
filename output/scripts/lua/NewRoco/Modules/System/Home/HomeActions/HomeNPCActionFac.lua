local HomeNPCActionFac = {}
local HomeNPCActionFac = {}
HomeNPCActionFac.Registry = {
  [Enum.ActionType.ACT_HOME_PET_CHECK_IN] = require("NewRoco.Modules.System.Home.HomeActions.HomePetCheckInAction"),
  [Enum.ActionType.ACT_HOME_PET_GET_BACK] = require("NewRoco.Modules.System.Home.HomeActions.HomePetGetBackAction")
}

function HomeNPCActionFac:Get(Option, ActionType, ownerNpc)
  local ActionCls = HomeNPCActionFac.Registry[ActionType]
  if ActionCls then
    return ActionCls(Option, ActionType, ownerNpc)
  end
  return nil
end

return HomeNPCActionFac
