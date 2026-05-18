local BattleDebugger = require("NewRoco.Modules.Core.Battle.Debugger.BattleDebugger_Declare")
require("NewRoco.Modules.Core.Battle.Debugger.BattleDebugger_ToString_Utils")

function BattleDebugger:ToString_BattleBuffChange(buff_change)
  return string.format("[buff_change] caster_id=%s, target_id=%s, buff_id=%s, type=%s, buff_info=%s", self:GetName_PetName(buff_change.caster_id), self:GetName_PetName(buff_change.target_id), self:GetName_BuffId(buff_change.buff_id), self:ToString_BuffChangeType(buff_change.type), self:ToString_BattleBuffInfo(buff_change.buff_info))
end

function BattleDebugger:ToString_BuffId(buff_id)
  return tostring(buff_id)
end

function BattleDebugger:GetName_BuffId(buff_id)
  local conf = _G.DataConfigManager:GetBuffConf(buff_id)
  if conf then
    return conf.name
  else
    return string.format("no_conf(%d)", buff_id)
  end
end

function BattleDebugger:GetName_PetName(pet_id)
  return tostring(pet_id)
end

function BattleDebugger:ToString_BuffChangeType(type)
  return self:ToString_ProtoEnum_Any("BuffChangeType", type)
end

function BattleDebugger:ToString_BattleBuffInfo(buff_info)
  return string.format("ToString_BattleBuffInfo(%s)", tostring(buff_info))
end

return BattleDebugger
