local WorldCombatActionFactory = {}
WorldCombatActionFactory.Registry = {
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_SKILL_CAST] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionSkillCast"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_SKILL_END] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionSkillEnd"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_CRUSH] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionCrush"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_Rotation] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionRotate"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_Hit] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionHit"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_LookAt] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionLookAt"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_CRUSH_END] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionCrushEnd"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_MISSILE_LAUNCH] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionMissileLaunch"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_MISSILE_DESTROY] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionMissileDestroy"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_MISSILE_STOP_TRACE] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionMissileStopTrace"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_JUMP] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionJump"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_JUMP_CANCEL] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionJumpCancel"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_RCD] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionRcd"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_JUMP_END] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionJumpEnd"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_RCD_END] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionRcdEnd"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_SHOW_HIDE_CHANGE] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionShowHideChange"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_LERP_POS_DIR] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionPosDirLerp"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_ANIM_CANCEL] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionAnimCancel"),
  [Enum.ActionType.ACT_DOTS_WORLD_COMBAT_SELECT_POS] = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionSelectPos")
}
WorldCombatActionFactory.ActionCachePool = {}
WorldCombatActionFactory.ReConnectActionType2SkillActionType = {
  [ProtoEnum.SkillActionType.WorldCombatDotsSkillCrush] = Enum.ActionType.ACT_DOTS_WORLD_COMBAT_CRUSH,
  [ProtoEnum.SkillActionType.WorldCombatDotsSkillJump] = Enum.ActionType.ACT_DOTS_WORLD_COMBAT_JUMP,
  [ProtoEnum.SkillActionType.WorldCombatDotsSkillRcd] = Enum.ActionType.ACT_DOTS_WORLD_COMBAT_RCD,
  [ProtoEnum.SkillActionType.WorldCombatDotsSkillMissile] = Enum.ActionType.ACT_DOTS_WORLD_COMBAT_MISSILE_LAUNCH,
  [ProtoEnum.SkillActionType.WorldCombatDotsSkillShowHide] = Enum.ActionType.ACT_DOTS_WORLD_COMBAT_SHOW_HIDE_CHANGE
}

function WorldCombatActionFactory:Get(Runner, ActionType, ServerInfo, skillId)
  if not ActionType then
    return nil
  end
  local ActionInst = WorldCombatActionFactory.ActionCachePool[ActionType]
  if ActionInst then
    ActionInst:InitAttr(Runner, ServerInfo.skill_id, ActionType, ServerInfo)
    return ActionInst
  end
  local ActionKlass = WorldCombatActionFactory.Registry[ActionType]
  if not ActionKlass then
    local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
    ActionKlass = WorldCombatActionBase
  end
  return ActionKlass(Runner, ServerInfo and ServerInfo.skill_id or skillId, ActionType, ServerInfo)
end

function WorldCombatActionFactory:DispatchActionOnReconnect(Runner, skillId, actionData)
  local worldCombatAction = WorldCombatActionFactory:Get(Runner, WorldCombatActionFactory.ReConnectActionType2SkillActionType[actionData.skill_action_type], nil, skillId)
  if not worldCombatAction then
    return
  end
  worldCombatAction:ProcessPerformOnReConnect(skillId, actionData)
end

function WorldCombatActionFactory:Recycle(Action)
  WorldCombatActionFactory.ActionCachePool[Action.ActionType] = Action
end

return WorldCombatActionFactory
