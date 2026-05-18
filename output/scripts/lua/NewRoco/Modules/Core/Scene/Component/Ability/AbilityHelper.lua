local EventDispatcher = require("Common.EventDispatcher")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityHelper = NRCClass:Extend("AbilityHelper")

function AbilityHelper:Ctor(abilityConfig)
  EventDispatcher():Attach(self)
  self.config = abilityConfig
  local skillPath = self.config.skill_path
  if not string.IsNilOrEmpty(skillPath) then
    local g6SkillClass = UE4.UNRCStatics.ResolveClass(skillPath)
    self.g6SkillClass = g6SkillClass
  end
  local abilityType = self.config.scene_ability_type
  if abilityType == Enum.SceneAbilityType.SCAT_DASH then
    if self.config.scene_ability_type_id > 0 then
      self.typedConfig = DataConfigManager:GetSceneAbilityDashConf(self.config.scene_ability_type_id)
    end
  elseif abilityType == Enum.SceneAbilityType.SCAT_RIDE then
    if self.config.scene_ability_type_id > 0 then
      self.typedConfig = DataConfigManager:GetSceneAbilityRidingConf(self.config.scene_ability_type_id)
    end
  elseif abilityType == Enum.SceneAbilityType.SCAT_FLY then
    if self.config.scene_ability_type_id > 0 then
      self.typedConfig = DataConfigManager:GetSceneAbilityFlyingConf(self.config.scene_ability_type_id)
    end
  elseif abilityType == Enum.SceneAbilityType.SCAT_ACSEND then
    if self.config.scene_ability_type_id > 0 then
      self.typedConfig = DataConfigManager:GetSceneAbilityAscendingConf(self.config.scene_ability_type_id)
    end
  elseif abilityType == Enum.SceneAbilityType.SCAT_SLIDE and self.config.scene_ability_type_id > 0 then
    self.typedConfig = DataConfigManager:GetSceneAbilitySlidingConf(self.config.scene_ability_type_id)
  end
end

function AbilityHelper:GetIcon(caster, isBlock)
  if nil == isBlock then
    isBlock = self:IsBlock(caster)
  end
  if isBlock then
    local blockIcon = self.config.ability_block_icon
    if not string.IsNilOrEmpty(blockIcon) then
      return blockIcon
    end
  end
  return self.config.ability_icon
end

function AbilityHelper:GetPressIcon(caster)
  return self.config.ability_press_icon
end

function AbilityHelper:HandleStatus(caster, ...)
  local statusComponent = caster.statusComponent
  for _, v in pairs(self.config.add_status) do
    statusComponent:ApplyStatus(v, nil, self.config.add_sub_status, ...)
  end
  for _, v in pairs(self.config.remove_status) do
    statusComponent:RemoveStatus(v, nil, self.config.remove_sub_status, ...)
  end
end

function AbilityHelper:IsBlock(caster)
  if not caster then
    return true
  end
  local isEnvBlock = self:IsEnvBlock()
  if isEnvBlock then
    return true, AbilityErrorCode.DUNGEON_BAN
  end
  local statusComponent = caster.statusComponent
  if self.config.add_status then
    for _, v in pairs(self.config.add_status) do
      local canApply, status, opCode = statusComponent:PreApplyStatus(v, self.config.add_sub_status)
      if not canApply then
        if v == _G.Enum.WorldPlayerStatusType.WPST_MAGIC then
          return true, AbilityErrorCode.CASTING_SCENE_MAGIC
        else
          return true
        end
      end
    end
  end
  return false
end

function AbilityHelper:IsEnvBlock()
  local disable_env = 0
  for _, v in pairs(self.config.disable_env) do
    disable_env = disable_env | v
  end
  local isEnvBlock = DataModelMgr.PlayerDataModel.envMask & disable_env
  return isEnvBlock > 0
end

function AbilityHelper:CanCastAbility(caster)
  local errorCode = AbilityErrorCode.NO_ERROR
  if self:IsInCD(caster) then
    errorCode = AbilityErrorCode.IN_COOLDOWN
  end
  if errorCode == AbilityErrorCode.NO_ERROR then
    local abilityComponent = caster.abilityComponent
    errorCode = abilityComponent:CanCastAbility(self.curAbility)
  end
  return errorCode
end

function AbilityHelper:IsInCD(caster)
  if caster.isLocal then
    local abilityCD = caster.abilityComponent:GetAbilityCD(self.config.id)
    return abilityCD and abilityCD:IsInCD()
  end
  return false
end

return AbilityHelper
