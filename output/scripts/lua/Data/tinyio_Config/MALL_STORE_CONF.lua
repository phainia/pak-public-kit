MALL_STORE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.reset_type = r.reset_type
  lua_record.reset_param = r.reset_param
  local _RandMallItem = {}
  for i = 0, #r.RandMallItem - 1 do
    local r_2 = r.RandMallItem[i]
    local lua_record_2 = {}
    lua_record_2.Id = r_2.Id
    lua_record_2.is_rand = r_2.is_rand
    lua_record_2.type = r_2.type
    table.insert(_RandMallItem, lua_record_2)
  end
  lua_record.RandMallItem = _RandMallItem
  MALL_STORE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = MALL_STORE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("MALL_STORE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return MALL_STORE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("MALL_STORE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #MALL_STORE_CONF then
    return MALL_STORE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return MALL_STORE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("MALL_STORE_CONF")
end

return dataTable
