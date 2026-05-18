GOODS_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.is_enable = r.is_enable
  lua_record.goods_name = r.goods_name
  if r.goods_name == "" then
    lua_record.goods_name = nil
  end
  lua_record.bagitem_id = r.bagitem_id
  lua_record.bagitem_quantity = r.bagitem_quantity
  lua_record.currency_type = r.currency_type
  lua_record.param = r.param
  lua_record.price = r.price
  lua_record.vitem_type = r.vitem_type
  lua_record.vitem_price = r.vitem_price
  lua_record.buy_limited = r.buy_limited
  lua_record.buy_limited_param = r.buy_limited_param
  if "" == r.buy_limited_param then
    lua_record.buy_limited_param = nil
  end
  GOODS_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = GOODS_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("GOODS_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return GOODS_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("GOODS_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #GOODS_CONF then
    return GOODS_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return GOODS_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("GOODS_CONF")
end

return dataTable
