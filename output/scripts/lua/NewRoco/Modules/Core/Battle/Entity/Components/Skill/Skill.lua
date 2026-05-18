local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Enum = require("Data.Config.Enum")
local SkillUtils = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.SkillUtils")
local Skill = NRCClass()
Skill.config = nil

function Skill:Ctor(owner)
  self.owner = owner
  self.CD = 0
  self.curCD = 0
  self.id = 0
  self.energy = 0
  self.type = Enum.SkillActiveType.SAT_NORMAL
end

function Skill:Init(skillConfig, skillRoundData)
  self.config = skillConfig
  self.skill_id = skillConfig.id
  self.CD = skillConfig.cd_round[1]
  self.type = skillConfig.type
  self.curCD = 0
  if skillRoundData then
    self.id = skillRoundData.id
    if 0 == skillRoundData.type then
      self.type = Enum.SkillActiveType.SAT_NORMAL
    else
      self.type = skillRoundData.type
    end
    self.skillData = skillRoundData
    if self:IsCostEnergy() then
      self.energy = skillRoundData.cost_energy or 0
    else
      self.energy = skillRoundData.cost_energy or 0
    end
    self.isPassive = false
  else
    self.isPassive = true
  end
end

function Skill:RefreshByServer(roundData, curRound)
  self.skillData = roundData
  self.curCD = (roundData.cd_round or 0) - (curRound - 1)
  if self.curCD < 0 then
    self.curCD = 0
  end
  if self:IsCostEnergy() then
    self.energy = roundData.cost_energy or 0
  else
    self.energy = roundData.cost_energy or 0
  end
  self.IsRefreshData = true
end

function Skill:CanCast()
  if self.config.type == ProtoEnum.SkillActiveType.SAT_LACKENERGY or self.config.type == ProtoEnum.SkillActiveType.SAT_IDLE then
    return true
  end
  if BattleUtils.CheckIfSkillLegendaryBan(self.owner, self) then
    return false, BattleEnum.SkillFailToCastReason.IsLegendaryBan
  end
  if BattleUtils.CheckIfSkillLegendaryTimeLimitBan(self.owner, self) then
    return false, BattleEnum.SkillFailToCastReason.IsLegendaryBan
  end
  if BattleUtils.CheckIfSkillTeamBan(self.owner, self) then
    return false, BattleEnum.SkillFailToCastReason.IsTeamBan
  end
  if BattleUtils.CheckIfSkillB1FinalBan(self.owner, self) then
    return false, BattleEnum.SkillFailToCastReason.IsSeal
  end
  if BattleUtils.CheckIfSkillFeverBan(self.owner, self) then
    return false, BattleEnum.SkillFailToCastReason.IsFeverBan
  end
  if BattleUtils.CheckIfSkillTypeBan(self.owner, self) then
    return false, BattleEnum.SkillFailToCastReason.IsBan
  end
  if BattleUtils.CheckIfSkillEnvBan(self.owner, self) then
    return false, BattleEnum.SkillFailToCastReason.IsBan
  end
  if self:IsSealBan() then
    return false, BattleEnum.SkillFailToCastReason.IsSeal
  end
  if self:IsBloodEnergy() then
    if self.owner.card:GetHp() <= self.skillData.cost_hp then
      return false, BattleEnum.SkillFailToCastReason.LackHealth
    else
      if 0 ~= self.curCD then
        return false, BattleEnum.SkillFailToCastReason.CD
      end
      return true, nil
    end
  elseif 0 ~= self.curCD then
    return false, BattleEnum.SkillFailToCastReason.CD
  elseif self:IsCostEnergy() then
    if not self.owner then
      return false, BattleEnum.SkillFailToCastReason.Other
    end
    if self.owner:GetEnergy() >= self.energy then
      return true, nil
    else
      return false, BattleEnum.SkillFailToCastReason.LackEnergy
    end
  end
  return false, BattleEnum.SkillFailToCastReason.Other
end

function Skill:IsBloodEnergy()
  return self.skillData and self.skillData.display_hp
end

function Skill:IsCostEnergy()
  return self.config.energy_rule ~= Enum.EnergyRule.ER_ROLEHP
end

function Skill:IsCostRoleHp()
  return self.config.energy_rule == Enum.EnergyRule.ER_ROLEHP
end

function Skill:GetInitEnergy()
  return self.config.energy_cost[1]
end

function Skill:IsBan()
  return BattleUtils.CheckIfSkillTypeBan(self.owner, self)
end

function Skill:IsLegendaryBan()
  return BattleUtils.CheckIfSkillLegendaryBan(self.owner, self)
end

function Skill:IsLegendaryTimeLimitBan()
  return BattleUtils.CheckIfSkillLegendaryTimeLimitBan(self.owner, self)
end

function Skill:IsTeamBan()
  return BattleUtils.CheckIfSkillTeamBan(self.owner, self)
end

function Skill:IsFeverBan()
  return BattleUtils.CheckIfSkillFeverBan(self.owner, self)
end

function Skill:IsEnvBan()
  return BattleUtils.CheckIfSkillEnvBan(self.owner, self)
end

function Skill:IsSealBan()
  return self.skillData.state_tips and self.skillData.state_tips > 0
end

function Skill:GetCastCount()
  if self.skillData and self.skillData.cast_cnt then
    return self.skillData.cast_cnt
  else
    return 1
  end
end

function Skill:GetEnergyChangeValue()
  if not self.skillData or not self.config then
    return nil
  end
  return self.skillData.cost_energy - self.config.energy_cost[1]
end

function Skill:IsFeverSkill()
  if self.skillData and self.skillData.fever_state == true then
    return true
  end
  return false
end

function Skill:IsNormalSkill()
  if self.config.type ~= Enum.SkillActiveType.SAT_LACKENERGY and self.config.type ~= Enum.SkillActiveType.SAT_IDLE and self.config.type ~= Enum.SkillActiveType.SAT_GLOBAL then
    return true
  end
  return false
end

function Skill:IsShowRestraint()
  if self.skillData.restraint_types then
    return true
  else
    return false
  end
end

function Skill:GetHighestDamage()
  if self.skillData and self.skillData.damage_params then
    local damage = 0
    for _, v in ipairs(self.skillData.damage_params) do
      if damage < v.damage_param then
        damage = v.damage_param
      end
    end
    return damage
  end
end

function Skill:GetDamageByPetId(petId)
  if self.skillData and self.skillData.damage_params then
    for _, v in ipairs(self.skillData.damage_params) do
      if v.pet_id == petId then
        return v.damage_param
      end
    end
  end
  return 0
end

function Skill:GetRestraint()
  return BattleUtils:GetSkillRestraint(self.skillData)
end

function Skill:GetRestraintByPetId(petId)
  return BattleUtils:GetSkillRestraintByPetId(self.skillData, petId)
end

function Skill:GetSkillconfig()
  return self.config
end

function Skill:GetUniqueExtraDamageType()
  local _ExtraDamageType = self.skillData.extra_damage_type
  return SkillUtils.GetUniqueExtraDamageTypes(_ExtraDamageType)
end

function Skill:IsDisableConfDamageType()
  return self.skillData.disable_conf_dam_type
end

return Skill
