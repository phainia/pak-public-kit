LEVEL_SKILL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.feature_rand_id = r.feature_rand_id
  local _level = {}
  for i = 0, #r.level - 1 do
    local r_2 = r.level[i]
    local lua_record_2 = {}
    lua_record_2.level_point = r_2.level_point
    lua_record_2.stage = r_2.stage
    lua_record_2.level_gain_skill = r_2.level_gain_skill
    lua_record_2.param = r_2.param
    table.insert(_level, lua_record_2)
  end
  lua_record.level = _level
  LEVEL_SKILL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = LEVEL_SKILL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("LEVEL_SKILL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return LEVEL_SKILL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("LEVEL_SKILL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #LEVEL_SKILL_CONF then
    return LEVEL_SKILL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return LEVEL_SKILL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("LEVEL_SKILL_CONF")
end

return dataTable
