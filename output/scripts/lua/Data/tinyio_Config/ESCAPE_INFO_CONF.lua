ESCAPE_INFO_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.escape_type = r.escape_type
  lua_record.escape_skill_id = r.escape_skill_id
  lua_record.description_short = r.description_short
  if "" == r.description_short then
    lua_record.description_short = nil
  end
  lua_record.description = r.description
  if "" == r.description then
    lua_record.description = nil
  end
  local _escape_param = {}
  for i = 0, #r.escape_param - 1 do
    local r_2 = r.escape_param[i]
    local lua_record_2 = {}
    _params = {}
    for i = 0, #r_2.params - 1 do
      table.insert(_params, r_2.params[i])
    end
    lua_record_2.params = _params
    table.insert(_escape_param, lua_record_2)
  end
  lua_record.escape_param = _escape_param
  lua_record.icon = r.icon
  if "" == r.icon then
    lua_record.icon = nil
  end
  ESCAPE_INFO_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ESCAPE_INFO_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ESCAPE_INFO_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ESCAPE_INFO_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ESCAPE_INFO_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ESCAPE_INFO_CONF then
    return ESCAPE_INFO_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ESCAPE_INFO_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ESCAPE_INFO_CONF")
end

return dataTable
