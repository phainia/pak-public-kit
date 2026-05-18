GOODS_RESERVE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.reserve_limit_type = r.reserve_limit_type
  lua_record.refresh_reset_type = r.refresh_reset_type
  lua_record.refresh_reset_param = r.refresh_reset_param
  if "" == r.refresh_reset_param then
    lua_record.refresh_reset_param = nil
  end
  local _goods = {}
  for i = 0, #r.goods - 1 do
    local r_2 = r.goods[i]
    local lua_record_2 = {}
    lua_record_2.goods_id = r_2.goods_id
    lua_record_2.goods_quantity = r_2.goods_quantity
    lua_record_2.prob = r_2.prob
    table.insert(_goods, lua_record_2)
  end
  lua_record.goods = _goods
  GOODS_RESERVE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = GOODS_RESERVE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("GOODS_RESERVE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return GOODS_RESERVE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("GOODS_RESERVE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #GOODS_RESERVE_CONF then
    return GOODS_RESERVE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return GOODS_RESERVE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("GOODS_RESERVE_CONF")
end

return dataTable
