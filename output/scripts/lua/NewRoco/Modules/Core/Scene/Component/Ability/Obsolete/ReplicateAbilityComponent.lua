local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local ReplicateAbilityComponent = Base:Extend("ReplicateAbilityComponent")

function ReplicateAbilityComponent:Ctor()
  self.Abilities = {}
end

function ReplicateAbilityComponent:Attach(owner)
  Base.Attach(self, owner)
end

function ReplicateAbilityComponent:Destroy()
  for _, v in pairs(self.Abilities) do
    local ability = v
    ability:K2_DestroyActor()
  end
  self.Abilities = nil
end

function ReplicateAbilityComponent:CastAbility(abilityId, onFinished, ...)
  local targetAbility = self:GetAbilityById(abilityId)
  if not targetAbility then
    return AbilityErrorCode.CAN_NOT_FIND_ABILITY
  end
  self.CurrentAbility = targetAbility
  if self.CurrentAbility:IsMountAbility() then
    self._curMountAbility = self.CurrentAbility
  end
  targetAbility:CastAbility(onFinished, ...)
  return AbilityErrorCode.NO_ERROR
end

function ReplicateAbilityComponent:GetAbilityById(abilityId)
  if not abilityId then
    return
  end
  self.Abilities = self.Abilities or {}
  local ability = self.Abilities[abilityId]
  if ability then
    return ability
  end
  ability = self:CreateAbility(abilityId)
  if ability then
    self.Abilities[abilityId] = ability
    return ability
  end
  return nil
end

function ReplicateAbilityComponent:CreateAbility(abilityId)
  local abilityConfig = DataConfigManager:GetSceneAbilityConf(abilityId)
  if not abilityConfig then
    Log.ErrorFormat("Can't find ability config by id %d ", abilityId)
    return nil
  end
  local skillLogicBPPath = abilityConfig.skill_bp_path
  if not string.IsNilOrEmpty(skillLogicBPPath) then
    local skillLogicClass = UE4.UNRCStatics.ResolveClass(skillLogicBPPath)
    if skillLogicClass then
      local logicAbility = UE4Helper.GetCurrentWorld():Abs_SpawnActor(skillLogicClass)
      if not logicAbility then
        Log.DebugFormat("Can't find ability with path %s ", skillLogicBPPath)
        return nil
      end
      logicAbility:Init(abilityConfig, self.owner)
      return logicAbility
    end
  end
  return nil
end

function ReplicateAbilityComponent:RemoveAbility()
end

function ReplicateAbilityComponent:SetAbilitySlotCurrentAbilityId()
end

function ReplicateAbilityComponent:ResetMainAbility()
end

function ReplicateAbilityComponent:SetAbilitySlotBlock()
end

return ReplicateAbilityComponent
