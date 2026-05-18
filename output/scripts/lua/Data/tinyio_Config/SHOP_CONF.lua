SHOP_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.shop_name = r.shop_name
  if "" == r.shop_name then
    lua_record.shop_name = nil
  end
  lua_record.shop_location = r.shop_location
  if "" == r.shop_location then
    lua_record.shop_location = nil
  end
  lua_record.is_enable = r.is_enable
  local _shop_currency_show = {}
  for i = 0, #r.shop_currency_show - 1 do
    local r_2 = r.shop_currency_show[i]
    local lua_record_2 = {}
    lua_record_2.currency_type = r_2.currency_type
    lua_record_2.param = r_2.param
    table.insert(_shop_currency_show, lua_record_2)
  end
  lua_record.shop_currency_show = _shop_currency_show
  lua_record.vitem_type1 = r.vitem_type1
  lua_record.vitem_type2 = r.vitem_type2
  lua_record.vitem_type3 = r.vitem_type3
  lua_record.shop_reset_type = r.shop_reset_type
  lua_record.refresh_reset_type = r.refresh_reset_type
  lua_record.refresh_reset_param = r.refresh_reset_param
  if "" == r.refresh_reset_param then
    lua_record.refresh_reset_param = nil
  end
  local _goods_reserve = {}
  for i = 0, #r.goods_reserve - 1 do
    local r_2 = r.goods_reserve[i]
    local lua_record_2 = {}
    lua_record_2.goods_reserve_id = r_2.goods_reserve_id
    lua_record_2.goods_reserve_quantity = r_2.goods_reserve_quantity
    lua_record_2.goods_reserve_type = r_2.goods_reserve_type
    table.insert(_goods_reserve, lua_record_2)
  end
  lua_record.goods_reserve = _goods_reserve
  SHOP_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SHOP_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SHOP_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SHOP_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SHOP_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SHOP_CONF then
    return SHOP_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SHOP_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SHOP_CONF")
end

return dataTable
