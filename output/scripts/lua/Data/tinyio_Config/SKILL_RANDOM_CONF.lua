SKILL_RANDOM_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  local _skill_pool = {}
  for i = 0, #r.skill_pool - 1 do
    local r_2 = r.skill_pool[i]
    local lua_record_2 = {}
    lua_record_2.skill_or_skill_pool = r_2.skill_or_skill_pool
    lua_record_2.param = r_2.param
    lua_record_2.prob = r_2.prob
    table.insert(_skill_pool, lua_record_2)
  end
  lua_record.skill_pool = _skill_pool
  SKILL_RANDOM_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SKILL_RANDOM_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SKILL_RANDOM_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SKILL_RANDOM_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SKILL_RANDOM_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SKILL_RANDOM_CONF then
    return SKILL_RANDOM_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SKILL_RANDOM_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SKILL_RANDOM_CONF")
end

return dataTable
