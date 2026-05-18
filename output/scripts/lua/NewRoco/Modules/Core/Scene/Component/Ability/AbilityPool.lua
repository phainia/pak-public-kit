local InstancePool = require("Utils.InstancePool")
local AbilityPool = Class("AbilityPool")
local BASE_ABILITY_PATH = "NewRoco.Modules.Core.Scene.Component.Ability."

function AbilityPool:Ctor()
  self._pools = {}
end

function AbilityPool:GetFromPool(abilityId, owner)
  local abilityConfig = DataConfigManager:GetSceneAbilityConf(abilityId)
  if abilityConfig then
    local poolKey = abilityConfig.id
    local pool = self._pools[poolKey]
    if not pool then
      pool = InstancePool(poolKey, nil, 0)
      self._pools[poolKey] = pool
    end
    local abilityInstance = pool:Get(false, owner)
    if not abilityInstance then
      abilityInstance = self:CreateAbility(abilityConfig)
      if abilityInstance and abilityInstance.AwakeFromPool then
        abilityInstance:AwakeFromPool(owner)
      end
    end
    Log.DebugFormat("AbilityPool GetFromPool %s, remain %d", poolKey, pool:Count())
    return abilityInstance
  end
end

function AbilityPool:ReturnToPool(ability)
  if not ability then
    Log.Error("Try return a nil ability to pool")
    return
  end
  local poolKey = ability.helper.config.id
  local pool = self._pools[poolKey]
  if not pool then
    pool = InstancePool(poolKey, nil, 0)
    self._pools[poolKey] = pool
  end
  pool:Recycle(ability)
  Log.DebugFormat("AbilityPool ReturnToPool %s, remain %d", poolKey, pool:Count())
end

function AbilityPool:CreateAbility(abilityConfig)
  local skillLogicBPPath = abilityConfig.skill_bp_path
  if not string.IsNilOrEmpty(skillLogicBPPath) then
    local skillLogicClass = UE4.UNRCStatics.ResolveClass(skillLogicBPPath)
    local CurrentWorld = UE4Helper.GetCurrentWorld()
    if skillLogicClass and CurrentWorld then
      local logicAbility = CurrentWorld:Abs_SpawnActor(skillLogicClass)
      if not logicAbility then
        Log.DebugFormat("Can't find ability with path %s ", skillLogicBPPath)
        return nil
      end
      if logicAbility.Init then
        logicAbility:Init(abilityConfig)
      else
        Log.DebugFormat("Ability has no Init func path %s ", skillLogicBPPath)
      end
      return logicAbility
    end
  elseif not string.IsNilOrEmpty(abilityConfig.skill_lua_path) then
    local skillLuaPath = BASE_ABILITY_PATH .. abilityConfig.skill_lua_path
    local skillClass = require(skillLuaPath)
    local logicAbility = skillClass()
    logicAbility:Init(abilityConfig)
    return logicAbility
  end
  return nil
end

function AbilityPool:ClearAll()
end

return AbilityPool
