ALERT_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.max_alert_val = r.max_alert_val
  lua_record.inc_step = r.inc_step
  lua_record.dec_step = r.dec_step
  _inc_oper = {}
  for i = 0, #r.inc_oper - 1 do
    table.insert(_inc_oper, r.inc_oper[i])
  end
  lua_record.inc_oper = _inc_oper
  _inc_val = {}
  for i = 0, #r.inc_val - 1 do
    table.insert(_inc_val, r.inc_val[i])
  end
  lua_record.inc_val = _inc_val
  _dec_oper = {}
  for i = 0, #r.dec_oper - 1 do
    table.insert(_dec_oper, r.dec_oper[i])
  end
  lua_record.dec_oper = _dec_oper
  _dec_val = {}
  for i = 0, #r.dec_val - 1 do
    table.insert(_dec_val, r.dec_val[i])
  end
  lua_record.dec_val = _dec_val
  ALERT_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ALERT_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ALERT_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ALERT_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ALERT_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ALERT_CONF then
    return ALERT_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ALERT_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ALERT_CONF")
end

return dataTable
