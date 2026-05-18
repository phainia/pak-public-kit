local SceneAttackEnum = require("NewRoco.Modules.Core.Scene.Component.Attack.SceneAttackEnum")
local SceneAttackRegistry = {
  aims = {
    [SceneAttackEnum.AimType.Simple] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackAimSimple"),
    [SceneAttackEnum.AimType.Laser] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackAimLaser"),
    [SceneAttackEnum.AimType.Ground] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackAimGround")
  },
  actions = {
    [SceneAttackEnum.ActionType.NearbyHit] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionNearbyHit"),
    [SceneAttackEnum.ActionType.Laser] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionLaser"),
    [SceneAttackEnum.ActionType.WaterSkill] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionWater"),
    [SceneAttackEnum.ActionType.FireSkill] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionFire"),
    [SceneAttackEnum.ActionType.Crush] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionCrush"),
    [SceneAttackEnum.ActionType.FixPos] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionFixPosCommon"),
    [SceneAttackEnum.ActionType.FixPosImme] = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionFixPosImme")
  }
}

function SceneAttackRegistry.GetAim(type)
  if not type then
    return nil
  end
  local Klass = SceneAttackRegistry.aims[type]
  if not Klass then
    return nil
  end
  return Klass()
end

function SceneAttackRegistry.GetAction(type)
  if not type then
    return nil
  end
  local Klass = SceneAttackRegistry.actions[type]
  if not Klass then
    return nil
  end
  return Klass()
end

return SceneAttackRegistry
