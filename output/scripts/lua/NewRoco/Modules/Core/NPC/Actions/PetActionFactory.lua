local PetActionFactory = {}
PetActionFactory.Registry = {
  [Enum.ActionType.ACT_PET_UNLOCK_NPC] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionUnlock"),
  [Enum.ActionType.ACT_PETSHAKETREE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionTree"),
  [Enum.ActionType.ACT_PETCOLLORE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionOre"),
  [Enum.ActionType.ACT_PET_TRIG_ENERGY] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionPotentialEnergy"),
  [Enum.ActionType.ACT_PET_SWITCH_TORCH] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionLightTorch"),
  [Enum.ActionType.ACT_PET_CREATE_FRUIT] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionSaplingGrow"),
  [Enum.ActionType.ACT_PET_DESTROY_THRON] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionUnlockThorns"),
  [Enum.ActionType.ACT_THROW_LIGHT_BONFIRE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionLightBonfire"),
  [Enum.ActionType.ACT_PET_TRIGGER_SWITCH] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionInstanceTriggerSwitch"),
  [Enum.ActionType.ACT_PET_WALL] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionWall"),
  [Enum.ActionType.ACT_PET_ADD_PROPERTY_TYPE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionAddPropertyType"),
  [Enum.ActionType.ACT_TRIG_PET_INTERACT] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionCommon"),
  [Enum.ActionType.ACT_PET_NPC_EVENT] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionMark"),
  [Enum.ActionType.ACT_PET_NPC_LIKE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionBubble"),
  [Enum.ActionType.ACT_PET_NPC_SURPRISE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionBubble"),
  [Enum.ActionType.ACT_PET_NPC_TROUBLE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionBubble"),
  [Enum.ActionType.ACT_PET_MIMIC] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionMimic"),
  [Enum.ActionType.ACT_PET_STRENGTH_TEST] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionForceTester"),
  [Enum.ActionType.ACT_PET_POISONOUS_GRASS] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionPoisonousGrass"),
  [Enum.ActionType.ACT_PET_FLAME_STONE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionHuoYanShi"),
  [Enum.ActionType.ACT_PET_REVIVE_NUTS] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionReviveNuts"),
  [Enum.ActionType.ACT_PET_CHANGE_WEATHER] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionRainMoai"),
  [Enum.ActionType.ACT_PET_NAUTY_CHEST] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionNaughtyChest"),
  [Enum.ActionType.ACT_PET_NORMAL] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionBatchCollect"),
  [Enum.ActionType.ACT_PET_DIG_LIGHTSPOT] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionDigLightSpot"),
  [Enum.ActionType.ACT_TRIGGER_OPTION_ACTION] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionTriggerOption"),
  [Enum.ActionType.ACT_PET_SWITCH_GENERAL] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionSwitchGeneral"),
  [Enum.ActionType.ACT_PET_DESTROY] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionDestroy"),
  [Enum.ActionType.ACT_CREATE_NPC] = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase"),
  [Enum.ActionType.ACT_AWARD] = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase"),
  [Enum.ActionType.ACT_PET_UNLOCK_NPC_AND_RECORD_TYPE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionUnlockAddEnergy"),
  [Enum.ActionType.ACT_HOME_PLANT_PET_WATER] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionInteractPlant"),
  [Enum.ActionType.ACT_HOME_PLANT_PET_MANURE] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionInteractPlant"),
  [Enum.ActionType.ACT_HOME_OWNER_PET_PICK] = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionHomeOwnerPick")
}

function PetActionFactory:IsSupportedAction(Type)
  Type = Type or Enum.ActionType.ACT_NONE
  return PetActionFactory.Registry[Type] ~= nil
end

function PetActionFactory:MakeWithType(Type, dontWarn, ...)
  local ActionKlass = PetActionFactory.Registry[Type]
  if not ActionKlass then
    if not dontWarn then
      local Name = table.getKeyName(Enum.ActionType, Type)
      Log.Error("\229\174\162\230\136\183\231\171\175\229\176\154\230\156\170\229\174\158\231\142\176\232\191\153\228\184\170Action!\239\188\129", Name, Type)
    end
    return nil
  end
  return ActionKlass(...)
end

function PetActionFactory:GetAction(Option, Action, dontWarn)
  local ActionType = Action.action_type
  return PetActionFactory:MakeWithType(ActionType, dontWarn, Option, Action, Option.optionInfo.cur_action_info)
end

function PetActionFactory:Get(Option, dontWarn)
  local Action = Option.config.pet_action
  local ActionInstance = PetActionFactory:GetAction(Option, Action, dontWarn)
  if ActionInstance then
    ActionInstance.ConfType = ProtoEnum.ClientOperationConfType.COCT_NPC_OPTION_CONF
    ActionInstance.ConfID = Option.config.id
  end
  return ActionInstance
end

function PetActionFactory:GetForWild(Option, dontWarn)
  local Action = Option.config.wild_action
  if not Action.action_type then
    return nil
  end
  local ActionInstance = PetActionFactory:GetAction(Option, Action, dontWarn)
  if ActionInstance then
    ActionInstance.ConfType = ProtoEnum.ClientOperationConfType.COCT_NPC_WILD_OPTION_CONF or 4
    ActionInstance.ConfID = Option.config.id
  end
  return ActionInstance
end

return PetActionFactory
