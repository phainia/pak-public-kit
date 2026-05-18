BREAK_ITEM_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.unit_type = r.unit_type
  lua_record.break_level = r.break_level
  lua_record.break_type_item = r.break_type_item
  BREAK_ITEM_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BREAK_ITEM_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BREAK_ITEM_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BREAK_ITEM_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BREAK_ITEM_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BREAK_ITEM_CONF then
    return BREAK_ITEM_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BREAK_ITEM_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BREAK_ITEM_CONF")
end

return dataTable
