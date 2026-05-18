PET_CLASSIS_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.pet_classis = r.pet_classis
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  PET_CLASSIS_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PET_CLASSIS_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("PET_CLASSIS_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PET_CLASSIS_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PET_CLASSIS_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PET_CLASSIS_CONF then
    return PET_CLASSIS_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PET_CLASSIS_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PET_CLASSIS_CONF")
end

return dataTable
