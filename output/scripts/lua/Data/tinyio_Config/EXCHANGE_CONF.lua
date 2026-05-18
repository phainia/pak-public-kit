EXCHANGE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  _editor_name = {}
  for i = 0, #r.editor_name - 1 do
    table.insert(_editor_name, r.editor_name[i])
  end
  lua_record.editor_name = _editor_name
  lua_record.role_level = r.role_level
  lua_record.use_type = r.use_type
  lua_record.exchange_time_lower_limit = r.exchange_time_lower_limit
  lua_record.exchange_time_upper_limit = r.exchange_time_upper_limit
  local _get_item = {}
  for i = 0, #r.get_item - 1 do
    local r_2 = r.get_item[i]
    local lua_record_2 = {}
    lua_record_2.get_goods_type = r_2.get_goods_type
    lua_record_2.get_goods_id = r_2.get_goods_id
    lua_record_2.get_goods_num = r_2.get_goods_num
    table.insert(_get_item, lua_record_2)
  end
  lua_record.get_item = _get_item
  local _cost_item = {}
  for i = 0, #r.cost_item - 1 do
    local r_2 = r.cost_item[i]
    local lua_record_2 = {}
    lua_record_2.cost_goods_type = r_2.cost_goods_type
    lua_record_2.cost_goods_id = r_2.cost_goods_id
    lua_record_2.cost_goods_num = r_2.cost_goods_num
    table.insert(_cost_item, lua_record_2)
  end
  lua_record.cost_item = _cost_item
  EXCHANGE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = EXCHANGE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("EXCHANGE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return EXCHANGE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("EXCHANGE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #EXCHANGE_CONF then
    return EXCHANGE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return EXCHANGE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("EXCHANGE_CONF")
end

return dataTable
