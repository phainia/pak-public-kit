BAG_ITEM_SEQUENCE = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.sequence = r.sequence
  lua_record.sequence_desc = r.sequence_desc
  if r.sequence_desc == "" then
    lua_record.sequence_desc = nil
  end
  BAG_ITEM_SEQUENCE[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BAG_ITEM_SEQUENCE[_key]
  if nil == r then
    local r = TinyData.GetRecord("BAG_ITEM_SEQUENCE", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BAG_ITEM_SEQUENCE[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BAG_ITEM_SEQUENCE", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BAG_ITEM_SEQUENCE then
    return BAG_ITEM_SEQUENCE
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BAG_ITEM_SEQUENCE
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BAG_ITEM_SEQUENCE")
end

return dataTable
