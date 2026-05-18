MONSTER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.base_id = r.base_id
  lua_record.level = r.level
  _new_level = {}
  for i = 0, #r.new_level - 1 do
    table.insert(_new_level, r.new_level[i])
  end
  lua_record.new_level = _new_level
  lua_record.catch_exp = r.catch_exp
  lua_record.catch_pet_back_level = r.catch_pet_back_level
  lua_record.active_skill1 = r.active_skill1
  lua_record.active_skill2 = r.active_skill2
  lua_record.active_skill3 = r.active_skill3
  lua_record.active_skill4 = r.active_skill4
  lua_record.gender = r.gender
  lua_record.nature_id = r.nature_id
  lua_record.catch_difficulty = r.catch_difficulty
  lua_record.Catch_difficulty_OverThreshold = r.Catch_difficulty_OverThreshold
  lua_record.Catch_difficulty_UnderThreshold = r.Catch_difficulty_UnderThreshold
  _hp_max_talent_random = {}
  for i = 0, #r.hp_max_talent_random - 1 do
    table.insert(_hp_max_talent_random, r.hp_max_talent_random[i])
  end
  lua_record.hp_max_talent_random = _hp_max_talent_random
  _phy_attack_talent_random = {}
  for i = 0, #r.phy_attack_talent_random - 1 do
    table.insert(_phy_attack_talent_random, r.phy_attack_talent_random[i])
  end
  lua_record.phy_attack_talent_random = _phy_attack_talent_random
  _spe_attack_talent_random = {}
  for i = 0, #r.spe_attack_talent_random - 1 do
    table.insert(_spe_attack_talent_random, r.spe_attack_talent_random[i])
  end
  lua_record.spe_attack_talent_random = _spe_attack_talent_random
  _phy_defence_talent_random = {}
  for i = 0, #r.phy_defence_talent_random - 1 do
    table.insert(_phy_defence_talent_random, r.phy_defence_talent_random[i])
  end
  lua_record.phy_defence_talent_random = _phy_defence_talent_random
  _spe_defence_talent_random = {}
  for i = 0, #r.spe_defence_talent_random - 1 do
    table.insert(_spe_defence_talent_random, r.spe_defence_talent_random[i])
  end
  lua_record.spe_defence_talent_random = _spe_defence_talent_random
  _speed_talent_random = {}
  for i = 0, #r.speed_talent_random - 1 do
    table.insert(_speed_talent_random, r.speed_talent_random[i])
  end
  lua_record.speed_talent_random = _speed_talent_random
  lua_record.hp_max_plus = r.hp_max_plus
  lua_record.phy_attack_plus = r.phy_attack_plus
  lua_record.spe_attack_plus = r.spe_attack_plus
  lua_record.phy_defence_plus = r.phy_defence_plus
  lua_record.spe_defence_plus = r.spe_defence_plus
  lua_record.speed_plus = r.speed_plus
  lua_record.hp_max_mag = r.hp_max_mag
  lua_record.phy_attack_mag = r.phy_attack_mag
  lua_record.spe_attack_mag = r.spe_attack_mag
  lua_record.phy_defence_mag = r.phy_defence_mag
  lua_record.spe_defence_mag = r.spe_defence_mag
  lua_record.speed_mag = r.speed_mag
  lua_record.level_skill_id = r.level_skill_id
  lua_record.exp_award_fight = r.exp_award_fight
  lua_record.exp_award_catch = r.exp_award_catch
  lua_record.defeat_award = r.defeat_award
  lua_record.catch_award = r.catch_award
  lua_record.exp_award_throwcatch = r.exp_award_throwcatch
  lua_record.mf_behavior_tree_fight = r.mf_behavior_tree_fight
  if "" == r.mf_behavior_tree_fight then
    lua_record.mf_behavior_tree_fight = nil
  end
  lua_record.pre_type = r.pre_type
  _pre_num = {}
  for i = 0, #r.pre_num - 1 do
    table.insert(_pre_num, r.pre_num[i])
  end
  lua_record.pre_num = _pre_num
  MONSTER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = MONSTER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("MONSTER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return MONSTER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("MONSTER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #MONSTER_CONF then
    return MONSTER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return MONSTER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("MONSTER_CONF")
end

return dataTable
