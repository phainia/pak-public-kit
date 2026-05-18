PETBASE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.completeness = r.completeness
  lua_record.quality = r.quality
  lua_record.stage = r.stage
  lua_record.consume_role_hp = r.consume_role_hp
  lua_record.max_energy = r.max_energy
  _unit_type = {}
  for i = 0, #r.unit_type - 1 do
    table.insert(_unit_type, r.unit_type[i])
  end
  lua_record.unit_type = _unit_type
  lua_record.show_tag = r.show_tag
  _ecology_feature = {}
  for i = 0, #r.ecology_feature - 1 do
    table.insert(_ecology_feature, r.ecology_feature[i])
  end
  lua_record.ecology_feature = _ecology_feature
  lua_record.pet_feature = r.pet_feature
  lua_record.pet_idle_skill = r.pet_idle_skill
  lua_record.pet_lackenergy_skill = r.pet_lackenergy_skill
  lua_record.model_conf = r.model_conf
  lua_record.scene_ability = r.scene_ability
  lua_record.description = r.description
  if "" == r.description then
    lua_record.description = nil
  end
  lua_record.pet_scale = r.pet_scale
  lua_record.pictorial_book_id = r.pictorial_book_id
  lua_record.petfree_sort = r.petfree_sort
  lua_record.ban_free = r.ban_free
  _evolution_pet_id = {}
  for i = 0, #r.evolution_pet_id - 1 do
    table.insert(_evolution_pet_id, r.evolution_pet_id[i])
  end
  lua_record.evolution_pet_id = _evolution_pet_id
  lua_record.evolution_poss_level = r.evolution_poss_level
  lua_record.evolution_need_level = r.evolution_need_level
  lua_record.evolution_need_type1 = r.evolution_need_type1
  lua_record.evolution_need_data1 = r.evolution_need_data1
  lua_record.evolution_need_type2 = r.evolution_need_type2
  lua_record.evolution_need_data2 = r.evolution_need_data2
  lua_record.evolution_need_money = r.evolution_need_money
  lua_record.evolution_task_id = r.evolution_task_id
  local _evolution_need_items = {}
  for i = 0, #r.evolution_need_items - 1 do
    local r_2 = r.evolution_need_items[i]
    local lua_record_2 = {}
    lua_record_2.evolution_need_item = r_2.evolution_need_item
    lua_record_2.number = r_2.number
    table.insert(_evolution_need_items, lua_record_2)
  end
  lua_record.evolution_need_items = _evolution_need_items
  local _evolution_reward_items = {}
  for i = 0, #r.evolution_reward_items - 1 do
    local r_2 = r.evolution_reward_items[i]
    local lua_record_2 = {}
    lua_record_2.evolution_reward_item = r_2.evolution_reward_item
    lua_record_2.reward_number = r_2.reward_number
    table.insert(_evolution_reward_items, lua_record_2)
  end
  lua_record.evolution_reward_items = _evolution_reward_items
  lua_record.base_point_limit = r.base_point_limit
  lua_record.proportion_male = r.proportion_male
  _nature_ids = {}
  for i = 0, #r.nature_ids - 1 do
    table.insert(_nature_ids, r.nature_ids[i])
  end
  lua_record.nature_ids = _nature_ids
  lua_record.hp_max_race = r.hp_max_race
  lua_record.phy_attack_race = r.phy_attack_race
  lua_record.spe_attack_race = r.spe_attack_race
  lua_record.phy_defence_race = r.phy_defence_race
  lua_record.spe_defence_race = r.spe_defence_race
  lua_record.speed_race = r.speed_race
  lua_record.hp_max_first = r.hp_max_first
  lua_record.phy_attack_first = r.phy_attack_first
  lua_record.spe_attack_first = r.spe_attack_first
  lua_record.phy_defence_first = r.phy_defence_first
  lua_record.spe_defence_first = r.spe_defence_first
  lua_record.speed_first = r.speed_first
  lua_record.hit = r.hit
  lua_record.dodge = r.dodge
  lua_record.critical = r.critical
  lua_record.critical_res = r.critical_res
  lua_record.critical_dam = r.critical_dam
  lua_record.critical_dam_res = r.critical_dam_res
  lua_record.phy_dam_add = r.phy_dam_add
  lua_record.spe_dam_add = r.spe_dam_add
  lua_record.phy_dam_res = r.phy_dam_res
  lua_record.spe_dam_res = r.spe_dam_res
  lua_record.all_dam_add = r.all_dam_add
  lua_record.all_dam_res = r.all_dam_res
  lua_record.dam_wave_low = r.dam_wave_low
  lua_record.dam_wave_high = r.dam_wave_high
  lua_record.counter_bonus = r.counter_bonus
  lua_record.resist_bonus = r.resist_bonus
  lua_record.common_enhance = r.common_enhance
  lua_record.grass_enhance = r.grass_enhance
  lua_record.fire_enhance = r.fire_enhance
  lua_record.water_enhance = r.water_enhance
  lua_record.light_enhance = r.light_enhance
  lua_record.earth_enhance = r.earth_enhance
  lua_record.phantom_enhance = r.phantom_enhance
  lua_record.ice_enhance = r.ice_enhance
  lua_record.dragon_enhance = r.dragon_enhance
  lua_record.electric_enhance = r.electric_enhance
  lua_record.toxic_enhance = r.toxic_enhance
  lua_record.insect_enhance = r.insect_enhance
  lua_record.fight_enhance = r.fight_enhance
  lua_record.wing_enhance = r.wing_enhance
  lua_record.moe_enhance = r.moe_enhance
  lua_record.ghost_enhance = r.ghost_enhance
  lua_record.demon_enhance = r.demon_enhance
  lua_record.mechanic_enhance = r.mechanic_enhance
  lua_record.candy_enhance = r.candy_enhance
  lua_record.common_resist = r.common_resist
  lua_record.grass_resist = r.grass_resist
  lua_record.fire_resist = r.fire_resist
  lua_record.water_resist = r.water_resist
  lua_record.light_resist = r.light_resist
  lua_record.earth_resist = r.earth_resist
  lua_record.phantom_resist = r.phantom_resist
  lua_record.ice_resist = r.ice_resist
  lua_record.dragon_resist = r.dragon_resist
  lua_record.electric_resist = r.electric_resist
  lua_record.toxic_resist = r.toxic_resist
  lua_record.insect_resist = r.insect_resist
  lua_record.fight_resist = r.fight_resist
  lua_record.wing_resist = r.wing_resist
  lua_record.moe_resist = r.moe_resist
  lua_record.ghost_resist = r.ghost_resist
  lua_record.demon_resist = r.demon_resist
  lua_record.mechanic_resist = r.mechanic_resist
  lua_record.candy_resist = r.candy_resist
  lua_record.heal_enhance = r.heal_enhance
  lua_record.sheild_enhance = r.sheild_enhance
  lua_record.hpmax_percent = r.hpmax_percent
  lua_record.phyatk_percent = r.phyatk_percent
  lua_record.speatk_percent = r.speatk_percent
  lua_record.phydef_percent = r.phydef_percent
  lua_record.spedef_percent = r.spedef_percent
  lua_record.speed_percent = r.speed_percent
  lua_record.evolution_or_not = r.evolution_or_not
  lua_record.base_point_type = r.base_point_type
  _happy_skill_ids = {}
  for i = 0, #r.happy_skill_ids - 1 do
    table.insert(_happy_skill_ids, r.happy_skill_ids[i])
  end
  lua_record.happy_skill_ids = _happy_skill_ids
  _angry_skill_ids = {}
  for i = 0, #r.angry_skill_ids - 1 do
    table.insert(_angry_skill_ids, r.angry_skill_ids[i])
  end
  lua_record.angry_skill_ids = _angry_skill_ids
  lua_record.release = r.release
  lua_record.pet_ui_percentage = r.pet_ui_percentage
  _ui_camera_offset = {}
  for i = 0, #r.ui_camera_offset - 1 do
    table.insert(_ui_camera_offset, r.ui_camera_offset[i])
  end
  lua_record.ui_camera_offset = _ui_camera_offset
  lua_record.shadow_height = r.shadow_height
  lua_record.shadow_scale = r.shadow_scale
  lua_record.model_height = r.model_height
  lua_record.show_area = r.show_area
  _scene_ability_id = {}
  for i = 0, #r.scene_ability_id - 1 do
    table.insert(_scene_ability_id, r.scene_ability_id[i])
  end
  lua_record.scene_ability_id = _scene_ability_id
  lua_record.npc_id = r.npc_id
  lua_record.appearTime = r.appearTime
  _special_act = {}
  for i = 0, #r.special_act - 1 do
    table.insert(_special_act, r.special_act[i])
  end
  lua_record.special_act = _special_act
  lua_record.Catch_Threshold_Bonustime = r.Catch_Threshold_Bonustime
  lua_record.Catch_Threshold_Bonus = r.Catch_Threshold_Bonus
  lua_record.weight_low = r.weight_low
  lua_record.weight_high = r.weight_high
  lua_record.height_low = r.height_low
  lua_record.height_high = r.height_high
  lua_record.pet_classis_id = r.pet_classis_id
  lua_record.break_cost_item = r.break_cost_item
  lua_record.break_boss_item = r.break_boss_item
  lua_record.break_award_sort = r.break_award_sort
  _enjoy_field_type = {}
  for i = 0, #r.enjoy_field_type - 1 do
    table.insert(_enjoy_field_type, r.enjoy_field_type[i])
  end
  lua_record.enjoy_field_type = _enjoy_field_type
  _hate_field_type = {}
  for i = 0, #r.hate_field_type - 1 do
    table.insert(_hate_field_type, r.hate_field_type[i])
  end
  lua_record.hate_field_type = _hate_field_type
  PETBASE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PETBASE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("PETBASE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PETBASE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PETBASE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PETBASE_CONF then
    return PETBASE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PETBASE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PETBASE_CONF")
end

return dataTable
