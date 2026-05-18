BREAK_REWARD_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  local _break_award = {}
  for i = 0, #r.break_award - 1 do
    local r_2 = r.break_award[i]
    local lua_record_2 = {}
    lua_record_2.break_level_point = r_2.break_level_point
    lua_record_2.break_hp_add = r_2.break_hp_add
    lua_record_2.break_phy_atk_add = r_2.break_phy_atk_add
    lua_record_2.break_spe_atk_add = r_2.break_spe_atk_add
    lua_record_2.break_phy_def_add = r_2.break_phy_def_add
    lua_record_2.break_spe_def_add = r_2.break_spe_def_add
    lua_record_2.break_speed_add = r_2.break_speed_add
    lua_record_2.break_attribute_type = r_2.break_attribute_type
    lua_record_2.break_attribute_add = r_2.break_attribute_add
    lua_record_2.is_slot_add = r_2.is_slot_add
    table.insert(_break_award, lua_record_2)
  end
  lua_record.break_award = _break_award
  BREAK_REWARD_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BREAK_REWARD_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BREAK_REWARD_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BREAK_REWARD_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BREAK_REWARD_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BREAK_REWARD_CONF then
    return BREAK_REWARD_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BREAK_REWARD_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BREAK_REWARD_CONF")
end

return dataTable
