BAG_ITEM_TYPE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.type = r.type
  lua_record.type_name = r.type_name
  if r.type_name == "" then
    lua_record.type_name = nil
  end
  lua_record.type_capacity_limit = r.type_capacity_limit
  lua_record.type_icon = r.type_icon
  if "" == r.type_icon then
    lua_record.type_icon = nil
  end
  _sequence = {}
  for i = 0, #r.sequence - 1 do
    table.insert(_sequence, r.sequence[i])
  end
  lua_record.sequence = _sequence
  BAG_ITEM_TYPE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BAG_ITEM_TYPE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BAG_ITEM_TYPE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BAG_ITEM_TYPE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BAG_ITEM_TYPE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BAG_ITEM_TYPE_CONF then
    return BAG_ITEM_TYPE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BAG_ITEM_TYPE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BAG_ITEM_TYPE_CONF")
end

return dataTable
