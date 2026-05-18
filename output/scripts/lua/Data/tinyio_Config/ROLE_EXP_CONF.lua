ROLE_EXP_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.need_exp = r.need_exp
  lua_record.pet_top_level = r.pet_top_level
  local _revival_desc = {}
  for i = 0, #r.revival_desc - 1 do
    local r_2 = r.revival_desc[i]
    local lua_record_2 = {}
    lua_record_2.desc = r_2.desc
    if r_2.desc == "" then
      lua_record_2.desc = nil
    end
    table.insert(_revival_desc, lua_record_2)
  end
  lua_record.revival_desc = _revival_desc
  local _reward = {}
  for i = 0, #r.reward - 1 do
    local r_2 = r.reward[i]
    local lua_record_2 = {}
    lua_record_2.level_reward_type = r_2.level_reward_type
    lua_record_2.level_reward_id = r_2.level_reward_id
    lua_record_2.level_reward_count = r_2.level_reward_count
    table.insert(_reward, lua_record_2)
  end
  lua_record.reward = _reward
  ROLE_EXP_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ROLE_EXP_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ROLE_EXP_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ROLE_EXP_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ROLE_EXP_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ROLE_EXP_CONF then
    return ROLE_EXP_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ROLE_EXP_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ROLE_EXP_CONF")
end

return dataTable
