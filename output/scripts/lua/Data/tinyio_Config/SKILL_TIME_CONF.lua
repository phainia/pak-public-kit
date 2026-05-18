SKILL_TIME_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.skill_path = r.skill_path
  if r.skill_path == "" then
    lua_record.skill_path = nil
  end
  lua_record.skill_time = r.skill_time
  SKILL_TIME_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SKILL_TIME_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SKILL_TIME_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SKILL_TIME_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SKILL_TIME_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SKILL_TIME_CONF then
    return SKILL_TIME_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SKILL_TIME_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SKILL_TIME_CONF")
end

return dataTable
