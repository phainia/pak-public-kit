MALL_RAND_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  local _RandItem = {}
  for i = 0, #r.RandItem - 1 do
    local r_2 = r.RandItem[i]
    local lua_record_2 = {}
    lua_record_2.Id = r_2.Id
    lua_record_2.weight = r_2.weight
    table.insert(_RandItem, lua_record_2)
  end
  lua_record.RandItem = _RandItem
  MALL_RAND_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = MALL_RAND_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("MALL_RAND_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return MALL_RAND_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("MALL_RAND_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #MALL_RAND_CONF then
    return MALL_RAND_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return MALL_RAND_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("MALL_RAND_CONF")
end

return dataTable
