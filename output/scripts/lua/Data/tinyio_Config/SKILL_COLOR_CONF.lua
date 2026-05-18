SKILL_COLOR_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.unit_type = r.unit_type
  lua_record.color = r.color
  if r.color == "" then
    lua_record.color = nil
  end
  lua_record.name = r.name
  if "" == r.name then
    lua_record.name = nil
  end
  SKILL_COLOR_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SKILL_COLOR_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SKILL_COLOR_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SKILL_COLOR_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SKILL_COLOR_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SKILL_COLOR_CONF then
    return SKILL_COLOR_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SKILL_COLOR_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SKILL_COLOR_CONF")
end

return dataTable
