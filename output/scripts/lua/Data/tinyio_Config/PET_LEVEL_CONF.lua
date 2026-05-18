PET_LEVEL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.pet_exp = r.pet_exp
  lua_record.need_role_level = r.need_role_level
  PET_LEVEL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PET_LEVEL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("PET_LEVEL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PET_LEVEL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PET_LEVEL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PET_LEVEL_CONF then
    return PET_LEVEL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PET_LEVEL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PET_LEVEL_CONF")
end

return dataTable
