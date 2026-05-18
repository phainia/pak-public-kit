BREAK_NUMBER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.type_item_number = r.type_item_number
  lua_record.cost_item_number = r.cost_item_number
  lua_record.boss_item_number = r.boss_item_number
  lua_record.currency_type = r.currency_type
  lua_record.currency_number = r.currency_number
  lua_record.level_number = r.level_number
  BREAK_NUMBER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BREAK_NUMBER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BREAK_NUMBER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BREAK_NUMBER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BREAK_NUMBER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BREAK_NUMBER_CONF then
    return BREAK_NUMBER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BREAK_NUMBER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BREAK_NUMBER_CONF")
end

return dataTable
