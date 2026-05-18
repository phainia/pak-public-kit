SKILL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  lua_record.flavor_text = r.flavor_text
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.desc = r.desc
  if "" == r.desc then
    lua_record.desc = nil
  end
  if r.flavor_text == "" then
    lua_record.flavor_text = nil
  end
  lua_record.type = r.type
  lua_record.skill_dam_type = r.skill_dam_type
  lua_record.is_special_skill = r.is_special_skill
  lua_record.damage_type = r.damage_type
  lua_record.contact_type = r.contact_type
  lua_record.combine_passive_id = r.combine_passive_id
  lua_record.skill_priority = r.skill_priority
  lua_record.cost_value = r.cost_value
  lua_record.energy_rule = r.energy_rule
  lua_record.energy_cost = r.energy_cost
  lua_record.ultimate_energy_gain = r.ultimate_energy_gain
  lua_record.skill_energy_gain = r.skill_energy_gain
  lua_record.target_type = r.target_type
  lua_record.client_target_type = r.client_target_type
  lua_record.skill_impact_type = r.skill_impact_type
  lua_record.target_count = r.target_count
  lua_record.cd_round = r.cd_round
  lua_record.unused_round = r.unused_round
  lua_record.dam_para = r.dam_para
  lua_record.spe_skill_type = r.spe_skill_type
  lua_record.hit_para = r.hit_para
  lua_record.critical_hit_para = r.critical_hit_para
  lua_record.dam_add = r.dam_add
  lua_record.repeat_attack_time_low = r.repeat_attack_time_low
  lua_record.repeat_attack_time_high = r.repeat_attack_time_high
  lua_record.repeat_attack_time_prob = r.repeat_attack_time_prob
  local _skill_result = {}
  for i = 0, #r.skill_result - 1 do
    local r_2 = r.skill_result[i]
    local lua_record_2 = {}
    lua_record_2.result_type = r_2.result_type
    lua_record_2.effect_id = r_2.effect_id
    lua_record_2.result_target_type = r_2.result_target_type
    lua_record_2.cast_moment = r_2.cast_moment
    lua_record_2.cast_judge = r_2.cast_judge
    lua_record_2.success_rate = r_2.success_rate
    lua_record_2.result_target_count = r_2.result_target_count
    lua_record_2.buff_level_rule = r_2.buff_level_rule
    lua_record_2.buff_group_level = r_2.buff_group_level
    lua_record_2.is_glue_skill = r_2.is_glue_skill
    table.insert(_skill_result, lua_record_2)
  end
  lua_record.skill_result = _skill_result
  lua_record.res_id = r.res_id
  if "" == r.res_id then
    lua_record.res_id = nil
  end
  lua_record.icon = r.icon
  if "" == r.icon then
    lua_record.icon = nil
  end
  lua_record.teammate_res_id = r.teammate_res_id
  if "" == r.teammate_res_id then
    lua_record.teammate_res_id = nil
  end
  lua_record.field_belong = r.field_belong
  _target_field = {}
  for i = 0, #r.target_field - 1 do
    table.insert(_target_field, r.target_field[i])
  end
  lua_record.target_field = _target_field
  _target_field_layer = {}
  for i = 0, #r.target_field_layer - 1 do
    table.insert(_target_field_layer, r.target_field_layer[i])
  end
  lua_record.target_field_layer = _target_field_layer
  _field_skill = {}
  for i = 0, #r.field_skill - 1 do
    table.insert(_field_skill, r.field_skill[i])
  end
  lua_record.field_skill = _field_skill
  _field_type = {}
  for i = 0, #r.field_type - 1 do
    table.insert(_field_type, r.field_type[i])
  end
  lua_record.field_type = _field_type
  _field_layer = {}
  for i = 0, #r.field_layer - 1 do
    table.insert(_field_layer, r.field_layer[i])
  end
  lua_record.field_layer = _field_layer
  _field_energy_reduse = {}
  for i = 0, #r.field_energy_reduse - 1 do
    table.insert(_field_energy_reduse, r.field_energy_reduse[i])
  end
  lua_record.field_energy_reduse = _field_energy_reduse
  lua_record.is_show = r.is_show
  SKILL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SKILL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SKILL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SKILL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SKILL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SKILL_CONF then
    return SKILL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SKILL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SKILL_CONF")
end

return dataTable
