SKILLSPECIAL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.petconf_id = r.petconf_id
  lua_record.res_id = r.res_id
  if r.res_id == "" then
    lua_record.res_id = nil
  end
  SKILLSPECIAL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SKILLSPECIAL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SKILLSPECIAL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SKILLSPECIAL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SKILLSPECIAL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SKILLSPECIAL_CONF then
    return SKILLSPECIAL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SKILLSPECIAL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SKILLSPECIAL_CONF")
end

return dataTable
