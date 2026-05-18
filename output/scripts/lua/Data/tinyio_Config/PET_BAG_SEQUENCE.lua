PET_BAG_SEQUENCE = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.sequence_default = r.sequence_default
  lua_record.sequence_switch = r.sequence_switch
  lua_record.sequence_desc = r.sequence_desc
  if r.sequence_desc == "" then
    lua_record.sequence_desc = nil
  end
  PET_BAG_SEQUENCE[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PET_BAG_SEQUENCE[_key]
  if nil == r then
    local r = TinyData.GetRecord("PET_BAG_SEQUENCE", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PET_BAG_SEQUENCE[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PET_BAG_SEQUENCE", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PET_BAG_SEQUENCE then
    return PET_BAG_SEQUENCE
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PET_BAG_SEQUENCE
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PET_BAG_SEQUENCE")
end

return dataTable
