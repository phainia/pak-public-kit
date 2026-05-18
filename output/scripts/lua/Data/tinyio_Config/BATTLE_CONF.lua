BATTLE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.background = r.background
  if "" == r.background then
    lua_record.background = nil
  end
  lua_record.type = r.type
  lua_record.opposite_type = r.opposite_type
  lua_record.show_availableHP_rule = r.show_availableHP_rule
  lua_record.role_available_HP = r.role_available_HP
  lua_record.rival_available_HP = r.rival_available_HP
  lua_record.battle_model = r.battle_model
  lua_record.npc_title = r.npc_title
  if "" == r.npc_title then
    lua_record.npc_title = nil
  end
  lua_record.screen_show_res = r.screen_show_res
  if "" == r.screen_show_res then
    lua_record.screen_show_res = nil
  end
  lua_record.show_res = r.show_res
  if "" == r.show_res then
    lua_record.show_res = nil
  end
  lua_record.show_brief_res = r.show_brief_res
  if "" == r.show_brief_res then
    lua_record.show_brief_res = nil
  end
  lua_record.challanger_unit_num = r.challanger_unit_num
  lua_record.bechallanger_unit_num = r.bechallanger_unit_num
  lua_record.exchange_cold = r.exchange_cold
  lua_record.exchange_initial_cold = r.exchange_initial_cold
  lua_record.max_round = r.max_round
  lua_record.result_over_type = r.result_over_type
  lua_record.background_music = r.background_music
  lua_record.is_auto = r.is_auto
  _assist1 = {}
  for i = 0, #r.assist1 - 1 do
    table.insert(_assist1, r.assist1[i])
  end
  lua_record.assist1 = _assist1
  _assist2 = {}
  for i = 0, #r.assist2 - 1 do
    table.insert(_assist2, r.assist2[i])
  end
  lua_record.assist2 = _assist2
  _assist3 = {}
  for i = 0, #r.assist3 - 1 do
    table.insert(_assist3, r.assist3[i])
  end
  lua_record.assist3 = _assist3
  _assist4 = {}
  for i = 0, #r.assist4 - 1 do
    table.insert(_assist4, r.assist4[i])
  end
  lua_record.assist4 = _assist4
  _assist5 = {}
  for i = 0, #r.assist5 - 1 do
    table.insert(_assist5, r.assist5[i])
  end
  lua_record.assist5 = _assist5
  _assist6 = {}
  for i = 0, #r.assist6 - 1 do
    table.insert(_assist6, r.assist6[i])
  end
  lua_record.assist6 = _assist6
  _pos1 = {}
  for i = 0, #r.pos1 - 1 do
    table.insert(_pos1, r.pos1[i])
  end
  lua_record.pos1 = _pos1
  _pos2 = {}
  for i = 0, #r.pos2 - 1 do
    table.insert(_pos2, r.pos2[i])
  end
  lua_record.pos2 = _pos2
  _pos3 = {}
  for i = 0, #r.pos3 - 1 do
    table.insert(_pos3, r.pos3[i])
  end
  lua_record.pos3 = _pos3
  _pos4 = {}
  for i = 0, #r.pos4 - 1 do
    table.insert(_pos4, r.pos4[i])
  end
  lua_record.pos4 = _pos4
  _pos5 = {}
  for i = 0, #r.pos5 - 1 do
    table.insert(_pos5, r.pos5[i])
  end
  lua_record.pos5 = _pos5
  _pos6 = {}
  for i = 0, #r.pos6 - 1 do
    table.insert(_pos6, r.pos6[i])
  end
  lua_record.pos6 = _pos6
  lua_record.ball1 = r.ball1
  lua_record.ball2 = r.ball2
  lua_record.ball3 = r.ball3
  lua_record.ball4 = r.ball4
  lua_record.ball5 = r.ball5
  lua_record.ball6 = r.ball6
  lua_record.can_catch_or_not = r.can_catch_or_not
  lua_record.can_useitem_or_not = r.can_useitem_or_not
  lua_record.can_escape = r.can_escape
  lua_record.use_ball_time = r.use_ball_time
  lua_record.use_happy_or_not = r.use_happy_or_not
  lua_record.round_pet_timeout = r.round_pet_timeout
  lua_record.round_select_timeout = r.round_select_timeout
  lua_record.pre_perform_timeout = r.pre_perform_timeout
  lua_record.use_random_or_not = r.use_random_or_not
  local _npc_battle_list = {}
  for i = 0, #r.npc_battle_list - 1 do
    local r_2 = r.npc_battle_list[i]
    local lua_record_2 = {}
    lua_record_2.battle_model_1st = r_2.battle_model_1st
    lua_record_2.npc_title_1st = r_2.npc_title_1st
    if "" == r_2.npc_title_1st then
      lua_record_2.npc_title_1st = nil
    end
    _pos1_1st = {}
    for i = 0, #r_2.pos1_1st - 1 do
      table.insert(_pos1_1st, r_2.pos1_1st[i])
    end
    lua_record_2.pos1_1st = _pos1_1st
    _pos2_1st = {}
    for i = 0, #r_2.pos2_1st - 1 do
      table.insert(_pos2_1st, r_2.pos2_1st[i])
    end
    lua_record_2.pos2_1st = _pos2_1st
    _pos3_1st = {}
    for i = 0, #r_2.pos3_1st - 1 do
      table.insert(_pos3_1st, r_2.pos3_1st[i])
    end
    lua_record_2.pos3_1st = _pos3_1st
    _pos4_1st = {}
    for i = 0, #r_2.pos4_1st - 1 do
      table.insert(_pos4_1st, r_2.pos4_1st[i])
    end
    lua_record_2.pos4_1st = _pos4_1st
    _pos5_1st = {}
    for i = 0, #r_2.pos5_1st - 1 do
      table.insert(_pos5_1st, r_2.pos5_1st[i])
    end
    lua_record_2.pos5_1st = _pos5_1st
    _pos6_1st = {}
    for i = 0, #r_2.pos6_1st - 1 do
      table.insert(_pos6_1st, r_2.pos6_1st[i])
    end
    lua_record_2.pos6_1st = _pos6_1st
    lua_record_2.ball1_1st = r_2.ball1_1st
    lua_record_2.ball2_1st = r_2.ball2_1st
    lua_record_2.ball3_1st = r_2.ball3_1st
    lua_record_2.ball4_1st = r_2.ball4_1st
    lua_record_2.ball5_1st = r_2.ball5_1st
    lua_record_2.ball6_1st = r_2.ball6_1st
    table.insert(_npc_battle_list, lua_record_2)
  end
  lua_record.npc_battle_list = _npc_battle_list
  BATTLE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BATTLE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BATTLE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BATTLE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BATTLE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BATTLE_CONF then
    return BATTLE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BATTLE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BATTLE_CONF")
end

return dataTable
