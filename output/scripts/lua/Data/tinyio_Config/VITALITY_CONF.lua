VITALITY_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.max_vitality = r.max_vitality
  lua_record.vitality_recover_delay = r.vitality_recover_delay
  lua_record.vitality_recover = r.vitality_recover
  _forbid_status = {}
  for i = 0, #r.forbid_status - 1 do
    table.insert(_forbid_status, r.forbid_status[i])
  end
  lua_record.forbid_status = _forbid_status
  VITALITY_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = VITALITY_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("VITALITY_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return VITALITY_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("VITALITY_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #VITALITY_CONF then
    return VITALITY_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return VITALITY_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("VITALITY_CONF")
end

return dataTable
