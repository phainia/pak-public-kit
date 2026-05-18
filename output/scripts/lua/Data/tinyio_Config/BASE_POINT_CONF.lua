BASE_POINT_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  local _base_point = {}
  for i = 0, #r.base_point - 1 do
    local r_2 = r.base_point[i]
    local lua_record_2 = {}
    lua_record_2.type_id = r_2.type_id
    lua_record_2.pet_type_crystal_type = r_2.pet_type_crystal_type
    lua_record_2.pet_type_crystal_number = r_2.pet_type_crystal_number
    local _need_item = {}
    for i = 0, #r_2.need_item - 1 do
      local r_2_2 = r_2.need_item[i]
      local lua_record_2_2 = {}
      lua_record_2_2.item_id = r_2_2.item_id
      lua_record_2_2.item_number = r_2_2.item_number
      table.insert(_need_item, lua_record_2_2)
    end
    lua_record_2.need_item = _need_item
    table.insert(_base_point, lua_record_2)
  end
  lua_record.base_point = _base_point
  BASE_POINT_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BASE_POINT_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BASE_POINT_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BASE_POINT_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BASE_POINT_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BASE_POINT_CONF then
    return BASE_POINT_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BASE_POINT_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BASE_POINT_CONF")
end

return dataTable
