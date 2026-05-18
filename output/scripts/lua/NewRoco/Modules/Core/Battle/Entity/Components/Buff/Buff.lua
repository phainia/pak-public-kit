local BuffUtils = require("NewRoco.Modules.Core.Battle.Entity.Components.Buff.BuffUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Buff = NRCClass()

function Buff:Ctor(owner)
  self.owner = owner
  self.config = nil
  self.id = nil
  self.name = nil
  self.type = nil
  self.cover_id = nil
  self.mutex = nil
  self.add_max = nil
  self.desc = nil
  self.icon = nil
  self.res_id = nil
  self.buff_group_reduce = nil
  self.is_clean_when_rest = nil
  self.is_hide = nil
  self.model = nil
  self.appendRound = 1
  self.stack = 0
  self.caster = nil
  self.desc_param_1 = nil
  self.desc_param_2 = nil
end

function Buff:InitByInfo(info)
  if not info or not info.buff_id then
    Log.ErrorFormat("BattleBuffInfo buff id is nil")
    return false
  end
  self.config = _G.DataConfigManager:GetBuffConf(info.buff_id)
  if not self.config then
    Log.ErrorFormat("zgx \233\156\128\232\166\129\231\173\150\229\136\146\230\163\128\230\159\165buffID %d \230\152\175\229\144\166\231\188\186\229\176\145\233\133\141\231\189\174  \230\136\150\232\128\133\228\189\191\231\148\168\230\156\128\230\150\176\231\154\132\229\174\162\230\136\183\231\171\175\231\137\136\230\156\172\239\188\129\239\188\129", info.buff_id)
    return false
  end
  self.id = self.config.id
  self.name = self.config.name
  self.type = self.config.type
  self.cover_id = self.config.cover_id
  self.add_max = self.config.add_max
  self.desc = self.config.desc
  self.buff_group_reduce = self.config.buff_group_reduce
  self.is_clean_when_rest = self.config.is_clean_when_rest
  self:Refresh(info)
  return true
end

function Buff:Refresh(Info)
  if not Info then
    return
  end
  self.caster = Info.caster_id
  if Info.append_round then
    self.appendRound = Info.append_round
  end
  self.stack = Info.stack
  self.desc_param_1 = Info.desc_param_1
  self.desc_param_2 = Info.desc_param_2
  self.buffInfo = Info
end

function Buff:IsDebuff()
  return BuffUtils.IsDebuff(self.config)
end

function Buff:GetBuffRemainTime()
  return BuffUtils.GetBuffRemainTime(self.id, self.appendRound)
end

function Buff:HasGroupSign(bgs)
  if self.config then
    for _, sign in ipairs(self.config.buff_groupsigns) do
      if sign == bgs then
        return true
      end
    end
  end
  return false
end

function Buff:NeedShow()
  local hasDes = self.config.desc ~= nil
  local showByCfg = BuffUtils.IsShowBuffOrLetter(self.owner.card, self.config)
  local showByServer = not self.buffInfo.is_hidden
  local isOwnerCheerPet = self.owner.card:IsCheerPet()
  return hasDes and showByCfg and showByServer and not isOwnerCheerPet
end

function Buff:GetShowStack()
  local hiddenStack = self.buffInfo.hidden_stack or 0
  return self.buffInfo.stack - hiddenStack
end

function Buff:GetSortOrder()
  if not self.config then
    return 0
  end
  if self.config.buff_list_priority >= 5 then
    return 1
  end
  local clusterIdx = 0
  if self.config.type == Enum.BuffGroupType.BGT_AREA then
    clusterIdx = 3
  else
    for _, sign in ipairs(self.config.buff_groupsigns) do
      if sign == Enum.BuffGroupSign.BGS_SPE then
        clusterIdx = 1
        break
      elseif sign == Enum.BuffGroupSign.BGS_ITEM then
        clusterIdx = 2
        break
      end
    end
  end
  if 0 == clusterIdx then
    clusterIdx = 4
  end
  local groupIdx = clusterIdx * 3 + (self.config.type or Enum.BuffGroupType.BGT_OTHER)
  return groupIdx
end

function Buff:CheckHasStuckBuff(damage_type)
  local isStuckNoneType = false
  local isStuckOtherType = false
  local isStuckAllType = false
  for i = 1, #self.config.buff_can_react do
    if 1 == self.config.buff_can_react[i] then
      isStuckNoneType = true
    end
    if 2 == self.config.buff_can_react[i] then
      isStuckOtherType = true
    end
    if 3 == self.config.buff_can_react[i] then
      isStuckAllType = true
    end
  end
  if isStuckAllType then
    return true
  elseif isStuckNoneType or isStuckOtherType then
    if isStuckNoneType and damage_type == Enum.DamageType.DT_NONE then
      return true
    elseif isStuckOtherType and damage_type ~= Enum.DamageType.DT_NONE then
      return true
    elseif isStuckNoneType and isStuckOtherType then
      return true
    elseif (isStuckNoneType or isStuckOtherType) and -1 == damage_type then
      return true
    end
  end
  return false
end

function Buff:GetDefaultSkillPath(buffSign)
  if self:CheckBuffSign(buffSign) then
    for i = 1, 3 do
      local resId = "res_id_" .. i - 1
      if self.config[resId] then
        return self.config[resId]
      end
    end
  end
  return nil
end

function Buff:CheckBuffSign(buffSign)
  for _, sign in ipairs(self.config.buff_groupsigns) do
    if sign == buffSign then
      return true
    end
  end
  return false
end

function Buff:GetBuffBaseOrder()
  if not (self.config and self.config.buff_base_ids) or #self.config.buff_base_ids <= 0 then
    Log.Warning("Buff:GetBuffBaseOrder Config Error ", self.id)
    return
  end
  local buffBaseConf = _G.DataConfigManager:GetBuffbaseConf(self.config.buff_base_ids[1])
  if not buffBaseConf then
    return
  end
  return buffBaseConf.buffbase_order
end

return Buff
